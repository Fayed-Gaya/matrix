class_name HubPlayer
extends MatrixPixelPlayer
## Hub configuration of the shared original avatar and movement component.

const SHEET: Texture2D = preload("res://shared/actors/astronaut.png")
const SPEED: float = 182.0

func _init() -> void:
	sprite_sheet = SHEET
	speed = SPEED
