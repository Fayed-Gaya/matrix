extends Node2D

const SHEET: Texture2D = preload("res://levels/busboy/assets/refinement/waykeeper.png")


func _draw() -> void:
	draw_set_transform(Vector2(0, 6), 0, Vector2(1, 0.5))
	draw_circle(Vector2.ZERO, 8, Color(0.03, 0.05, 0.04, 0.7))
	draw_set_transform(Vector2.ZERO)
	draw_texture_rect_region(SHEET, Rect2(-16, -28, 32, 32), Rect2(32, 96, 32, 32))
