class_name PegasusOverlay
extends Control
## Full-window opening and terminal rendering, separate from the pixel world.

const TEXT: Color = Color("e2efeb")
const MUTED: Color = Color("91a4a6")
const GREEN: Color = Color("6fe89e")
var terminal_font: SystemFont = SystemFont.new()
var native_input: LineEdit
var opening: bool = true
var terminal_active: bool = false
var near_terminal: bool = false
var input_text: String = ""
var message: String = ""


func _ready() -> void:
	terminal_font.font_names = PackedStringArray(["Menlo", "DejaVu Sans Mono", "Liberation Mono", "monospace"])
	native_input = LineEdit.new()
	native_input.name = "TerminalInput"
	native_input.max_length = 18
	native_input.virtual_keyboard_enabled = true
	native_input.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_DEFAULT
	native_input.add_theme_font_override("font", terminal_font)
	native_input.add_theme_font_size_override("font_size", 24)
	native_input.add_theme_color_override("font_color", GREEN)
	for style: String in ["normal", "focus", "read_only"]:
		native_input.add_theme_stylebox_override(style, StyleBoxEmpty.new())
	native_input.text_changed.connect(func(value: String) -> void: input_text = value.to_upper())
	native_input.text_submitted.connect(func(value: String) -> void:
		input_text = value.to_upper()
		(get_parent() as Pegasus).submit_code())
	add_child(native_input)
	native_input.hide()


func _process(_delta: float) -> void:
	native_input.visible = terminal_active and MatrixMobileOverlay.active(self) and not OS.has_feature("web")
	if native_input.visible:
		native_input.position = terminal_panel().position + Vector2(46, 64)
		native_input.size = Vector2(terminal_panel().size.x - 76, 48)
		if native_input.text != input_text:
			native_input.text = input_text
			native_input.caret_column = input_text.length()


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
	var extent: Vector2 = Vector2(minf(800, size.x - 32), minf(350, size.y - 24))
	return Rect2(((size - extent) / 2).floor(), extent)


func _draw_terminal() -> void:
	# Web owns the complete terminal in DOM. Do not draw a hidden second UI:
	# Firefox/macOS rejects the engine's thin-line canvas shader variant.
	if OS.has_feature("web"):
		return
	var panel: Rect2 = terminal_panel()
	var origin: Vector2 = panel.position
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.01, 0.03, 0.03, 0.94))
	draw_rect(panel, Color("030b09"))
	draw_rect(panel, Color("305846"), false)
	draw_string(terminal_font, origin + Vector2(24, 34), "MATRIX", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("4d7966"))
	draw_string(terminal_font, origin + Vector2(panel.size.x - 62, 34), "ESC", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, MUTED)
	var at: Vector2 = origin + Vector2(24, 94)
	draw_string(terminal_font, at, ">", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, GREEN)
	if not native_input.visible:
		draw_string(terminal_font, at + Vector2(24, 0), input_text + "_", HORIZONTAL_ALIGNMENT_LEFT, panel.size.x - 76, 24, GREEN)
	draw_line(origin + Vector2(24, 112), origin + Vector2(panel.size.x - 24, 112), Color("234b3a"))
	if not message.is_empty():
		draw_string(terminal_font, origin + Vector2(24, 152), message, HORIZONTAL_ALIGNMENT_LEFT, panel.size.x - 48, 16, Color("b39472"))
