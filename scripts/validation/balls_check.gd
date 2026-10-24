extends SceneTree
## Source trace, timing distinction, wrap rendering, input and lifecycle checks.

var failures: int = 0


func _initialize() -> void:
	run.call_deferred()


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func settle() -> void:
	await process_frame
	await process_frame


func run() -> void:
	var original_cap: int = Engine.max_fps
	Engine.max_fps = 97
	root.size = Vector2i(1280, 720)
	var app: MatrixApp = load("res://app/main.tscn").instantiate() as MatrixApp
	root.add_child(app)
	app.pegasus.overlay.opening = false
	var pegasus_position: Vector2 = app.pegasus.player.position
	app.launch_level("BALLS")
	await settle()
	var level: BallsLevel = app.active_level as BallsLevel
	check(level != null, "BALLS launches actual scene")
	if level == null:
		app.free()
		Engine.max_fps = original_cap
		quit(1)
		return
	level.set_process(false)
	check(Engine.max_fps == 60, "Level uses source 60 FPS cap")
	check(level.positions == [Vector2(590, 360), Vector2(690, 360)], "Reference spawns")
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() == 1:
		var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(args[0]))
		check(data.frames.size() == 400 and data.wraps.size() == 13, "Complete source trace")
		check(level.BACKGROUND == Color(data.background[0] / 255.0,
			data.background[1] / 255.0, data.background[2] / 255.0), "Pygame purple")
		var max_error: float = 0.0
		for row: Dictionary in data.frames:
			level.advance_frame(Vector2(row.direction[0], row.direction[1]), row.dt)
			for index: int in range(2):
				var expected: Vector2 = Vector2(row.positions[index][0], row.positions[index][1])
				var difference: Vector2 = (level.positions[index] - expected).abs()
				# Near a seam, 0 and field-size minus a rounding error are neighbors.
				difference = difference.min(level.FIELD_SIZE - difference)
				max_error = maxf(max_error, difference.length())
			check(level.positions[1] == Vector2(row.positions[1][0], row.positions[1][1]),
				"Frame-based circle matches source exactly")
		print("Maximum variable-dt trace error (logical pixels): ", max_error)
		check(max_error < 0.001, "Variable-dt source trace within 0.001 logical pixel")
		for row: Dictionary in data.wraps:
			var centers: Array[Vector2] = level.wrapped_centers(Vector2(row.position[0], row.position[1]))
			check(centers.size() == row.centers.size(), "Source wrap-copy count")
			for center: Array in row.centers:
				check(centers.has(Vector2(center[0], center[1])), "Source edge/corner drawing")
	# Preserve the timing experiment rather than normalizing the two circles.
	level.positions = [Vector2(590, 360), Vector2(690, 360)]
	level.advance_frame(Vector2(1, 1), 0.1)
	check(level.positions == [Vector2(620, 390), Vector2(695, 365)], "Distinct timing and unnormalized diagonal")
	level.positions = [Vector2(1, 1), Vector2(1, 1)]
	level.advance_frame(Vector2(-1, -1), 0.01)
	check(level.positions == [Vector2(1278, 718), Vector2(1276, 716)], "Negative modulo wrap")
	for action: String in ["balls_up", "balls_down", "balls_left", "balls_right"]:
		var keys: Dictionary = {"balls_up": KEY_W, "balls_down": KEY_S, "balls_left": KEY_A, "balls_right": KEY_D}
		check(InputMap.action_get_events(action).size() == 1
			and InputMap.action_get_events(action)[0].physical_keycode == keys[action], "WASD binding")
	# Exercise the real render-frame path, including draw-before-update and dt lag.
	level.positions = [Vector2(590, 360), Vector2(690, 360)]
	level.previous_delta = 0.0
	Input.action_press("balls_right")
	level._process(0.1)
	check(level.drawn_positions == [Vector2(590, 360), Vector2(690, 360)], "Draw precedes movement")
	check(level.positions == [Vector2(590, 360), Vector2(695, 360)], "Initial zero dt")
	level._process(0.02)
	check(level.positions == [Vector2(620, 360), Vector2(700, 360)], "Previous frame dt retained")
	Input.action_press("balls_left")
	var stationary: Array[Vector2] = level.positions.duplicate()
	level._process(0.02)
	check(level.positions == stationary, "Opposite keys cancel")
	Input.action_release("balls_right")
	Input.action_release("balls_left")
	for window: Vector2i in [Vector2i(640, 480), Vector2i(1920, 1080), Vector2i(1280, 720)]:
		root.size = window
		await settle()
		var displayed: Vector2 = level.FIELD_SIZE * level.field_scale
		check(displayed.x <= window.x + 0.01 and displayed.y <= window.y + 0.01, "Field fits window")
		check(level.field_offset.is_equal_approx((Vector2(window) - displayed) / 2), "Centered field")
	check(level.get_node("Field").clip_contents, "Wrap copies clipped to original field")
	if args.size() == 2 and args[0] == "--capture":
		level.drawn_positions = [Vector2(590, 360), Vector2(690, 360)]
		level.get_node("Field/Circles").queue_redraw()
		await RenderingServer.frame_post_draw
		check(root.get_texture().get_image().save_png(args[1] + "-center.png") == OK, "Center screenshot")
		root.size = Vector2i(640, 480)
		await settle()
		level.drawn_positions = [Vector2(10, 10), Vector2(1270, 710)]
		level.get_node("Field/Circles").queue_redraw()
		await RenderingServer.frame_post_draw
		var image: Image = root.get_texture().get_image()
		check(image.save_png(args[1] + "-wrap.png") == OK, "Corner screenshot")
		check(image.get_pixel(5, 55) == Color.BLACK, "Circle copies stay out of letterbox margin")
	level.positions = [Vector2(590, 360), Vector2(690, 360)]
	level.set_process(true)
	Input.action_press("balls_down")
	await settle()
	Input.action_release("balls_down")
	check(level.positions[1].y > 360, "Live frame processing moves circles")
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
	await settle()
	check(app.active_level == null and previous.get_ref() == null, "Escape frees scene")
	check(Engine.max_fps == 97, "Prior FPS setting restored")
	check(app.pegasus.visible and app.pegasus.player.position == pegasus_position, "Pegasus resumes at same position")
	app.launch_level("BALLS")
	await settle()
	level = app.active_level as BallsLevel
	check(level != null and level.positions == [Vector2(590, 360), Vector2(690, 360)], "Fresh state on reentry")
	app.free()
	check(Engine.max_fps == 97, "App teardown restores FPS setting")
	Engine.max_fps = original_cap
	if failures == 0:
		print("Balls validation passed")
	quit(0 if failures == 0 else 1)
