extends Control

func _draw() -> void:
	var level: BubbyLevel = get_parent() as BubbyLevel
	if level.room == null: return
	var font: Font = ThemeDB.fallback_font
	draw_rect(Rect2(0, 0, size.x, 128), Color(0.05, 0.08, 0.1, 0.9))
	draw_string(font, Vector2(18, 26), "BUBBY · Provisional " + ("apartment" if level.room_name == "apartment" else "outside"), HORIZONTAL_ALIGNMENT_LEFT, size.x - 36, 22, Color("f2d3bc"))
	draw_multiline_string(font, Vector2(18, 50), level.objective(), HORIZONTAL_ALIGNMENT_LEFT, size.x - 36, 17, 2, Color.WHITE)
	var controls: String = "WASD/arrows: move · E: interact · Space: shoo · Escape: Matrix"
	draw_rect(Rect2(0, size.y - 42, size.x, 42), Color(0.05, 0.08, 0.1, 0.9))
	draw_string(font, Vector2(18, size.y - 15), controls, HORIZONTAL_ALIGNMENT_LEFT, size.x - 36, 16, Color("c6d5ce"))
	if level.room_name == "outside":
		draw_string(font, Vector2(18, 82), "Composure: %d/3     Pigeon: %d/3" % [level.health, level.pigeon_health], HORIZONTAL_ALIGNMENT_LEFT, size.x - 36, 16, Color("f2d3bc"))
	if not level.interaction_hint().is_empty() and level.dialogue.is_empty():
		draw_string(font, Vector2(18, size.y - 55), level.interaction_hint(), HORIZONTAL_ALIGNMENT_LEFT, size.x - 36, 20, Color("f4d39c"))
	if level.notice_time > 0 and level.dialogue.is_empty():
		draw_multiline_string(font, Vector2(18, 110), level.notice, HORIZONTAL_ALIGNMENT_LEFT, size.x - 36, 16, 1, Color("e5cba5"))
	if not level.dialogue.is_empty():
		var box: Rect2 = Rect2(24, size.y / 2 - 90, size.x - 48, 180)
		draw_rect(box, Color("202f35"))
		draw_rect(box, Color("e0b89a"), false, 2)
		draw_multiline_string(font, box.position + Vector2(20, 34), level.dialogue, HORIZONTAL_ALIGNMENT_LEFT, box.size.x - 40, 20, 5, Color.WHITE)
		draw_string(font, box.position + Vector2(20, 160), "Enter/E: continue · Escape: close", HORIZONTAL_ALIGNMENT_LEFT, box.size.x - 40, 16, Color("b9cbc1"))
