extends SceneTree
## Checks project policy and loads every Godot-owned script and scene.

var failures: int = 0


func _initialize() -> void:
	var version: Dictionary = Engine.get_version_info()
	check(version.major == 4 and version.minor == 7 and version.patch == 2,
		"Expected Godot 4.7.2")
	for setting: String in ["rendering/renderer/rendering_method",
			"rendering/renderer/rendering_method.mobile",
			"rendering/renderer/rendering_method.web"]:
		check(ProjectSettings.get_setting(setting) == "gl_compatibility",
			"Compatibility renderer required: " + setting)
	check(ProjectSettings.get_setting("application/run/main_scene") == "res://app/main.tscn",
		"Expected Matrix startup scene")
	check(FileAccess.file_exists("res://legacy/.gdignore"), "Archive must be excluded")
	for folder: String in ["app", "hub", "levels", "shared", "scripts"]:
		check(DirAccess.dir_exists_absolute("res://" + folder), "Missing folder: " + folder)
		check_resources("res://" + folder)
	if failures == 0:
		print("Matrix project validation passed")
	quit(0 if failures == 0 else 1)


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func check_resources(path: String) -> void:
	var directory: DirAccess = DirAccess.open(path)
	if directory == null:
		check(false, "Cannot open: " + path)
		return
	for child: String in directory.get_directories():
		if not child.begins_with("."):
			check_resources(path.path_join(child))
	for file: String in directory.get_files():
		if file.get_extension() in ["gd", "tscn", "tres", "gdshader"]:
			var resource_path: String = path.path_join(file)
			var resource: Resource = load(resource_path)
			check(resource != null, "Cannot load: " + resource_path)
			if resource is PackedScene:
				var instance: Node = resource.instantiate()
				check(instance != null, "Cannot instantiate: " + resource_path)
				if instance != null:
					instance.free()
