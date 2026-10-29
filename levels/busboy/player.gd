class_name BusboyPlayer
extends Node2D
## Reference 16x16 hitbox and axis-separated rectangle movement.

const SHEET: Texture2D = preload("res://assets/art/sprites/busboy/player/player_snoblin.png")
const SPEED: float = 160.0
const HALF_SIZE: Vector2 = Vector2(8, 8)
var facing: String = "down"
var frame_index: float = 0.0
var moving: bool = false


func hitbox() -> Rect2:
	return Rect2(position - HALF_SIZE, HALF_SIZE * 2)


func step(direction: Vector2, delta: float, obstacles: Array[Rect2], bounds: Vector2) -> void:
	direction = direction.normalized()
	moving = not direction.is_zero_approx()
	if moving:
		if absf(direction.x) > absf(direction.y):
			facing = "right" if direction.x > 0 else "left"
		else:
			facing = "down" if direction.y > 0 else "up"
		frame_index = fmod(frame_index + delta * 10.0, SHEET.get_width() / 32)
	else:
		frame_index = 0.0
	# Small substeps also prevent tunneling through thin rectangles on slow frames.
	var displacement: Vector2 = direction * SPEED * delta
	var count: int = maxi(1, ceili(displacement.length() / 4.0))
	for i: int in range(count):
		_move_axis(Vector2(displacement.x / count, 0), obstacles, bounds)
		_move_axis(Vector2(0, displacement.y / count), obstacles, bounds)
	queue_redraw()


func _move_axis(amount: Vector2, obstacles: Array[Rect2], bounds: Vector2) -> void:
	position = (position + amount).clamp(HALF_SIZE, bounds - HALF_SIZE)
	for obstacle: Rect2 in obstacles:
		if not hitbox().intersects(obstacle):
			continue
		if amount.x > 0:
			position.x = obstacle.position.x - HALF_SIZE.x
		elif amount.x < 0:
			position.x = obstacle.end.x + HALF_SIZE.x
		elif amount.y > 0:
			position.y = obstacle.position.y - HALF_SIZE.y
		elif amount.y < 0:
			position.y = obstacle.end.y + HALF_SIZE.y


func _draw() -> void:
	var row: int = 3 if facing == "down" else (5 if facing == "up" else 4)
	var column: int = int(frame_index) if moving else 1
	draw_set_transform(Vector2(0, 6), 0, Vector2(1, 0.5))
	draw_circle(Vector2.ZERO, 8, Color(0.03, 0.05, 0.04, 0.7))
	draw_set_transform(Vector2.ZERO, 0, Vector2(-1 if facing == "left" else 1, 1))
	draw_texture_rect_region(SHEET, Rect2(-16, -20, 32, 32), Rect2(column * 32, row * 32, 32, 32))
