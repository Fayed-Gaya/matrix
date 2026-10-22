extends SceneTree

var failures: int = 0

func _initialize() -> void:
	run.call_deferred()

func check(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error(message)

func settle() -> void:
	await process_frame
	await process_frame

func touch(index: int, position: Vector2, pressed: bool) -> void:
	var event: InputEventScreenTouch = InputEventScreenTouch.new()
	event.index = index
	event.position = position
	event.pressed = pressed
	root.push_input(event)

func run() -> void:
	root.set_meta("matrix_test_mode", true)
	root.set_meta("matrix_force_touch", true)
	root.size = Vector2i(1280, 720)
	var app: MatrixApp = load("res://app/main.tscn").instantiate() as MatrixApp
	root.add_child(app)
	await settle()
	var controls: MatrixMobileControls = app.mobile_controls
	check(controls.enabled and controls.context == "opening", "Touch opening available")
	controls.activate("Begin")
	await settle()
	check(not (app.hub as MatrixHub).overlay.opening, "Touch begins game")
	touch(1, (controls.regions["Right"] as Rect2).get_center(), true)
	await settle()
	check(Input.is_action_pressed("hub_right"), "Touch holds movement")
	touch(2, (controls.regions["Up"] as Rect2).get_center(), true)
	await settle()
	check(Input.is_action_pressed("hub_right") and Input.is_action_pressed("hub_up"), "Independent fingers allow diagonal movement")
	touch(1, Vector2.ZERO, false)
	await settle()
	check(not Input.is_action_pressed("hub_right") and Input.is_action_pressed("hub_up"), "Releasing outside retains other finger")
	controls._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(not Input.is_action_pressed("hub_up"), "Focus loss releases movement")
	for code: String in LevelRegistry.ENTRIES:
		(app.hub as MatrixHub).open_terminal()
		await settle()
		check(not controls.regions.has(code), "Touch terminal never advertises " + code)
		var field: LineEdit = (app.hub as MatrixHub).overlay.native_input
		check(field.visible and field.virtual_keyboard_enabled, "Native touch terminal uses real LineEdit")
		field.text_submitted.emit(code.to_lower())
		await settle()
		check(app.active_code == code, "Touch code routes " + code)
		if code == "BUBBY":
			var bubby: BubbyLevel = app.active_level as BubbyLevel
			bubby.show_room("outside")
			bubby.player.position = bubby.pigeon.position
			controls.activate("Shoo")
			check(bubby.pigeon_health == 2, "Shoo touch button reaches combat input")
			bubby.dialogue = "Fixture conversation"
			controls.activate("Use")
			check(bubby.dialogue.is_empty(), "Use closes narrative dialogue")
		if code == "MACHINE":
			var machine: MachineLevel = app.active_level as MachineLevel
			machine.show_room("outskirts")
			machine.player.position = machine.room.get_node("Governor").position
			machine.boss_phase = MachineLevel.BossPhase.RECOVER
			controls.activate("Spark")
			check(machine.boss_health == 5, "Spark touch button reaches combat input")
			controls.activate("Brace")
			check(machine.guard_left > 0, "Brace touch button reaches combat input")
		if code == "BUSBOY":
			controls.activate("Begin")
			check(not (app.active_level as BusboyLevel).opening, "Touch begins Busboy opening")
		if code == "BUG":
			var bug: BugLevel = app.active_level as BugLevel
			var point: Vector2 = bug.field_offset + Vector2(123, 234) * bug.field_scale
			touch(9, point, true)
			check(bug.buttons[0] and bug.mouse_position == Vector2(123,234), "BUG touch maps to field and left pointer")
			touch(9, point, false)
			check(not bug.buttons[0], "BUG touch release")
		controls.activate("Matrix")
		await settle()
		check(app.active_level == null and app.hub.visible, "Touch returns from " + code)
	root.size = Vector2i(390,844)
	await settle()
	check(paused and controls.context == "portrait", "Portrait pauses and explains rotation")
	root.size = Vector2i(844,390)
	await settle()
	check(not paused and controls.context == "hub", "Landscape resumes")
	var hub: MatrixHub = app.hub as MatrixHub
	check(hub.pixel_scale == 1 and hub.world_viewport.size == Vector2i(512,320), "Phone shows both chambers and viewport without camera cropping")
	hub.open_terminal()
	await settle()
	var panel: Rect2 = (hub.overlay as HubOverlay).terminal_panel()
	check(panel.encloses(controls.regions["Enter"]), "Phone submit target stays inside terminal")
	check(hub.overlay.native_input.max_length == 18, "Touch text entry keeps length limit")
	for code: String in LevelRegistry.ENTRIES:
		check(not controls.regions.has(code), "Phone has no known-code hit area")
	app.free()
	await process_frame
	await create_timer(0.15).timeout # Let the audio mixer release the generated combat tone.
	root.remove_meta("matrix_force_touch")
	print("Mobile input validation passed" if failures == 0 else "Mobile input validation failed")
	quit(0 if failures == 0 else 1)
