class_name MatrixLevel
extends Control
## A level owns all of its nodes/audio/timers below this root.
## Emit return_requested to leave; consume Escape locally to close menus first.

signal return_requested


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("return_to_hub"):
		get_viewport().set_input_as_handled()
		return_requested.emit()
