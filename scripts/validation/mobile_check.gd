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
	check(not (app.pegasus as Pegasus).overlay.opening, "Touch begins game")
	touch(1, (controls.regions["Right"] as Rect2).get_center(), true)
	await settle()
	check(Input.is_action_pressed("pegasus_right"), "Touch holds movement")
	touch(2, (controls.regions["Up"] as Rect2).get_center(), true)
	await settle()
	check(Input.is_action_pressed("pegasus_right") and Input.is_action_pressed("pegasus_up"), "Independent fingers allow diagonal movement")
	touch(1, Vector2.ZERO, false)
	await settle()
	check(not Input.is_action_pressed("pegasus_right") and Input.is_action_pressed("pegasus_up"), "Releasing outside retains other finger")
	controls._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(not Input.is_action_pressed("pegasus_up"), "Focus loss releases movement")
	for code: String in LevelRegistry.ENTRIES:
		(app.pegasus as Pegasus).open_terminal()
		await settle()
		check(not controls.regions.has(code), "Touch terminal never advertises " + code)
		var field: LineEdit = (app.pegasus as Pegasus).overlay.native_input
		check(field.visible and field.virtual_keyboard_enabled, "Native touch terminal uses real LineEdit")
		field.text_submitted.emit(code.to_lower())
		await settle()
		check(app.active_code == code, "Touch code routes " + code)
		if code == "BUBBY":
			var bubby: BubbyLevel = app.active_level as BubbyLevel
			bubby.show_room("outside")
			bubby.close_dialogue()
			bubby.player.position = bubby.pigeon.position
			controls.activate("Shoo")
			check(bubby.pigeon_health == BubbyLevel.MAX_PIGEON - 1, "Shoo touch button reaches combat input")
			bubby.shoo_wait = 0
			bubby.player.position = bubby.pigeon.position - Vector2(70,0)
			var before: Vector2 = bubby.player.position
			touch(3, (controls.regions["Right"] as Rect2).get_center(), true)
			touch(4, (controls.regions["Shoo"] as Rect2).get_center(), true)
			await settle()
			check(Input.is_action_pressed("pegasus_right") and bubby.pigeon_health == BubbyLevel.MAX_PIGEON - 2, "Independent movement and shoo fingers reach Bubby together")
			bubby._physics_process(0.05)
			check(bubby.player.position.x > before.x, "Bubby moves while shoo finger is held")
			touch(4, Vector2.ZERO, false)
			check(Input.is_action_pressed("pegasus_right"), "Releasing shoo preserves movement finger")
			touch(3, Vector2.ZERO, false)
			check(not Input.is_action_pressed("pegasus_right"), "Bubby touch movement releases")
			bubby.health = 1
			bubby.hurt_wait = 0
			bubby.take_nudge()
			controls.activate("Use")
			check(bubby.health == BubbyLevel.MAX_COMPOSURE and bubby.boss_state == "rest", "Touch Use retries a failed encounter")
			bubby.dialogue = "Fixture conversation"
			controls.activate("Use")
			check(bubby.dialogue.is_empty(), "Use closes narrative dialogue")
		if code == "SIMULATION":
			var simulation: SimulationLevel = app.active_level as SimulationLevel
			simulation.show_room("outskirts")
			simulation.player.position = simulation.room.get_node("Governor").position
			simulation.boss_phase = SimulationLevel.BossPhase.RECOVER
			controls.activate("Spark")
			check(simulation.boss_health == 5, "Spark touch button reaches combat input")
			controls.activate("Brace")
			check(simulation.guard_left > 0, "Brace touch button reaches combat input")
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
		check(app.active_level == null and app.pegasus.visible, "Touch returns from " + code)
	root.size = Vector2i(390,844)
	await settle()
	check(paused and controls.context == "portrait", "Portrait pauses and explains rotation")
	root.size = Vector2i(844,390)
	await settle()
	check(not paused and controls.context == "pegasus", "Landscape resumes")
	var pegasus: Pegasus = app.pegasus as Pegasus
	check(pegasus.pixel_scale == 1 and pegasus.world_viewport.size == Vector2i(512,320), "Phone shows both chambers and viewport without camera cropping")
	pegasus.open_terminal()
	await settle()
	var panel: Rect2 = (pegasus.overlay as PegasusOverlay).terminal_panel()
	check(panel.encloses(controls.regions["Enter"]), "Phone submit target stays inside terminal")
	check(pegasus.overlay.native_input.max_length == 18, "Touch text entry keeps length limit")
	for code: String in LevelRegistry.ENTRIES:
		check(not controls.regions.has(code), "Phone has no known-code hit area")
	app.free()
	await process_frame
	await create_timer(0.15).timeout # Let the audio mixer release the generated combat tone.
	root.remove_meta("matrix_force_touch")
	print("Mobile input validation passed" if failures == 0 else "Mobile input validation failed")
	quit(0 if failures == 0 else 1)
