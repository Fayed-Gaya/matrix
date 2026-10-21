class_name HubWorld
extends Node2D
## Authoritative native scene. Rectangle movement reads editor shapes/markers.

@export var bounds: Vector2 = Vector2(800, 800)
var player_spawn: Vector2:
 get: return $PlayerSpawn.position
var terminal_rect: Rect2:
 get: return Rect2($Terminal.position, $Terminal.size)
var collision_rects: Array[Rect2]:
 get:
  var result: Array[Rect2] = []
  for shape: CollisionShape2D in $Collisions.get_children():
   var rectangle: RectangleShape2D = shape.shape as RectangleShape2D
   result.append(Rect2(shape.position - rectangle.size / 2, rectangle.size))
  return result
