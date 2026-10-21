class_name UntitledLevel
extends MatrixLevel

const FIELD_SIZE: Vector2 = Vector2(960, 540)
const NPC: Texture2D = preload("res://levels/untitled/assets/sprites/npc_snoblin_blue.png")
var opening: bool = true
var dialogue: String = ""
var dialogue_visible: bool = false
var player: UntitledPlayer
@onready var world: UntitledWorld = $Viewport/World


func _ready() -> void:
	player = load("res://levels/untitled/player.gd").new()
	player.position = world.player_spawn
	player.z_index = 1
	world.add_child(player)
	for data: Dictionary in world.npc_data:
		var sprite: Node2D = load("res://levels/untitled/npc.gd").new()
		sprite.position = Vector2(data.position[0], data.position[1])
		sprite.z_index = 1
		world.add_child(sprite)
	# Source NPCs draw before the player.
	world.move_child(player, world.get_child_count() - 1)
	$Display.texture = $Viewport.get_texture()
	var ambience: AudioStreamMP3 = $Ambience.stream.duplicate()
	ambience.loop = true
	$Ambience.stream = ambience
	$Ambience.play()
	resized.connect(fit_field)
	fit_field()


func _exit_tree() -> void:
	$Ambience.stop()


func fit_field() -> void:
	var factor: float = minf(size.x / 960, size.y / 540)
	$Display.position = (size - FIELD_SIZE * factor) / 2
	$Display.size = FIELD_SIZE * factor
	$Overlay.position = $Display.position
	$Overlay.scale = Vector2.ONE * factor
	queue_redraw()


func nearby_npc() -> Dictionary:
	for npc: Dictionary in world.npc_data:
		var position: Vector2 = Vector2(npc.position[0], npc.position[1])
		if Rect2(position - Vector2(34, 34), Vector2(68, 68)).intersects(player.hitbox()):
			return npc
	return {}


func _physics_process(delta: float) -> void:
	if not opening and not dialogue_visible:
		var direction: Vector2 = Vector2(
			float(Input.is_action_pressed("hub_right")) - float(Input.is_action_pressed("hub_left")),
			float(Input.is_action_pressed("hub_down")) - float(Input.is_action_pressed("hub_up")))
		player.step(direction, delta, world.collision_rects, world.bounds)
	var offset: Vector2 = (player.position - FIELD_SIZE / 2).clamp(Vector2.ZERO,
		(world.bounds - FIELD_SIZE).max(Vector2.ZERO))
	$Viewport.canvas_transform = Transform2D(0, -offset.round())
	$Display.visible = not opening
	$Overlay.queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed:
		return
	if event.keycode == KEY_ESCAPE:
		if dialogue_visible:
			dialogue_visible = false
		else:
			return_requested.emit()
	elif opening and event.keycode in [KEY_SPACE, KEY_ENTER]:
		opening = false
	elif event.keycode == KEY_E:
		var npc: Dictionary = nearby_npc()
		if not npc.is_empty():
			dialogue = npc.dialogue if not npc.dialogue.is_empty() else "The truth is I got on that bus a boy, and I never got off the bus. I still haven't."
			dialogue_visible = not dialogue_visible
	get_viewport().set_input_as_handled()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("121b17"))
