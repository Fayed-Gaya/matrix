class_name JumpLevel
extends MatrixLevel

const FIELD_SIZE: Vector2 = Vector2(800, 400)
const WALK: Array[Texture2D] = [preload("res://levels/jump/graphics/player/player_walk_1.png"), preload("res://levels/jump/graphics/player/player_walk_2.png")]
const JUMP: Texture2D = preload("res://levels/jump/graphics/player/jump.png")
const SNAIL: Array[Texture2D] = [preload("res://levels/jump/graphics/snail/snail1.png"), preload("res://levels/jump/graphics/snail/snail2.png")]
const FLY: Array[Texture2D] = [preload("res://levels/jump/graphics/fly/Fly1.png"), preload("res://levels/jump/graphics/fly/Fly2.png")]
var active: bool = false
var player: Rect2i = Rect2i(48, 216, 64, 84)
var gravity: int = 0
var player_frame: float = 0.0
var obstacles: Array[Dictionary] = []
var score: int = 0
var start_seconds: int = 0


func _ready() -> void:
	resized.connect(fit_field)
	fit_field()
	$Spawn.timeout.connect(func() -> void:
		if active:
			spawn_obstacle("fly" if randi_range(0, 3) == 0 else "snail", randi_range(900, 1100)))
	var music: AudioStreamWAV = $Music.stream.duplicate()
	music.loop_mode = AudioStreamWAV.LOOP_FORWARD
	music.loop_end = int(music.get_length() * music.mix_rate)
	$Music.stream = music
	$Music.play()


func _exit_tree() -> void:
	$Music.stop()
	$JumpSound.stop()


func fit_field() -> void:
	var factor: float = minf(size.x / 800, size.y / 400)
	$Field.position = (size - FIELD_SIZE * factor) / 2
	$Field.scale = Vector2.ONE * factor
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE and not active:
		reset_run()
		get_viewport().set_input_as_handled()
	else:
		super._unhandled_input(event)


func reset_run() -> void:
	player = Rect2i(48, 216, 64, 84)
	gravity = 0
	player_frame = 0
	obstacles.clear()
	score = 0
	start_seconds = int(Time.get_ticks_msec() / 1000)
	active = true


func spawn_obstacle(kind: String, center_x: int) -> void:
	var dimensions: Vector2i = Vector2i(84, 40) if kind == "fly" else Vector2i(72, 36)
	var bottom: int = 210 if kind == "fly" else 300
	obstacles.append({"kind": kind, "rect": Rect2i(Vector2i(center_x - dimensions.x / 2, bottom - dimensions.y), dimensions), "frame": 0.0})


func _physics_process(_delta: float) -> void:
	if active:
		advance_tick(Input.is_physical_key_pressed(KEY_SPACE))
	$Field/Canvas.queue_redraw()


func advance_tick(jump_held: bool) -> void:
	if jump_held and player.end.y >= 300:
		gravity = -25
		$JumpSound.play()
	gravity += 1
	player.position.y += gravity
	if player.end.y >= 300:
		player.position.y = 300 - player.size.y
	if player.end.y >= 300:
		player_frame += 0.1
		if player_frame >= 2:
			player_frame = 0
	for obstacle: Dictionary in obstacles:
		obstacle.frame += 0.2 if obstacle.kind == "fly" else 0.025
		if obstacle.frame >= 2:
			obstacle.frame = 0.0
		var rect: Rect2i = obstacle.rect
		rect.position.x -= 5 if obstacle.kind == "fly" else 3
		obstacle.rect = rect
	obstacles = obstacles.filter(func(obstacle: Dictionary) -> bool: return obstacle.rect.position.x > -100)
	score = int(Time.get_ticks_msec() / 1000) - start_seconds
	for obstacle: Dictionary in obstacles:
		if player.intersects(obstacle.rect):
			active = false
			obstacles.clear()
			break


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color.BLACK)
