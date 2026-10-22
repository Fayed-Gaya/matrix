extends SceneTree
## Intro slice: exploration/dialogue, gated turn encounter, defeat/retry/retreat,
## victory/collision removal, shrine objective and hub return.

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

func capture(level: BusboyLevel, label: String) -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() != 1: return
	level.update_camera()
	level.overlay.queue_redraw()
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(args[0] + "-" + label + ".png") == OK)

func check_model() -> void:
	var battle: BusboyEncounter = BusboyEncounter.new()
	assert(battle.intent().contains("Gather"))
	assert(battle.choose("cleanse"))
	assert(battle.mana == 2 and battle.corruption == 1 and battle.enemy_health == 12)
	assert(not battle.choose("strike"), "One action per resolved turn")
	battle.tick(0.61)
	assert(battle.phase == BusboyEncounter.Phase.PLAYER and battle.health == 18)
	assert(battle.intent().contains("Heavy"))
	assert(battle.choose("guard"))
	battle.tick(0.61)
	assert(battle.health == 15 and battle.mana == 3, "Guard halves telegraphed damage and restores mana")
	battle.mana = 0
	var turn: int = battle.turn
	assert(not battle.choose("cleanse"))
	assert(battle.phase == BusboyEncounter.Phase.PLAYER and battle.turn == turn)
	assert(not battle.choose("unknown"))

func run() -> void:
	check_model()
	assert(LevelRegistry.lookup("UNTITLED").is_empty())
	assert(LevelRegistry.lookup(" busboy ").name == "Busboy")
	var app: MatrixApp = load("res://app/main.tscn").instantiate() as MatrixApp
	root.add_child(app)
	app.launch_level("BUSBOY")
	await process_frame
	await process_frame
	var level: BusboyLevel = app.active_level as BusboyLevel
	assert(level != null and level.opening and level.room_name == "cabin")
	assert(level.get_node("Ambience").playing)
	var start: Vector2 = level.player.position
	Input.action_press("hub_right")
	await physics_frame
	await physics_frame
	Input.action_release("hub_right")
	assert(level.player.position == start)
	key(KEY_SPACE)
	assert(not level.opening)
	level.set_physics_process(false)
	level.display.show()
	await capture(level,"cabin")
	# Scene persistence and external TileSet authority, including resized NPC regions.
	for title: String in ["cabin", "forest"]:
		var room: BusboyRoom = (BusboyLevel.ROOMS[title] as PackedScene).instantiate() as BusboyRoom
		var layer: TileMapLayer = room.get_node("Ground") as TileMapLayer
		assert(layer.tile_set.resource_path == "res://levels/busboy/tileset.tres")
		var cell: Vector2i = layer.get_used_cells()[0]
		layer.erase_cell(cell)
		room.get_node("Exit").position += Vector2(5,7)
		var packed: PackedScene = PackedScene.new()
		assert(packed.pack(room) == OK)
		var path: String = "user://busboy-room-check.tscn"
		assert(ResourceSaver.save(packed,path) == OK)
		var edited: BusboyRoom = (ResourceLoader.load(path,"PackedScene",ResourceLoader.CACHE_MODE_IGNORE) as PackedScene).instantiate() as BusboyRoom
		assert(edited.region("Exit") == room.region("Exit"))
		assert(edited.npc_data == room.npc_data)
		assert((edited.get_node("Ground") as TileMapLayer).get_cell_source_id(cell) == -1)
		edited.free()
		room.free()
		DirAccess.remove_absolute(path)
	level.player.position = Vector2(480,296)
	key(KEY_E)
	assert(level.room_name == "forest")
	level.player.position = Vector2(704,240)
	key(KEY_E)
	assert(level.encounter == null and not level.advised)
	level.player.position = Vector2(740,208)
	level.player.step(Vector2.RIGHT,1,level.room.collision_rects,level.room.bounds)
	assert(level.player.position.x <= 760, "Corruption gate blocks the clearing")
	level.player.position = Vector2(344,400)
	key(KEY_E)
	assert(level.advised and level.dialogue.contains("Earth") and level.dialogue.contains("Blood"))
	start = level.player.position
	Input.action_press("hub_right")
	level._physics_process(0.1)
	Input.action_release("hub_right")
	assert(level.player.position == start, "Dialogue locks movement")
	key(KEY_ESCAPE)
	assert(level.dialogue.is_empty() and app.active_level == level)
	await capture(level,"forest")
	level.player.position = Vector2(704,240)
	key(KEY_E)
	assert(level.encounter != null)
	await capture(level,"battle")
	# Defeat returns safely to the starting room, retaining only intro advice.
	level.encounter.health = 1
	level.encounter.turn = 1
	key(KEY_1)
	level.encounter.tick(0.61)
	assert(level.encounter.phase == BusboyEncounter.Phase.DEFEAT)
	key(KEY_ENTER)
	assert(level.room_name == "cabin" and level.encounter == null and level.advised)
	level.player.position = Vector2(480,296)
	key(KEY_E)
	level.player.position = Vector2(704,240)
	key(KEY_E)
	assert(level.encounter.health == 18)
	key(KEY_ESCAPE)
	assert(level.encounter == null and level.room_name == "forest" and app.active_level == level)
	key(KEY_E)
	for i: int in range(5):
		if level.encounter.phase != BusboyEncounter.Phase.PLAYER: break
		key(KEY_1)
		level.encounter.tick(0.61)
	assert(level.encounter.phase == BusboyEncounter.Phase.VICTORY)
	key(KEY_ENTER)
	assert(level.encounter == null and level.encounter_won)
	assert(not level.room.get_node("Guardian").visible)
	assert(level.room.get_node("Collisions/CorruptionGate").disabled)
	level.player.position = Vector2(740,208)
	level.player.step(Vector2.RIGHT,0.4,level.room.collision_rects,level.room.bounds)
	assert(level.player.position.x > 784, "Victory physically opens the gate")
	level.player.position = Vector2(832,168)
	key(KEY_E)
	assert(level.complete and level.dialogue.contains("introduction complete"))
	key(KEY_ESCAPE)
	key(KEY_ESCAPE)
	await process_frame
	await process_frame
	assert(app.active_level == null and app.hub.visible)
	app.free()
	await process_frame
	await create_timer(0.15).timeout
	print("Busboy validation passed: dialogue, turn encounter, retry, retreat, gate, shrine and return")
	quit()
