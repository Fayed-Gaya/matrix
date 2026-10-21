@tool
class_name MatrixMapObject
extends Control
## Native editor rectangles for objects, spawns, regions and transitions.
## Resize with 2D handles; object_name/properties carry gameplay semantics.

@export var object_name: String = ""
@export var image_id: int = -1
@export var object_size: Vector2 = Vector2.ZERO:
	get: return size
	set(value): size = value
@export var properties: Dictionary = {}
static var catalog: Dictionary = {}
var editor_key: int = 0
var preview: Texture2D


func descriptor() -> Dictionary:
	return {"name": object_name, "position": [position.x, position.y],
		"size": [size.x, size.y], "image": image_id, "properties": properties.duplicate(true)}


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		var key: int = hash([image_id, object_name, properties, size])
		if key != editor_key:
			editor_key = key
			preview = null
			queue_redraw()


static func atlas_image(id: int) -> Texture2D:
	var entry: Dictionary = catalog.images[id]
	var texture: AtlasTexture = AtlasTexture.new()
	texture.atlas = load(entry.atlas)
	texture.region = Rect2(entry.rect[0],entry.rect[1],entry.rect[2],entry.rect[3])
	return texture


func _draw() -> void:
	if not Engine.is_editor_hint(): return
	if catalog.is_empty():
		catalog = JSON.parse_string(FileAccess.get_file_as_string("res://levels/monsters/assets/manifest.json"))
	if preview == null:
		if image_id >= 0:
			preview = atlas_image(image_id)
		elif get_parent() != null and get_parent().name == "Coast":
			preview = atlas_image(int(catalog.sheets["coast/"+str(properties.get("terrain","grass"))][properties.get("side","top")][0]))
		elif get_parent() != null and get_parent().name == "Water":
			preview = load(catalog.frames["tilesets/water"][0])
		elif get_parent() != null and get_parent().name == "Entities":
			var graphic: String = "player" if object_name == "Player" else str(properties.get("graphic","player"))
			preview = atlas_image(int(catalog.sheets["characters/"+graphic]["down_idle"][0]))
	if preview != null:
		if get_parent().name == "Water":
			draw_texture_rect(preview,Rect2(Vector2.ZERO,size),true)
		else:
			draw_texture(preview,-preview.get_size()/2 if get_parent().name == "Entities" else Vector2.ZERO)
	var dimensions: Vector2 = size.max(Vector2(12,12))
	draw_rect(Rect2(Vector2.ZERO,dimensions),Color(0.1,0.8,1.0,0.8),false,1.0)
	draw_line(Vector2(-6,0),Vector2(6,0),Color.YELLOW)
	draw_line(Vector2(0,-6),Vector2(0,6),Color.YELLOW)
