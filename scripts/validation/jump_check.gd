extends SceneTree


func _initialize() -> void:
	run.call_deferred()


func run() -> void:
	var app: MatrixApp = load("res://app/main.tscn").instantiate()
	root.add_child(app)
	app.launch_level("JUMP")
	await process_frame
	await process_frame
	var level: JumpLevel = app.active_level as JumpLevel
	assert(level != null and not level.active and level.get_node("Music").playing)
	level.set_physics_process(false)
	level.reset_run()
	assert(level.player == Rect2i(48, 216, 64, 84))
	level.advance_tick(true)
	assert(level.gravity == -24 and level.player.position.y == 192)
	for i: int in range(60):
		level.advance_tick(false)
	assert(level.player.end.y == 300)
	level.spawn_obstacle("snail", 1000)
	level.spawn_obstacle("fly", 1000)
	level.advance_tick(false)
	assert(level.obstacles[0].rect == Rect2i(961, 264, 72, 36))
	assert(level.obstacles[1].rect == Rect2i(953, 170, 84, 40))
	level.obstacles.clear()
	level.spawn_obstacle("snail", 80)
	level.advance_tick(false)
	assert(not level.active and level.obstacles.is_empty())
	level.reset_run()
	level.get_node("Spawn").timeout.emit()
	assert(level.obstacles.size() == 1)
	level.active = false
	level.get_node("Field/Canvas").queue_redraw()
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() == 1:
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(args[0]) == OK)
	var audio: WeakRef = weakref(level.get_node("Music"))
	app.return_to_hub()
	await process_frame
	await process_frame
	assert(app.active_level == null and audio.get_ref() == null)
	app.free()
	await process_frame
	await process_frame
	print("Jump validation passed")
	quit()
