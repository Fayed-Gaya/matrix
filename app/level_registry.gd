class_name LevelRegistry
extends RefCounted
## Empty scene paths explicitly identify levels awaiting migration.

const ENTRIES: Dictionary = {
	"MACHINE": {"name":"Machine", "scene":"res://levels/machine/machine.tscn"},
	"BUBBY": {"name": "Bubby", "scene": "res://levels/bubby/bubby.tscn"},
	"BALLS": {"name": "Balls", "scene": "res://levels/balls/balls.tscn"},
	"BOUNCE": {"name": "Bouncing Ball", "scene": "res://levels/bouncing_ball/bouncing_ball.tscn"},
	"BUG": {"name": "The Bug", "scene": "res://levels/the_bug/the_bug.tscn"},
	"YOU": {"name": "You", "scene": "res://levels/you/you.tscn"},
	"BUSBOY": {"name": "Busboy", "scene": "res://levels/busboy/busboy.tscn"},
}


static func lookup(code: String) -> Dictionary:
	return ENTRIES.get(code.strip_edges().to_upper(), {})
