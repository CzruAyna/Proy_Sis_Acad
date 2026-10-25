extends RefCounted

var directory: String
var slot_count: int


func _init(save_directory: String = "user://partidas", count: int = 3) -> void:
	directory = save_directory.trim_suffix("/")
	slot_count = count


func path(slot: int) -> String:
	return "%s/solo_partida_%d.json" % [directory, slot]


func read_slot(slot: int) -> Dictionary:
	if slot < 1 or slot > slot_count:
		return {}
	for candidate in [path(slot), path(slot) + ".bak", "%s/partida_%d.json" % [directory, slot]]:
		if not FileAccess.file_exists(candidate):
			continue
		var parsed: Variant = _parse_file(candidate)
		if parsed is Dictionary and str(parsed.get("mode", "solo")) == "solo":
			return parsed
	return {}


func save_slot(slot: int, profile: Dictionary) -> Error:
	if slot < 1 or slot > slot_count or profile.is_empty() or int(profile.get("slot", slot)) != slot or profile.get("mode", "solo") != "solo":
		return ERR_INVALID_PARAMETER
	var create_error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	if create_error != OK:
		return create_error
	var target := path(slot)
	var temporary := target + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(profile, "\t"))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		return write_error
	if FileAccess.file_exists(target) and _parse_file(target) is Dictionary:
		var backup_error := DirAccess.copy_absolute(ProjectSettings.globalize_path(target), ProjectSettings.globalize_path(target + ".bak"))
		if backup_error != OK:
			return backup_error
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary), ProjectSettings.globalize_path(target))


func remove_slot(slot: int) -> Error:
	if slot < 1 or slot > slot_count:
		return ERR_INVALID_PARAMETER
	var targets := [path(slot), path(slot) + ".bak", path(slot) + ".tmp"]
	var legacy := "%s/partida_%d.json" % [directory, slot]
	if FileAccess.file_exists(legacy):
		var parsed: Variant = _parse_file(legacy)
		if parsed is Dictionary and str(parsed.get("mode", "solo")) == "solo":
			targets.append(legacy)
	for target in targets:
		if FileAccess.file_exists(target):
			var remove_error := DirAccess.remove_absolute(ProjectSettings.globalize_path(target))
			if remove_error != OK:
				return remove_error
	return OK


func _parse_file(file_path: String) -> Variant:
	var decoder := JSON.new()
	if decoder.parse(FileAccess.get_file_as_string(file_path)) != OK:
		return null
	return decoder.data
