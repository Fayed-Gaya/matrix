class_name MachineRoom
extends Node2D
## Native scenes own all geometry, portal wiring, NPC dialogue and spawn points.

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

func portals() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for marker: ReferenceRect in $Portals.get_children():
		result.append({"rect":Rect2(marker.position,marker.size), "target":str(marker.get_meta("target")), "arrival":marker.get_meta("arrival",Vector2.ZERO), "label":str(marker.get_meta("label","Travel")), "needs_relays":bool(marker.get_meta("needs_relays",false))})
	return result

func npcs() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for marker: Marker2D in $NPCs.get_children():
		result.append({"position":marker.position, "name":String(marker.name), "dialogue":str(marker.get_meta("dialogue","")), "relay":str(marker.get_meta("relay",""))})
	return result
