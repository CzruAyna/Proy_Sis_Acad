extends SceneTree


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 1:
		push_error("Indica el JPEG original del logo después de --.")
		quit(1)
		return
	var source := Image.new()
	var result := source.load_jpg_from_buffer(FileAccess.get_file_as_bytes(args[0]))
	if result != OK:
		push_error("No se pudo leer el logo JPEG: " + error_string(result))
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/branding"))
	result = source.save_png("res://assets/branding/sis_inf_logo.png")
	print("LOGO_IMPORT: ", source.get_size(), " ", error_string(result))
	quit(0 if result == OK else 1)
