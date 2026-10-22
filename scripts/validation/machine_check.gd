extends SceneTree
## Complete native portal progression and deterministic boss timing/state checks.

func _initialize() -> void:
	root.set_meta("matrix_test_mode",true)
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

func portal(level: MachineLevel,target: String) -> void:
	for entry: Dictionary in level.room.portals():
		if entry.target == target:
			level.player.position = entry.rect.get_center()
			key(KEY_E)
			return
	assert(false,"No native portal to "+target)

func capture(level: MachineLevel,label: String) -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() != 1: return
	level.update_camera()
	level.overlay.queue_redraw()
	if level.room_name == "outskirts": (level.room.get_child(level.room.get_child_count()-1) as CanvasItem).queue_redraw()
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(args[0]+"-"+label+".png") == OK)

func run() -> void:
	assert(LevelRegistry.lookup(" machine ").name == "Machine")
	var app: MatrixApp = load("res://app/main.tscn").instantiate() as MatrixApp
	root.add_child(app)
	app.launch_level("MACHINE")
	await process_frame
	await process_frame
	var level: MachineLevel = app.active_level as MachineLevel
	assert(level != null and level.room_name == "bedroom")
	level.set_physics_process(false)
	# All seven scenes and every portal destination are valid, native and persistent.
	for title: String in MachineLevel.ROOMS:
		var room: MachineRoom = (MachineLevel.ROOMS[title] as PackedScene).instantiate() as MachineRoom
		var ground: TileMapLayer = room.get_node("Ground") as TileMapLayer
		assert(ground.tile_set.resource_path == "res://levels/machine/maps/town.tres")
		for entry: Dictionary in room.portals():
			assert(MachineLevel.ROOMS.has(entry.target))
			var destination: MachineRoom = (MachineLevel.ROOMS[entry.target] as PackedScene).instantiate() as MachineRoom
			assert(Rect2(Vector2.ZERO,destination.bounds).has_point(entry.arrival))
			for wall: Rect2 in destination.collision_rects:
				assert(not Rect2(entry.arrival-Vector2(8,8),Vector2(16,16)).intersects(wall),"Portal arrival intersects collision: "+title+" -> "+str(entry.target))
			destination.free()
		var cell: Vector2i = ground.get_used_cells()[0]
		ground.erase_cell(cell)
		room.get_node("PlayerSpawn").position += Vector2(5,7)
		var packed: PackedScene = PackedScene.new()
		assert(packed.pack(room) == OK)
		var path: String = "user://machine-room-check.tscn"
		assert(ResourceSaver.save(packed,path) == OK)
		var saved: MachineRoom = (ResourceLoader.load(path,"PackedScene",ResourceLoader.CACHE_MODE_IGNORE) as PackedScene).instantiate() as MachineRoom
		assert(saved.player_spawn == room.player_spawn and saved.portals() == room.portals())
		assert((saved.get_node("Ground") as TileMapLayer).get_cell_source_id(cell) == -1)
		saved.free()
		room.free()
		DirAccess.remove_absolute(path)
	await capture(level,"bedroom")
	portal(level,"home")
	assert(level.room_name == "home")
	portal(level,"town")
	assert(level.room_name == "town")
	portal(level,"outskirts")
	assert(level.room_name == "town" and level.relays.is_empty(),"East gate needs all three relays")
	await capture(level,"town")
	for target: String in ["workshop","library","cafe"]:
		portal(level,target)
		assert(level.room_name == target)
		level.player.position = level.room.npcs()[0].position+Vector2(24,16)
		key(KEY_E)
		assert(not level.dialogue.is_empty())
		var count: int = level.relays.size()
		key(KEY_ESCAPE)
		assert(level.dialogue.is_empty() and app.active_level == level)
		key(KEY_E)
		assert(level.relays.size() == count,"Each NPC gives a relay only once")
		key(KEY_ENTER)
		portal(level,"town")
	assert(level.relays.size() == 3)
	portal(level,"outskirts")
	assert(level.room_name == "outskirts")
	level.player.position = Vector2(640,272)
	key(KEY_E)
	assert(level.boss_phase == MachineLevel.BossPhase.WINDUP)
	var hp: int = level.boss_health
	key(KEY_SPACE)
	assert(level.boss_health == hp,"Boss only accepts sparks during recovery")
	# Dodge a marked location, then land a spark in the recovery window.
	level.player.position = Vector2(752,272)
	level.update_boss(1.2)
	assert(level.health == 5 and level.boss_phase == MachineLevel.BossPhase.RECOVER)
	key(KEY_SPACE)
	assert(level.boss_health == hp-1)
	key(KEY_SPACE)
	assert(level.boss_health == hp-1,"Spark cooldown prevents key spam")
	# Timed brace blocks a pulse, then a defeat safely preserves the three relays.
	level.update_boss(1.3)
	key(KEY_SHIFT)
	level.update_boss(1.1)
	assert(level.health == 5)
	level.health = 1
	level.guard_left = 0
	level.update_boss(1.3)
	level.update_boss(1.1)
	assert(level.room_name == "town" and level.health == 5 and level.relays.size() == 3)
	portal(level,"outskirts")
	level.player.position = Vector2(640,272)
	key(KEY_E)
	await capture(level,"boss")
	for i: int in range(6):
		level.player.position = Vector2(752,272)
		if level.boss_phase == MachineLevel.BossPhase.WINDUP:
			level.strike_target = Vector2(600,200)
			level.update_boss(1.2)
		level.attack_wait = 0
		key(KEY_SPACE)
		if not level.complete: level.update_boss(1.3)
	assert(level.complete and level.boss_health == 0 and not level.dialogue.is_empty())
	key(KEY_ESCAPE)
	portal(level,"town")
	var rotation: float = level.room.get_node("ClockHand").rotation
	level._physics_process(0.1)
	assert(level.room.get_node("ClockHand").rotation != rotation,"Town clock restarts after victory")
	assert(level.visited.size() == 7)
	key(KEY_ESCAPE)
	await process_frame
	await process_frame
	assert(app.active_level == null and app.hub.visible)
	app.free()
	await process_frame
	await create_timer(0.15).timeout
	print("Machine validation passed: seven rooms, NPC relays, gated boss, dodge/brace/retry and return")
	quit()
