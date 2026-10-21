class_name BallsLevel
extends MatrixLevel
## Two timing models: elapsed-time movement versus five pixels per render frame.

const FIELD_SIZE: Vector2 = Vector2(1280, 720)
const RADIUS: float = 40.0
const BACKGROUND: Color = Color("a020f0")
var positions: Array[Vector2] = [Vector2(590, 360), Vector2(690, 360)]
var drawn_positions: Array[Vector2] = [Vector2(590, 360), Vector2(690, 360)]
var previous_delta: float = 0.0
var previous_max_fps: int = 0
var field_scale: float = 1.0
var field_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	previous_max_fps = Engine.max_fps
	Engine.max_fps = 60
	resized.connect(fit_field)
	fit_field()


func _exit_tree() -> void:
	Engine.max_fps = previous_max_fps


func fit_field() -> void:
	field_scale = minf(size.x / FIELD_SIZE.x, size.y / FIELD_SIZE.y)
	field_offset = (size - FIELD_SIZE * field_scale) / 2
	$Field.position = field_offset
	$Field.scale = Vector2.ONE * field_scale
	queue_redraw()
	$Field/Circles.queue_redraw()


func _process(delta: float) -> void:
	# The source draws before updating, using the preceding iteration's dt.
	drawn_positions = positions.duplicate()
	var direction: Vector2 = Vector2(
		float(Input.is_action_pressed("balls_right")) - float(Input.is_action_pressed("balls_left")),
		float(Input.is_action_pressed("balls_down")) - float(Input.is_action_pressed("balls_up")))
	advance_frame(direction, previous_delta)
	previous_delta = delta
	$Field/Circles.queue_redraw()


func advance_frame(direction: Vector2, elapsed: float) -> void:
	# Deliberately do not normalize diagonals: both source axes act independently.
	positions[0] += direction * 300.0 * elapsed
	positions[1] += direction * 5.0
	for index: int in range(positions.size()):
		positions[index] = Vector2(fposmod(positions[index].x, FIELD_SIZE.x),
			fposmod(positions[index].y, FIELD_SIZE.y))


func wrapped_centers(center: Vector2) -> Array[Vector2]:
	var xs: Array[float] = [center.x]
	var ys: Array[float] = [center.y]
	if center.x - RADIUS < 0:
		xs.append(center.x + FIELD_SIZE.x)
	elif center.x + RADIUS > FIELD_SIZE.x:
		xs.append(center.x - FIELD_SIZE.x)
	if center.y - RADIUS < 0:
		ys.append(center.y + FIELD_SIZE.y)
	elif center.y + RADIUS > FIELD_SIZE.y:
		ys.append(center.y - FIELD_SIZE.y)
	var centers: Array[Vector2] = []
	for x: float in xs:
		for y: float in ys:
			centers.append(Vector2(x, y))
	return centers


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color.BLACK)
