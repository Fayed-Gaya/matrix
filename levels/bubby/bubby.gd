class_name BubbyLevel
extends MatrixLevel
## A small balcony adventure; apartment and protagonist art remain provisional.

const PlayerScript: GDScript = preload("res://levels/bubby/player.gd")
const ROOMS: Dictionary = {"apartment": preload("res://levels/bubby/maps/apartment.tscn"), "outside": preload("res://levels/bubby/maps/outside.tscn")}
const PIGEON: Texture2D = preload("res://levels/bubby/assets/refinement/grand-coo.png")
const MAX_COMPOSURE: int = 5
const MAX_PIGEON: int = 6
var room: BubbyRoom
var player: BubbyPlayer
var room_name: String = ""
var pigeon: Sprite2D
var pigeon_health: int = MAX_PIGEON
var health: int = MAX_COMPOSURE
var shoo_wait: float = 0
var hurt_wait: float = 0
var complete: bool = false
var dialogue: String = ""
var notice: String = "A suspicious amount of cooing is coming from the balcony."
var notice_time: float = 7
var discovered: bool = false
var boss_state: String = "idle"
var phase_time: float = 0
var hop_origin: Vector2
var hop_target: Vector2
var scatter_time: float = 0
var birds: Array[Sprite2D] = []
var shoo_flash: float = 0
@onready var field: SubViewport = $WorldViewport
@onready var display: TextureRect = $WorldDisplay
@onready var overlay: Control = $Overlay

func _ready() -> void:
	show_room("apartment")
	var music: AudioStreamOggVorbis = (load("res://levels/bubby/assets/music.ogg") as AudioStreamOggVorbis).duplicate()
	music.loop = true
	$Music.stream = music
	$Music.play()
	display.texture = field.get_texture()
	resized.connect(fit_field)
	fit_field()

func fit_field() -> void:
	if not is_node_ready(): return
	var factor: float = minf(size.x / 640.0, maxf(1, size.y - 76 - (0 if MatrixMobileOverlay.active(self) else 32)) / 352.0)
	display.size = Vector2(640, 352) * factor
	display.position = Vector2((size.x - display.size.x) / 2, 76).floor()
	overlay.queue_redraw()

func show_room(title: String, returning: bool = false) -> void:
	if room != null:
		field.remove_child(room)
		room.queue_free()
	room_name = title
	room = (ROOMS[title] as PackedScene).instantiate() as BubbyRoom
	field.add_child(room)
	player = PlayerScript.new() as BubbyPlayer
	player.position = room.player_spawn
	if title == "apartment" and returning: player.position = room.get_node("ReturnSpawn").position
	room.add_child(player)
	pigeon = null
	birds.clear()
	boss_state = "idle"
	if title == "outside":
		health = MAX_COMPOSURE
		pigeon_health = 0 if complete else MAX_PIGEON
		pigeon = Sprite2D.new()
		pigeon.texture = PIGEON
		pigeon.position = room.get_node("PigeonSpawn").position
		pigeon.offset = Vector2(0, -35)
		pigeon.visible = not complete
		room.add_child(pigeon)
		for i: int in range(3):
			var bird: Sprite2D = Sprite2D.new()
			bird.texture = PIGEON
			bird.scale = Vector2.ONE * 0.29
			bird.position = Vector2(250 + i * 100, 162 + (i % 2) * 60)
			bird.visible = not complete
			room.add_child(bird)
			birds.append(bird)
		scatter_time = 0
		if complete:
			room.get_node("Mess").hide()
		elif not discovered:
			discovered = true
			dialogue = "The balcony has been claimed.\nThree little pigeons. One VERY important pigeon.\n\nStep out of the marked circle. Shoo when it catches its breath."
			boss_state = "intro"
		else: begin_encounter()
	if is_instance_valid(overlay): overlay.queue_redraw()

func near(title: String) -> bool:
	return player.hitbox().grow(8).intersects(room.region(title))

func interact() -> void:
	if near("Exit"):
		show_room("outside" if room_name == "apartment" else "apartment", true)
		if room_name == "apartment": say("A moment to regroup. The balcony can wait.")
	elif room_name == "apartment" and near("Table"):
		dialogue = "A quiet corner. An open notebook.\nOutside: the unmistakable sound of someone making themselves at home."
	elif complete and room_name == "outside":
		dialogue = "The balcony is yours again.\nA little peace. A little sunshine.\nA very large victory over a very ordinary problem."

func say(value: String) -> void:
	notice = value
	notice_time = 4

func begin_encounter() -> void:
	boss_state = "rest"
	phase_time = 1.8
	say("THE GRAND COO — a rather grand inconvenience. Shoo while it rests!")

func close_dialogue() -> void:
	dialogue = ""
	if boss_state == "defeated": retry()
	elif boss_state == "intro": begin_encounter()

func shoo() -> void:
	if shoo_wait > 0 or room_name != "outside" or complete or boss_state in ["intro", "defeated"]: return
	shoo_wait = 0.42
	shoo_flash = 0.25
	player.action_time = 0.25
	if boss_state != "rest":
		say("Let that grand entrance finish. Shoo while it catches its breath!")
	elif player.position.distance_to(pigeon.position) > 86:
		say("A little closer, then Shoo! No need to touch the pigeon.")
	else:
		pigeon_health -= 1
		pigeon.modulate = Color("ffe5c1")
		say("Shoo! Its grand resolve wobbles.")
		if pigeon_health <= 0:
			complete = true
			boss_state = "depart"
			phase_time = 1.6
			say("With one final, deeply offended coo…")

func _physics_process(delta: float) -> void:
	if room == null: return
	notice_time = maxf(0, notice_time - delta)
	shoo_wait = maxf(0, shoo_wait - delta)
	hurt_wait = maxf(0, hurt_wait - delta)
	shoo_flash = maxf(0, shoo_flash - delta)
	if dialogue.is_empty():
		var direction: Vector2 = Input.get_vector("hub_left", "hub_right", "hub_up", "hub_down")
		player.step(direction, delta, room.collision_rects, room.bounds)
		if room_name == "outside": update_encounter(delta)
	player.modulate = Color("f0b6a4") if hurt_wait > 0.8 else Color.WHITE
	overlay.queue_redraw()

func update_encounter(delta: float) -> void:
	scatter_time += delta
	for i: int in range(birds.size()):
		var bird: Sprite2D = birds[i]
		bird.position += Vector2((-95 if i % 2 == 0 else 110), -95) * delta
		if scatter_time > 2: bird.hide()
	pigeon.modulate = pigeon.modulate.lerp(Color.WHITE, minf(1, delta * 8))
	phase_time -= delta
	if boss_state == "rest":
		pigeon.scale = Vector2(1, 1 + sin(scatter_time * 3) * 0.015)
		if phase_time <= 0:
			boss_state = "tell"
			phase_time = 1.15
			hop_origin = pigeon.position
			# Lock target once: a visible, avoidable landing, never a homing attack.
			hop_target = player.position.clamp(Vector2(150, 158), Vector2(536, 284))
			say("A mighty hop approaches. Step out of the circle!")
	elif boss_state == "tell":
		pigeon.scale = Vector2(1.06, 0.94)
		if phase_time <= 0:
			boss_state = "hop"
			phase_time = 0.48
	elif boss_state == "hop":
		var progress: float = clampf(1 - phase_time / 0.48, 0, 1)
		pigeon.position = hop_origin.lerp(hop_target, progress)
		pigeon.offset.y = -35 - sin(progress * PI) * 44
		if phase_time <= 0:
			pigeon.position = hop_target
			pigeon.offset.y = -35
			pigeon.scale = Vector2.ONE
			boss_state = "rest"
			phase_time = 2.2
			if player.position.distance_to(hop_target) < 52: take_nudge()
			if boss_state != "defeated": say("An impressive landing. An excellent time to shoo.")
	elif boss_state == "depart":
		pigeon.position += Vector2(35, -130) * delta
		if phase_time <= 0:
			pigeon.hide()
			room.get_node("Mess").hide()
			boss_state = "cleared"
			dialogue = "BALCONY RECLAIMED\nThe Grand Coo has relocated its empire.\nEveryone leaves with their feathers intact.\n\nA little peace. A little sunshine. Yours again."

func take_nudge() -> void:
	if hurt_wait > 0: return
	health -= 1
	hurt_wait = 1.25
	if health <= 0:
		boss_state = "defeated"
		dialogue = "A tactical tea break.\nThe pigeon is still very pleased with itself.\n\nContinue to try again, fully refreshed."
	else: say("Only your composure is ruffled. Move out of the next landing circle.")

func retry() -> void:
	dialogue = ""
	show_room("outside")
	hurt_wait = 1.25
	say("Fresh composure. Same very important pigeon. You've got this.")

func interaction_hint() -> String:
	if near("Exit"): return "Use: balcony" if room_name == "apartment" else "Use: step inside"
	if room_name == "apartment" and near("Table"): return "Use: notebook"
	if room_name == "outside" and complete: return "Use: enjoy the quiet"
	if room_name == "outside" and boss_state == "rest": return "Shoo: approach while the pigeon rests"
	return ""

func objective() -> String:
	if complete: return "Balcony reclaimed. Everyone keeps their feathers."
	if room_name == "apartment": return "Investigate the cooing beyond the glass doors."
	if boss_state == "defeated": return "Continue to retry — no progress or lives to lose."
	return "Avoid the landing circle. Shoo while it rests."

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	if not dialogue.is_empty():
		if event.keycode in [KEY_ENTER, KEY_SPACE, KEY_ESCAPE, KEY_E]: close_dialogue()
	elif event.is_action_pressed("return_to_hub"): return_requested.emit()
	elif event.is_action_pressed("hub_interact"): interact()
	elif event.keycode == KEY_SPACE: shoo()
	else: return
	get_viewport().set_input_as_handled()
	overlay.queue_redraw()
