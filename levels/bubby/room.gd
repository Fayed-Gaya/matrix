class_name BubbyRoom
extends Node2D
## All layout, collision, spawn and interaction regions are native scene nodes.

@export var bounds: Vector2 = Vector2(640, 352)
var player_spawn: Vector2:
	get: return $PlayerSpawn.position
var collision_rects: Array[Rect2]:
	get:
		var result: Array[Rect2] = []
		for shape: CollisionShape2D in $Collisions.get_children():
			var rectangle: RectangleShape2D = shape.shape as RectangleShape2D
			result.append(Rect2(shape.position - rectangle.size / 2, rectangle.size))
		return result

func region(title: String) -> Rect2:
	var marker: Control = get_node(NodePath(title)) as Control
	return Rect2(marker.position, marker.size)
