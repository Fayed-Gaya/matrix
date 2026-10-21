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


func run() -> void:
	var app: MatrixApp = load("res://app/main.tscn").instantiate()
	root.add_child(app)
	app.launch_level("MONSTERS")
	await process_frame
	await process_frame
	var game: MonstersLevel = app.active_level as MonstersLevel
	assert(game != null and game.party.size() == 7 and game.map_name == "world")
	game.set_physics_process(false)
	assert(game.player_position.distance_to(Vector2(4223.94,3661.26)) < 0.01)
	assert(game.data.maps.size() == 8 and game.data.images.size() == 792)
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() == 1:
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(args[0]+"-world.png") == OK)
	key(KEY_ENTER)
	assert(game.index_open)
	key(KEY_SPACE)
	key(KEY_DOWN)
	var original: MonsterState = game.party[0]
	key(KEY_SPACE)
	assert(game.party[1] == original)
	game.get_node("Field/Canvas").queue_redraw()
	if args.size() == 1:
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(args[0]+"-index.png") == OK)
	key(KEY_ENTER)
	assert(not game.index_open)
	# Load every declared spawn and validate every inter-map target.
	for map: String in game.data.maps:
		for entity: Dictionary in game.data.maps[map].groups.Entities:
			if entity.name == "Player":
				game.setup_map(map,entity.properties.pos)
		for transition: Dictionary in game.data.maps[map].groups.Transition:
			var destination: Dictionary = game.data.maps[transition.properties.target]
			assert(destination.groups.Entities.any(func(entity: Dictionary) -> bool: return entity.name == "Player" and entity.properties.pos == transition.properties.pos))
	game.setup_map("house","world")
	var exit: Dictionary = game.world.groups.Transition[0]
	game.player_position = Vector2(exit.position[0]+exit.size[0]/2,exit.position[1]+exit.size[1]/2)
	for i: int in range(80):
		game._physics_process(1.0/60)
	assert(game.map_name == exit.properties.target and game.tint_direction == 0)
	game.setup_map("world","house")
	var trainer: Dictionary = game.npcs[0].duplicate()
	assert(game.data.TRAINER_DATA[trainer.id].look_around)
	trainer.position = Vector2(500,500)
	trainer.facing = "down"
	trainer.radius = 400
	game.npcs = [trainer]
	game.player_position = Vector2(500,700)
	game.obstacles = [{"rect":Rect2(450,550,100,100),"box":Rect2(450,550,100,100)}]
	game.update_npcs(0.01)
	assert(not game.noticed)
	game.obstacles.clear()
	game.update_npcs(0.01)
	assert(game.noticed and game.blocked())
	for i: int in range(90):
		game.update_npcs(1.0/60)
	assert(game.dialogue_active and not game.noticed)
	game.dialogue_active = false
	game.setup_map("world","house")
	var patch: Dictionary = game.world.groups.Monsters[0]
	game.player_position = Vector2(patch.position[0],patch.position[1])+game.tile(int(patch.image)).get_size()/2
	game.player_direction = Vector2.RIGHT
	game.encounter_duration = 2
	game.check_encounter(0)
	assert(game.encounter_left == 2)
	game.check_encounter(2.1)
	assert(game.pending.kind == "battle" and not game.pending.opponents.is_empty())
	game.pending = {}
	game.tint_direction = 0
	game.setup_map("hospital","world")
	var nurse_index: int = -1
	for i: int in range(game.npcs.size()):
		if game.npcs[i].id == "Nurse":
			nurse_index = i
	assert(nurse_index >= 0)
	game.party[0].health = 1
	game.party[0].energy = 0
	game.start_dialogue(nurse_index)
	while game.dialogue_active:
		game.dialogue_wait = 0
		game.advance_dialogue()
	assert(game.party[0].health == game.party[0].stat("max_health") and game.party[0].energy == game.party[0].stat("max_energy"))
	# Source stat, ability/cost, XP and element/defense formulas.
	var attacker: MonsterState = game.new_monster("Cindrill",16)
	var victim: MonsterState = game.new_monster("Plumette",14)
	var opponents: Array[MonsterState] = [victim]
	var battle: MonsterBattle = MonsterBattle.new(game,opponents,"forest")
	var expected: float = attacker.stat("attack")*float(game.data.ATTACK_DATA.fire.amount)*2*(1-victim.stat("defense")/2000)
	assert(is_equal_approx(battle.damage_amount(attacker,victim,"fire"),expected))
	victim.defending = true
	assert(battle.damage_amount(attacker,victim,"fire") < expected)
	var ability: String = attacker.abilities()[0]
	attacker.energy = game.data.ATTACK_DATA[ability].cost
	assert(not attacker.abilities(false).has(ability))
	attacker.xp = attacker.level_up-1
	attacker.update_xp(10)
	assert(attacker.level == 17 and attacker.xp == 9)
	# Initiative, defending, target/attack state, capture threshold, bench switching.
	battle.actors[0].monster.initiative = 100
	battle.tick(0.001)
	assert(battle.mode == "general")
	battle.index = 1
	battle.input_key(KEY_SPACE)
	assert(battle.actors[0].monster.defending and battle.mode.is_empty())
	battle.current = battle.actors[0]
	battle.mode = "general"
	battle.index = 2
	battle.input_key(KEY_SPACE)
	assert(battle.mode == "switch" and not battle.bench().is_empty())
	var next: int = battle.bench()[0]
	battle.input_key(KEY_SPACE)
	assert(battle.actors.any(func(actor: Dictionary) -> bool: return actor.side == 0 and actor.monster == game.party[next]))
	battle.current = battle.team(0)[0]
	battle.mode = "general"
	battle.index = 3
	battle.input_key(KEY_SPACE)
	assert(battle.mode == "target")
	var count: int = game.party.size()
	battle.input_key(KEY_SPACE)
	assert(game.party.size() == count and battle.message_left > 0)
	victim.health = victim.stat("max_health")*0.5
	battle.input_key(KEY_SPACE)
	assert(game.party.size() == count+1)
	# Death/replacement and XP follow a separate battle to avoid captured aliases.
	opponents = [game.new_monster("Plumette",1),game.new_monster("Atrox",1),game.new_monster("Pouch",1),game.new_monster("Draem",1)]
	battle = MonsterBattle.new(game,opponents,"forest")
	var current: Dictionary = battle.team(0)[0]
	var target: Dictionary = battle.team(1)[0]
	target.monster.health = 1
	var old_xp: float = current.monster.xp
	battle.apply_attack(current,target,"scratch")
	assert(target.marked and current.monster.xp != old_xp)
	battle.tick(0.61)
	assert(battle.team(1).size() == 3 and battle.reserves.is_empty())
	game.setup_map("world","house")
	game.battle = battle
	game.get_node("Field/Canvas").queue_redraw()
	if args.size() == 1:
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(args[0]+"-battle.png") == OK)
	game.battle = null
	var evolve: MonsterState = game.new_monster("Ivieron",32)
	game.party = [evolve]
	game.finish_battle("")
	for i: int in range(30):
		game._physics_process(1.0/60)
	assert(game.party[0].name == "Pluma" and game.evolution_queue.size() == 1)
	game.evolution_elapsed = 4.1
	game.tint = 0
	game.get_node("Field/Canvas").queue_redraw()
	if args.size() == 1:
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(args[0]+"-evolution.png") == OK)
	game.evolution_queue.clear()
	key(KEY_ESCAPE)
	await process_frame
	await process_frame
	assert(app.active_level == null and app.hub.visible)
	app.free()
	battle = null
	await create_timer(0.15).timeout
	print("Monsters validation passed")
	quit()
