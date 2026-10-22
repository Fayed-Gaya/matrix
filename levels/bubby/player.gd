class_name BubbyPlayer
extends Node2D
## Zelda-derived axis-separated exploration, with substeps and scaled source frames.
## Existing tutorial avatar is provisional, not a depiction of Kate.

const SPEED: float = 135.0
const HALF_SIZE: Vector2 = Vector2(14.5, 9.5)
var facing: String = "down"
var frame_index: float = 0.0
var moving: bool = false
var action_time: float = 0.0
var frames: Dictionary = {}

func _ready() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://levels/bubby/assets/manifest.json"))
	for key: String in data.frames:
		var textures: Array[Texture2D] = []
		for path: String in data.frames[key]: textures.append(load(path))
		frames[key] = textures

func hitbox() -> Rect2:
	return Rect2(position - HALF_SIZE, HALF_SIZE * 2)

func step(direction: Vector2, delta: float, obstacles: Array[Rect2], bounds: Vector2) -> void:
	action_time = maxf(0, action_time - delta)
	direction = direction.normalized()
	moving = not direction.is_zero_approx()
	if moving:
		facing = ("right" if direction.x > 0 else "left") if absf(direction.x) > absf(direction.y) else ("down" if direction.y > 0 else "up")
		frame_index += delta * 9.0
	else:
		frame_index = 0
	var displacement: Vector2 = direction * SPEED * delta
	var steps: int = maxi(1, ceili(displacement.length() / 4.0))
	for i: int in range(steps):
		move_axis(Vector2(displacement.x / steps, 0), obstacles, bounds)
		move_axis(Vector2(0, displacement.y / steps), obstacles, bounds)
	queue_redraw()

func move_axis(amount: Vector2, obstacles: Array[Rect2], bounds: Vector2) -> void:
	position = (position + amount).clamp(HALF_SIZE, bounds - HALF_SIZE)
	for obstacle: Rect2 in obstacles:
		if not hitbox().intersects(obstacle): continue
		if amount.x > 0: position.x = obstacle.position.x - HALF_SIZE.x
		elif amount.x < 0: position.x = obstacle.end.x + HALF_SIZE.x
		elif amount.y > 0: position.y = obstacle.position.y - HALF_SIZE.y
		elif amount.y < 0: position.y = obstacle.end.y + HALF_SIZE.y

func _draw() -> void:
	if frames.is_empty(): return
	var state: String = facing + ("_attack" if action_time > 0 else ("" if moving else "_idle"))
	var images: Array = frames["player/" + state]
	var picture: Texture2D = images[int(frame_index) % images.size()]
	draw_set_transform(Vector2(0, 6), 0, Vector2(1, 0.5))
	draw_circle(Vector2.ZERO, 10, Color(0.1, 0.1, 0.1, 0.3))
	draw_set_transform(Vector2.ZERO)
	draw_texture_rect(picture, Rect2(-16, -23, 32, 32), false)
