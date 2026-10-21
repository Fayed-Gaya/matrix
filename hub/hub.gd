class_name MatrixHub
extends Control

signal level_requested(code: String)

const PlayerScript: GDScript = preload("res://hub/player.gd")
var player: HubPlayer
@onready var world: HubWorld = $WorldViewport/World
@onready var world_viewport: SubViewport = $WorldViewport
@onready var display: TextureRect = $WorldDisplay
@onready var overlay: Control = $Overlay
var camera_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	player = PlayerScript.new()
	player.name = "Player"
	player.position = world.player_spawn
	player.z_index = 1
	world.add_child(player)
	display.texture = world_viewport.get_texture()
	resized.connect(sync_viewport)
	sync_viewport()


func sync_viewport() -> void:
	if not is_node_ready():
		return
	var render_size: Vector2i = Vector2i(
		maxi(1, int(size.x) / 2), maxi(1, int(size.y) / 2))
	render_size = render_size.min(Vector2i(world.bounds))
	world_viewport.size = render_size
	display.size = Vector2(render_size * 2)
	display.position = ((size - display.size) / 2).floor()
	update_camera()
	overlay.queue_redraw()


func update_camera() -> void:
	camera_offset = (player.position - Vector2(world_viewport.size) / 2).clamp(
		Vector2.ZERO, (world.bounds - Vector2(world_viewport.size)).max(Vector2.ZERO))
	world_viewport.canvas_transform = Transform2D(0, -camera_offset.round())


func _physics_process(delta: float) -> void:
	if not overlay.opening and not overlay.terminal_active:
		# Opposite directions cancel; diagonal movement is normalized by the player.
		var direction: Vector2 = Vector2(
			float(Input.is_action_pressed("hub_right")) - float(Input.is_action_pressed("hub_left")),
			float(Input.is_action_pressed("hub_down")) - float(Input.is_action_pressed("hub_up")))
		player.step(direction, delta, world.collision_rects, world.bounds)
	update_camera()
	overlay.near_terminal = is_near_terminal()
	overlay.queue_redraw()


func is_near_terminal() -> bool:
	return player.hitbox().intersects(world.terminal_rect)


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed:
		return
	get_viewport().set_input_as_handled()
	if overlay.opening:
		overlay.opening = false
	elif overlay.terminal_active:
		terminal_key(event)
	elif event.is_action_pressed("return_to_hub"):
		get_tree().quit()
	elif event.is_action_pressed("hub_interact") and is_near_terminal():
		open_terminal()
	overlay.queue_redraw()


func open_terminal() -> void:
	overlay.terminal_active = true
	overlay.input_text = ""
	overlay.message = ""


func terminal_key(event: InputEventKey) -> void:
	match event.keycode:
		KEY_ESCAPE:
			overlay.terminal_active = false
		KEY_BACKSPACE:
			overlay.input_text = overlay.input_text.left(-1)
		KEY_ENTER, KEY_KP_ENTER:
			submit_code()
		_:
			if event.unicode >= 32 and event.unicode != 127 and overlay.input_text.length() < 18:
				overlay.input_text += String.chr(event.unicode).to_upper()


func submit_code() -> void:
	var code: String = overlay.input_text.strip_edges().to_upper()
	if LevelRegistry.lookup(code).is_empty():
		overlay.message = "Unknown code: " + (overlay.input_text if not overlay.input_text.is_empty() else "<empty>")
		overlay.input_text = ""
	else:
		level_requested.emit(code)


func suspend() -> void:
	overlay.terminal_active = false
	process_mode = Node.PROCESS_MODE_DISABLED
	world_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	hide()


func resume() -> void:
	show()
	process_mode = Node.PROCESS_MODE_INHERIT
	world_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	sync_viewport()
