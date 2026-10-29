class_name BubbyLevel
extends MatrixLevel
## Small provisional narrative slice. No personal details or progression persistence.

const PlayerScript: GDScript = preload("res://levels/bubby/player.gd")
const ROOMS: Dictionary = {"apartment": preload("res://levels/bubby/maps/apartment.tscn"), "outside": preload("res://levels/bubby/maps/outside.tscn")}
const PIGEON: Texture2D = preload("res://assets/art/sprites/bubby/pigeon/pigeon.png")
var room: BubbyRoom
var player: BubbyPlayer
var room_name: String = ""
var pigeon: Sprite2D
var pigeon_health: int = 3
var health: int = 3
var shoo_wait: float = 0
var hurt_wait: float = 0
var envelope: bool = false
var complete: bool = false
var dialogue: String = ""
var notice: String = "A small delivery: bring the envelope outside back to the table. [Provisional story]"
var notice_time: float = 8
@onready var field: SubViewport = $WorldViewport
@onready var display: TextureRect = $WorldDisplay
@onready var overlay: Control = $Overlay

func _ready() -> void:
	show_room("apartment")
	var music: AudioStreamOggVorbis = (load("res://assets/audio/bubby/music.ogg") as AudioStreamOggVorbis).duplicate()
	music.loop = true
	$Music.stream = music
	$Music.play()
	display.texture = field.get_texture()
	resized.connect(fit_field)
	fit_field()

func fit_field() -> void:
	if not is_node_ready(): return
	var factor: float = minf(size.x / 640.0, size.y / 352.0)
	display.size = Vector2(640, 352) * factor
	display.position = ((size - display.size) / 2).floor()
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
	if title == "apartment" and returning: player.position = Vector2(480, 256)
	player.z_index = 1
	room.add_child(player)
	pigeon = null
	if title == "outside":
		pigeon = Sprite2D.new()
		pigeon.texture = PIGEON
		pigeon.position = room.get_node("PigeonSpawn").position
		pigeon.z_index = 1
		pigeon.visible = pigeon_health > 0
		room.add_child(pigeon)
		if envelope: (room.get_node("Details") as TileMapLayer).erase_cell(Vector2i(16, 4))

	if is_instance_valid(overlay): overlay.queue_redraw()

func near(title: String) -> bool:
	return player.hitbox().grow(8).intersects(room.region(title))

func interact() -> void:
	if near("Exit"):
		show_room("outside" if room_name == "apartment" else "apartment", true)
	elif room_name == "apartment" and near("Table"):
		if envelope:
			complete = true
			say("Delivery complete. A small thing, safely home. [Placeholder ending]")
			dialogue = "The envelope is home. A small thing, safely delivered.\n[Placeholder ending — personal story awaits references.]"
		else:
			dialogue = "A sealed envelope was left outside. Bring it back to this table.\n[Placeholder premise — this room is not Kate's actual apartment.]"
	elif room_name == "outside" and near("Envelope"):
		if envelope: say("The envelope is already with you.")
		elif pigeon_health > 0: say("The pigeon guards the envelope. Approach and press Space to shoo it.")
		else:
			envelope = true
			(room.get_node("Details") as TileMapLayer).erase_cell(Vector2i(16, 4))
			say("Envelope collected. Return inside and bring it to the table.")

func say(value: String) -> void:
	notice = value
	notice_time = 5

func shoo() -> void:
	if shoo_wait > 0 or room_name != "outside" or pigeon_health <= 0: return
	shoo_wait = 0.45
	player.action_time = 0.25
	if player.position.distance_to(pigeon.position) <= 56:
		pigeon_health -= 1
		if pigeon_health == 0:
			pigeon.hide()
			say("The pigeon flutters away unharmed. The envelope is clear.")
		else: say("Shoo! Give the pigeon a little space, then try again.")
	else: say("Get closer to the pigeon to shoo it.")

func _physics_process(delta: float) -> void:
	if room == null: return
	notice_time = maxf(0, notice_time - delta)
	shoo_wait = maxf(0, shoo_wait - delta)
	hurt_wait = maxf(0, hurt_wait - delta)
	if dialogue.is_empty():
		var direction: Vector2 = Input.get_vector("pegasus_left", "pegasus_right", "pegasus_up", "pegasus_down")
		player.step(direction, delta, room.collision_rects, room.bounds)
		if room_name == "outside" and pigeon_health > 0:
			var offset: Vector2 = player.position - pigeon.position
			if offset.length() < 100 and offset.length() > 22:
				pigeon.position += offset.normalized() * 24 * delta
			if offset.length() < 28 and hurt_wait <= 0:
				health -= 1
				hurt_wait = 1.4
				say("The pigeon nudges you back. Space: shoo. Step away between attempts.")
				if health <= 0: retry()
	overlay.queue_redraw()

func retry() -> void:
	health = 3
	pigeon_health = 3
	hurt_wait = 1.4
	show_room("apartment")
	say("Back home to catch your breath. Try the delivery again.")

func interaction_hint() -> String:
	if near("Exit"): return "E: go outside" if room_name == "apartment" else "E: return inside"
	if room_name == "apartment" and near("Table"): return "E: read the table" if not envelope else "E: deliver the envelope"
	if room_name == "outside" and near("Envelope") and not envelope: return "E: collect the envelope"
	if room_name == "outside" and pigeon_health > 0 and player.position.distance_to(pigeon.position) <= 70: return "Space: shoo the pigeon"
	return ""

func objective() -> String:
	if complete: return "Delivery complete. Explore or Escape to return to Matrix."
	if envelope: return "Bring the envelope to the table inside."
	return "Outside: shoo the pigeon, collect the envelope, bring it home."

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	if not dialogue.is_empty():
		if event.keycode in [KEY_ENTER, KEY_SPACE, KEY_ESCAPE, KEY_E]: dialogue = ""
	elif event.is_action_pressed("return_to_pegasus"): return_requested.emit()
	elif event.is_action_pressed("pegasus_interact"): interact()
	elif event.keycode == KEY_SPACE: shoo()
	else: return
	get_viewport().set_input_as_handled()
	overlay.queue_redraw()
