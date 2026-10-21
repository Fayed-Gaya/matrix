extends SceneTree


func _initialize() -> void:
	run.call_deferred()


func key(code: Key) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	root.push_input(event)
	event = event.duplicate()
	event.pressed = false
	root.push_input(event)


func run() -> void:
	var app: MatrixApp = load("res://app/main.tscn").instantiate()
	root.add_child(app)
	app.launch_level("UNTITLED")
	await process_frame
	await process_frame
	var level: UntitledLevel = app.active_level as UntitledLevel
	assert(level != null and level.opening and level.get_node("Ambience").playing)
	assert(level.player.position == Vector2(454, 423))
	assert(level.world.collision_rects.size() == 11 and level.world.npc_data.size() == 1)
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() == 1 and not args[0].ends_with(".json"):
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(args[0] + "-opening.png") == OK)
	key(KEY_SPACE)
	assert(not level.opening)
	level.player.position = Vector2(422, 448)
	key(KEY_E)
	assert(level.dialogue_visible and level.dialogue.contains("bus a boy"))
	var position: Vector2 = level.player.position
	Input.action_press("hub_right")
	await physics_frame
	await physics_frame
	Input.action_release("hub_right")
	assert(level.player.position == position)
	if args.size() == 1 and not args[0].ends_with(".json"):
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(args[0] + "-dialogue.png") == OK)
	key(KEY_ESCAPE)
	assert(not level.dialogue_visible and app.active_level == level)
	if args.size() == 1 and args[0].ends_with(".json"):
		var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(args[0]))
		for i: int in range(data.collision.size()):
			var r: Array = data.collision[i]
			assert(level.world.collision_rects[i] == Rect2(r[0], r[1], r[2], r[3]))
		for layer: Dictionary in data.layers:
			var tiles: TileMapLayer = level.world.get_node(layer.name)
			for i: int in range(layer.cells.size()):
				var cell: Vector2i = Vector2i(i % int(layer.width), i / int(layer.width))
				var gid: int = int(layer.cells[i])
				assert(tiles.get_cell_source_id(cell) == (-1 if gid == 0 else 0))
				if gid > 0:
					var tile: int = gid - 1
					assert(tiles.get_cell_atlas_coords(cell) == Vector2i(tile % 26, tile / 26))
	key(KEY_ESCAPE)
	await process_frame
	await process_frame
	assert(app.active_level == null and app.hub.visible)
	app.free()
	await process_frame
	await process_frame
	# AudioServer releases stopped decoder instances on its mixer thread.
	await create_timer(0.15).timeout
	print("Untitled validation passed")
	quit()
