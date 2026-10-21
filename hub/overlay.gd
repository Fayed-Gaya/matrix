extends Control
## Full-window opening and terminal rendering, separate from the pixel world.

const BACKGROUND: Texture2D = preload("res://hub/assets/backgrounds/matrix-opening.jpg")
const TEXT: Color = Color("e2efeb")
const MUTED: Color = Color("91a4a6")
const GREEN: Color = Color("6fe89e")
var opening: bool = true
var terminal_active: bool = false
var near_terminal: bool = false
var input_text: String = ""
var message: String = ""


func _draw() -> void:
	var font: Font = ThemeDB.fallback_font
	if opening:
		var factor: float = maxf(size.x / BACKGROUND.get_width(), size.y / BACKGROUND.get_height())
		var crop: Vector2 = size / factor
		draw_texture_rect_region(BACKGROUND, Rect2(Vector2.ZERO, size),
			Rect2((BACKGROUND.get_size() - crop) / 2, crop))
		_center("Press start (any key) to begin", size.y - 52, 34, TEXT)
		_center("MATRIX", size.y - 18, 28, MUTED)
	elif terminal_active:
		draw_rect(Rect2(Vector2.ZERO, size), Color("02080a"))
		var prompt: Rect2 = Rect2(28, size.y - 76, maxf(1, size.x - 56), 46)
		draw_rect(prompt, Color("001210"))
		draw_rect(prompt, Color("5cbeff"), false)
		draw_string(font, prompt.position + Vector2(14, 32), "> " + input_text,
			HORIZONTAL_ALIGNMENT_LEFT, prompt.size.x - 28, 28, GREEN)
		if not message.is_empty():
			draw_string(font, Vector2(30, size.y - 90), message,
				HORIZONTAL_ALIGNMENT_LEFT, size.x - 60, 22, Color("ff7070"))
	elif near_terminal:
		_center("Press E to access terminal", size.y - 22, 22, TEXT)


func _center(text: String, y: float, font_size: int, color: Color) -> void:
	var font: Font = ThemeDB.fallback_font
	var width: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	draw_string(font, Vector2((size.x - width) / 2 + 2, y + 2), text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.BLACK)
	draw_string(font, Vector2((size.x - width) / 2, y), text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
