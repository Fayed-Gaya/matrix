class_name LevelRegistry
extends RefCounted
## Empty scene paths explicitly identify levels awaiting migration.

const ENTRIES: Dictionary = {
	"JUMP": {"name": "Jump", "scene": ""},
	"MARIO": {"name": "Mario", "scene": ""},
	"MONSTERS": {"name": "Monsters", "scene": ""},
	"ZELDA": {"name": "Zelda", "scene": ""},
	"PONG": {"name": "Tom Pong", "scene": ""},
	"BALLS": {"name": "Balls", "scene": ""},
	"BOUNCE": {"name": "Bouncing Ball", "scene": ""},
	"BUG": {"name": "The Bug", "scene": ""},
	"YOU": {"name": "You", "scene": ""},
	"UNTITLED": {"name": "Untitled Game", "scene": ""},
}


static func lookup(code: String) -> Dictionary:
	return ENTRIES.get(code.strip_edges().to_upper(), {})
