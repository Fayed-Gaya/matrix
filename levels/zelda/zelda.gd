class_name ZeldaLevel
extends MatrixLevel

const FIELD_SIZE: Vector2 = Vector2(1280,720)
const ATTRIBUTES: Array[String] = ["health","energy","attack","magic","speed"]
const WEAPONS: Array[String] = ["sword","lance","axe","rapier","sai"]
const SPELLS: Array[String] = ["flame","heal"]
var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://levels/zelda/assets/manifest.json"))
var cache: Dictionary = {}
var objects: Array[Dictionary] = []
var enemies: Array[Dictionary] = []
var particles: Array[Dictionary] = []
var buckets: Dictionary = {}
var stats: Dictionary = {"health":100.0,"energy":60.0,"attack":10.0,"magic":4.0,"speed":5.0}
var maximum: Dictionary = {"health":300.0,"energy":140.0,"attack":20.0,"magic":10.0,"speed":10.0}
var costs: Dictionary = {"health":100.0,"energy":100.0,"attack":100.0,"magic":100.0,"speed":100.0}
var health: float = 50
var energy: float = 48
var experience: float = 5000
var player: Rect2 = Rect2()
var facing: String = "down"
var moving: bool = false
var frame: float = 0
var weapon_index: int = 0
var magic_index: int = 0
var weapon_switch: float = 0
var magic_switch: float = 0
var attack_left: float = 0
var hurt_left: float = 0
var weapon_rect: Rect2 = Rect2()
var weapon_texture: Texture2D
var paused: bool = false
var menu_index: int = 0
var menu_wait: float = 0


func frames(folder: String) -> Array:
	if not cache.has(folder):
		var result: Array = []
		for path: String in data.frames[folder]:
			result.append(load(path))
		cache[folder] = result
	return cache[folder]


func image(path: String) -> Texture2D:
	var key: String = "image:"+path
	if not cache.has(key):
		cache[key] = load("res://levels/zelda/assets/graphics/"+path)
	return cache[key]


func sound(path: String, volume: float = 0.6) -> void:
	var key: String = "sound:"+path
	if not cache.has(key):
		var audio: AudioStreamPlayer = AudioStreamPlayer.new()
		audio.stream = load(path if path.begins_with("res://") else "res://levels/zelda/assets/audio/"+path)
		audio.volume_db = linear_to_db(volume)
		audio.max_polyphony = 8
		add_child(audio)
		cache[key] = audio
	cache[key].play()


func _ready() -> void:
	build_world()
	var music: AudioStreamOggVorbis = load("res://levels/zelda/assets/audio/main.ogg").duplicate()
	music.loop = true
	$Music.stream = music
	$Music.play()
	resized.connect(fit_field)
	fit_field()


func _exit_tree() -> void:
	for child: Node in get_children():
		if child is AudioStreamPlayer:
			child.stop()


func fit_field() -> void:
	var factor: float = minf(size.x/1280,size.y/720)
	$Field.position = (size-FIELD_SIZE*factor)/2
	$Field.scale = Vector2.ONE*factor
	queue_redraw()


func shrink(rect: Rect2, x: float, y: float) -> Rect2:
	return Rect2(rect.position+Vector2(x,y)/2,rect.size-Vector2(x,y))


func build_world() -> void:
	for kind: String in ["map_FloorBlocks","map_Grass","map_Objects","map_Entities"]:
		var rows: Array = data.maps[kind]
		for y: int in range(rows.size()):
			for x: int in range(rows[y].size()):
				var tile: int = int(rows[y][x])
				if tile < 0:
					continue
				var position: Vector2 = Vector2(x*64,y*64)
				if kind == "map_Entities":
					if tile == 394:
						player = shrink(Rect2(position,image("test/player.png").get_size()),6,26)
					else:
						var name: String = "bamboo" if tile == 390 else ("spirit" if tile == 391 else ("raccoon" if tile == 392 else "squid"))
						enemies.append({"name":name,"box":shrink(Rect2(position,frames("monsters/"+name+"/idle")[0].get_size()),0,10),"health":float(data.monster_data[name].health),"direction":Vector2.ZERO,"state":"idle","frame":0.0,"hurt":0.0,"wait":0.0,"can_attack":true,"dead":false})
					continue
				var texture: Texture2D
				var type: String = "boundary"
				var rect: Rect2 = Rect2(position,Vector2(64,64))
				if kind == "map_Grass":
					type = "grass"
					texture = frames("grass").pick_random()
					rect.size = texture.get_size()
				elif kind == "map_Objects":
					type = "object"
					texture = frames("objects")[tile]
					rect = Rect2(position-Vector2(0,64),texture.get_size())
				var item: Dictionary = {"type":type,"texture":texture,"rect":rect,"box":shrink(rect,0,40 if type == "object" else (10 if type == "grass" else 0)),"dead":false}
				objects.append(item)
				index_obstacle(item)


func index_obstacle(item: Dictionary) -> void:
	var rect: Rect2 = item.box
	for y: int in range(floori(rect.position.y/64),floori(rect.end.y/64)+1):
		for x: int in range(floori(rect.position.x/64),floori(rect.end.x/64)+1):
			var cell: Vector2i = Vector2i(x,y)
			if not buckets.has(cell):
				buckets[cell] = []
			buckets[cell].append(item)


func candidates(rect: Rect2) -> Array:
	var found: Array = []
	for y: int in range(floori(rect.position.y/64),floori(rect.end.y/64)+1):
		for x: int in range(floori(rect.position.x/64),floori(rect.end.x/64)+1):
			for item: Dictionary in buckets.get(Vector2i(x,y),[]):
				if not item.dead and not found.has(item):
					found.append(item)
	return found


func move_box(box: Rect2, direction: Vector2, speed: float) -> Rect2:
	direction = direction.normalized()
	for axis: int in range(2):
		box.position[axis] = int(box.position[axis]+direction[axis]*speed)
		for item: Dictionary in candidates(box):
			if box.intersects(item.box):
				if direction[axis] > 0:
					box.position[axis] = item.box.position[axis]-box.size[axis]
				elif direction[axis] < 0:
					box.position[axis] = item.box.end[axis]
	return box


func player_texture() -> Texture2D:
	var state: String = facing+("_attack" if attack_left > 0 else ("" if moving else "_idle"))
	var images: Array = frames("player/"+state)
	return images[int(frame)%images.size()]


func player_rect() -> Rect2:
	var texture: Texture2D = player_texture()
	return Rect2(player.get_center()-texture.get_size()/2,texture.get_size())


func add_particle(folder: String, position: Vector2, damaging: bool = false, flip: bool = false) -> void:
	particles.append({"folder":"particles/"+folder,"position":position,"frame":0.0,"damage":damaging,"flip":flip})


func attack(magic: bool = false) -> void:
	attack_left = 0.4+float(data.weapon_data[WEAPONS[weapon_index]].cooldown)/1000
	if magic:
		var spell: Dictionary = data.magic_data[SPELLS[magic_index]]
		if energy < spell.cost:
			return
		energy -= spell.cost
		if magic_index == 1:
			health = minf(stats.health,health+spell.strength+stats.magic)
			sound("heal.wav",1)
			add_particle("aura",player.get_center())
			add_particle("heal/frames",player.get_center())
		else:
			sound("Fire.wav",1)
			var direction: Vector2 = {"right":Vector2.RIGHT,"left":Vector2.LEFT,"up":Vector2.UP,"down":Vector2.DOWN}[facing]
			for i: int in range(1,6):
				add_particle("flame/frames",player.get_center()+direction*i*64+Vector2(randi_range(-22,21),randi_range(-22,21)),true)
	else:
		weapon_texture = image("weapons/"+WEAPONS[weapon_index]+"/"+facing+".png")
		var body: Rect2 = player_rect()
		var extent: Vector2 = weapon_texture.get_size()
		if facing == "right":
			weapon_rect = Rect2(Vector2(body.end.x,body.get_center().y+16-extent.y/2),extent)
		elif facing == "left":
			weapon_rect = Rect2(Vector2(body.position.x-extent.x,body.get_center().y+16-extent.y/2),extent)
		elif facing == "down":
			weapon_rect = Rect2(Vector2(body.get_center().x-10-extent.x/2,body.end.y),extent)
		else:
			weapon_rect = Rect2(Vector2(body.get_center().x-10-extent.x/2,body.position.y-extent.y),extent)
		sound("sword.wav",0.4)


func upgrade(index: int) -> void:
	var attribute: String = ATTRIBUTES[index]
	if experience >= costs[attribute] and stats[attribute] < maximum[attribute]:
		experience -= costs[attribute]
		stats[attribute] = minf(maximum[attribute],stats[attribute]*1.2)
		costs[attribute] *= 1.4


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_M:
		paused = not paused
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("return_to_hub") and paused:
		paused = false
		get_viewport().set_input_as_handled()
	else:
		super._unhandled_input(event)


func _physics_process(delta: float) -> void:
	weapon_switch = maxf(0,weapon_switch-delta)
	magic_switch = maxf(0,magic_switch-delta)
	hurt_left = maxf(0,hurt_left-delta)
	attack_left = maxf(0,attack_left-delta)
	if attack_left <= 0:
		weapon_rect = Rect2()
	menu_wait = maxf(0,menu_wait-delta)
	if paused:
		if menu_wait <= 0:
			if Input.is_physical_key_pressed(KEY_RIGHT):
				menu_index = mini(4,menu_index+1)
				menu_wait = 0.3
			elif Input.is_physical_key_pressed(KEY_LEFT):
				menu_index = maxi(0,menu_index-1)
				menu_wait = 0.3
			if Input.is_physical_key_pressed(KEY_SPACE):
				upgrade(menu_index)
				menu_wait = 0.3
	else:
		var direction: Vector2 = Vector2.ZERO
		if attack_left <= 0:
			direction.y = -1 if Input.is_physical_key_pressed(KEY_UP) else (1 if Input.is_physical_key_pressed(KEY_DOWN) else 0)
			direction.x = 1 if Input.is_physical_key_pressed(KEY_RIGHT) else (-1 if Input.is_physical_key_pressed(KEY_LEFT) else 0)
			if direction.y != 0:
				facing = "up" if direction.y < 0 else "down"
			if direction.x != 0:
				facing = "left" if direction.x < 0 else "right"
			if Input.is_physical_key_pressed(KEY_SPACE):
				attack()
			if Input.is_physical_key_pressed(KEY_CTRL):
				attack(true)
			if Input.is_physical_key_pressed(KEY_Q) and weapon_switch <= 0:
				weapon_index = (weapon_index+1)%5
				weapon_switch = 0.2
			if Input.is_physical_key_pressed(KEY_E) and magic_switch <= 0:
				magic_index = (magic_index+1)%2
				magic_switch = 0.2
		if attack_left > 0:
			direction = Vector2.ZERO
		moving = not direction.is_zero_approx()
		player = move_box(player,direction,stats.speed)
		frame += 0.15
		if frame >= frames("player/"+facing+("_attack" if attack_left > 0 else ("" if moving else "_idle"))).size():
			frame = 0
		energy = minf(stats.energy,energy+0.01*stats.magic)
		update_enemies(delta)
		apply_attacks()
		for effect: Dictionary in particles:
			effect.frame += 0.15
		particles = particles.filter(func(effect: Dictionary) -> bool: return effect.frame < frames(effect.folder).size())
	$Field/Canvas.queue_redraw()


func damage_player(amount: float, type: String) -> void:
	if hurt_left <= 0:
		health -= amount
		hurt_left = 0.5
		add_particle(type,player.get_center())


func update_enemies(delta: float) -> void:
	for enemy: Dictionary in enemies:
		var info: Dictionary = data.monster_data[enemy.name]
		enemy.hurt = maxf(0,enemy.hurt-delta)
		enemy.wait = maxf(0,enemy.wait-delta)
		if enemy.wait <= 0:
			enemy.can_attack = true
		if enemy.hurt > 0:
			enemy.direction *= -float(info.resistance)
		enemy.box = move_box(enemy.box,enemy.direction,info.speed)
		var images: Array = frames("monsters/"+enemy.name+"/"+enemy.state)
		enemy.frame += 0.15
		if enemy.frame >= images.size():
			if enemy.state == "attack":
				enemy.can_attack = false
				enemy.wait = 0.4
			enemy.frame = 0.0
		if enemy.health <= 0:
			enemy.dead = true
			experience += info.exp
			add_particle({"squid":"smoke_orange","raccoon":"raccoon","spirit":"nova","bamboo":"bamboo"}[enemy.name],enemy.box.get_center())
			sound("death.wav")
			continue
		var offset: Vector2 = player.get_center()-enemy.box.get_center()
		var distance: float = offset.length()
		if distance <= info.attack_radius and enemy.can_attack:
			if enemy.state != "attack":
				enemy.frame = 0.0
				sound(info.attack_sound)
			enemy.state = "attack"
			damage_player(info.damage,info.attack_type)
		elif distance <= info.notice_radius:
			enemy.state = "move"
			enemy.direction = offset.normalized()
		else:
			enemy.state = "idle"
			enemy.direction = Vector2.ZERO
	enemies = enemies.filter(func(enemy: Dictionary) -> bool: return not enemy.dead)


func apply_attacks() -> void:
	var attacks: Array[Dictionary] = []
	if weapon_rect.has_area():
		attacks.append({"rect":weapon_rect,"amount":stats.attack+data.weapon_data[WEAPONS[weapon_index]].damage})
	for effect: Dictionary in particles:
		if effect.damage:
			var texture: Texture2D = frames(effect.folder)[int(effect.frame)]
			attacks.append({"rect":Rect2(effect.position-texture.get_size()/2,texture.get_size()),"amount":stats.magic+data.magic_data[SPELLS[magic_index]].strength})
	for strike: Dictionary in attacks:
		for item: Dictionary in candidates(strike.rect):
			if item.type == "grass" and not item.dead and strike.rect.intersects(item.rect):
				item.dead = true
				for i: int in range(randi_range(3,6)):
					add_particle("leaf"+str(randi_range(1,6)),item.rect.get_center()-Vector2(0,75),false,bool(randi()%2))
		for enemy: Dictionary in enemies:
			var texture: Texture2D = frames("monsters/"+enemy.name+"/"+enemy.state)[int(enemy.frame)%frames("monsters/"+enemy.name+"/"+enemy.state).size()]
			var rect: Rect2 = Rect2(enemy.box.get_center()-texture.get_size()/2,texture.get_size())
			if enemy.hurt <= 0 and strike.rect.intersects(rect):
				enemy.health -= strike.amount
				enemy.hurt = 0.3
				enemy.direction = (player.get_center()-enemy.box.get_center()).normalized()
				sound("hit.wav")


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Color.BLACK)
