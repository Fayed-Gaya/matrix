extends SceneTree
## Runs against the exported PCK from an external script, without source assets.

func _initialize() -> void:
	root.set_meta("matrix_test_mode",true)
	run.call_deferred()

func run() -> void:
	for excluded: String in ["res://legacy/pygame/main.py","res://docs/migration/README.md","res://scripts/validation/hub_check.gd","res://build/toolchain/godot/web_nothreads_release.zip"]:
		assert(not FileAccess.file_exists(excluded),"Unnecessary export file: "+excluded)
	for module: String in ["mario","zelda","monsters"]:
		var path: String = "res://levels/"+module+"/assets/manifest.json"
		assert(FileAccess.file_exists(path),"Missing runtime JSON: "+path)
		check_paths(JSON.parse_string(FileAccess.get_file_as_string(path)))
	var app: MatrixApp = load("res://app/main.tscn").instantiate() as MatrixApp
	root.add_child(app)
	await process_frame
	for code: String in LevelRegistry.ENTRIES:
		app.launch_level(code)
		await process_frame
		await process_frame
		assert(app.active_level != null and app.active_code == code)
		app.return_to_hub()
		await process_frame
		await process_frame
	app.free()
	await process_frame
	await create_timer(0.15).timeout
	print("Exported web pack validation passed: ten codes and runtime manifests")
	quit()

func check_paths(value: Variant) -> void:
	if value is Dictionary:
		for child: Variant in value.values(): check_paths(child)
	elif value is Array:
		for child: Variant in value: check_paths(child)
	elif value is String and value.begins_with("res://"):
		assert(ResourceLoader.exists(value),"Missing dynamic resource: "+value)
