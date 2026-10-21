class_name BugLevel
extends MatrixLevel

const CAT: Texture2D = preload("res://levels/the_bug/assets/cat.png")
const FIELD_SIZE: Vector2 = Vector2(600, 600)
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
	if event is InputEventMouse:
		mouse_position = ((event.position - field_offset) / field_scale).floor()
	if event is InputEventMouseButton:
		var index: int = [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_MIDDLE, MOUSE_BUTTON_RIGHT].find(event.button_index)
		if index >= 0:
			buttons[index] = event.pressed
	$Field/Canvas.queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color.BLACK)
