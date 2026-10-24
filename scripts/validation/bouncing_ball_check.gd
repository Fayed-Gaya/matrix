extends SceneTree
## Compares the port with a trace produced by the original Pygame update rule.

var failures: int = 0


func _initialize() -> void:
	run.call_deferred()


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func run() -> void:
	var app: MatrixApp = load("res://app/main.tscn").instantiate() as MatrixApp
	root.add_child(app)
	app.pegasus.overlay.opening = false
	app.pegasus.player.position = Vector2(410, 436)
	var pegasus_position: Vector2 = app.pegasus.player.position
	app.launch_level(" bounce ")
	await process_frame
	await process_frame
	var level: BouncingBallLevel = app.active_level as BouncingBallLevel
	check(level != null, "BOUNCE launches the actual level")
	if level == null:
		app.free()
		quit(1)
		return
	level.set_physics_process(false)
	check(level.BALL.get_size() == Vector2(111, 111), "Original image dimensions")
	var imported_image: Image = level.BALL.get_image()
	check(imported_image.get_pixel(0, 0).a == 0.0, "Imported PNG retains transparent corners")
	check(imported_image.get_pixel(55, 55).a == 1.0, "Imported ball remains opaque")
	check(Engine.physics_ticks_per_second == 60, "Documented stable tick rate")
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() == 1:
		var reference: Array = JSON.parse_string(FileAccess.get_file_as_string(args[0]))
		check(reference.size() == 5000, "Complete reference trace")
		level.ball_position = Vector2i.ZERO
		level.direction = Vector2i.ONE
		for i: int in range(reference.size()):
			level.advance_tick()
			var tick: Array = reference[i]
			check(level.ball_position == Vector2i(tick[0], tick[1])
				and level.direction == Vector2i(tick[2], tick[3]),
				"Pygame update trace at tick " + str(i + 1))
	# Exact contact does not bounce; crossing both edges reverses both components.
	level.ball_position = Vector2i(1088, 888)
	level.direction = Vector2i.ONE
	level.advance_tick()
	check(level.ball_position == Vector2i(1089, 889) and level.direction == Vector2i.ONE,
		"Exact edge contact")
	level.advance_tick()
	check(level.ball_position == Vector2i(1090, 890) and level.direction == -Vector2i.ONE,
		"Bottom-right corner overshoots then reflects")
	level.advance_tick()
	check(level.ball_position == Vector2i(1089, 889), "Returns inside after overshoot")
	level.ball_position = Vector2i.ZERO
	level.direction = -Vector2i.ONE
	level.advance_tick()
	check(level.ball_position == Vector2i(-1, -1) and level.direction == Vector2i.ONE,
		"Top-left corner reflection")
	for window: Vector2i in [Vector2i(1280, 720), Vector2i(640, 480), Vector2i(1920, 1080)]:
		root.size = window
		await process_frame
		await process_frame
		var displayed: Vector2 = level.FIELD_SIZE * level.field_scale
		check(displayed.x <= window.x + 0.01 and displayed.y <= window.y + 0.01,
			"Playfield fits window")
		check(level.field_offset.is_equal_approx((Vector2(window) - displayed) / 2),
			"Playfield stays centered")
	# Verify automatic ticking in the live scene and that returning releases it.
	level.ball_position = Vector2i(200, 200)
	level.direction = Vector2i.ONE
	level.set_physics_process(true)
	await physics_frame
	await physics_frame
	check(level.ball_position.x > 200, "Live scene advances automatically")
	if args.size() == 2 and args[0] == "--capture":
		root.size = Vector2i(1280, 720)
		await process_frame
		await RenderingServer.frame_post_draw
		check(root.get_texture().get_image().save_png(args[1]) == OK, "Window capture")
	var previous: WeakRef = weakref(level)
	level = null
	var event: InputEventKey = InputEventKey.new()
	event.keycode = KEY_ESCAPE
	event.physical_keycode = KEY_ESCAPE
	event.pressed = true
	root.push_input(event)
	event = event.duplicate()
	event.pressed = false
	root.push_input(event)
	await process_frame
	await process_frame
	check(app.active_level == null and previous.get_ref() == null, "Escape frees level")
	check(app.pegasus.visible and app.pegasus.player.position == pegasus_position, "Same pegasus position resumes")
	app.launch_level("BOUNCE")
	await process_frame
	await process_frame
	level = app.active_level as BouncingBallLevel
	check(level != null and level.ball_position.x < 20 and level.direction == Vector2i.ONE,
		"Reentry starts a fresh demo")
	app.free()
	if failures == 0:
		print("Bouncing Ball validation passed")
	quit(0 if failures == 0 else 1)
