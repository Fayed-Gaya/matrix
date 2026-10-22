extends SceneTree


func _initialize() -> void:
	run.call_deferred()


func run() -> void:
	var app: MatrixApp = load("res://app/main.tscn").instantiate()
	root.add_child(app)
	app.launch_level("MARIO")
	await process_frame
	await process_frame
	var level: MarioLevel = app.active_level as MarioLevel
	assert(level != null and level.mode == "overworld" and level.max_level == 2)
	level.set_physics_process(false)
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() == 1:
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(args[0]+"-overworld.png") == OK)
	for index: int in range(6):
		level.enter_stage(index)
		assert(level.player.size == Vector2(50,56) and level.goal.has_area())
		assert(level.objects.size() > 50)
		var start: Vector2 = level.player.position
		level.advance_stage(1.0/60,1,false)
		assert(level.player.position.x > start.x)
		for tick: int in range(90):
			level.advance_stage(1.0/60,0,false)
		assert(level.mode == "stage" and level.on_ground)
		level.advance_stage(1.0/60,0,true)
		assert(level.velocity.y < 0 and not level.on_ground)
	level.enter_stage(0)
	if args.size() == 1:
		level.get_node("Field/Canvas").queue_redraw()
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(args[0]+"-stage.png") == OK)
	# Isolate collection/damage/stomp rules from layout and random enemy speed.
	level.objects.clear()
	level.health = 100
	level.hurt_left = 0
	level.player = Rect2(500,300,50,56)
	level.velocity = Vector2.ZERO
	level.objects.append({"kind":"coins","rect":Rect2(500,300,32,32),"tile":0,"frame":0.0,"dead":false,"folder":"coins/gold","speed":0})
	var before: int = level.coins
	level.advance_stage(1.0/60,0,false)
	assert(level.coins == before+5 and level.objects.is_empty())
	level.objects.append({"kind":"enemies","rect":Rect2(500,300,64,64),"tile":0,"frame":0.0,"dead":false,"folder":"enemy/run","speed":0})
	level.advance_stage(1.0/60,0,false)
	assert(level.health == 90 and level.hurt_left > 0)
	level.advance_stage(1.0/60,0,false)
	assert(level.health == 90)
	level.objects.clear()
	level.player = Rect2(500,300,50,56)
	level.velocity = Vector2(0,1)
	level.objects.append({"kind":"enemies","rect":Rect2(500,350,64,64),"tile":0,"frame":0.0,"dead":false,"folder":"enemy/run","speed":0})
	level.advance_stage(1.0/60,0,false)
	assert(level.objects.is_empty() and level.velocity.y == -15)
	level.enter_stage(2)
	level.objects.clear()
	level.max_level = 2
	level.health = 100
	level.player = Rect2(500,300,50,56)
	level.goal = Rect2(500,300,64,64)
	level.advance_stage(1.0/60,0,false)
	assert(level.mode == "overworld" and level.max_level == 3)
	level.enter_stage(0)
	level.objects.clear()
	level.player.position.x = 1100
	level.advance_stage(1.0/60,1,false)
	assert(level.camera_x > 0)
	level.player.position.y = 800
	level.advance_stage(1.0/60,0,false)
	assert(level.mode == "overworld")
	level.enter_stage(0)
	level.health = 0
	level.advance_stage(1.0/60,0,false)
	assert(level.mode == "overworld" and level.max_level == 0 and level.health == 100 and level.coins == 0)
	app.return_to_hub()
	await process_frame
	await process_frame
	assert(app.active_level == null)
	app.free()
	await create_timer(0.15).timeout
	print("Mario validation passed")
	quit()
