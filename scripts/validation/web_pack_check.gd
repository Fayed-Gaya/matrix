extends SceneTree
## Runs against the exported PCK from an external script, without source assets.

var retired_imports: Array = []

func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	assert(args.size() == 1, "Expected external retired-import audit list")
	retired_imports = JSON.parse_string(FileAccess.get_file_as_string(args[0]))
	root.set_meta("matrix_test_mode",true)
	run.call_deferred()

func run() -> void:
	check_exclusions("res://")
	for excluded: String in ["res://legacy/pygame/main.py","res://assets/audio/redgifs-wittysizzlingmongoose.mp3","res://docs/migration/README.md","res://scripts/validation/pegasus_check.gd","res://build/toolchain/godot/web_nothreads_release.zip"]:
		assert(not FileAccess.file_exists(excluded),"Unnecessary export file: "+excluded)
	for module: String in ["bubby"]:
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
		app.return_to_pegasus()
		await process_frame
		await process_frame
	app.free()
	await process_frame
	await create_timer(0.15).timeout
	print("Exported web pack validation passed: active codes and runtime manifests")
	quit()

func check_paths(value: Variant) -> void:
	if value is Dictionary:
		for child: Variant in value.values(): check_paths(child)
	elif value is Array:
		for child: Variant in value: check_paths(child)
	elif value is String and value.begins_with("res://"):
		assert(ResourceLoader.exists(value),"Missing dynamic resource: "+value)

func check_exclusions(path: String) -> void:
	var directory: DirAccess = DirAccess.open(path)
	assert(directory != null, "Cannot inspect exported directory: " + path)
	directory.include_hidden = true
	for file: String in directory.get_files():
		var resource_path: String = path.path_join(file)
		for fingerprint: String in retired_imports:
			assert(not resource_path.begins_with(fingerprint + "."), "Retired imported asset bundled: " + resource_path)
	for child: String in directory.get_directories():
		var next: String = path.path_join(child)
		assert(child != "source", "Excluded source reference bundled: " + next)
		assert(not next in ["res://archive", "res://legacy", "res://art", "res://tests", "res://build"], "Excluded directory bundled: " + next)
		assert(not next in ["res://levels/jump", "res://levels/mario", "res://levels/monsters", "res://levels/tom_pong", "res://levels/zelda", "res://levels/untitled"], "Archived module bundled: " + next)
		check_exclusions(next)
