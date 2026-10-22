class_name PongLevel
extends MatrixLevel
## Port of Tom Chance's Tom's Pong v0.4, originally released under the GNU GPL.

const FIELD_SIZE: Vector2i = Vector2i(640, 480)
const BALL: Texture2D = preload("res://levels/tom_pong/assets/ball.png")
const BAT: Texture2D = preload("res://levels/tom_pong/assets/bat.png")
var ball: Rect2i = Rect2i(304, 224, 33, 33)
var paddles: Array[Rect2i] = [Rect2i(0, 229, 22, 22), Rect2i(618, 229, 22, 22)]
var movement: Array[int] = [0, 0]
var angle: float = 0.47
var hit: bool = false
var field_scale: float = 1.0
var field_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	resized.connect(fit_field)
	fit_field()


func fit_field() -> void:
	field_scale = minf(size.x / 640, size.y / 480)
	field_offset = (size - Vector2(FIELD_SIZE) * field_scale) / 2
	queue_redraw()


func _input(event: InputEvent) -> void:
	if not event is InputEventKey or event.echo:
		return
	var index: int = 0 if event.physical_keycode in [KEY_A, KEY_Z] else 1
	if event.physical_keycode not in [KEY_A, KEY_Z, KEY_UP, KEY_DOWN]:
		return
	if event.pressed:
		movement[index] += -10 if event.physical_keycode in [KEY_A, KEY_UP] else 10
	else:
		# Source releases either key to stop that bat, even if the other is held.
		movement[index] = 0


func _physics_process(_delta: float) -> void:
	advance_tick()


func advance_tick() -> void:
	var area: Rect2i = Rect2i(Vector2i.ZERO, FIELD_SIZE)
	ball.position += Vector2i(int(13 * cos(angle)), int(13 * sin(angle)))
	if not area.encloses(ball):
		var tl: bool = not area.has_point(ball.position)
		var tr: bool = not area.has_point(ball.position + Vector2i(ball.size.x, 0))
		var bl: bool = not area.has_point(ball.position + Vector2i(0, ball.size.y))
		var br: bool = not area.has_point(ball.end)
		if (tr and tl) or (br and bl):
			angle = -angle
		if tl and bl:
			angle = PI - angle
		if tr and br:
			angle = PI - angle
	else:
		var collided: bool = false
		for paddle: Rect2i in paddles:
			var inset: Rect2i = Rect2i(paddle.position + Vector2i.ONE, paddle.size - Vector2i(3, 3))
			if ball.intersects(inset) and not hit:
				angle = PI - angle
				hit = true
				collided = true
				break
		if not collided and hit:
			hit = false
	# The source updates the ball before the bats and rejects out-of-bounds steps.
	for index: int in range(2):
		var candidate: Rect2i = Rect2i(paddles[index].position + Vector2i(0, movement[index]), paddles[index].size)
		if area.encloses(candidate):
			paddles[index] = candidate
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color.BLACK)
	draw_set_transform(field_offset, 0, Vector2.ONE * field_scale)
	texture_clipped(BALL, ball)
	for paddle: Rect2i in paddles:
		texture_clipped(BAT, paddle)
	draw_set_transform(Vector2.ZERO)
	draw_string(ThemeDB.fallback_font, Vector2(16, size.y - 16),
		"A/Z, Up/Down: paddles    Escape: return to Matrix", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)


func texture_clipped(texture: Texture2D, rect: Rect2i) -> void:
	var visible_rect: Rect2 = Rect2(rect).intersection(Rect2(Vector2.ZERO, Vector2(FIELD_SIZE)))
	if visible_rect.has_area():
		draw_texture_rect_region(texture, visible_rect,
			Rect2(visible_rect.position - Vector2(rect.position), visible_rect.size))
