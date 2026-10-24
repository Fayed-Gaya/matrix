extends SceneTree
## One startup and one real launch/return per registered level. No gameplay walkthrough.

func _initialize() -> void:
	root.set_meta("matrix_test_mode", true) # YOU must never activate physical cameras.
	run.call_deferred()

func settle() -> void:
	await process_frame
	await process_frame

func run() -> void:
	if "--archive-free" in OS.get_cmdline_user_args():
		assert(not DirAccess.dir_exists_absolute("res://legacy"))
	assert(ProjectSettings.get_setting("application/run/main_scene") == "res://app/main.tscn")
	for setting: String in ["rendering/renderer/rendering_method", "rendering/renderer/rendering_method.mobile", "rendering/renderer/rendering_method.web"]:
		assert(ProjectSettings.get_setting(setting) == "gl_compatibility", "Compatibility renderer required")
	var app: MatrixApp = load("res://app/main.tscn").instantiate() as MatrixApp
	root.add_child(app)
	await settle()
	assert(app.pegasus is Pegasus and app.pegasus.visible and app.active_level == null)
	assert(app.pegasus.overlay.opening, "Opening must be available on startup")
	var position_before: Vector2 = app.pegasus.player.position
	var count: int = 0
	assert(not LevelRegistry.ENTRIES.is_empty(), "Playable registry must not be empty")
	for code: String in LevelRegistry.ENTRIES:
		var entry: Dictionary = LevelRegistry.lookup(code)
		assert(not entry.scene.is_empty(), "Registered scene required: " + code)
		app.launch_level(code)
		await settle()
		assert(app.active_level is MatrixLevel and app.active_code == code, "Launch failed: " + code)
		assert(app.active_level.scene_file_path == entry.scene)
		assert(not app.pegasus.visible and not app.pegasus.can_process())
		var previous: WeakRef = weakref(app.active_level)
		app.active_level.return_requested.emit()
		await settle()
		assert(app.active_level == null and previous.get_ref() == null, "Level not freed: " + code)
		assert(app.pegasus.visible and app.pegasus.can_process(), "Pegasus not restored: " + code)
		assert(app.pegasus.player.position == position_before)
		count += 1
	app.free()
	await settle()
	await create_timer(0.15).timeout # Let the audio mixer release stopped decoders.
	print("Matrix integration smoke passed: %d registered routes and returns" % count)
	quit()
