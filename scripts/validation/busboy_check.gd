extends SceneTree
## Full introduction, real input, path collisions, native edits and turn tradeoffs.
var prefix: String = ""
func _initialize() -> void:
	root.set_meta("matrix_test_mode", true)
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() == 1:
		prefix = args[0]
		root.size = Vector2i(1280,720)
	run.call_deferred()

func key(code: Key) -> void:
	for pressed: bool in [true,false]:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = pressed
		root.push_input(event)

func capture(level: BusboyLevel, label: String) -> void:
	if prefix.is_empty(): return
	level.update_camera()
	level.overlay.queue_redraw()
	await process_frame
	RenderingServer.force_draw(false)
	await process_frame
	assert(root.get_texture().get_image().save_png(prefix+"-"+label+".png") == OK)

func walk(level: BusboyLevel, point: Vector2) -> void:
	var delta: Vector2 = point-level.player.position
	if absf(delta.x)>0.01: level.player.step(Vector2(signf(delta.x),0),absf(delta.x)/BusboyPlayer.SPEED,level.room.collision_rects,level.room.bounds)
	delta = point-level.player.position
	if absf(delta.y)>0.01: level.player.step(Vector2(0,signf(delta.y)),absf(delta.y)/BusboyPlayer.SPEED,level.room.collision_rects,level.room.bounds)
	assert(level.player.position.distance_to(point)<0.1,"Authored route obstructed at "+str(level.player.position)+" toward "+str(point))

func check_model() -> void:
	var battle: BusboyEncounter = BusboyEncounter.new()
	assert(battle.intent().contains("GATHER") and battle.incoming_damage()==0)
	assert(battle.choose("cleanse"))
	assert(battle.mana==2 and battle.corruption==1 and battle.enemy_health==21)
	assert(not battle.choose("strike"),"One action per turn")
	battle.tick(1)
	assert(battle.phase==BusboyEncounter.Phase.PLAYER and battle.health==24)
	assert(battle.intent().contains("HEAVY") and battle.incoming_damage()==8,"A cast adds a visible point of incoming damage")
	assert(battle.choose("guard"))
	assert(battle.corruption==0 and battle.incoming_damage()==3)
	battle.tick(1)
	assert(battle.health==21 and battle.mana==3,"Guard halves the reply, restores mana and grounds stain")
	assert(battle.choose("cleanse"))
	battle.tick(1)
	assert(battle.health==17 and battle.mana==1 and battle.corruption==1)
	var turn: int = battle.turn
	assert(not battle.choose("cleanse") and battle.phase==BusboyEncounter.Phase.PLAYER and battle.turn==turn)
	assert(battle.message.contains("no turn was spent") and battle.last_reply.is_empty())
	assert(not battle.choose("unknown"))
	var mundane: BusboyEncounter = BusboyEncounter.new()
	for i: int in range(10):
		if mundane.phase != BusboyEncounter.Phase.PLAYER: break
		mundane.choose("strike");mundane.tick(1)
	assert(mundane.phase == BusboyEncounter.Phase.VICTORY and mundane.health > 0 and mundane.corruption == 0,"A slower non-magic route remains viable")
	var repeated: BusboyEncounter = BusboyEncounter.new()
	repeated.turn=1
	repeated.choose("cleanse"); repeated.tick(1)
	assert(repeated.health==16 and repeated.corruption==1)
	repeated.choose("cleanse"); repeated.tick(1)
	assert(repeated.health==11 and repeated.corruption==2,"Repeated magic stacks attack cost, not just a cosmetic counter")
	repeated.choose("guard");repeated.tick(1)
	assert(repeated.corruption==1 and repeated.mana==1)

func run() -> void:
	check_model()
	assert(LevelRegistry.lookup("UNTITLED").is_empty())
	assert(LevelRegistry.lookup(" busboy ").name=="Busboy")
	var app: MatrixApp = load("res://app/main.tscn").instantiate() as MatrixApp
	root.add_child(app)
	app.launch_level("BUSBOY")
	await process_frame
	await process_frame
	var level: BusboyLevel = app.active_level as BusboyLevel
	assert(level!=null and level.opening and level.room_name=="cabin")
	assert(level.get_node("Ambience").playing)
	var start: Vector2 = level.player.position
	Input.action_press("hub_right")
	await physics_frame;await physics_frame
	Input.action_release("hub_right")
	assert(level.player.position==start,"Opening locks movement")
	key(KEY_SPACE)
	assert(not level.opening)
	level.set_physics_process(false)
	level.display.show()
	await capture(level,"opening")
	for title: String in ["cabin","forest"]:
		var room: BusboyRoom = (BusboyLevel.ROOMS[title] as PackedScene).instantiate() as BusboyRoom
		var layer: TileMapLayer = room.get_node("Ground") as TileMapLayer
		assert(layer.tile_set.resource_path=="res://levels/busboy/maps/woodland.tres")
		assert(layer.tile_set.tile_size==Vector2i(16,16) and layer.scale==Vector2(2,2))
		assert(layer.get_used_cells().size()==(510 if title=="forest" else 220))
		var cell: Vector2i = layer.get_used_cells()[0]
		layer.erase_cell(cell)
		room.get_node("Exit").position+=Vector2(5,7)
		var packed: PackedScene = PackedScene.new()
		assert(packed.pack(room)==OK)
		var path: String = "user://busboy-room-check.tscn"
		assert(ResourceSaver.save(packed,path)==OK)
		var edited: BusboyRoom = (ResourceLoader.load(path,"PackedScene",ResourceLoader.CACHE_MODE_IGNORE) as PackedScene).instantiate() as BusboyRoom
		assert(edited.region("Exit")==room.region("Exit") and edited.npc_data==room.npc_data)
		assert(edited.collision_rects==room.collision_rects)
		assert((edited.get_node("Ground") as TileMapLayer).get_cell_source_id(cell)==-1)
		edited.free();room.free();DirAccess.remove_absolute(path)
	# Optional refuge inspection, followed by an actual clear walk from spawn.
	walk(level,Vector2(336,180));key(KEY_E)
	assert(not level.dialogue.is_empty())
	key(KEY_E)
	walk(level,Vector2(480,256));walk(level,Vector2(480,296));key(KEY_E)
	assert(level.room_name=="forest")
	level.player.position=Vector2(704,240)
	key(KEY_E)
	assert(level.encounter==null and not level.advised,"Waykeeper advice precedes the encounter")
	level.player.position=level.room.player_spawn
	walk(level,Vector2(224,464));walk(level,Vector2(224,432));walk(level,Vector2(360,432));walk(level,Vector2(360,400))
	await capture(level,"forest")
	key(KEY_E)
	assert(level.advised and level.dialogue.contains("stain"))
	start=level.player.position
	Input.action_press("hub_right");level._physics_process(0.1);Input.action_release("hub_right")
	assert(level.player.position==start,"Dialogue locks movement")
	await capture(level,"npc")
	key(KEY_ESCAPE)
	assert(level.dialogue.is_empty() and app.active_level==level)
	walk(level,Vector2(400,400));walk(level,Vector2(400,240));walk(level,Vector2(704,240))
	level.player.position=Vector2(740,240)
	level.player.step(Vector2.RIGHT,1,level.room.collision_rects,level.room.bounds)
	assert(level.player.position.x<=760,"Gate prevents bypassing the encounter")
	level.player.position=Vector2(704,240)
	key(KEY_E)
	assert(level.encounter!=null)
	key(KEY_3)
	assert(level.encounter.phase==BusboyEncounter.Phase.RESOLVING)
	level.encounter.tick(1)
	await capture(level,"combat")
	level.encounter.health=1;level.encounter.turn=1
	key(KEY_1);level.encounter.tick(1)
	assert(level.encounter.phase==BusboyEncounter.Phase.DEFEAT)
	key(KEY_ENTER)
	assert(level.room_name=="forest" and level.encounter.health==24 and level.encounter.corruption==0 and level.encounter.mana==4)
	key(KEY_ESCAPE)
	assert(level.encounter==null and not level.encounter_won and app.active_level==level)
	key(KEY_E)
	for i: int in range(30):
		if level.encounter.phase!=BusboyEncounter.Phase.PLAYER: break
		key(KEY_2 if level.encounter.turn%3==1 else (KEY_3 if level.encounter.mana>=2 else KEY_1))
		level.encounter.tick(1)
	assert(level.encounter.phase==BusboyEncounter.Phase.VICTORY and level.encounter.health>0)
	key(KEY_ENTER)
	assert(level.encounter==null and level.encounter_won)
	assert(not level.room.get_node("Guardian").visible and level.room.get_node("Collisions/CorruptionGate").disabled)
	walk(level,Vector2(832,240));walk(level,Vector2(832,188));key(KEY_E)
	assert(level.complete and level.dialogue.contains("Introduction complete") and level.room.get_node("ShrineArt/Halo").visible)
	await capture(level,"conclusion")
	key(KEY_ESCAPE);key(KEY_ESCAPE)
	await process_frame;await process_frame
	assert(app.active_level==null and app.hub.visible)
	app.free()
	await process_frame
	await create_timer(0.15).timeout
	print("Busboy validation passed: native authoring, full collision route, dialogue, turn/stain/guard costs, defeat/retry/retreat, victory/gate/shrine and return")
	quit()
