extends Control

func _draw() -> void:
	var level: SimulationLevel = get_parent() as SimulationLevel
	if level.room == null: return
	if MatrixMobileOverlay.active(self):
		MatrixMobileOverlay.draw(self, "SIMULATION · Draft", level.objective() + (" · You %d/5 · Governor %d/6" % [level.health, level.boss_health] if level.room_name == "outskirts" else ""), level.interaction_hint(), level.dialogue)
		return
	var font: Font = ThemeDB.fallback_font
	draw_rect(Rect2(0,0,size.x,128),Color(0.05,0.08,0.11,0.92))
	draw_string(font,Vector2(18,26),"SIMULATION · The quiet hour · Draft",HORIZONTAL_ALIGNMENT_LEFT,size.x-36,22,Color("edc58a"))
	draw_multiline_string(font,Vector2(18,52),level.objective(),HORIZONTAL_ALIGNMENT_LEFT,size.x-36,18,2,Color.WHITE)
	if level.notice_time > 0:
		draw_string(font,Vector2(18,110),level.notice,HORIZONTAL_ALIGNMENT_LEFT,size.x-36,16,Color("c6d7d5"))
	if level.room_name == "outskirts" and not level.complete:
		var phase: String = "Press E near the governor"
		if level.boss_phase == SimulationLevel.BossPhase.WINDUP: phase = "Orange pulse: move away or brace"
		elif level.boss_phase == SimulationLevel.BossPhase.RECOVER: phase = "Green ring: get close and spark"
		draw_string(font,Vector2(18,82),"You: %d/5 · Governor: %d/6 · %s" % [level.health,level.boss_health,phase],HORIZONTAL_ALIGNMENT_LEFT,size.x-36,16,Color("edc58a"))
	draw_rect(Rect2(0,size.y-42,size.x,42),Color(0.05,0.08,0.11,0.92))
	draw_string(font,Vector2(18,size.y-15),"WASD/arrows: move · E: interact · Space: spark · Shift: brace · Escape: Matrix",HORIZONTAL_ALIGNMENT_LEFT,size.x-36,16,Color("c6d7d5"))
	if not level.interaction_hint().is_empty():
		draw_string(font,Vector2(18,size.y-55),level.interaction_hint(),HORIZONTAL_ALIGNMENT_LEFT,size.x-36,20,Color("edc58a"))
	if not level.dialogue.is_empty():
		var box: Rect2 = Rect2(24,size.y/2-100,size.x-48,210)
		draw_rect(box,Color("20323c"))
		draw_rect(box,Color("bd9b70"),false,2)
		draw_multiline_string(font,box.position+Vector2(20,34),level.dialogue,HORIZONTAL_ALIGNMENT_LEFT,box.size.x-40,20,6,Color.WHITE)
		draw_string(font,box.position+Vector2(20,190),"E/Enter: continue · Escape: close",HORIZONTAL_ALIGNMENT_LEFT,box.size.x-40,16,Color("c6d7d5"))
