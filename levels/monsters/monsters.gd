class_name MonstersLevel
extends MatrixLevel

const FIELD_SIZE: Vector2 = Vector2(1280,720)
var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://levels/monsters/assets/manifest.json"))
var cache: Dictionary = {}
var party: Array[MonsterState] = []
var battle: MonsterBattle
var world: Dictionary
var map_name: String = "world"
var player_position: Vector2 = Vector2.ZERO
var player_direction: Vector2 = Vector2.ZERO
var facing: String = "down"
var age: float = 0
var npcs: Array[Dictionary] = []
var obstacles: Array[Dictionary] = []
var noticed: bool = false
var dialogue_active: bool = false
var dialogue_lines: Array = []
var dialogue_index: int = 0
var dialogue_npc: int = -1
var dialogue_wait: float = 0
var index_open: bool = false
var party_index: int = 0
var swap_index: int = -1
var encounter_left: float = 0
var encounter_duration: float = 2.0
var tint: float = 0
var tint_direction: int = 0
var pending: Dictionary = {}
var evolution_queue: Array[Dictionary] = []
var evolution_elapsed: float = 0


func trainer_data(id: String) -> Dictionary:
	if data.TRAINER_DATA.has(id):
		return data.TRAINER_DATA[id]
	# The unused source arena references undefined trainers; do not invent teams.
	return {"missing":true,"defeated":false,"directions":["down"],"look_around":false,
		"dialog":{"default":["This trainer is unavailable in the original prototype."]}}


func new_monster(name: String,level: int) -> MonsterState:
	return MonsterState.new(name,level,data.MONSTER_DATA,data.ATTACK_DATA)


func image(path: String) -> Texture2D:
	var key: String = "image:"+path
	if not cache.has(key):
		cache[key] = load(path if path.begins_with("res://") else "res://levels/monsters/assets/graphics/"+path)
	return cache[key]


func tile(id: int) -> Texture2D:
	var key: String = "tile:"+str(id)
	if not cache.has(key):
		var entry: Dictionary = data.images[id]
		var atlas: AtlasTexture = AtlasTexture.new()
		atlas.atlas = image(entry.atlas)
		atlas.region = Rect2(entry.rect[0],entry.rect[1],entry.rect[2],entry.rect[3])
		cache[key] = atlas
	return cache[key]


func sprite(sheet: String,state: String,time: float) -> Texture2D:
	var ids: Array = data.sheets[sheet][state]
	return tile(int(ids[int(time*6)%ids.size()]))


func frames(folder: String) -> Array:
	if not cache.has(folder):
		var result: Array = []
		for path: String in data.frames[folder]:
			result.append(image(path))
		cache[folder] = result
	return cache[folder]


func sound(name: String) -> void:
	var key: String = "sound:"+name
	if not cache.has(key):
		var audio: AudioStreamPlayer = AudioStreamPlayer.new()
		audio.stream = load(data.audio[name])
		audio.max_polyphony = 8
		add_child(audio)
		cache[key] = audio
	cache[key].play()


func music(name: String,loop: bool = true) -> void:
	$Music.stop()
	var stream: AudioStream = load(data.audio[name]).duplicate()
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if loop else AudioStreamWAV.LOOP_DISABLED
		stream.loop_end = int(stream.get_length()*stream.mix_rate)
	elif stream is AudioStreamOggVorbis or stream is AudioStreamMP3:
		stream.loop = loop
	$Music.stream = stream
	$Music.play()


func _ready() -> void:
	for spec: Array in [["Ivieron",32],["Atrox",15],["Cindrill",16],["Atrox",10],["Sparchu",11],["Gulfin",9],["Jacana",10]]:
		var monster: MonsterState = new_monster(spec[0],spec[1])
		monster.xp = randi_range(0,monster.level*100)
		party.append(monster)
	setup_map("world","house")
	music("overworld")
	resized.connect(fit_field)
	fit_field()


func _exit_tree() -> void:
	for child: Node in get_children():
		if child is AudioStreamPlayer:
			child.stop()
	battle = null


func fit_field() -> void:
	var factor: float = minf(size.x/1280,size.y/720)
	$Field.position = (size-FIELD_SIZE*factor)/2
	$Field.scale = Vector2.ONE*factor
	queue_redraw()


func entity_box(position: Vector2,graphic: String = "player") -> Rect2:
	var extent: Vector2 = sprite("characters/"+graphic,"down_idle",0).get_size()
	var dimensions: Vector2 = Vector2(extent.x/2,extent.y-60)
	return Rect2(position-dimensions/2,dimensions)


func setup_map(name: String,spawn: String) -> void:
	map_name = name
	world = data.maps[name]
	npcs.clear()
	obstacles.clear()
	noticed = false
	player_direction = Vector2.ZERO
	age = 0
	encounter_left = 0
	var found: bool = false
	for obj: Dictionary in world.groups.get("Objects",[]):
		if obj.name != "top" and obj.image >= 0:
			var extent: Vector2 = tile(int(obj.image)).get_size()
			var rect: Rect2 = Rect2(Vector2(obj.position[0],obj.position[1]),extent)
			obstacles.append({"rect":rect,"box":Rect2(rect.position+Vector2(0,extent.y*0.3),Vector2(extent.x,extent.y*0.4))})
	for obj: Dictionary in world.groups.get("Collisions",[]):
		var rect: Rect2 = Rect2(obj.position[0],obj.position[1],obj.size[0],obj.size[1])
		obstacles.append({"rect":rect,"box":rect})
	for obj: Dictionary in world.groups.get("Entities",[]):
		var properties: Dictionary = obj.properties
		if obj.name == "Player":
			if properties.pos == spawn:
				player_position = Vector2(obj.position[0],obj.position[1])
				facing = properties.direction
				found = true
		else:
			npcs.append({"id":properties.character_id,"graphic":properties.graphic,"position":Vector2(obj.position[0],obj.position[1]),"facing":properties.get("direction",trainer_data(properties.character_id).get("direction","down")),"radius":float(properties.get("radius",trainer_data(properties.character_id).get("radius",0))),"direction":Vector2.ZERO,"look":1.5,"notice":-1.0,"noticed":false,"moved":false,"rotate":not trainer_data(properties.character_id).get("missing",false)})
	assert(found,"Missing map spawn: "+name+"/"+spawn)


func connected(origin: Vector2,direction: String,destination: Vector2,radius: float) -> bool:
	var relation: Vector2 = destination-origin
	if relation.length() >= radius:
		return false
	return (direction == "left" and relation.x < 0 and absf(relation.y) < 30
		or direction == "right" and relation.x > 0 and absf(relation.y) < 30
		or direction == "up" and relation.y < 0 and absf(relation.x) < 30
		or direction == "down" and relation.y > 0 and absf(relation.x) < 30)


func face_toward(origin: Vector2,destination: Vector2) -> String:
	var relation: Vector2 = destination-origin
	return ("right" if relation.x > 0 else "left") if absf(relation.y) < 30 else ("down" if relation.y > 0 else "up")


func rect_blocks(rect: Rect2,start: Vector2,end: Vector2) -> bool:
	if rect.has_point(start) or rect.has_point(end):
		return true
	var points: Array[Vector2] = [rect.position,rect.position+Vector2(rect.size.x,0),rect.end,rect.position+Vector2(0,rect.size.y)]
	for i: int in range(4):
		if Geometry2D.segment_intersects_segment(start,end,points[i],points[(i+1)%4]) != null:
			return true
	return false


func line_blocked(start: Vector2,end: Vector2,ignore_npc: int) -> bool:
	for item: Dictionary in obstacles:
		if rect_blocks(item.rect,start,end):
			return true
	for i: int in range(npcs.size()):
		if i != ignore_npc:
			var npc: Dictionary = npcs[i]
			var extent: Vector2 = sprite("characters/"+npc.graphic,"down_idle",0).get_size()
			if rect_blocks(Rect2(npc.position-extent/2,extent),start,end):
				return true
	return false


func blocked() -> bool:
	return dialogue_active or index_open or battle != null or tint_direction != 0 or noticed or not evolution_queue.is_empty()


func move_player(delta: float) -> void:
	player_direction = Vector2(
		float(Input.is_physical_key_pressed(KEY_RIGHT))-float(Input.is_physical_key_pressed(KEY_LEFT)),
		float(Input.is_physical_key_pressed(KEY_DOWN))-float(Input.is_physical_key_pressed(KEY_UP))).normalized()
	if player_direction.x != 0:
		facing = "right" if player_direction.x > 0 else "left"
	if player_direction.y != 0:
		facing = "down" if player_direction.y > 0 else "up"
	for axis: int in range(2):
		player_position[axis] += player_direction[axis]*250*delta
		var box: Rect2 = entity_box(player_position)
		var colliders: Array[Rect2] = []
		for item: Dictionary in obstacles:
			colliders.append(item.box)
		for npc: Dictionary in npcs:
			colliders.append(entity_box(npc.position,npc.graphic))
		for collider: Rect2 in colliders:
			if box.intersects(collider):
				if player_direction[axis] > 0:
					player_position[axis] = collider.position[axis]-box.size[axis]/2
				elif player_direction[axis] < 0:
					player_position[axis] = collider.end[axis]+box.size[axis]/2
				box = entity_box(player_position)


func update_npcs(delta: float) -> void:
	for i: int in range(npcs.size()):
		var npc: Dictionary = npcs[i]
		var trainer: Dictionary = trainer_data(npc.id)
		npc.look -= delta
		if npc.look <= 0:
			npc.look = 1.5
			if npc.rotate:
				npc.facing = trainer.directions.pick_random()
		if not trainer.look_around or dialogue_active or index_open:
			continue
		if not npc.noticed and not npc.moved and connected(npc.position,npc.facing,player_position,npc.radius) and not line_blocked(npc.position,player_position,i):
			npc.noticed = true
			npc.notice = 0.5
			npc.rotate = false
			noticed = true
			facing = face_toward(player_position,npc.position)
			player_direction = Vector2.ZERO
			sound("notice")
		if npc.notice >= 0:
			npc.notice -= delta
			if npc.notice <= 0:
				npc.notice = -1
				var direction: Vector2 = (player_position-npc.position).normalized()
				npc.direction = Vector2(roundf(direction.x),roundf(direction.y))
		if not npc.direction.is_zero_approx() and not npc.moved:
			if entity_box(npc.position,npc.graphic).grow(5).intersects(entity_box(player_position)):
				npc.direction = Vector2.ZERO
				npc.moved = true
				noticed = false
				start_dialogue(i)
			else:
				npc.position += npc.direction*250*delta
				npc.facing = face_toward(npc.position,player_position)


func start_dialogue(npc_index: int) -> void:
	dialogue_npc = npc_index
	var npc: Dictionary = npcs[npc_index]
	var trainer: Dictionary = trainer_data(npc.id)
	dialogue_lines = trainer.dialog["defeated" if trainer.defeated else "default"]
	dialogue_index = 0
	dialogue_wait = 0.5
	dialogue_active = true
	npc.rotate = false
	npc.facing = face_toward(npc.position,player_position)
	player_direction = Vector2.ZERO


func advance_dialogue() -> void:
	if dialogue_wait > 0:
		return
	dialogue_index += 1
	dialogue_wait = 0.5
	if dialogue_index < dialogue_lines.size():
		return
	dialogue_active = false
	var npc: Dictionary = npcs[dialogue_npc]
	var trainer: Dictionary = trainer_data(npc.id)
	if trainer.get("missing",false):
		return
	if npc.id == "Nurse":
		for monster: MonsterState in party:
			monster.health = monster.stat("max_health")
			monster.energy = monster.stat("max_energy")
	elif not trainer.defeated:
		var opponents: Array[MonsterState] = []
		for key: String in trainer.monsters:
			var spec: Array = trainer.monsters[key]
			opponents.append(new_monster(spec[0],int(spec[1])))
		queue_battle(opponents,trainer.biome,npc.id)
	else:
		check_evolution()


func queue_battle(opponents: Array[MonsterState],biome: String,trainer: String = "") -> void:
	pending = {"kind":"battle","opponents":opponents,"biome":biome,"trainer":trainer}
	tint_direction = 1
	player_direction = Vector2.ZERO
	music("battle")


func finish_battle(trainer: String) -> void:
	for monster: MonsterState in party:
		monster.initiative = 0
	$Music.stop()
	pending = {"kind":"victory","trainer":trainer}
	tint_direction = 1


func check_evolution() -> void:
	for i: int in range(party.size()):
		var evolution: Variant = data.MONSTER_DATA[party[i].name].evolve
		if evolution != null and party[i].level == int(evolution[1]):
			evolution_queue.append({"from":party[i].name,"to":evolution[0]})
			party[i] = new_monster(evolution[0],party[i].level)
	evolution_elapsed = 0
	if evolution_queue.is_empty():
		music("overworld")
	else:
		music("evolution",false)


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var key: Key = event.keycode
	if battle != null:
		if key == KEY_ESCAPE and battle.mode not in ["attacks","switch","target"]:
			return_requested.emit()
		else:
			battle.input_key(key)
	elif not evolution_queue.is_empty():
		if key == KEY_ESCAPE:
			return_requested.emit()
	elif index_open:
		if key in [KEY_ENTER,KEY_ESCAPE]:
			index_open = false
		elif key in [KEY_DOWN,KEY_UP]:
			party_index = posmod(party_index+(1 if key == KEY_DOWN else -1),party.size())
		elif key == KEY_SPACE:
			if swap_index < 0:
				swap_index = party_index
			else:
				var selected: MonsterState = party[swap_index]
				party[swap_index] = party[party_index]
				party[party_index] = selected
				swap_index = -1
	elif dialogue_active:
		if key == KEY_SPACE:
			advance_dialogue()
		elif key == KEY_ESCAPE:
			return_requested.emit()
	elif key == KEY_ENTER and tint_direction == 0:
		index_open = true
		player_direction = Vector2.ZERO
	elif key == KEY_SPACE and not blocked():
		for i: int in range(npcs.size()):
			if connected(player_position,facing,npcs[i].position,100):
				start_dialogue(i)
				break
	elif key == KEY_ESCAPE:
		return_requested.emit()
	get_viewport().set_input_as_handled()


func _physics_process(delta: float) -> void:
	age += delta
	dialogue_wait = maxf(0,dialogue_wait-delta)
	if tint_direction != 0:
		tint = clampf(tint+tint_direction*(600.0/255)*delta,0,1)
		if tint >= 1 and tint_direction > 0:
			if pending.kind == "map":
				setup_map(pending.map,pending.spawn)
			elif pending.kind == "battle":
				battle = MonsterBattle.new(self,pending.opponents,pending.biome,pending.trainer)
			elif pending.kind == "victory":
				battle = null
				if not pending.trainer.is_empty():
					data.TRAINER_DATA[pending.trainer].defeated = true
					for i: int in range(npcs.size()):
						if npcs[i].id == pending.trainer:
							start_dialogue(i)
				else:
					check_evolution()
			pending = {}
			tint_direction = -1
		elif tint <= 0:
			tint_direction = 0
	if battle != null:
		var active: MonsterBattle = battle
		active.tick(delta)
	elif not evolution_queue.is_empty():
		evolution_elapsed += delta
		if evolution_elapsed >= 5.8:
			evolution_queue.pop_front()
			evolution_elapsed = 0
			if evolution_queue.is_empty():
				music("overworld")
	else:
		if not blocked():
			move_player(delta)
		update_npcs(delta)
		if not blocked():
			for transition: Dictionary in world.groups.get("Transition",[]):
				if entity_box(player_position).intersects(Rect2(transition.position[0],transition.position[1],transition.size[0],transition.size[1])):
					pending = {"kind":"map","map":transition.properties.target,"spawn":transition.properties.pos}
					tint_direction = 1
					break
			if tint_direction == 0:
				check_encounter(delta)
	$Field/Canvas.queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Color.BLACK)


func check_encounter(delta: float) -> void:
	var patch: Dictionary = {}
	for item: Dictionary in world.groups.get("Monsters",[]):
		if item.image >= 0 and Rect2(Vector2(item.position[0],item.position[1]),tile(int(item.image)).get_size()).intersects(entity_box(player_position)):
			patch = item
			break
	if encounter_left > 0:
		encounter_left -= delta
		if encounter_left <= 0 and not patch.is_empty() and not player_direction.is_zero_approx():
			var opponents: Array[MonsterState] = []
			for name: String in patch.properties.monsters.split(","):
				opponents.append(new_monster(name,int(patch.properties.level)+randi_range(-3,3)))
			encounter_duration = randf_range(0.8,2.5)
			queue_battle(opponents,patch.properties.biome)
	elif not patch.is_empty() and not player_direction.is_zero_approx():
		encounter_left = encounter_duration
