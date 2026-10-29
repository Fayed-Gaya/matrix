class_name BugLevel
extends MatrixLevel

const CAT: Texture2D = preload("res://assets/art/sprites/bug/cat/cat.png")
const FIELD_SIZE: Vector2 = Vector2(600, 600)
var touch_index: int = -1
var mouse_position: Vector2 = Vector2.ZERO
var buttons: Array[bool] = [false, false, false]
var field_scale: float = 1.0
var field_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	resized.connect(fit_field)
	fit_field()


func fit_field() -> void:
	field_scale = minf(size.x / 600, size.y / 600)
	field_offset = (size - FIELD_SIZE * field_scale) / 2
	$Field.position = field_offset
	$Field.scale = Vector2.ONE * field_scale
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and touch_index == -1:
			touch_index = event.index
			buttons[0] = true
		if event.index == touch_index:
			mouse_position = ((event.position - field_offset) / field_scale).floor()
			if not event.pressed:
				buttons[0] = false
				touch_index = -1
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and event.index == touch_index:
		mouse_position = ((event.position - field_offset) / field_scale).floor()
		get_viewport().set_input_as_handled()
	if event is InputEventMouse:
		mouse_position = ((event.position - field_offset) / field_scale).floor()
	if event is InputEventMouseButton:
		var index: int = [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_MIDDLE, MOUSE_BUTTON_RIGHT].find(event.button_index)
		if index >= 0:
			buttons[index] = event.pressed
	$Field/Canvas.queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color.BLACK)

func cancel_pointer() -> void:
	touch_index = -1
	buttons = [false, false, false]

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT: cancel_pointer()
