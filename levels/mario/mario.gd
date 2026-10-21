class_name MarioLevel
extends MatrixLevel

const FIELD_SIZE: Vector2 = Vector2(1200, 704)
const NODES: Array[Vector2] = [Vector2(110,400), Vector2(300,220), Vector2(480,610), Vector2(610,350), Vector2(880,210), Vector2(1050,400)]
var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://levels/mario/assets/manifest.json"))
var cache: Dictionary = {}
var mode: String = "overworld"
var selected: int = 0
var max_level: int = 2
var health: int = 100
var coins: int = 0
var icon: Vector2 = NODES[0]
var icon_moving: bool = false
var input_delay: float = 0.3
var objects: Array[Dictionary] = []
var clouds: Array[Dictionary] = []
var effects: Array[Dictionary] = []
var player: Rect2 = Rect2(0,0,50,56)
var velocity: Vector2 = Vector2.ZERO
var on_ground: bool = false
var facing_right: bool = true
var status: String = "idle"
var animation: float = 0.0
var camera_x: float = 0.0
var hurt_left: float = 0.0
var age: float = 0.0
var level_width: float = 0.0
var goal: Rect2 = Rect2()


func frames(folder: String) -> Array:
	if not cache.has(folder):
		var images: Array = []
		for path: String in manifest.frames[folder]:
			images.append(load(path))
		cache[folder] = images
	return cache[folder]


func image(path: String) -> Texture2D:
	var key: String = "texture:" + path
	if not cache.has(key):
		cache[key] = load("res://levels/mario/assets/graphics/" + path)
	return cache[key] as Texture2D


func _ready() -> void:
	for name: String in ["jump", "hit", "coin", "stomp"]:
		var audio: AudioStreamPlayer = AudioStreamPlayer.new()
		audio.name = name.capitalize()
		audio.stream = load("res://levels/mario/assets/audio/effects/" + name + ".wav")
		audio.volume_db = -6.0206 if name == "jump" else 0.0
		add_child(audio)
	resized.connect(fit_field)
	fit_field()
	show_overworld(0)


func _exit_tree() -> void:
	for node: Node in get_children():
		if node is AudioStreamPlayer:
			node.stop()


func fit_field() -> void:
	var factor: float = minf(size.x / 1200, size.y / 704)
	$Field.position = (size - FIELD_SIZE * factor) / 2
	$Field.scale = Vector2.ONE * factor
	queue_redraw()


func music(name: String) -> void:
	$Music.stop()
	var stream: AudioStreamWAV = load("res://levels/mario/assets/audio/" + name + ".wav").duplicate()
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = int(stream.get_length() * stream.mix_rate)
	$Music.stream = stream
	$Music.play()


func sound(name: String) -> void:
	get_node(name.capitalize()).play()


func show_overworld(unlock: int) -> void:
	max_level = maxi(max_level, mini(unlock, 5))
	mode = "overworld"
	age = 0
	icon = NODES[selected]
	icon_moving = false
	input_delay = 0.3
	clouds.clear()
	for i: int in range(10):
		var palms: Array = frames("overworld/palms")
		clouds.append({"image": palms.pick_random(), "position": Vector2(randi_range(0,1200), randi_range(562,612)), "bottom": true})
		clouds.append({"image": frames("overworld/clouds").pick_random(), "position": Vector2(randi_range(0,1200), randi_range(0,412)), "bottom": true})
	music("overworld_music")


func enter_stage(index: int) -> void:
	selected = index
	mode = "stage"
	age = 0
	objects.clear()
	effects.clear()
	clouds.clear()
	camera_x = 0
	velocity = Vector2.ZERO
	on_ground = false
	hurt_left = 0
	animation = 0
	status = "idle"
	facing_right = true
	var data: Dictionary = manifest.maps[mini(index, 2)]
	level_width = data.terrain[0].size() * 64
	for kind: String in data:
		var rows: Array = data[kind]
		for y: int in range(rows.size()):
			for x: int in range(rows[y].size()):
				var tile: int = int(rows[y][x])
				if tile < 0:
					continue
				var position: Vector2 = Vector2(x * 64, y * 64)
				if kind == "player":
					if tile == 0:
						player = Rect2(position, Vector2(50, frames("character/idle")[0].get_height()))
					else:
						goal = Rect2(position, Vector2(64,64))
					continue
				var item: Dictionary = {"kind":kind, "rect":Rect2(position,Vector2(64,64)), "tile":tile, "frame":0.0, "dead":false, "folder":"", "speed":0}
				if kind == "crates":
					item.rect = Rect2(position + Vector2(0,64) - Vector2(0,image("terrain/crate.png").get_height()), image("terrain/crate.png").get_size())
				elif kind == "coins":
					item.folder = "coins/gold" if tile == 0 else "coins/silver"
					var dimensions: Vector2 = frames(item.folder)[0].get_size()
					item.rect = Rect2(position + Vector2(32,32) - dimensions / 2, dimensions)
				elif kind in ["fg palms", "bg palms"]:
					item.folder = "terrain/palm_bg" if kind == "bg palms" else ("terrain/palm_small" if tile == 0 else "terrain/palm_large")
					item.rect.position.y -= 38 if kind == "fg palms" and tile == 0 else 64
				elif kind == "enemies":
					item.folder = "enemy/run"
					item.rect.position.y += 64 - frames(item.folder)[0].get_height()
					item.speed = randi_range(3,5)
				objects.append(item)
	for i: int in range(30):
		clouds.append({"image":frames("decoration/clouds").pick_random(), "position":Vector2(randi_range(-1200,int(level_width+1200)),randi_range(0,400)), "bottom":false})
	music("level_music")


func visual_rect() -> Rect2:
	var texture: Texture2D = frames("character/" + status)[int(animation) % frames("character/" + status).size()]
	return Rect2(Vector2(player.position.x if facing_right else player.end.x - texture.get_width(), player.end.y - texture.get_height()), texture.get_size())


func particle(kind: String, position: Vector2) -> void:
	effects.append({"folder":"enemy/explosion" if kind == "explosion" else "character/dust_particles/" + kind, "position":position, "frame":0.0})


func _physics_process(delta: float) -> void:
	age += 0.15
	if mode == "overworld":
		input_delay -= delta
		if icon_moving:
			icon = icon.move_toward(NODES[selected],8)
			icon_moving = icon != NODES[selected]
		elif input_delay <= 0:
			if Input.is_physical_key_pressed(KEY_RIGHT) and selected < max_level:
				selected += 1
				icon_moving = true
			elif Input.is_physical_key_pressed(KEY_LEFT) and selected > 0:
				selected -= 1
				icon_moving = true
			elif Input.is_physical_key_pressed(KEY_SPACE):
				enter_stage(selected)
	else:
		advance_stage(delta, 1 if Input.is_physical_key_pressed(KEY_RIGHT) else (-1 if Input.is_physical_key_pressed(KEY_LEFT) else 0), Input.is_physical_key_pressed(KEY_SPACE))
	$Field/Canvas.queue_redraw()


func advance_stage(delta: float, direction: int, jumping: bool) -> void:
	hurt_left = maxf(0,hurt_left-delta)
	if direction != 0:
		facing_right = direction > 0
	velocity.x = direction * 8
	if jumping and on_ground:
		velocity.y = -16
		sound("jump")
		particle("jump", Vector2(player.get_center().x,player.end.y) + Vector2(-10 if facing_right else 10,-5))
	status = "jump" if velocity.y < 0 else ("fall" if velocity.y > 1 else ("run" if direction != 0 else "idle"))
	animation += 0.15
	if animation >= frames("character/" + status).size():
		animation = 0
	for item: Dictionary in objects:
		if not item.folder.is_empty():
			item.frame = fmod(item.frame + 0.15, frames(item.folder).size())
		if item.kind == "enemies":
			item.rect.position.x += item.speed
			for constraint: Dictionary in objects:
				if constraint.kind == "constraints" and item.rect.intersects(constraint.rect):
					item.speed = -item.speed
	player.position.x += velocity.x
	collide_axis(true)
	var was_grounded: bool = on_ground
	velocity.y += 0.8
	player.position.y = int(player.position.y + velocity.y)
	collide_axis(false)
	if velocity.y < 0 or velocity.y > 1:
		on_ground = false
	if on_ground and not was_grounded:
		particle("land",Vector2(player.get_center().x,player.end.y)-Vector2(10 if facing_right else -10,15))
	if player.get_center().x - camera_x > 900 and direction > 0:
		camera_x = player.get_center().x - 900
	elif player.get_center().x - camera_x < 300 and direction < 0:
		camera_x = player.get_center().x - 300
	var body: Rect2 = visual_rect()
	for item: Dictionary in objects:
		if not body.intersects(item.rect):
			continue
		if item.kind == "coins":
			coins += 5 if item.tile == 0 else 1
			item.dead = true
			sound("coin")
		elif item.kind == "enemies":
			if item.rect.position.y < body.end.y and body.end.y < item.rect.get_center().y and velocity.y >= 0:
				item.dead = true
				velocity.y = -15
				particle("explosion",item.rect.get_center())
				sound("stomp")
			elif hurt_left <= 0:
				health -= 10
				hurt_left = 0.5
				sound("hit")
	objects = objects.filter(func(item: Dictionary) -> bool: return not item.dead)
	for effect: Dictionary in effects:
		effect.frame += 0.5
	effects = effects.filter(func(effect: Dictionary) -> bool: return effect.frame < frames(effect.folder).size())
	if health <= 0:
		health = 100
		coins = 0
		max_level = 0
		show_overworld(0)
	elif body.position.y > 704:
		show_overworld(0)
	elif body.intersects(goal):
		show_overworld(selected+1)


func collide_axis(horizontal: bool) -> void:
	for item: Dictionary in objects:
		if item.kind not in ["terrain", "crates", "fg palms"] or not player.intersects(item.rect):
			continue
		if horizontal:
			if velocity.x > 0:
				player.position.x = item.rect.position.x - player.size.x
			elif velocity.x < 0:
				player.position.x = item.rect.end.x
		else:
			if velocity.y > 0:
				player.position.y = item.rect.position.y - player.size.y
				on_ground = true
			elif velocity.y < 0:
				player.position.y = item.rect.end.y
			velocity.y = 0


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Color.BLACK)
