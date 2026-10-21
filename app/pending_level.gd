extends MatrixLevel
## Honest temporary destination for registered, not-yet-ported levels.

var level_name: String = "Level"


func _ready() -> void:
	$Message.text = level_name + "\nThis level has not been migrated yet.\nPress Escape to return to Matrix."
	$Return.pressed.connect(func() -> void: return_requested.emit())
