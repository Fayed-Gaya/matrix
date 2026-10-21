@tool
class_name MatrixMapObject
extends Node2D
## Move/duplicate these in the 2D editor. Region dimensions and behavior are
## editable in the Inspector; the runtime reads these nodes, never TMX/JSON maps.

@export var object_name: String = ""
@export var image_id: int = -1:
	set(value):
		image_id = value
		queue_redraw()
@export var object_size: Vector2 = Vector2.ZERO:
	set(value):
		object_size = value
		queue_redraw()
@export var properties: Dictionary = {}
var preview: Texture2D
var preview_id: int = -2


func descriptor() -> Dictionary:
	return {"name": object_name, "position": [position.x, position.y],
		"size": [object_size.x, object_size.y], "image": image_id, "properties": properties.duplicate(true)}


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	if preview_id != image_id:
		preview_id = image_id
		preview = null
		if image_id >= 0:
			var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://levels/monsters/assets/manifest.json"))
			var entry: Dictionary = data.images[image_id]
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = load(entry.atlas)
			atlas.region = Rect2(entry.rect[0], entry.rect[1], entry.rect[2], entry.rect[3])
			preview = atlas
	if preview != null:
		draw_texture(preview, Vector2.ZERO)
	var dimensions: Vector2 = object_size.max(Vector2(12,12))
	draw_rect(Rect2(Vector2.ZERO, dimensions), Color(0.1,0.8,1.0,0.8), false, 1.0)
	draw_line(Vector2(-6,0), Vector2(6,0), Color.YELLOW)
	draw_line(Vector2(0,-6), Vector2(0,6), Color.YELLOW)
