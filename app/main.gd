class_name MatrixApp
extends Control
## Keeps the hub in memory; only the active level is replaced and freed.

const HUB_SCENE: PackedScene = preload("res://hub/hub.tscn")
const PENDING_SCENE: PackedScene = preload("res://app/pending_level.tscn")
var hub: Control
var active_level: MatrixLevel
var active_code: String = ""
var transitioning: bool = false


func _ready() -> void:
	hub = HUB_SCENE.instantiate()
	add_child(hub)
	hub.level_requested.connect(launch_level)
	print("Matrix hub ready")
	if OS.has_feature("web"):
		add_child(preload("res://app/web_diagnostics.gd").new())


func launch_level(code: String) -> void:
	var entry: Dictionary = LevelRegistry.lookup(code)
	if entry.is_empty() or active_level != null or transitioning:
		return
	transitioning = true
	_enter_level.call_deferred(code.strip_edges().to_upper(), entry)


func _enter_level(code: String, entry: Dictionary) -> void:
	var scene: PackedScene = PENDING_SCENE
	if not entry.scene.is_empty():
		scene = load(entry.scene) as PackedScene
	if scene == null:
		push_error("Unable to load level: " + code)
		transitioning = false
		return
	var instance: Node = scene.instantiate()
	if not instance is MatrixLevel:
		instance.free()
		push_error("Level must extend MatrixLevel: " + code)
		transitioning = false
		return
	active_level = instance as MatrixLevel
	if entry.scene.is_empty():
		active_level.level_name = entry.name
	active_code = code
	hub.suspend()
	active_level.return_requested.connect(return_to_hub)
	add_child(active_level)
	transitioning = false


func return_to_hub() -> void:
	if active_level == null or transitioning:
		return
	transitioning = true
	_leave_level.call_deferred()


func _leave_level() -> void:
	remove_child(active_level)
	active_level.queue_free()
	active_level = null
	active_code = ""
	hub.resume()
	transitioning = false
