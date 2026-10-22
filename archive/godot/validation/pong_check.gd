extends SceneTree


func _initialize() -> void:
	run.call_deferred()


func run() -> void:
	var app: MatrixApp = load("res://app/main.tscn").instantiate()
	root.add_child(app)
	app.launch_level("PONG")
	await process_frame
	await process_frame
	var level: PongLevel = app.active_level as PongLevel
	assert(level != null)
	level.set_physics_process(false)
	level.ball = Rect2i(304, 224, 33, 33)
	level.paddles = [Rect2i(0, 229, 22, 22), Rect2i(618, 229, 22, 22)]
	level.angle = 0.47
	level.hit = false
	var data: Array = JSON.parse_string(FileAccess.get_file_as_string("res://scripts/validation/pong_reference.json"))
	var failures: int = 0
	for row: Dictionary in data:
		level.movement = [int(row.movement[0]), int(row.movement[1])]
		level.advance_tick()
		var values: Array = row.ball
		if level.ball != Rect2i(values[0], values[1], values[2], values[3]) or absf(level.angle - row.angle) > 0.00001 or level.hit != row.hit:
			failures += 1
		for index: int in range(2):
			values = row.paddles[index]
			if level.paddles[index] != Rect2i(values[0], values[1], values[2], values[3]):
				failures += 1
	assert(data.size() == 1600 and failures == 0, "Original Pong trace mismatch")
	level.movement = [0, 0]
	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = KEY_A
	event.pressed = true
	root.push_input(event)
	assert(level.movement[0] == -10)
	event = event.duplicate()
	event.physical_keycode = KEY_Z
	root.push_input(event)
	assert(level.movement[0] == 0)
	event = event.duplicate()
	event.pressed = false
	root.push_input(event)
	assert(level.movement[0] == 0)
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() == 1:
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(args[0]) == OK)
	app.return_to_hub()
	await process_frame
	await process_frame
	assert(app.active_level == null)
	app.free()
	print("Pong validation passed")
	quit()
