extends Control


func _draw() -> void:
	var level: BugLevel = get_parent().get_parent() as BugLevel
	draw_rect(Rect2(Vector2.ZERO, size), Color.WHITE)
	draw_texture(level.CAT, Vector2(15, 20))
	debug_text("(%d, %d)" % [level.mouse_position.x, level.mouse_position.y], Vector2(10, 10))
	var states: Array[String] = []
	for pressed: bool in level.buttons:
		states.append("True" if pressed else "False")
	debug_text("(" + ", ".join(states) + ")", Vector2(10, 40))
	debug_text("mouse!", level.mouse_position)


func debug_text(text: String, position: Vector2) -> void:
	var font: Font = ThemeDB.fallback_font
	var extent: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 22)
	draw_rect(Rect2(position, Vector2(extent.x, 26)), Color.BLACK)
	draw_string(font, position + Vector2(0, 21), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)
