extends Control
## Clip edge/corner copies to the logical field, as the Pygame window did.


func _draw() -> void:
	var level: BallsLevel = get_parent().get_parent() as BallsLevel
	draw_rect(Rect2(Vector2.ZERO, size), level.BACKGROUND)
	for center: Vector2 in level.drawn_positions:
		for wrapped: Vector2 in level.wrapped_centers(center):
			draw_circle(wrapped, level.RADIUS, Color.RED)
