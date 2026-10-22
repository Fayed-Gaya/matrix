class_name HubOverlay
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
		_center("Tap Begin" if MatrixMobileOverlay.active(self) else "Press any key to begin", size.y * 0.72, 26, GREEN)
	elif terminal_active:
		_draw_terminal()
	elif near_terminal:
		_center("Tap Use to access terminal" if MatrixMobileOverlay.active(self) else "Press E to access terminal", size.y - 22, 22, TEXT)


func _center(text: String, y: float, font_size: int, color: Color) -> void:
	var font: Font = ThemeDB.fallback_font
	var width: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	draw_string(font, Vector2((size.x - width) / 2 + 2, y + 2), text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.BLACK)
	draw_string(font, Vector2((size.x - width) / 2, y), text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


func terminal_panel() -> Rect2:
	var extent: Vector2 = Vector2(minf(860, size.x - 40), minf(440, size.y - 40))
	return Rect2(((size - extent) / 2).floor(), extent)


func code_rect(index: int) -> Rect2:
	var panel: Rect2 = terminal_panel()
	var width: float = (panel.size.x - 60) / 4
	return Rect2(panel.position + Vector2(20 + (index % 4) * (width + 6), 92 + (index / 4) * 58), Vector2(width, 48))


func _draw_terminal() -> void:
	var panel: Rect2 = terminal_panel()
	var origin: Vector2 = panel.position
	var font: Font = ThemeDB.fallback_font
	# Keep the cabin visible behind a deliberately sized monitor-like panel.
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.06, 0.09, 0.85))
	draw_rect(Rect2(origin + Vector2(6, 8), panel.size), Color("071017"))
	draw_rect(panel, Color("101f27"))
	draw_rect(panel, Color("718c87"), false, 2)
	draw_rect(Rect2(origin + Vector2(1, 1), Vector2(panel.size.x - 2, 54)), Color("1b3339"))
	draw_rect(Rect2(origin + Vector2(20, 20), Vector2(4, 14)), GREEN)
	draw_string(font, origin + Vector2(36, 35), "MATRIX / WORLD ACCESS", HORIZONTAL_ALIGNMENT_LEFT, panel.size.x - 180, 22, TEXT)
	draw_string(font, origin + Vector2(20, 76), "SELECT A DESTINATION" if MatrixMobileOverlay.active(self) else "AVAILABLE CODES", HORIZONTAL_ALIGNMENT_LEFT, panel.size.x - 40, 14, MUTED)
	if not MatrixMobileOverlay.active(self):
		var codes: Array = LevelRegistry.ENTRIES.keys()
		for i: int in range(codes.size()):
			var slot: Rect2 = code_rect(i)
			draw_rect(slot, Color("183037"))
			draw_rect(slot, Color("365b59"), false)
			draw_string(font, slot.position + Vector2(12, 30), str(codes[i]), HORIZONTAL_ALIGNMENT_LEFT, slot.size.x - 20, 18, GREEN)
	var prompt: Rect2 = Rect2(origin + Vector2(20, panel.size.y - 88), Vector2(panel.size.x - 40, 42))
	draw_rect(prompt, Color("09191e"))
	draw_rect(prompt, Color("568e80"), false)
	draw_string(font, prompt.position + Vector2(12, 28), "> " + input_text + "_", HORIZONTAL_ALIGNMENT_LEFT, prompt.size.x - 24, 23, GREEN)
	if not message.is_empty():
		draw_string(font, prompt.position + Vector2(0, -12), message, HORIZONTAL_ALIGNMENT_LEFT, prompt.size.x, 16, Color("e9b28e"))
	draw_string(font, origin + Vector2(20, panel.size.y - 18), "Tap a code to enter / Back to cabin" if MatrixMobileOverlay.active(self) else "TYPE CODE + ENTER    /    ESC RETURN TO CABIN", HORIZONTAL_ALIGNMENT_LEFT, panel.size.x - 40, 14, MUTED)
