extends Node
## Opt-in, read-only browser smoke telemetry. Never launches or mutates gameplay.

var app: MatrixApp
var bridge: Object


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	app = get_parent() as MatrixApp
	if not OS.has_feature("web"):
		set_process(false)
		return
	bridge = Engine.get_singleton("JavaScriptBridge")
	set_process(bool(bridge.call("eval","new URLSearchParams(location.search).get('matrix_smoke') === '1'")))


func _process(_delta: float) -> void:
	var hub: MatrixHub = app.hub as MatrixHub
	var state: Dictionary = {
		"touch": app.mobile_controls.enabled, "touch_context": app.mobile_controls.context,
		"touch_regions": touch_regions(), "touch_held": app.mobile_controls.fingers.values(),
		"code": app.active_code, "opening": hub.overlay.opening,
		"terminal": hub.overlay.terminal_active, "near_terminal": hub.is_near_terminal(),
		"x": hub.player.position.x, "y": hub.player.position.y,
		"width": app.size.x, "height": app.size.y,
		"scene": app.active_level.scene_file_path if app.active_level != null else "",
		"camera_status": app.active_level.get_node("Status").text if app.active_code == "YOU" else "",
	}
	if app.active_level is BubbyLevel:
		var level: BubbyLevel = app.active_level as BubbyLevel
		state["bubby"] = {"room": level.room_name, "x": level.player.position.x, "y": level.player.position.y,
			"phase": level.boss_state, "composure": level.health, "resolve": level.pigeon_health,
			"dialogue": not level.dialogue.is_empty(), "complete": level.complete,
			"bird_x": level.pigeon.position.x if is_instance_valid(level.pigeon) else 0,
			"bird_y": level.pigeon.position.y if is_instance_valid(level.pigeon) else 0}
	bridge.call("eval","document.documentElement.setAttribute('data-matrix-state', %s)" % JSON.stringify(JSON.stringify(state)))

func touch_regions() -> Dictionary:
	var result: Dictionary = {}
	for command: String in app.mobile_controls.regions:
		var rect: Rect2 = app.mobile_controls.regions[command]
		result[command] = [rect.get_center().x, rect.get_center().y]
	return result
