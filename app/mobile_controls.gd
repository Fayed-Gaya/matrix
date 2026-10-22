class_name MatrixMobileControls
extends Control
## Multi-touch adapter over existing game inputs; desktop input remains unchanged.

var app: MatrixApp
var enabled: bool = false
var regions: Dictionary = {}
var fingers: Dictionary = {}
var context: String = ""
var owns_pause: bool = false

func _ready() -> void:
	app = get_parent() as MatrixApp
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	process_mode = Node.PROCESS_MODE_ALWAYS
	enabled = DisplayServer.is_touchscreen_available() or bool(get_tree().root.get_meta("matrix_force_touch", false))
	if OS.has_feature("web"):
		enabled = enabled or bool(JavaScriptBridge.eval("navigator.maxTouchPoints > 0"))
	visible = enabled
	set_process(enabled)
	set_process_input(enabled)

func _process(_delta: float) -> void:
	if OS.has_feature("web"):
		# Match CSS pixels instead of shrinking controls by the phone's devicePixelRatio.
		var css_size: Vector2i = Vector2i(int(JavaScriptBridge.eval("innerWidth")), int(JavaScriptBridge.eval("innerHeight")))
		if get_window().content_scale_size != css_size:
			get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
			get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_IGNORE
			get_window().content_scale_size = css_size
	var next: String = app.active_code
	var hub: MatrixHub = app.hub as MatrixHub
	if next.is_empty(): next = "opening" if hub.overlay.opening else ("terminal" if hub.overlay.terminal_active else "hub")
	elif next == "BUSBOY":
		var level: BusboyLevel = app.active_level as BusboyLevel
		if level.opening: next = "busboy_opening"
		elif level.encounter != null: next = "battle"
	if size.y > size.x: next = "portrait"
	if next != context:
		release_all()
		context = next
	if context == "portrait" and not get_tree().paused:
		get_tree().paused = true
		owns_pause = true
	elif context != "portrait" and owns_pause:
		get_tree().paused = false
		owns_pause = false
	layout_controls()
	queue_redraw()

func layout_controls() -> void:
	regions.clear()
	if context == "portrait": return
	if context == "opening" or context == "busboy_opening":
		regions["Begin"] = Rect2(size.x / 2 - 85, size.y - 80, 170, 52)
		if context == "opening": return
	if not app.active_code.is_empty(): regions["Matrix"] = Rect2(size.x - 126, 12, 110, 44)
	if context == "terminal":
		# Web terminal owns real DOM input/buttons. Native touch uses LineEdit.
		if not OS.has_feature("web"):
			var panel: Rect2 = ((app.hub as MatrixHub).overlay as HubOverlay).terminal_panel()
			regions["Back"] = Rect2(panel.end.x - 80, panel.position.y + 8, 68, 44)
			regions["Enter"] = Rect2(panel.position + Vector2(24, 162), Vector2(92, 44))
		return
	if context in ["battle", "busboy_opening"] or app.active_code in ["BOUNCE", "BUG", "YOU"]: return
	# Leave the world centre visible and provide two independent action fingers.
	var unit: float = 48
	var origin: Vector2 = Vector2(20, size.y - 164)
	regions["Up"] = Rect2(origin + Vector2(unit, 0), Vector2(unit, unit))
	regions["Left"] = Rect2(origin + Vector2(0, unit), Vector2(unit, unit))
	regions["Right"] = Rect2(origin + Vector2(unit * 2, unit), Vector2(unit, unit))
	regions["Down"] = Rect2(origin + Vector2(unit, unit * 2), Vector2(unit, unit))
	if app.active_code == "BALLS": return
	regions["Use"] = Rect2(size.x - 108, size.y - 74, 90, 52)
	if app.active_code in ["BUBBY", "MACHINE"]:
		regions["Shoo" if app.active_code == "BUBBY" else "Spark"] = Rect2(size.x - 210, size.y - 74, 90, 52)
	if app.active_code == "MACHINE": regions["Brace"] = Rect2(size.x - 108, size.y - 136, 90, 52)

func command_at(point: Vector2) -> String:
	for command: String in regions:
		if (regions[command] as Rect2).has_point(point): return command
	return ""

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			var command: String = command_at(event.position)
			if not command.is_empty():
				fingers[event.index] = command
				activate.call_deferred(command)
				get_viewport().set_input_as_handled()
		elif fingers.has(event.index):
			fingers.erase(event.index)
			sync_movement()
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and fingers.has(event.index):
		var previous: String = fingers[event.index]
		if previous in ["Up", "Down", "Left", "Right"]:
			fingers[event.index] = command_at(event.position)
			sync_movement()
		get_viewport().set_input_as_handled()
	if context == "portrait": get_viewport().set_input_as_handled()

func activate(command: String) -> void:
	if command in ["Up", "Down", "Left", "Right"]:
		sync_movement()
	elif command == "Enter": send_key(KEY_ENTER)
	elif command == "Matrix":
		release_all()
		app.return_to_hub()
	elif command == "Back":
		if context == "terminal": (app.hub as MatrixHub).close_terminal()
	elif command == "Begin": send_key(KEY_ENTER)
	elif command == "Use": send_key(KEY_E)
	elif command in ["Shoo", "Spark"]: send_key(KEY_SPACE)
	elif command == "Brace": send_key(KEY_SHIFT)

func send_key(code: Key) -> void:
	for pressed: bool in [true, false]:
		var key: InputEventKey = InputEventKey.new()
		key.keycode = code
		key.physical_keycode = code
		key.pressed = pressed
		get_viewport().push_input(key)

func sync_movement() -> void:
	for direction: String in ["Up", "Down", "Left", "Right"]:
		for prefix: String in ["hub_", "balls_"]:
			var action: String = prefix + direction.to_lower()
			if direction in fingers.values(): Input.action_press(action)
			else: Input.action_release(action)

func release_all() -> void:
	if is_instance_valid(app) and app.active_level is BugLevel:
		(app.active_level as BugLevel).cancel_pointer()
	fingers.clear()
	sync_movement()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT: release_all()

func _exit_tree() -> void:
	release_all()
	if owns_pause: get_tree().paused = false

func _draw() -> void:
	if context == "portrait":
		draw_rect(Rect2(Vector2.ZERO, size), Color("101c30"))
		draw_multiline_string(ThemeDB.fallback_font, Vector2(24, size.y / 2), "Rotate your phone to landscape.\nMatrix is paused.", HORIZONTAL_ALIGNMENT_CENTER, size.x - 48, 22)
		return
	for command: String in regions:
		var rect: Rect2 = regions[command]
		draw_rect(rect, Color(0.05, 0.12, 0.17, 0.87))
		draw_rect(rect, Color("88cbbd"), false, 2)
		if command in ["Up", "Down", "Left", "Right"]:
			var angle: float = {"Up":0.0, "Down":PI, "Left":-PI/2, "Right":PI/2}[command]
			var points: PackedVector2Array = PackedVector2Array()
			for point: Vector2 in [Vector2(-10,8), Vector2(0,-10), Vector2(10,8)]:
				points.append(rect.get_center() + point.rotated(angle))
			draw_colored_polygon(points, Color.WHITE)
			continue
		var font: Font = ((app.hub as MatrixHub).overlay as HubOverlay).terminal_font if context == "terminal" else ThemeDB.fallback_font
		draw_string(font, rect.position + Vector2(5, 31), command, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 10, 18, Color.WHITE)
