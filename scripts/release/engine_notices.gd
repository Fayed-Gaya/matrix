extends SceneTree
func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("res://exports/web/LICENSES")
	var file: FileAccess = FileAccess.open("res://exports/web/LICENSES/Godot-engine.txt",FileAccess.WRITE)
	file.store_string(Engine.get_license_text()+"\n\nBundled components:\n"+JSON.stringify(Engine.get_copyright_info(),"  ")+"\n\n")
	var licenses: Dictionary = Engine.get_license_info()
	for name: String in licenses:
		file.store_string(name+"\n"+str(licenses[name])+"\n\n")
	file.close()
	print("Exact Godot engine notices written")
	quit()
