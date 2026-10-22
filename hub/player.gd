class_name HubPlayer
extends MatrixPixelPlayer
## Hub configuration of the shared original avatar and movement component.

const SHEET: Texture2D = preload("res://hub/assets/round2/player.png")
const SPEED: float = 182.0

func _init() -> void:
	sprite_sheet = SHEET
	speed = SPEED
