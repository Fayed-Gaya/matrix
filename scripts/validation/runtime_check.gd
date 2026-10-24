extends SceneTree
## Runs from a fresh temporary project that contains no Python/archive or cache.


func _initialize() -> void:
	root.set_meta("matrix_test_mode",true)
	run.call_deferred()


func settle() -> void:
	await process_frame
	await process_frame


func run() -> void:
	assert(not DirAccess.dir_exists_absolute("res://legacy"))
	var app: MatrixApp = load("res://app/main.tscn").instantiate() as MatrixApp
	root.add_child(app)
	await settle()
	for code: String in LevelRegistry.ENTRIES:
		assert(not LevelRegistry.lookup(code).scene.is_empty())
		app.launch_level(code)
		await settle()
		assert(app.active_level != null and app.active_code == code)
		# Render enough frames to resolve each level's initial dynamic resources.
		for tick: int in range(5):
			await process_frame
		app.active_level.return_requested.emit()
		await settle()
		assert(app.active_level == null and app.pegasus.visible)
	app.free()
	await settle()
	await create_timer(0.15).timeout
	print("Standalone runtime validation passed: active native routes, no archive")
	quit()
