class_name UntitledWorld
extends Node2D
## Native map authority; movement and dialogue read editable scene nodes.

@export var bounds: Vector2 = Vector2(800, 800)
var player_spawn: Vector2:
 get: return $PlayerSpawn.position
var collision_rects: Array[Rect2]:
 get:
  var result: Array[Rect2] = []
  for shape: CollisionShape2D in $Collisions.get_children():
   var rectangle: RectangleShape2D = shape.shape as RectangleShape2D
   result.append(Rect2(shape.position - rectangle.size / 2, rectangle.size))
  return result
var npc_data: Array[Dictionary]:
 get:
  var result: Array[Dictionary] = []
  for npc: Marker2D in $NPCs.get_children():
   result.append({"position": [npc.position.x, npc.position.y], "dialogue": npc.get_meta("dialogue", "")})
  return result
