extends SceneTree
func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var destination: String = args[0] if args.size() == 1 else "res://exports/web"
	var directory: String = destination.path_join("LICENSES")
	assert(DirAccess.make_dir_recursive_absolute(directory) == OK)
	var file: FileAccess = FileAccess.open(directory.path_join("Godot-engine.txt"),FileAccess.WRITE)
	assert(file != null)
	file.store_string(Engine.get_license_text()+"\n\nBundled components:\n"+JSON.stringify(Engine.get_copyright_info(),"  ")+"\n\n")
	var licenses: Dictionary = Engine.get_license_info()
	for name: String in licenses:
		file.store_string(name+"\n"+str(licenses[name])+"\n\n")
	file.close()
	print("Exact Godot engine notices written")
	quit()
