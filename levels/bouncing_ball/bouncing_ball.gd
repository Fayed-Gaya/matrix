class_name BouncingBallLevel
extends MatrixLevel
## The original one-pixel update, paced at 60 fixed ticks per second.

const FIELD_SIZE: Vector2 = Vector2(1200, 1000)
const BALL: Texture2D = preload("res://assets/art/bounce/intro_ball.png")
var ball_position: Vector2i = Vector2i.ZERO
var direction: Vector2i = Vector2i.ONE
var field_scale: float = 1.0
var field_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	resized.connect(fit_field)
	fit_field()


func fit_field() -> void:
	field_scale = minf(size.x / FIELD_SIZE.x, size.y / FIELD_SIZE.y)
	field_offset = (size - FIELD_SIZE * field_scale) / 2
	queue_redraw()


func _physics_process(_delta: float) -> void:
	advance_tick()


func advance_tick() -> void:
	ball_position += direction
	# Keep the source's one-pixel overshoot; equality alone does not reflect.
	if ball_position.x < 0 or ball_position.x + BALL.get_width() > int(FIELD_SIZE.x):
		direction.x = -direction.x
	if ball_position.y < 0 or ball_position.y + BALL.get_height() > int(FIELD_SIZE.y):
		direction.y = -direction.y
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color.BLACK)
	draw_set_transform(field_offset, 0, Vector2.ONE * field_scale)
	var visible_ball: Rect2 = Rect2(Vector2(ball_position), BALL.get_size()).intersection(
		Rect2(Vector2.ZERO, FIELD_SIZE))
	draw_texture_rect_region(BALL, visible_ball,
		Rect2(visible_ball.position - Vector2(ball_position), visible_ball.size))
	draw_set_transform(Vector2.ZERO)
	# A single app needs a discoverable return control; the original had only quit.
	draw_string(ThemeDB.fallback_font, Vector2(16, size.y - 16),
		"Escape: return to Matrix", HORIZONTAL_ALIGNMENT_LEFT, size.x - 32, 18,
		Color(0.6, 0.65, 0.63))
