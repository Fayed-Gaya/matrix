extends SceneTree


func _initialize() -> void:
	run.call_deferred()


func run() -> void:
	var app: MatrixApp = load("res://app/main.tscn").instantiate()
	root.add_child(app)
	app.launch_level("BUG")
	await process_frame
	await process_frame
	var level: BugLevel = app.active_level as BugLevel
	assert(level != null)
	var event: InputEventMouseMotion = InputEventMouseMotion.new()
	event.position = level.field_offset + Vector2(123.25, 234.25) * level.field_scale
	root.push_input(event)
	assert(level.mouse_position == Vector2(123, 234))
	for button: MouseButton in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_MIDDLE, MOUSE_BUTTON_RIGHT]:
		var click: InputEventMouseButton = InputEventMouseButton.new()
		click.position = event.position
		click.button_index = button
		click.pressed = true
		root.push_input(click)
	assert(level.buttons == [true, true, true])
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() == 1:
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(args[0]) == OK)
	app.return_to_pegasus()
	await process_frame
	await process_frame
	assert(app.active_level == null and app.pegasus.visible)
	app.free()
	print("The Bug validation passed")
	quit()
