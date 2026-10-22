extends Control
## Bubby's own warm paper/plum HUD; world-space marks follow the scaled viewport.

func _draw() -> void:
	var level: BubbyLevel = get_parent() as BubbyLevel
	if level.room == null: return
	var font: Font = ThemeDB.fallback_font
	var mobile: bool = MatrixMobileOverlay.active(self)
	var scale_factor: float = level.display.size.x / 640.0
	var origin: Vector2 = level.display.position
	var ink: Color = Color("ede0c9")
	if level.room_name == "outside" and level.boss_state in ["tell", "hop"]:
		var target: Vector2 = origin + level.hop_target * scale_factor
		draw_circle(target, 52 * scale_factor, Color(0.79, 0.47, 0.43, 0.22))
		draw_arc(target, 52 * scale_factor, 0, TAU, 64, Color("e4ab8c"), 2)
		draw_line(target - Vector2(9, 0), target + Vector2(9, 0), ink, 2)
		draw_line(target - Vector2(0, 9), target + Vector2(0, 9), ink, 2)
	if level.shoo_flash > 0:
		var centre: Vector2 = origin + level.player.position * scale_factor
		draw_arc(centre, (32 + (0.25 - level.shoo_flash) * 150) * scale_factor, -PI, 0, 20, Color("f6dda9"), 2)
	draw_rect(Rect2(0, 0, size.x, 76), Color("38313fee"))
	draw_line(Vector2(0, 75), Vector2(size.x, 75), Color("b79a8c"))
	var location: String = "APARTMENT" if level.room_name == "apartment" else "BALCONY"
	draw_string(font, Vector2(20, 26), "BUBBY / " + location, HORIZONTAL_ALIGNMENT_LEFT, size.x - 170, 20, ink)
	draw_string(font, Vector2(20, 50), level.objective(), HORIZONTAL_ALIGNMENT_LEFT, size.x - 40, 16, Color("d0c0ba"))
	if level.room_name == "outside" and not level.complete:
		var x: float = minf(size.x - 300, 310)
		for i: int in range(BubbyLevel.MAX_COMPOSURE):
			draw_circle(Vector2(x + i * 14, 21), 4, Color("d9a68c") if i < level.health else Color("685766"))
		draw_string(font, Vector2(x + 80, 26), "Composure", HORIZONTAL_ALIGNMENT_LEFT, 110, 13, ink)
		for i: int in range(BubbyLevel.MAX_PIGEON):
			draw_rect(Rect2(20 + i * 18, 60, 14, 5), Color("a9b6a2") if i < level.pigeon_health else Color("655465"))
		var phase: String = "SHOO WINDOW" if level.boss_state == "rest" else ("STEP ASIDE" if level.boss_state in ["tell", "hop"] else "THE GRAND COO")
		draw_string(font, Vector2(138, 67), phase, HORIZONTAL_ALIGNMENT_LEFT, 220, 12, Color("ddc9a6"))
	if not mobile:
		draw_rect(Rect2(0, size.y - 32, size.x, 32), Color("38313fee"))
		draw_string(font, Vector2(20, size.y - 11), "WASD / arrows: move     E: use     Space: shoo     Esc: Matrix", HORIZONTAL_ALIGNMENT_LEFT, size.x - 40, 15, ink)
	var hint: String = level.interaction_hint()
	if not hint.is_empty() and level.dialogue.is_empty():
		var pos: Vector2 = Vector2(190 if mobile else 20, size.y - (84 if mobile else 43))
		draw_string(font, pos, hint, HORIZONTAL_ALIGNMENT_LEFT, size.x - (400 if mobile else 40), 15, Color("f0d5ab"))
	if not level.dialogue.is_empty():
		var box: Rect2 = Rect2(24, 88 if mobile else size.y / 2 - 116, size.x - 48, size.y - 184 if mobile else 232)
		draw_rect(box, Color("413745f8"))
		draw_rect(box.grow(-5), Color("ac8d85"), false, 1)
		draw_multiline_string(font, box.position + Vector2(20, 30), level.dialogue, HORIZONTAL_ALIGNMENT_LEFT, box.size.x - 40, 17 if mobile else 20, -1, ink)
		draw_string(font, box.position + Vector2(20, box.size.y - 20), "Use / Enter: continue", HORIZONTAL_ALIGNMENT_LEFT, box.size.x - 40, 15, Color("cfb0a2"))
	elif level.notice_time > 0:
		draw_rect(Rect2(12, 82, size.x - 24, 29), Color("413745dc"))
		draw_string(font, Vector2(22, 102), level.notice, HORIZONTAL_ALIGNMENT_LEFT, size.x - 44, 14, ink)
