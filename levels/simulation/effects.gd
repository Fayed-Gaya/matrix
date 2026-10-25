extends Node2D
var level: SimulationLevel

func _draw() -> void:
	if level == null: return
	if level.boss_phase == SimulationLevel.BossPhase.WINDUP:
		draw_circle(level.strike_target,38,Color(0.95,0.5,0.2,0.28))
		draw_arc(level.strike_target,38,0,TAU,48,Color("ffc47c"),2)
	elif level.boss_phase == SimulationLevel.BossPhase.RECOVER:
		draw_arc(level.room.get_node("Governor").position,42,0,TAU,48,Color("73d7bd"),2)
	if level.guard_left > 0:
		draw_arc(level.player.position,18,0,TAU,32,Color("9ce8ef"),3)
	if level.attack_flash > 0:
		draw_arc(level.player.position,32,-PI*0.8,PI*0.8,24,Color("fff0b6"),3)
