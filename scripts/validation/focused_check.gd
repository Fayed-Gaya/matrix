extends SceneTree
## Small invariants only: no exact maps, speeds, balance values or walkthroughs.

func _initialize() -> void:
	root.set_meta("matrix_test_mode", true)
	root.size = Vector2i(1280, 720)
	run.call_deferred()

func run() -> void:
	for component: String in OS.get_cmdline_user_args():
		if component == "pegasus":
			await check_pegasus()
		elif component == "mobile":
			await check_mobile()
		else:
			var entry: Dictionary = LevelRegistry.lookup(component.to_upper())
			assert(not entry.is_empty() and not entry.scene.is_empty(), "Unknown component: " + component)
			var game: MatrixLevel = load(entry.scene).instantiate() as MatrixLevel
			root.add_child(game)
			await process_frame
			game.set_process(false)
			game.set_physics_process(false)
			match component:
				"bounce": check_bounce(game as BouncingBallLevel)
				"balls": check_balls(game as BallsLevel)
				"bug": check_bug(game as BugLevel)
				"busboy": check_turns()
				"bubby": check_bubby(game as BubbyLevel)
				"simulation": check_simulation(game as SimulationLevel)
				"you": assert((game as YouLevel).feed == null, "Test mode must not start a camera")
			game.free()
		await process_frame
	await create_timer(0.15).timeout
	print("Focused checks passed: " + ", ".join(OS.get_cmdline_user_args()))
	quit()

func check_pegasus() -> void:
	var game: Pegasus = load("res://pegasus/pegasus.tscn").instantiate() as Pegasus
	root.add_child(game)
	await process_frame
	game.set_physics_process(false)
	assert(game.overlay.opening)
	game.overlay.opening = false
	game.open_terminal()
	assert(game.overlay.terminal_active)
	game.overlay.input_text = "not-a-code"
	game.submit_code()
	assert(not game.overlay.message.is_empty() and game.overlay.input_text.is_empty())
	var requested: Array[String] = []
	game.level_requested.connect(func(code: String) -> void: requested.append(code))
	var code: String = LevelRegistry.ENTRIES.keys()[0]
	game.overlay.input_text = " " + code.to_lower() + " "
	game.submit_code()
	assert(requested == [code], "Terminal normalizes and emits the requested code")
	game.close_terminal()
	assert(not game.overlay.terminal_active)
	# Synthetic obstacle: collision integrity without freezing authored room geometry.
	var obstacle: Rect2 = Rect2(80, 0, 20, 200)
	game.player.position = Vector2(40, 80)
	assert(game.player.speed > 0)
	game.player.step(Vector2.RIGHT, 200.0 / game.player.speed, [obstacle], Vector2(200, 200))
	assert(not game.player.hitbox().intersects(obstacle), "Long movement must not tunnel")
	assert(game.player.hitbox().end.x <= obstacle.position.x)
	game.free()

func check_bounce(game: BouncingBallLevel) -> void:
	game.ball_position = Vector2i(game.FIELD_SIZE) - Vector2i(game.BALL.get_size())
	game.direction = Vector2i.ONE
	game.advance_tick()
	assert(game.direction.x < 0 and game.direction.y < 0, "Ball reflects at field edges")

func check_balls(game: BallsLevel) -> void:
	game.positions = [game.FIELD_SIZE - Vector2.ONE, game.FIELD_SIZE - Vector2.ONE]
	game.advance_frame(Vector2.ONE, 1.0)
	for position: Vector2 in game.positions:
		assert(position.x >= 0 and position.x < game.FIELD_SIZE.x)
		assert(position.y >= 0 and position.y < game.FIELD_SIZE.y)

func check_bug(game: BugLevel) -> void:
	var event: InputEventScreenTouch = InputEventScreenTouch.new()
	event.index = 7
	event.position = game.field_offset + Vector2(20, 30) * game.field_scale
	event.pressed = true
	game._input(event)
	assert(game.buttons[0] and game.mouse_position == Vector2(20, 30))
	event.pressed = false
	game._input(event)
	assert(not game.buttons[0] and game.touch_index == -1, "Touch release clears pointer state")

func resolve(battle: BusboyEncounter) -> void:
	battle.tick(battle.wait + 1.0)

func check_turns() -> void:
	var battle: BusboyEncounter = BusboyEncounter.new()
	battle.enemy_health = 1000 # Force a pending reply without locking starting balance.
	battle.health = 1000
	battle.mana = 100
	var mana_before: int = battle.mana
	var enemy_before: int = battle.enemy_health
	assert(battle.choose("cleanse"))
	assert(battle.mana < mana_before and battle.corruption > 0 and battle.enemy_health < enemy_before)
	assert(not battle.choose("strike"), "One action per pending reply")
	resolve(battle)
	assert(battle.phase == BusboyEncounter.Phase.PLAYER)
	battle.mana = 0
	var turn_before: int = battle.turn
	assert(not battle.choose("cleanse") and battle.turn == turn_before)
	assert(battle.phase == BusboyEncounter.Phase.PLAYER, "Failed cast does not consume a turn")
	assert(battle.choose("guard"))
	resolve(battle)
	assert(battle.mana > 0 and not battle.guarding)
	battle.enemy_health = 1
	assert(battle.choose("strike") and battle.phase == BusboyEncounter.Phase.VICTORY)
	assert(not battle.choose("strike"), "Completed encounter cannot accept another action")
	var loss: BusboyEncounter = BusboyEncounter.new()
	loss.enemy_health = 1000
	loss.turn = 1
	loss.health = 1
	assert(loss.choose("strike"))
	resolve(loss)
	assert(loss.phase == BusboyEncounter.Phase.DEFEAT and loss.health == 0)

func check_kate(player: BubbyPlayer) -> void:
	var directions: Dictionary = {"down": Vector2.DOWN, "up": Vector2.UP, "right": Vector2.RIGHT, "left": Vector2.LEFT}
	var names: Dictionary = {"down": "south", "up": "north", "right": "east", "left": "west"}
	assert(player.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST)
	var foot_line: float = -INF
	for facing: String in directions:
		var direction: String = names[facing]
		var walks: Array = player.frames["player/" + facing]
		assert(walks.size() == 4)
		assert(player.frames["player/" + facing + "_idle"].size() == 1)
		for picture: Texture2D in walks + player.frames["player/" + facing + "_idle"]:
			assert(picture.get_size() == Vector2(32, 32))
			var baseline: float = player.frame_origins[picture].y + picture.get_image().get_used_rect().end.y
			if foot_line == -INF: foot_line = baseline
			assert(baseline == foot_line, "Idle and walking feet share one anchor")
		player.position = Vector2(200, 200)
		player.frame_index = 0
		for i: int in range(5):
			player.step(directions[facing], 1.0 / 9.0, [], Vector2(640, 352))
			assert(player.facing == facing and player.moving)
			assert(player.current_texture() == walks[(i + 1) % 4], "Walking selects and loops the directional frames")
		player.step(Vector2.ZERO, 0, [], Vector2(640, 352))
		assert(not player.moving and player.facing == facing)
		assert(player.current_texture().resource_path.ends_with("idle_" + direction + ".png"))
	player.position = Vector2(200, 160)
	var wall: Rect2 = Rect2(240, 120, 20, 160)
	player.step(Vector2.RIGHT, 1.0, [wall], Vector2(640, 352))
	assert(not player.hitbox().intersects(wall), "Visual replacement preserves collision blocking")

func check_bubby(game: BubbyLevel) -> void:
	check_kate(game.player)
	game.show_room("outside")
	game.close_dialogue()
	game.pigeon_health = 1000 # Keep the encounter alive while exercising cooldown.
	game.player.position = game.pigeon.position
	var before: int = game.pigeon_health
	game.shoo()
	assert(game.pigeon_health < before)
	var after: int = game.pigeon_health
	game.shoo()
	assert(game.pigeon_health == after, "Cooldown prevents repeated immediate hits")
	game.health = 0
	game.retry()
	assert(game.health > 0 and game.pigeon_health > 0 and game.room_name == "outside" and game.boss_state == "rest")

func check_simulation(game: SimulationLevel) -> void:
	assert(LevelRegistry.lookup("MACHINE").is_empty(), "The retired code must not remain an alias")
	assert(LevelRegistry.lookup(" simulation ").name == "Simulation")
	game.show_room("outskirts")
	game.player.position = game.room.get_node("Governor").position
	game.start_boss()
	game.boss_health = 1000 # Keep this probe in the recovery/cooldown state.
	var before: int = game.boss_health
	game.attack()
	assert(game.boss_health == before, "Windup is not a damage window")
	game.brace()
	var health_before: int = game.health
	game.update_boss(game.boss_wait + 1.0)
	assert(game.health == health_before and game.boss_phase == SimulationLevel.BossPhase.RECOVER)
	game.attack()
	assert(game.boss_health < before)
	var after: int = game.boss_health
	game.attack()
	assert(game.boss_health == after, "Cooldown prevents duplicate attack")
	game.reset_boss()
	assert(game.boss_phase == SimulationLevel.BossPhase.DORMANT and game.health > 0)

func check_mobile() -> void:
	root.set_meta("matrix_force_touch", true)
	var app: MatrixApp = load("res://app/main.tscn").instantiate() as MatrixApp
	root.add_child(app)
	app.pegasus.overlay.opening = false
	await process_frame
	await process_frame
	for finger: int in range(2):
		var event: InputEventScreenTouch = InputEventScreenTouch.new()
		event.index = finger
		event.position = app.mobile_controls.regions["Right" if finger == 0 else "Up"].get_center()
		event.pressed = true
		root.push_input(event)
	await process_frame
	await process_frame
	assert(Input.is_action_pressed("pegasus_right") and Input.is_action_pressed("pegasus_up"))
	app.mobile_controls._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	assert(not Input.is_action_pressed("pegasus_right") and not Input.is_action_pressed("pegasus_up"))
	app.free()
	root.remove_meta("matrix_force_touch")
