extends SceneTree
## Frozen fixtures are regression expectations, never authoring inputs.
var checked: int = 0

func _initialize() -> void:
	check_pegasus("pegasus", "pegasus")
	print("Native map authoring validation passed: "+str(checked)+" scenes")
	quit()

func check_pegasus(module: String, fixture: String) -> void:
	var map: Node2D = load("res://"+module+"/world.tscn").instantiate()
	var expected: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://scripts/validation/"+fixture+"_map_reference.json"))
	assert(map.player_spawn == Vector2(expected.spawn[0],expected.spawn[1]))
	assert(map.collision_rects.size() == expected.collision.size())
	for i: int in range(expected.collision.size()):
		var entry: Array = expected.collision[i]
		assert(map.collision_rects[i] == Rect2(entry[0],entry[1],entry[2],entry[3]))
	map.get_node("PlayerSpawn").position += Vector2(5,7)
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
	var path: String = "user://native-pegasus-roundtrip.tscn"
	assert(ResourceSaver.save(packed,path) == OK)
	var edited: Node2D = (ResourceLoader.load(path,"PackedScene",ResourceLoader.CACHE_MODE_IGNORE) as PackedScene).instantiate()
	assert(edited.player_spawn == map.player_spawn)
	assert(edited.collision_rects[0] == map.collision_rects[0])
	assert(edited.get_node("Ground").get_cell_source_id(cell) == -1)
	assert(edited.terminal_rect == map.terminal_rect)

	edited.free()
	map.free()
	DirAccess.remove_absolute(path)
	checked += 1
