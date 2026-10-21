extends SceneTree
## Frozen fixtures are regression expectations, never authoring inputs.
var checked: int = 0

func _initialize() -> void:
	var modules: PackedStringArray = OS.get_cmdline_user_args()
	check_hub("hub", "hub")
	check_hub("levels/untitled", "untitled")
	for module: String in modules:
		var expected: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://scripts/validation/"+module+"_map_reference.json"))
		if module == "mario":
			for index: int in range(expected.size()):
				check_grid("res://levels/mario/maps/stage_"+str(index)+".tscn",expected[index])
		elif module == "zelda":
			var active: Dictionary = {}
			for key: String in ["map_FloorBlocks","map_Grass","map_Objects","map_Entities"]:
				active[key] = expected[key]
			check_grid("res://levels/zelda/maps/world.tscn",active)
		elif module == "monsters":
			for name: String in expected:
				var map: MatrixNativeMap = MatrixNativeMap.open("res://levels/monsters/maps/"+name+".tscn")
				var actual: Dictionary = map.read_monsters()
				actual.erase("origin")
				assert(equivalent(actual,expected[name]),"Native map mismatch: "+name)
				var groups: Node = map.get_node("Groups")
				for group: Node in groups.get_children():
					if group.get_child_count() > 0:
						var marker: MatrixMapObject = group.get_child(0)
						marker.position += Vector2(13,17)
						marker.properties["native_edit_test"] = true
						var entry: Dictionary = map.read_monsters().groups[String(group.name)][0]
						assert(entry.position == [marker.position.x,marker.position.y] and entry.properties.native_edit_test)
						break
				check_roundtrip(map)
				map.free()
	print("Native map authoring validation passed: "+str(checked)+" scenes")
	quit()

func equivalent(a: Variant,b: Variant) -> bool:
	if a is Dictionary and b is Dictionary:
		if a.size() != b.size(): return false
		for key: Variant in a:
			if not b.has(key) or not equivalent(a[key],b[key]): return false
		return true
	if a is Array and b is Array:
		if a.size() != b.size(): return false
		for i: int in range(a.size()):
			if not equivalent(a[i],b[i]): return false
		return true
	if (a is float or a is int) and (b is float or b is int):
		return absf(float(a)-float(b)) < 0.001
	return a == b

func check_grid(path: String, expected: Dictionary) -> void:
	var map: MatrixNativeMap = MatrixNativeMap.open(path)
	assert(equivalent(map.read_rows(),expected),"Native grid mismatch: "+path)
	check_roundtrip(map)
	map.free()

func check_roundtrip(map: MatrixNativeMap) -> void:
	var selected: TileMapLayer
	for child: Node in map.get_children():
		if child is TileMapLayer and not child.get_meta("preview_only",false) and not child.get_used_cells().is_empty():
			selected = child
			break
	assert(selected != null)
	var sample: Vector2i = selected.get_used_cells()[0]
	var source_id: int = selected.get_cell_source_id(sample)
	var atlas: Vector2i = selected.get_cell_atlas_coords(sample)
	var value: int = int(selected.get_cell_tile_data(sample).get_custom_data("value"))
	# Paint beyond old dimensions and across the origin, then save/reload. This
	# exercises native resource persistence and the exact readers used at runtime.
	var added: Vector2i = map.cell_bounds().end+Vector2i(2,2)
	selected.set_cell(added,source_id,atlas)
	selected.set_cell(Vector2i(-1,-1),source_id,atlas)
	selected.erase_cell(sample)
	var packed: PackedScene = PackedScene.new()
	assert(packed.pack(map) == OK)
	var path: String = "user://native-map-roundtrip.tscn"
	assert(ResourceSaver.save(packed,path) == OK)
	var reloaded: MatrixNativeMap = (ResourceLoader.load(path,"PackedScene",ResourceLoader.CACHE_MODE_IGNORE) as PackedScene).instantiate()
	var edited: TileMapLayer = reloaded.get_node(NodePath(String(selected.name)))
	assert(edited.get_cell_source_id(sample) == -1)
	assert(edited.get_cell_source_id(added) == source_id)
	assert(reloaded.cell_bounds().position == Vector2i(-1,-1))
	if reloaded.has_node("Groups"):
		var grid: Dictionary = reloaded.read_monsters()
		assert(grid.layers[0].cells.size() == grid.width*grid.height)
		assert(equivalent(grid.groups,map.read_monsters().groups))
	else:
		var grid: Dictionary = reloaded.read_rows()
		assert(int(grid[String(selected.name)][0][0]) == value)
		assert(int(grid[String(selected.name)][added.y+1][added.x+1]) == value)
	reloaded.free()
	DirAccess.remove_absolute(path)
	checked += 1

func check_hub(module: String, fixture: String) -> void:
	var map: Node2D = load("res://"+module+"/world.tscn").instantiate()
	var expected: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://scripts/validation/"+fixture+"_map_reference.json"))
	assert(map.player_spawn == Vector2(expected.spawn[0],expected.spawn[1]))
	assert(map.collision_rects.size() == expected.collision.size())
	for i: int in range(expected.collision.size()):
		var entry: Array = expected.collision[i]
		assert(map.collision_rects[i] == Rect2(entry[0],entry[1],entry[2],entry[3]))
	map.get_node("PlayerSpawn").position += Vector2(5,7)
	if fixture == "untitled":
		map.get_node("NPCs").get_child(0).position += Vector2(6,8)
		map.get_node("NPCs").get_child(0).set_meta("dialogue","Native editor dialogue test")
	else:
		map.get_node("Terminal").position += Vector2(4,7)
		map.get_node("Terminal").size += Vector2(3,5)
	var shape: CollisionShape2D = map.get_node("Collisions").get_child(0)
	shape.position += Vector2(3,9)
	shape.shape = shape.shape.duplicate()
	shape.shape.size += Vector2(4,6)
	var layer: TileMapLayer = map.get_node("Ground")
	var cell: Vector2i = layer.get_used_cells()[0]
	layer.erase_cell(cell)
	var packed: PackedScene = PackedScene.new()
	assert(packed.pack(map) == OK)
	var path: String = "user://native-hub-roundtrip.tscn"
	assert(ResourceSaver.save(packed,path) == OK)
	var edited: Node2D = (ResourceLoader.load(path,"PackedScene",ResourceLoader.CACHE_MODE_IGNORE) as PackedScene).instantiate()
	assert(edited.player_spawn == map.player_spawn)
	assert(edited.collision_rects[0] == map.collision_rects[0])
	assert(edited.get_node("Ground").get_cell_source_id(cell) == -1)
	if fixture == "untitled":
		assert(edited.npc_data == map.npc_data)
	else:
		assert(edited.terminal_rect == map.terminal_rect)
	edited.free()
	map.free()
	DirAccess.remove_absolute(path)
	checked += 1
