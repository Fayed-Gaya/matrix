extends SceneTree
## Invoked by convert_hub_map.py. Runtime uses only the generated native scene.


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() != 1:
		push_error("Expected map descriptor path")
		quit(1)
		return
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(args[0]))
	var world: Node2D = Node2D.new()
	world.set_script(load("res://hub/world.gd"))
	world.name = "World"
	world.bounds = Vector2(data.bounds[0], data.bounds[1])
	world.player_spawn = Vector2(data.spawn[0], data.spawn[1])
	world.terminal_rect = Rect2(data.terminal[0], data.terminal[1], data.terminal[2], data.terminal[3])
	var rectangles: Array[Rect2] = []
	for rect: Array in data.collision:
		rectangles.append(Rect2(rect[0], rect[1], rect[2], rect[3]))
	world.collision_rects = rectangles
	var tiles: TileSet = TileSet.new()
	tiles.tile_size = Vector2i(data.tile_size, data.tile_size)
	for index: int in range(data.tilesets.size()):
		var entry: Dictionary = data.tilesets[index]
		var atlas: TileSetAtlasSource = TileSetAtlasSource.new()
		atlas.texture = load(entry.texture)
		atlas.texture_region_size = tiles.tile_size
		for tile: int in range(int(entry.count)):
			atlas.create_tile(Vector2i(tile % int(entry.columns), tile / int(entry.columns)))
		tiles.add_source(atlas, index)
	for entry: Dictionary in data.layers:
		var layer: TileMapLayer = TileMapLayer.new()
		layer.name = entry.name
		layer.tile_set = tiles
		layer.visible = entry.visible
		layer.z_index = 2 if entry.name == "Above" else 0
		world.add_child(layer)
		layer.owner = world
		for index: int in range(entry.cells.size()):
			var gid: int = int(entry.cells[index])
			if gid == 0:
				continue
			var source_id: int = data.tilesets.size() - 1
			while gid < int(data.tilesets[source_id].firstgid):
				source_id -= 1
			var source: Dictionary = data.tilesets[source_id]
			var tile_id: int = gid - int(source.firstgid)
			assert(tile_id < int(source.count))
			layer.set_cell(Vector2i(index % int(entry.width), index / int(entry.width)),
				source_id, Vector2i(tile_id % int(source.columns), tile_id / int(source.columns)))
	var scene: PackedScene = PackedScene.new()
	var result: Error = scene.pack(world)
	if result == OK:
		result = ResourceSaver.save(scene, "res://hub/world.tscn")
	world.free()
	if result != OK:
		push_error("Could not save hub map: " + str(result))
	else:
		print("Hub map saved")
	quit(0 if result == OK else 1)
