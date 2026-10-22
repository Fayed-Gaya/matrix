extends Control
## Full-window opening and terminal rendering, separate from the pixel world.

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
		draw_rect(Rect2(Vector2.ZERO, size), Color("101c30"))
		for i: int in range(64):
			var star: Vector2 = Vector2(fposmod(i * 173.0 + 41.0, size.x), fposmod(i * 97.0 + 19.0, size.y))
			draw_rect(Rect2(star, Vector2(2, 2)), MUTED if i % 3 else GREEN)
		_center("MATRIX", size.y * 0.42, 64, TEXT)
		_center("A quiet cabin. A thousand possible worlds.", size.y * 0.52, 22, MUTED)
		_center("Press any key to begin", size.y * 0.72, 26, GREEN)
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
