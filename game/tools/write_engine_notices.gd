extends SceneTree
## Export the running engine's notices for the desktop distribution.


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("res://build")
	var file := FileAccess.open("res://build/GODOT-NOTICES.txt", FileAccess.WRITE)
	if file == null:
		push_error("No se pudieron escribir los avisos del motor")
		quit(1)
		return
	file.store_string("Godot Engine " + Engine.get_version_info()["string"] + "\nhttps://godotengine.org/license/\n\n")
	file.store_string(Engine.get_license_text() + "\n\n")
	for component in Engine.get_copyright_info():
		file.store_string(str(component["name"]) + "\n")
		for part in component["parts"]:
			file.store_string("Files: " + ", ".join(part["files"]) + "\n")
			file.store_string("Copyright: " + "; ".join(part["copyright"]) + "\n")
			file.store_string("License: " + str(part["license"]) + "\n")
		file.store_string("\n")
	var licenses := Engine.get_license_info()
	for name in licenses:
		file.store_string(str(name) + "\n" + str(licenses[name]) + "\n\n")
	file.close()
	print("ENGINE_NOTICES: written")
	quit()
