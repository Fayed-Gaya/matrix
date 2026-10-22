class_name BusboyRoom
extends Node2D
## Untitled-derived native geometry/NPC reader, with explicit interaction regions.

@export var bounds: Vector2 = Vector2(640,352)
var player_spawn: Vector2:
	get: return $PlayerSpawn.position
var collision_rects: Array[Rect2]:
	get:
		var result: Array[Rect2] = []
		for shape: CollisionShape2D in $Collisions.get_children():
			if shape.disabled: continue
			var rectangle: RectangleShape2D = shape.shape as RectangleShape2D
			result.append(Rect2(shape.position - rectangle.size / 2, rectangle.size))
		return result
var npc_data: Array[Dictionary]:
	get:
		var result: Array[Dictionary] = []
		for npc: Marker2D in $NPCs.get_children():
			result.append({"position": npc.position, "dialogue": str(npc.get_meta("dialogue", ""))})
		return result

func region(title: String) -> Rect2:
	var marker: Control = get_node(NodePath(title)) as Control
	return Rect2(marker.position, marker.size)

func clear_corruption() -> void:
	$Corruption.hide()
	$Guardian.hide()
	$Collisions/CorruptionGate.disabled = true
	$Collisions/Guardian.disabled = true
