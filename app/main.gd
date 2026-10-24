class_name MatrixApp
extends Control
## Keeps the pegasus in memory; only the active level is replaced and freed.

const PEGASUS_SCENE: PackedScene = preload("res://pegasus/pegasus.tscn")
const PENDING_SCENE: PackedScene = preload("res://app/pending_level.tscn")
var mobile_controls: MatrixMobileControls
var pegasus: Control
var active_level: MatrixLevel
var active_code: String = ""
var transitioning: bool = false


func _ready() -> void:
	pegasus = PEGASUS_SCENE.instantiate()
	add_child(pegasus)
	pegasus.level_requested.connect(launch_level)
	mobile_controls = preload("res://app/mobile_controls.gd").new()
	add_child(mobile_controls)
	print("Matrix pegasus ready")
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
	pegasus.suspend()
	active_level.return_requested.connect(return_to_pegasus)
	add_child(active_level)
	move_child(mobile_controls, -1)
	transitioning = false


func return_to_pegasus() -> void:
	if active_level == null or transitioning:
		return
	transitioning = true
	_leave_level.call_deferred()


func _leave_level() -> void:
	remove_child(active_level)
	active_level.queue_free()
	active_level = null
	active_code = ""
	pegasus.resume()
	transitioning = false
