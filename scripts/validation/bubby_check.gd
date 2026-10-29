extends SceneTree
## Actual-input progression, telegraph targeting, damage/retry and native authoring.
var prefix: String = ""

func _initialize() -> void:
	root.set_meta("matrix_test_mode", true)
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() == 1:
		prefix = args[0]
		root.size = Vector2i(1280, 720)
	run.call_deferred()

func key(code: Key) -> void:
	for pressed: bool in [true, false]:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = pressed
		root.push_input(event)

func capture(label: String) -> void:
	if prefix.is_empty(): return
	await process_frame
	RenderingServer.force_draw(false)
	await process_frame
	assert(root.get_texture().get_image().save_png(prefix + "-" + label + ".png") == OK)

func run() -> void:
	assert(LevelRegistry.lookup("ZELDA").is_empty())
	assert(LevelRegistry.lookup(" bubby ").name == "Bubby")
	var app: MatrixApp = load("res://app/main.tscn").instantiate() as MatrixApp
	root.add_child(app)
	app.launch_level("BUBBY")
	await process_frame
	await process_frame
	var level: BubbyLevel = app.active_level as BubbyLevel
	assert(level != null and level.room_name == "apartment")
	level.set_physics_process(false)
	assert(level.get_node("Music").playing and not level.player.frames.is_empty())
	# Native cells, props, spawn and collision remain editable/saveable.
	for title: String in ["apartment", "outside"]:
		var room: BubbyRoom = (BubbyLevel.ROOMS[title] as PackedScene).instantiate() as BubbyRoom
		var tiles: TileMapLayer = room.get_node("Ground") as TileMapLayer
		assert(tiles.tile_set.resource_path.ends_with(title + ".tres"))
		assert(tiles.get_used_cells().size() == 220)
		assert(tiles.get_cell_atlas_coords(Vector2i(5,6)).y == (0 if title == "apartment" else 1), "Floor cells must reference the intended floor row, not empty atlas alternatives")
		var sample: Vector2i = tiles.get_used_cells()[0]
		tiles.erase_cell(sample)
		room.get_node("PlayerSpawn").position += Vector2(5,7)
		var packed: PackedScene = PackedScene.new()
		assert(packed.pack(room) == OK)
		var path: String = "user://bubby-room-check.tscn"
		assert(ResourceSaver.save(packed,path) == OK)
		var saved: BubbyRoom = (ResourceLoader.load(path,"PackedScene",ResourceLoader.CACHE_MODE_IGNORE) as PackedScene).instantiate() as BubbyRoom
		assert(saved.player_spawn == room.player_spawn)
		assert((saved.get_node("Ground") as TileMapLayer).get_cell_source_id(sample) == -1)
		assert(saved.collision_rects == room.collision_rects)
		saved.free()
		room.free()
		DirAccess.remove_absolute(path)
	await capture("apartment")
	# Notebook is flavor, never a mandatory errand.
	level.player.position = Vector2(298,207)
	key(KEY_E)
	assert(not level.dialogue.is_empty() and not level.complete)
	key(KEY_ESCAPE)
	assert(level.dialogue.is_empty() and app.active_level == level)
	# Natural approaches below the visible curtain must not snag its collider.
	for approach_y: float in [268.0, 282.0, 306.0]:
		level.player.position = Vector2(235, approach_y)
		level.player.step(Vector2.RIGHT, 2.4, level.room.collision_rects, level.room.bounds)
		assert(level.near("Exit"), "Door curtain must leave the lower approach clear")
	# Walk the authored route from spawn to door using the actual collision algorithm.
	level.player.position = level.room.player_spawn
	for i: int in range(8): level.player.step(Vector2.DOWN, 0.05, level.room.collision_rects, level.room.bounds)
	for i: int in range(49): level.player.step(Vector2.RIGHT, 0.05, level.room.collision_rects, level.room.bounds)
	assert(level.near("Exit"), "Apartment spawn must have a clear route to balcony doors")
	key(KEY_E)
	assert(level.room_name == "outside" and level.boss_state == "intro")
	key(KEY_E)
	assert(level.boss_state == "rest")
	level._physics_process(0.1)
	assert(level.birds[0].position.y < 162, "Small pigeons scatter on entry")
	await capture("balcony")
	level.player.position = level.pigeon.position - Vector2(70,0)
	var initial: int = level.pigeon_health
	key(KEY_SPACE)
	key(KEY_SPACE)
	assert(level.pigeon_health == initial - 1, "Shoo cooldown blocks repeated keys")
	level.player.position = Vector2(100,270)
	level.shoo_wait = 0
	key(KEY_SPACE)
	assert(level.pigeon_health == initial - 1, "Distant shoo must miss")
	# Target locks before the jump; moving after the tell avoids the landing.
	level.phase_time = 0
	level._physics_process(0.01)
	assert(level.boss_state == "tell")
	var target: Vector2 = level.hop_target
	level.player.position = Vector2(520,282)
	level._physics_process(0.5)
	assert(level.hop_target == target)
	level.shoo_wait = 0
	key(KEY_SPACE)
	assert(level.pigeon_health == initial - 1, "Only recovery windows accept shoo")
	await capture("boss")
	level._physics_process(0.7)
	assert(level.boss_state == "hop")
	level._physics_process(0.5)
	assert(level.health == BubbyLevel.MAX_COMPOSURE and level.boss_state == "rest")
	# A real landing hit, cooldown, defeat dialogue and input-triggered immediate retry.
	level.player.position = level.pigeon.position
	level.phase_time = 0
	level._physics_process(0.01)
	level.player.position = level.hop_target
	level._physics_process(1.2)
	level._physics_process(0.5)
	assert(level.health == BubbyLevel.MAX_COMPOSURE - 1)
	level.take_nudge()
	assert(level.health == BubbyLevel.MAX_COMPOSURE - 1, "Damage grace prevents repeated hits")
	level.health = 1
	level.hurt_wait = 0
	level.phase_time = 0
	level._physics_process(0.01)
	level.player.position = level.hop_target
	level._physics_process(1.2)
	level._physics_process(0.5)
	assert(level.boss_state == "defeated" and not level.dialogue.is_empty())
	key(KEY_E)
	assert(level.health == BubbyLevel.MAX_COMPOSURE and level.pigeon_health == BubbyLevel.MAX_PIGEON)
	assert(level.boss_state == "rest" and level.dialogue.is_empty())
	# Win through the real phase/cooldown loop, dodge while the circle is active.
	for i: int in range(900):
		if level.boss_state == "rest":
			level.player.position = level.pigeon.position - Vector2(70,0)
			key(KEY_SPACE)
		elif level.boss_state in ["tell", "hop"]:
			level.player.position = Vector2(100,280)
		level._physics_process(0.05)
		if level.boss_state == "cleared": break
	assert(level.complete and level.pigeon_health == 0 and not level.pigeon.visible)
	assert(not level.room.get_node("Mess").visible and level.dialogue.contains("BALCONY RECLAIMED"))
	await capture("ending")
	key(KEY_E)
	level.player.position = Vector2(96,270)
	key(KEY_E)
	assert(level.room_name == "apartment")
	level.player.position = Vector2(560,282)
	key(KEY_E)
	assert(level.complete and not level.pigeon.visible, "Re-entry preserves this session's victory")
	# Rail and furnishing collisions constrain long-frame movement.
	level.player.position = Vector2(320,180)
	level.player.step(Vector2.UP, 3, level.room.collision_rects, level.room.bounds)
	assert(level.player.hitbox().position.y >= 128)
	key(KEY_ESCAPE)
	await process_frame
	await process_frame
	assert(app.active_level == null and app.pegasus.visible)
	app.free()
	await process_frame
	await create_timer(0.15).timeout
	print("Bubby validation passed: balcony route, native edits, scatter, locked tells, shoo windows/cooldown, dodge, damage/defeat/retry, victory and return")
	quit()
