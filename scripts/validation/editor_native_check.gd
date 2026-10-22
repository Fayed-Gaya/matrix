@tool
extends EditorPlugin
## Runs only in a disposable validation copy, never in the user's project.

class PaintProbe extends Node2D:
	var map: MatrixNativeMap
	func _draw() -> void:
		map.paint_cell(self,"Test",Vector2i.ZERO)


func _enter_tree() -> void:
	run.call_deferred()

func run() -> void:
	await get_tree().create_timer(3.0).timeout
	var paths: Array[String] = ["res://hub/world.tscn"]
	for room: String in ["apartment", "outside"]:
		paths.append("res://levels/bubby/maps/" + room + ".tscn")
	for room: String in ["cabin", "forest"]:
		paths.append("res://levels/busboy/maps/" + room + ".tscn")
	var editor: EditorInterface = get_editor_interface()
	for i: int in range(paths.size()):
		editor.open_scene_from_path(paths[i])
		await get_tree().process_frame
		await get_tree().process_frame
		var world: Node = editor.get_edited_scene_root()
		assert(world != null and world.scene_file_path == paths[i], "Editor could not open " + paths[i])
		var packed: PackedScene = PackedScene.new()
		assert(packed.pack(world) == OK)
		var scratch: String = "res://_native_editor_check_"+str(i)+".tscn"
		assert(ResourceSaver.save(packed,scratch) == OK)
		editor.open_scene_from_path(scratch)
		await get_tree().process_frame
		await get_tree().process_frame
		world = editor.get_edited_scene_root()
		assert(world != null and world.scene_file_path == scratch, "Scratch editor scene did not activate")
		var layer: TileMapLayer
		for child: Node in world.get_children():
			if child is TileMapLayer and not child.get_used_cells().is_empty():
				layer = child
				break
		assert(layer != null and layer.owner == world)
		assert(layer.tile_set.resource_path.begins_with("res://"), "Expected editable external TileSet")
		editor.set_main_screen_editor("2D")
		editor.get_selection().clear()
		editor.get_selection().add_node(layer)
		editor.edit_node(layer)
		var sample: Vector2i = layer.get_used_cells()[0]
		var source_id: int = layer.get_cell_source_id(sample)
		var coords: Vector2i = layer.get_cell_atlas_coords(sample)
		var added: Vector2i = layer.get_used_rect().end + Vector2i(3,3)
		layer.set_cell(added,source_id,coords)
		layer.erase_cell(sample)
		assert(editor.get_edited_scene_root() == world and world.scene_file_path == scratch)
		assert(editor.save_scene() == OK)
		var reloaded: Node = (ResourceLoader.load(scratch,"PackedScene",ResourceLoader.CACHE_MODE_IGNORE) as PackedScene).instantiate()
		var edited: TileMapLayer = reloaded.get_node(NodePath(String(layer.name)))
		assert(edited.get_cell_source_id(added) == source_id and edited.get_cell_source_id(sample) == -1)
		reloaded.free()
		print("Editor open/paint/erase/save/reload passed: "+paths[i])
	await check_tile_transforms()
	print("Native Godot editor validation passed: " + str(paths.size()) + " directly editable scenes")
	get_tree().quit()


func check_tile_transforms() -> void:
	# Compare custom drawing with native TileMapLayer pixels, including rectangular
	# tiles and nonzero texture origins. Scene serialization alone misses this.
	var picture: Image = Image.create(40,24,false,Image.FORMAT_RGBA8)
	for y: int in range(24):
		for x: int in range(40):
			picture.set_pixel(x,y,Color(float(x)/40,float(y)/24,0.8 if x < 13 else 0.2,1))
	var atlas: TileSetAtlasSource = TileSetAtlasSource.new()
	atlas.texture = ImageTexture.create_from_image(picture)
	atlas.texture_region_size = Vector2i(40,24)
	atlas.create_tile(Vector2i.ZERO)
	atlas.create_alternative_tile(Vector2i.ZERO,1)
	var tile_set: TileSet = TileSet.new()
	tile_set.tile_size = Vector2i(40,24)
	tile_set.add_source(atlas,0)
	var viewport: SubViewport = SubViewport.new()
	viewport.size = Vector2i(160,96)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	var native: TileMapLayer = TileMapLayer.new()
	native.tile_set = tile_set
	native.position = Vector2(20,30)
	native.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	viewport.add_child(native)
	var map: MatrixNativeMap = MatrixNativeMap.new()
	var custom: TileMapLayer = TileMapLayer.new()
	custom.name = "Test"
	custom.tile_set = tile_set
	custom.position = native.position+Vector2(80,0)
	map.add_child(custom)
	var painter: PaintProbe = PaintProbe.new()
	painter.map = map
	painter.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	viewport.add_child(painter)
	add_child(viewport)
	for base: int in range(2):
		var tile: TileData = atlas.get_tile_data(Vector2i.ZERO,base)
		tile.texture_origin = Vector2i(5,3)
		tile.flip_h = base == 1
		tile.transpose = base == 1
		for flags: int in range(8):
			var alternative: int = base | (TileSetAtlasSource.TRANSFORM_FLIP_H if flags & 1 else 0) | (TileSetAtlasSource.TRANSFORM_FLIP_V if flags & 2 else 0) | (TileSetAtlasSource.TRANSFORM_TRANSPOSE if flags & 4 else 0)
			native.set_cell(Vector2i.ZERO,0,Vector2i.ZERO,alternative)
			custom.set_cell(Vector2i.ZERO,0,Vector2i.ZERO,alternative)
			painter.queue_redraw()
			await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var rendered: Image = viewport.get_texture().get_image()
			for y: int in range(96):
				for x: int in range(80):
					assert(rendered.get_pixel(x,y).is_equal_approx(rendered.get_pixel(x+80,y)),"Native/custom tile transform mismatch: base %d, flags %d, pixel %d,%d" % [base,flags,x,y])
	map.free()
	viewport.queue_free()
	await get_tree().process_frame
	print("Native/custom renderer transform pixels passed: 16 combinations")
