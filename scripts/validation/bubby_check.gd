extends SceneTree
## Exercise a complete provisional delivery, local dialogue, failure/retry and routing.

func _initialize() -> void:
	root.set_meta("matrix_test_mode", true)
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
	assert(level.get_node("Music").playing)
	assert(not level.player.frames.is_empty())
	assert(not level.room.collision_rects.is_empty())
	# New room uses native external TileSets and editable collision/interaction nodes.
	for title: String in ["apartment", "outside"]:
		var room: BubbyRoom = (BubbyLevel.ROOMS[title] as PackedScene).instantiate() as BubbyRoom
		var tiles: TileMapLayer = room.get_node("Ground") as TileMapLayer
		assert(tiles.tile_set.resource_path.ends_with(title + ".tres"))
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
		saved.free()
		room.free()
		DirAccess.remove_absolute(path)
	level.player.position = Vector2(304,176)
	key(KEY_E)
	assert(not level.dialogue.is_empty() and not level.complete)
	key(KEY_ESCAPE)
	assert(level.dialogue.is_empty() and app.active_level == level)
	# Use real input at the authored door and encounter regions.
	level.player.position = Vector2(480,292)
	key(KEY_E)
	assert(level.room_name == "outside")
	var capture_args: PackedStringArray = OS.get_cmdline_user_args()
	if capture_args.size() == 1:
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(capture_args[0] + "-encounter.png") == OK)
	level.player.position = Vector2(528,160)
	key(KEY_E)
	assert(not level.envelope and level.notice.contains("pigeon"))
	level.player.position = level.pigeon.position - Vector2(40,0)
	var initial: int = level.pigeon_health
	key(KEY_SPACE)
	key(KEY_SPACE)
	assert(level.pigeon_health == initial - 1, "Shoo cooldown blocks repeated key hits")
	level.health = 1
	level.hurt_wait = 0
	level.player.position = level.pigeon.position
	level._physics_process(0.01)
	assert(level.room_name == "apartment" and level.health == 3 and level.pigeon_health == 3)
	level.player.position = Vector2(480,292)
	key(KEY_E)
	for i: int in range(3):
		level.player.position = level.pigeon.position - Vector2(40,0)
		level.shoo_wait = 0
		key(KEY_SPACE)
	assert(level.pigeon_health == 0 and not level.pigeon.visible)
	level.player.position = Vector2(528,160)
	key(KEY_E)
	assert(level.envelope and not level.complete)
	assert((level.room.get_node("Details") as TileMapLayer).get_cell_source_id(Vector2i(16,4)) == -1)
	level.player.position = Vector2(96,272)
	key(KEY_E)
	assert(level.room_name == "apartment")
	level.player.position = Vector2(304,176)
	key(KEY_E)
	assert(level.complete and level.dialogue.contains("Placeholder ending"))
	key(KEY_ESCAPE)
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() == 1:
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(args[0] + "-apartment.png") == OK)
		level.show_room("outside")
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(args[0] + "-outside.png") == OK)
	key(KEY_ESCAPE)
	await process_frame
	await process_frame
	assert(app.active_level == null and app.pegasus.visible)
	app.free()
	await process_frame
	await create_timer(0.15).timeout
	print("Bubby validation passed: provisional delivery, encounter, retry, editor resources and return")
	quit()
