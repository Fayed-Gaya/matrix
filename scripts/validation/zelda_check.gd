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


func enemy(level: ZeldaLevel,position: Vector2) -> Dictionary:
	return {"name":"squid","box":Rect2(position,Vector2(64,54)),"health":100.0,"direction":Vector2.ZERO,"state":"idle","frame":0.0,"hurt":0.0,"wait":0.0,"can_attack":true,"dead":false}


func run() -> void:
	var app: MatrixApp = load("res://app/main.tscn").instantiate()
	root.add_child(app)
	app.launch_level("ZELDA")
	await process_frame
	await process_frame
	var level: ZeldaLevel = app.active_level as ZeldaLevel
	assert(level != null and level.health == 50 and level.experience == 5000)
	level.set_physics_process(false)
	assert(level.player.size == Vector2(58,38) and level.objects.size() > 100)
	assert(level.enemies.size() > 4 and level.get_node("Music").playing)
	var names: Dictionary = {}
	for item: Dictionary in level.enemies:
		names[item.name] = true
	assert(names.size() == 4)
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() == 1:
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(args[0]+"-world.png") == OK)
	key(KEY_M)
	assert(level.paused)
	level.get_node("Field/Canvas").queue_redraw()
	if args.size() == 1:
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(args[0]+"-upgrades.png") == OK)
	key(KEY_ESCAPE)
	assert(not level.paused and app.active_level == level)
	var barrier: Dictionary = level.objects[0]
	var initial: Rect2 = Rect2(barrier.box.position-Vector2(58,0),Vector2(58,38))
	var stopped: Rect2 = level.move_box(initial,Vector2.RIGHT,5)
	assert(stopped.position.x <= initial.position.x)
	# Exercise combat, spells and upgrades with isolated source-sized fixtures.
	level.objects.clear()
	level.buckets.clear()
	level.enemies.clear()
	level.player = Rect2(500,500,58,38)
	level.facing = "right"
	level.attack()
	assert(level.weapon_rect.has_area() and is_equal_approx(level.attack_left,0.5))
	var target: Dictionary = enemy(level,level.weapon_rect.position)
	level.enemies.append(target)
	level.apply_attacks()
	assert(target.health == 75 and is_equal_approx(target.hurt,0.3))
	level.apply_attacks()
	assert(target.health == 75)
	level.hurt_left = 0
	level.health = 50
	level.damage_player(20,"slash")
	level.damage_player(20,"slash")
	assert(level.health == 30 and is_equal_approx(level.hurt_left,0.5))
	level.particles.clear()
	level.health = 50
	level.energy = 48
	level.magic_index = 1
	level.attack(true)
	assert(level.health == 74 and level.energy == 38 and level.particles.size() == 2)
	level.particles.clear()
	level.magic_index = 0
	level.attack(true)
	assert(level.energy == 18 and level.particles.size() == 5)
	level.particles.clear()
	level.energy = 0
	level.attack(true)
	assert(level.particles.is_empty())
	level.attack()
	var grass: Dictionary = {"type":"grass","rect":level.weapon_rect,"box":level.weapon_rect,"dead":false,"texture":level.frames("grass")[0]}
	level.objects.append(grass)
	level.index_obstacle(grass)
	level.apply_attacks()
	assert(grass.dead and level.particles.size() >= 3 and level.particles.size() <= 6)
	level.enemies.clear()
	target = enemy(level,Vector2(1000,1000))
	target.health = 0
	level.enemies.append(target)
	var xp: float = level.experience
	level.update_enemies(1.0/60)
	assert(level.enemies.is_empty() and level.experience == xp+100)
	level.experience = 5000
	level.upgrade(0)
	assert(level.stats.health == 120 and level.experience == 4900 and level.costs.health == 140)
	level.stats.health = 299
	level.upgrade(0)
	assert(level.stats.health == 300)
	key(KEY_ESCAPE)
	await process_frame
	await process_frame
	assert(app.active_level == null and app.hub.visible)
	app.free()
	await create_timer(0.15).timeout
	print("Zelda validation passed")
	quit()
