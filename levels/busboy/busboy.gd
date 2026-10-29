class_name BusboyLevel
extends MatrixLevel
## Introductory cursed-forest slice; creative specifics remain provisional.

const FIELD_SIZE: Vector2 = Vector2(640,352)
const PlayerScript: GDScript = preload("res://levels/busboy/player.gd")
const NpcScript: GDScript = preload("res://levels/busboy/npc.gd")
const ROOMS: Dictionary = {"cabin": preload("res://levels/busboy/maps/cabin.tscn"), "forest": preload("res://levels/busboy/maps/forest.tscn")}
var room: BusboyRoom
var player: BusboyPlayer
var room_name: String = ""
var opening: bool = true
var dialogue: String = ""
var advised: bool = false
var encounter_won: bool = false
var complete: bool = false
var ending_stain: int = 0
var encounter: BusboyEncounter
var notice: String = "A lantern still burns. Beyond the door, the roots have stirred."
var notice_time: float = 7
@onready var field: SubViewport = $Viewport
@onready var display: TextureRect = $Display
@onready var overlay: Control = $Overlay

func _ready() -> void:
	show_room("cabin")
	display.texture = field.get_texture()
	var ambience: AudioStreamMP3 = (load("res://assets/audio/busboy/forest_ambience.mp3") as AudioStreamMP3).duplicate()
	ambience.loop = true
	$Ambience.stream = ambience
	$Ambience.play()
	resized.connect(fit_field)
	fit_field()

func _exit_tree() -> void:
	$Ambience.stop()

func fit_field() -> void:
	if not is_node_ready(): return
	var factor: float = minf(size.x / FIELD_SIZE.x, maxf(1, size.y - 76 - (0 if MatrixMobileOverlay.active(self) else 32)) / FIELD_SIZE.y)
	display.size = FIELD_SIZE * factor
	display.position = Vector2((size.x - display.size.x) / 2, 76).floor()
	overlay.queue_redraw()

func show_room(title: String) -> void:
	if room != null:
		field.remove_child(room)
		room.queue_free()
	room_name = title
	room = (ROOMS[title] as PackedScene).instantiate() as BusboyRoom
	field.add_child(room)
	player = PlayerScript.new() as BusboyPlayer
	player.position = room.player_spawn
	player.scale = Vector2(2,2)
	player.z_index = 0
	room.add_child(player)
	for data: Dictionary in room.npc_data:
		var npc: Node2D = NpcScript.new() as Node2D
		npc.position = data.position
		npc.scale = Vector2(2,2)
		npc.z_index = 0
		room.add_child(npc)
	room.move_child(player, room.get_child_count() - 1)
	if title == "forest" and encounter_won:
		room.clear_corruption()
		if complete: room.get_node("ShrineArt/Halo").show()
	update_camera()
	if is_instance_valid(overlay): overlay.queue_redraw()

func update_camera() -> void:
	var offset: Vector2 = (player.position - FIELD_SIZE / 2).clamp(Vector2.ZERO, (room.bounds - FIELD_SIZE).max(Vector2.ZERO))
	field.canvas_transform = Transform2D(0, -offset.round())

func near(title: String) -> bool:
	return player.hitbox().grow(8).intersects(room.region(title))

func nearby_npc() -> Dictionary:
	for npc: Dictionary in room.npc_data:
		if Rect2(npc.position - Vector2(34,34), Vector2(68,68)).intersects(player.hitbox()): return npc
	return {}

func say(value: String) -> void:
	notice = value
	notice_time = 6

func interact() -> void:
	if near("Exit"):
		show_room("forest" if room_name == "cabin" else "cabin")
		say("Follow the lanterns. Someone waits along the path." if room_name == "forest" else "The refuge lantern still burns.")
	elif room_name == "cabin" and near("Table"):
		dialogue = "A lantern, a walking staff, and a map with one path left unmarked.\nOutside, pale light moves between the roots."
	elif not nearby_npc().is_empty():
		advised = true
		say("Strike without drawing magic. Guard to ground yourself. Cleanse carefully.")
		dialogue = nearby_npc().dialogue
	elif room_name == "forest" and near("Encounter") and not encounter_won:
		if not advised: say("Speak with the waykeeper before touching the corrupted roots.")
		else: encounter = BusboyEncounter.new()
	elif room_name == "forest" and near("Shrine"):
		if encounter_won:
			complete = true
			room.get_node("ShrineArt/Halo").show()
			var residue: String = "A trace of the light lingers on your hands." if ending_stain > 0 else "Your hands are clear. The light is not still."
			dialogue = "The shrine answers with a single pale pulse.\n" + residue + "\n\nBeyond the clearing, something answers.\n\nBUSBOY · Introduction complete"
		else: say("The roots still bind this clearing.")

func choose(action: String) -> void:
	if encounter != null: encounter.choose(action)
	overlay.queue_redraw()

func leave_encounter(retry_on_defeat: bool = true) -> void:
	if encounter == null: return
	var result: BusboyEncounter.Phase = encounter.phase
	if result == BusboyEncounter.Phase.VICTORY: ending_stain = encounter.corruption
	if result == BusboyEncounter.Phase.DEFEAT and retry_on_defeat:
		encounter = BusboyEncounter.new()
		return
	encounter = null
	if result == BusboyEncounter.Phase.VICTORY:
		encounter_won = true
		room.clear_corruption()
		say("The roots part. Cross to the small shrine and press E.")
	elif result == BusboyEncounter.Phase.DEFEAT:
		say("A safe step back. Every new attempt starts refreshed.")
	else: say("You step back. The roots will wait; the next attempt starts fresh.")

func objective() -> String:
	if complete: return "The clearing is open. The mystery remains."
	if encounter_won: return "Reach the shrine beyond the cleared roots."
	if advised: return "Face the corrupted roots. Guard a heavy lash; magic has a cost."
	return "Follow the lanterns. Find the waykeeper."

func interaction_hint() -> String:
	if near("Exit"): return "E: enter forest" if room_name == "cabin" else "E: return to starting room"
	if room_name == "cabin" and near("Table"): return "E: inspect the lantern table"
	if not nearby_npc().is_empty(): return "E: talk to the waykeeper"
	if room_name == "forest":
		if near("Encounter") and not encounter_won: return "E: face the corrupted roots"
		if near("Shrine"): return "E: tend the shrine"
	return ""

func _physics_process(delta: float) -> void:
	if room == null: return
	notice_time = maxf(0, notice_time - delta)
	if encounter != null: encounter.tick(delta)
	elif not opening and dialogue.is_empty():
		player.step(Input.get_vector("pegasus_left", "pegasus_right", "pegasus_up", "pegasus_down"), delta, room.collision_rects, room.bounds)
	update_camera()
	display.visible = not opening
	overlay.queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	if encounter != null:
		if event.keycode == KEY_ESCAPE: leave_encounter(false)
		elif encounter.phase in [BusboyEncounter.Phase.VICTORY, BusboyEncounter.Phase.DEFEAT] and event.keycode in [KEY_ENTER, KEY_SPACE]: leave_encounter()
		elif event.keycode in [KEY_1, KEY_KP_1]: choose("strike")
		elif event.keycode in [KEY_2, KEY_KP_2]: choose("guard")
		elif event.keycode in [KEY_3, KEY_KP_3]: choose("cleanse")
	elif not dialogue.is_empty():
		if event.keycode in [KEY_E, KEY_ENTER, KEY_SPACE, KEY_ESCAPE]: dialogue = ""
	elif event.is_action_pressed("return_to_pegasus"): return_requested.emit()
	elif opening and event.keycode in [KEY_ENTER, KEY_SPACE]: opening = false
	elif not opening and event.is_action_pressed("pegasus_interact"): interact()
	else: return
	get_viewport().set_input_as_handled()
	overlay.queue_redraw()
