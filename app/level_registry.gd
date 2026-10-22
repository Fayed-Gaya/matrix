class_name LevelRegistry
extends RefCounted
## Empty scene paths explicitly identify levels awaiting migration.

const ENTRIES: Dictionary = {
	"ZELDA": {"name": "Zelda", "scene": "res://levels/zelda/zelda.tscn"},
	"BALLS": {"name": "Balls", "scene": "res://levels/balls/balls.tscn"},
	"BOUNCE": {"name": "Bouncing Ball", "scene": "res://levels/bouncing_ball/bouncing_ball.tscn"},
	"BUG": {"name": "The Bug", "scene": "res://levels/the_bug/the_bug.tscn"},
	"YOU": {"name": "You", "scene": "res://levels/you/you.tscn"},
	"UNTITLED": {"name": "Untitled Game", "scene": "res://levels/untitled/untitled.tscn"},
}


static func lookup(code: String) -> Dictionary:
	return ENTRIES.get(code.strip_edges().to_upper(), {})
