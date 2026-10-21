extends Control

const SKY: Texture2D = preload("res://levels/jump/graphics/Sky.png")
const GROUND: Texture2D = preload("res://levels/jump/graphics/ground.png")
const STAND: Texture2D = preload("res://levels/jump/graphics/player/player_stand.png")
const FONT: Font = preload("res://levels/jump/font/Pixeltype.ttf")


func _draw() -> void:
	var level: JumpLevel = get_parent().get_parent() as JumpLevel
	if level.active:
		draw_texture(SKY, Vector2.ZERO)
		draw_texture(GROUND, Vector2(0, 300))
		center("Score: " + str(level.score), Vector2(400, 50), Color("404040"))
		var texture: Texture2D = level.JUMP if level.player.end.y < 300 else level.WALK[int(level.player_frame)]
		draw_texture(texture, Vector2(level.player.position))
		for obstacle: Dictionary in level.obstacles:
			var frames: Array[Texture2D] = level.FLY if obstacle.kind == "fly" else level.SNAIL
			draw_texture(frames[int(obstacle.frame)], Vector2(obstacle.rect.position))
	else:
		draw_rect(Rect2(Vector2.ZERO, size), Color("5e81a2"))
		draw_texture_rect(STAND, Rect2(332, 116, 136, 168), false)
		center("Jump", Vector2(400, 80), Color("6fc4a9"))
		center("Your score: " + str(level.score) if level.score > 0 else "Press space to run",
			Vector2(400, 340), Color("6fc4a9"))


func center(text: String, position: Vector2, color: Color) -> void:
	var extent: Vector2 = FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 50)
	draw_string(FONT, position + Vector2(-extent.x / 2, 16), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 50, color)
