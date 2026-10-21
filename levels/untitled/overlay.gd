extends Control

const BACKGROUND: Texture2D = preload("res://levels/untitled/assets/backgrounds/environment_forestbackground.png")


func _draw() -> void:
	var level: UntitledLevel = get_parent() as UntitledLevel
	var font: Font = ThemeDB.fallback_font
	if level.opening:
		draw_texture_rect(BACKGROUND, Rect2(0, 0, 960, 540), false)
		draw_rect(Rect2(0, 0, 960, 540), Color(0, 0, 0, 92.0 / 255))
		center("Untitled Game", 222, 40)
		center("Press Space to enter the forest", 278, 28)
		center("WASD or arrows to move. E to interact.", 312, 22)
	else:
		draw_string(font, Vector2(24, 52), "Untitled Game", HORIZONTAL_ALIGNMENT_LEFT, -1, 40)
		if not level.nearby_npc().is_empty() and not level.dialogue_visible:
			draw_string(font, Vector2(24, 80), "Press E to talk", HORIZONTAL_ALIGNMENT_LEFT, -1, 22)
		if level.dialogue_visible:
			draw_rect(Rect2(58, 384, 844, 112), Color("0e1614"))
			draw_rect(Rect2(58, 384, 844, 112), Color("70bc96"), false, 2)
			var line: String = ""
			var y: float = 428
			for word: String in level.dialogue.split(" "):
				var candidate: String = word if line.is_empty() else line + " " + word
				if font.get_string_size(candidate, HORIZONTAL_ALIGNMENT_LEFT, -1, 28).x > 800:
					draw_string(font, Vector2(80, y), line, HORIZONTAL_ALIGNMENT_LEFT, -1, 28)
					line = word
					y += 26
				else:
					line = candidate
			draw_string(font, Vector2(80, y), line, HORIZONTAL_ALIGNMENT_LEFT, -1, 28)
			draw_string(font, Vector2(680, 480), "Press E to close", HORIZONTAL_ALIGNMENT_LEFT, -1, 22)


func center(text: String, y: float, font_size: int) -> void:
	var font: Font = ThemeDB.fallback_font
	var width: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	draw_string(font, Vector2((960 - width) / 2, y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
