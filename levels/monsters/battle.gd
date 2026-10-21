class_name MonsterBattle
extends RefCounted

const POSITIONS: Array[Vector2] = [Vector2(360,260),Vector2(190,400),Vector2(410,520),Vector2(900,260),Vector2(1110,390),Vector2(900,550)]
var game: Node
var actors: Array[Dictionary] = []
var reserves: Array[MonsterState] = []
var current: Dictionary = {}
var mode: String = ""
var index: int = 0
var chosen_attack: String = ""
var target_side: int = 1
var delay: float = 0
var target: Dictionary = {}
var biome: String = "forest"
var trainer: String = ""
var finished: bool = false
var lost: bool = false
var effects: Array[Dictionary] = []
var message: String = ""
var message_left: float = 0


func _init(level: Node,opponents: Array[MonsterState],background: String,trainer_id: String = "") -> void:
	game = level
	biome = background
	trainer = trainer_id
	for i: int in range(mini(3,game.party.size())):
		actors.append(actor(game.party[i],0,i,i))
	for i: int in range(opponents.size()):
		if i < 3:
			actors.append(actor(opponents[i],1,i,i))
		else:
			reserves.append(opponents[i])


func actor(monster: MonsterState,side: int,slot: int,roster_index: int) -> Dictionary:
	return {"monster":monster,"side":side,"slot":slot,"index":roster_index,"frame":0.0,"state":"idle","dying":0.0,"capture":false,"marked":false}


func team(side: int) -> Array[Dictionary]:
	return actors.filter(func(item: Dictionary) -> bool: return item.side == side and not item.marked)


func bench() -> Array[int]:
	var result: Array[int] = []
	for i: int in range(game.party.size()):
		var active: bool = false
		for item: Dictionary in actors:
			if item.side == 0 and item.monster == game.party[i]:
				active = true
		if not active and game.party[i].health > 0:
			result.append(i)
	return result


func resume() -> void:
	mode = ""
	current = {}
	chosen_attack = ""
	index = 0


func tick(delta: float) -> void:
	if finished:
		return
	message_left = maxf(0,message_left-delta)
	for item: Dictionary in actors.duplicate():
		item.monster.limit_stats()
		item.frame += 6*delta
		if item.marked:
			item.dying -= delta
			if item.dying <= 0:
				var replacement: MonsterState
				var roster: int = item.index
				if not item.capture:
					if item.side == 1 and not reserves.is_empty():
						replacement = reserves.pop_front()
					elif item.side == 0:
						var available: Array[int] = bench()
						if not available.is_empty():
							roster = available[0]
							replacement = game.party[roster]
				actors.erase(item)
				if replacement != null:
					actors.append(actor(replacement,item.side,item.slot,roster))
	for effect: Dictionary in effects:
		effect.time -= delta
	effects = effects.filter(func(effect: Dictionary) -> bool: return effect.time > 0)
	if team(1).is_empty() and not actors.any(func(item: Dictionary) -> bool: return item.side == 1):
		finished = true
		game.finish_battle(trainer)
		return
	if team(0).is_empty() and not actors.any(func(item: Dictionary) -> bool: return item.side == 0):
		finished = true
		lost = true
		message = "Your party was defeated. Escape returns to Matrix."
		return
	if mode == "enemy":
		delay -= delta
		if delay <= 0:
			var abilities: Array[String] = current.monster.abilities()
			if abilities.is_empty():
				resume()
			else:
				var ability: String = abilities.pick_random()
				var side: int = current.side if game.data.ATTACK_DATA[ability].target == "player" else 1-int(current.side)
				var targets: Array[Dictionary] = team(side)
				if not targets.is_empty():
					start_attack(ability,targets.pick_random())
	elif mode == "animating":
		delay -= delta
		if delay <= 0:
			apply_attack(current,target,chosen_attack)
			current.state = "idle"
			resume()
	elif mode.is_empty():
		for item: Dictionary in actors:
			if item.marked:
				continue
			item.monster.initiative += item.monster.stat("speed")*delta
			if item.monster.initiative >= 100:
				current = item
				item.monster.initiative = 0
				item.monster.defending = false
				mode = "general" if item.side == 0 else "enemy"
				delay = 0.6
				index = 0
				break


func choices() -> Array:
	if current.is_empty():
		return []
	match mode:
		"general": return ["Fight","Defend","Switch","Catch"]
		"attacks": return current.monster.abilities(false)
		"switch": return bench()
		"target": return team(target_side)
	return []


func input_key(key: Key) -> void:
	if finished or mode in ["enemy","animating",""]:
		return
	if key == KEY_ESCAPE and mode != "general":
		mode = "general"
		index = 0
		chosen_attack = ""
		return
	var options: Array = choices()
	if key in [KEY_DOWN,KEY_UP] and not options.is_empty():
		index = posmod(index+(1 if key == KEY_DOWN else -1),options.size())
	if key != KEY_SPACE or options.is_empty():
		return
	if mode == "general":
		match index:
			0: mode = "attacks"
			1:
				current.monster.defending = true
				resume()
			2: mode = "switch"
			3:
				mode = "target"
				target_side = 1
				chosen_attack = ""
		index = 0
		if choices().is_empty():
			message = "No available choices. Escape goes back."
			message_left = 2
	elif mode == "attacks":
		chosen_attack = options[index]
		target_side = 0 if game.data.ATTACK_DATA[chosen_attack].target == "player" else 1
		mode = "target"
		index = 0
	elif mode == "switch":
		var roster: int = options[index]
		var old: Dictionary = current
		actors.erase(old)
		actors.append(actor(game.party[roster],0,old.slot,roster))
		resume()
	elif mode == "target":
		var selected: Dictionary = options[index]
		if not chosen_attack.is_empty():
			start_attack(chosen_attack,selected)
		elif selected.monster.health < selected.monster.stat("max_health")*0.9:
			game.party.append(selected.monster)
			selected.capture = true
			selected.marked = true
			selected.dying = 0.6
			resume()
		else:
			message = "Capture failed: weaken the monster below 90% health."
			message_left = 1


func start_attack(ability: String,selected: Dictionary) -> void:
	chosen_attack = ability
	target = selected
	current.monster.energy -= game.data.ATTACK_DATA[ability].cost
	current.state = "attack"
	current.frame = 0.0
	delay = 4.0/6.0
	mode = "animating"


func damage_amount(attacker: MonsterState,victim: MonsterState,ability: String) -> float:
	var attack: Dictionary = game.data.ATTACK_DATA[ability]
	var amount: float = attacker.stat("attack")*float(attack.amount)
	var strong: Dictionary = {"fire":"plant","water":"fire","plant":"water"}
	var weak: Dictionary = {"fire":"water","water":"plant","plant":"fire"}
	if strong.get(attack.element,"") == victim.element():
		amount *= 2
	elif weak.get(attack.element,"") == victim.element():
		amount *= 0.5
	return amount*clampf(1-victim.stat("defense")/2000-(0.2 if victim.defending else 0),0,1)


func apply_attack(attacker: Dictionary,victim: Dictionary,ability: String) -> void:
	victim.monster.health -= damage_amount(attacker.monster,victim.monster,ability)
	victim.monster.limit_stats()
	var animation: String = game.data.ATTACK_DATA[ability].animation
	effects.append({"animation":animation,"position":POSITIONS[victim.side*3+victim.slot],"time":4.0/6.0})
	game.sound(animation)
	for item: Dictionary in actors:
		if item.monster.health <= 0 and not item.marked:
			item.marked = true
			item.dying = 0.6
			if item.side == 1:
				var allies: Array = actors.filter(func(member: Dictionary) -> bool: return member.side == 0)
				for ally: Dictionary in allies:
					ally.monster.update_xp(item.monster.level*100.0/maxi(1,allies.size()))
