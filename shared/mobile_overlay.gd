class_name MatrixMobileOverlay
extends RefCounted
## Compact exploration text; each level still owns its gameplay and dialogue.

static func active(node: Node) -> bool:
	return DisplayServer.is_touchscreen_available() or bool(node.get_tree().root.get_meta("matrix_force_touch", false)) or (OS.has_feature("web") and bool(JavaScriptBridge.eval("navigator.maxTouchPoints > 0")))

static func draw(canvas: Control, title: String, objective: String, hint: String, dialogue: String) -> void:
	var font: Font = ThemeDB.fallback_font
	var size: Vector2 = canvas.size
	canvas.draw_rect(Rect2(0, 0, size.x, 76), Color(0.04, 0.08, 0.11, 0.91))
	canvas.draw_string(font, Vector2(18, 24), title, HORIZONTAL_ALIGNMENT_LEFT, size.x - 160, 19, Color("edc58a"))
	canvas.draw_multiline_string(font, Vector2(18, 47), objective, HORIZONTAL_ALIGNMENT_LEFT, size.x - 36, 16, 2, Color.WHITE)
	if not hint.is_empty():
		canvas.draw_string(font, Vector2(190, size.y - 18), hint.replace("E:", "Use:"), HORIZONTAL_ALIGNMENT_LEFT, size.x - 420, 16, Color("edc58a"))
	if not dialogue.is_empty():
		var box: Rect2 = Rect2(24, 82, size.x - 48, maxf(170, size.y - 172))
		canvas.draw_rect(box, Color("20323c"))
		canvas.draw_rect(box, Color("bd9b70"), false, 2)
		canvas.draw_multiline_string(font, box.position + Vector2(16, 26), dialogue, HORIZONTAL_ALIGNMENT_LEFT, box.size.x - 32, 17, -1, Color.WHITE)
		canvas.draw_string(font, Vector2(190, size.y - 78), "Use: continue", HORIZONTAL_ALIGNMENT_LEFT, size.x - 380, 16, Color.WHITE)
