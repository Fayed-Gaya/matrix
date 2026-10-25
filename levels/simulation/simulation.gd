class_name SimulationLevel
extends MatrixLevel
## Provisional general-audience clockwork-town showcase; progress is session-only.

const FIELD_SIZE: Vector2 = Vector2(640,352)
const AVATAR: Texture2D = preload("res://assets/art/shared/actors/astronaut.png")
const ROOMS: Dictionary = {
	"bedroom":preload("res://levels/simulation/maps/bedroom.tscn"),
	"home":preload("res://levels/simulation/maps/home.tscn"),
	"town":preload("res://levels/simulation/maps/town.tscn"),
	"workshop":preload("res://levels/simulation/maps/workshop.tscn"),
	"library":preload("res://levels/simulation/maps/library.tscn"),
	"cafe":preload("res://levels/simulation/maps/cafe.tscn"),
	"outskirts":preload("res://levels/simulation/maps/outskirts.tscn"),
}
enum BossPhase {DORMANT, WINDUP, RECOVER, COMPLETE}
var room: SimulationRoom
var player: MatrixPixelPlayer
var room_name: String = ""
var visited: Array[String] = []
var relays: Array[String] = []
var dialogue: String = ""
var notice: String = "The town has stopped ticking. Step out of your room to begin."
var notice_time: float = 7
var complete: bool = false
var health: int = 5
var boss_health: int = 6
var boss_phase: BossPhase = BossPhase.DORMANT
var boss_wait: float = 0
var strike_target: Vector2 = Vector2.ZERO
var attack_wait: float = 0
var attack_flash: float = 0
var guard_left: float = 0
var guard_wait: float = 0
@onready var field: SubViewport = $Viewport
@onready var display: TextureRect = $Display
@onready var overlay: Control = $Overlay

func _ready() -> void:
	show_room("bedroom")
	display.texture = field.get_texture()
	resized.connect(fit_field)
	fit_field()

func fit_field() -> void:
	if not is_node_ready(): return
	var factor: float = minf(size.x/FIELD_SIZE.x,size.y/FIELD_SIZE.y)
	display.size = FIELD_SIZE * factor
	display.position = ((size-display.size)/2).floor()
	overlay.queue_redraw()

func show_room(title: String, arrival: Vector2 = Vector2.ZERO) -> void:
	if room != null:
		field.remove_child(room)
		room.queue_free()
	room_name = title
	if not title in visited: visited.append(title)
	room = (ROOMS[title] as PackedScene).instantiate() as SimulationRoom
	field.add_child(room)
	player = MatrixPixelPlayer.new()
	player.sprite_sheet = AVATAR
	player.speed = 145
	player.position = room.player_spawn if arrival == Vector2.ZERO else arrival
	player.z_index = 1
	room.add_child(player)
	for data: Dictionary in room.npcs():
		var npc: MatrixPixelPlayer = MatrixPixelPlayer.new()
		npc.sprite_sheet = AVATAR
		npc.position = data.position
		npc.modulate = Color("c7c897") if data.relay.is_empty() else Color("d9ae91")
		npc.z_index = 1
		room.add_child(npc)
	if title == "outskirts":
		var effects: Node2D = load("res://levels/simulation/effects.gd").new() as Node2D
		effects.set("level",self)
		effects.z_index = 3
		room.add_child(effects)
		if complete: room.get_node("Governor").modulate = Color("73d7bd")
	update_camera()
	if is_instance_valid(overlay): overlay.queue_redraw()

func update_camera() -> void:
	var offset: Vector2 = (player.position-FIELD_SIZE/2).clamp(Vector2.ZERO,(room.bounds-FIELD_SIZE).max(Vector2.ZERO))
	field.canvas_transform = Transform2D(0,-offset.round())

func nearby_npc() -> Dictionary:
	for npc: Dictionary in room.npcs():
		if player.position.distance_to(npc.position) <= 48: return npc
	return {}

func near_portal() -> Dictionary:
	for portal: Dictionary in room.portals():
		if player.hitbox().grow(8).intersects(portal.rect): return portal
	return {}

func say(value: String) -> void:
	notice = value
	notice_time = 6

func interact() -> void:
	var portal: Dictionary = near_portal()
	if not portal.is_empty():
		if portal.needs_relays and relays.size() < 3:
			say("The east gate needs three relays: workshop, library and cafe.")
			return
		if room_name == "outskirts" and not complete: reset_boss()
		show_room(portal.target,portal.arrival)
		return
	var npc: Dictionary = nearby_npc()
	if not npc.is_empty():
		dialogue = npc.name + ": " + npc.dialogue
		if not npc.relay.is_empty() and not npc.relay in relays:
			relays.append(npc.relay)
			dialogue += "\nRelay received (%d/3)." % relays.size()
			beep(660)
		return
	if room_name == "outskirts" and boss_phase == BossPhase.DORMANT and not complete and player.position.distance_to(room.get_node("Governor").position) < 105:
		start_boss()

func start_boss() -> void:
	boss_phase = BossPhase.WINDUP
	boss_wait = 1.1
	strike_target = player.position
	say("Orange ring: move away or brace. Spark the governor while it recovers.")

func reset_boss() -> void:
	health = 5
	boss_health = 6
	boss_phase = BossPhase.DORMANT
	attack_wait = 0
	guard_left = 0
	guard_wait = 0

func attack() -> void:
	if room_name != "outskirts" or attack_wait > 0 or boss_phase != BossPhase.RECOVER: return
	attack_wait = 0.45
	attack_flash = 0.18
	if player.position.distance_to(room.get_node("Governor").position) <= 76:
		boss_health -= 1
		beep(880)
		if boss_health <= 0:
			complete = true
			boss_phase = BossPhase.COMPLETE
			room.get_node("Governor").modulate = Color("73d7bd")
			dialogue = "The governor settles into rhythm. Back in town, the clock ticks once more.\nA small machine, working again.\n[Provisional ending — premise, art and boss await review.]"
		else: say("Spark connected. Watch the next orange ring.")
	else: say("Get closer during recovery to land a spark.")

func brace() -> void:
	if guard_wait > 0 or room_name != "outskirts" or boss_phase in [BossPhase.DORMANT,BossPhase.COMPLETE]: return
	guard_left = 0.7
	guard_wait = 1.0

func update_boss(delta: float) -> void:
	boss_wait -= delta
	if boss_wait > 0: return
	if boss_phase == BossPhase.WINDUP:
		if player.position.distance_to(strike_target) < 38:
			if guard_left > 0: say("Braced. The pulse passes safely.")
			else:
				health -= 1
				beep(150)
				if health <= 0:
					reset_boss()
					show_room("town",Vector2(848,464))
					say("Safe in town. Your relays remain ready; try again at the east gate.")
					return
		boss_phase = BossPhase.RECOVER
		boss_wait = 1.2
	else:
		boss_phase = BossPhase.WINDUP
		boss_wait = 1.0
		strike_target = player.position

func objective() -> String:
	if complete: return "Machine restored. Explore or Escape to return to Matrix."
	if relays.size() == 3: return "Take the east gate outside town. Restore the stalled governor."
	return "Explore town: collect relays from the workshop, library and cafe (%d/3)." % relays.size()

func interaction_hint() -> String:
	var portal: Dictionary = near_portal()
	if not portal.is_empty(): return "E: " + portal.label
	var npc: Dictionary = nearby_npc()
	if not npc.is_empty(): return "E: talk to " + npc.name
	if room_name == "outskirts" and boss_phase == BossPhase.DORMANT: return "Approach the governor and press E."
	return ""

func beep(pitch: float) -> void:
	var wave: AudioStreamWAV = AudioStreamWAV.new()
	wave.format = AudioStreamWAV.FORMAT_16_BITS
	wave.mix_rate = 22050
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(2205 * 2)
	for i: int in range(2205):
		bytes.encode_s16(i*2,int(sin(TAU*pitch*i/22050.0)*(1.0-i/2205.0)*2200))
	wave.data = bytes
	$Sound.stream = wave
	$Sound.play()

func _physics_process(delta: float) -> void:
	if room == null: return
	notice_time = maxf(0,notice_time-delta)
	attack_wait = maxf(0,attack_wait-delta)
	attack_flash = maxf(0,attack_flash-delta)
	guard_left = maxf(0,guard_left-delta)
	guard_wait = maxf(0,guard_wait-delta)
	if dialogue.is_empty():
		player.step(Input.get_vector("pegasus_left","pegasus_right","pegasus_up","pegasus_down"),delta,room.collision_rects,room.bounds)
		if room_name == "outskirts" and boss_phase in [BossPhase.WINDUP,BossPhase.RECOVER]: update_boss(delta)
	if room_name == "town" and complete:
		room.get_node("ClockHand").rotation += delta
	update_camera()
	overlay.queue_redraw()
	if room_name == "outskirts": (room.get_child(room.get_child_count()-1) as CanvasItem).queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	if not dialogue.is_empty():
		if event.keycode in [KEY_ENTER,KEY_SPACE,KEY_E,KEY_ESCAPE]: dialogue = ""
	elif event.is_action_pressed("return_to_pegasus"): return_requested.emit()
	elif event.is_action_pressed("pegasus_interact"): interact()
	elif event.keycode == KEY_SPACE: attack()
	elif event.keycode == KEY_SHIFT: brace()
	else: return
	get_viewport().set_input_as_handled()
	overlay.queue_redraw()
