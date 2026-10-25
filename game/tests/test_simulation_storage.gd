extends SceneTree

const SaveStore = preload("res://scripts/simulation_save_store.gd")
var failures: Array[String] = []
var assertions := 0


func _check(condition: bool, description: String) -> void:
	assertions += 1
	if not condition:
		failures.append(description)


func _initialize() -> void:
	var directory := "res://.test-artifacts/storage-%d" % OS.get_process_id()
	var store := SaveStore.new(directory)
	var profile := {"slot": 1, "mode": "solo", "player_name": "Guardado aislado", "revision": 1}
	_check(store.read_slot(1).is_empty(), "Espacio vacío")
	_check(store.save_slot(1, profile) == OK, "Primer guardado")
	_check(int(store.read_slot(1)["revision"]) == 1, "Lectura del primer guardado")
	profile["revision"] = 2
	_check(store.save_slot(1, profile) == OK, "Reemplazo atómico en Windows")
	_check(int(store.read_slot(1)["revision"]) == 2, "Última revisión disponible")
	_check(FileAccess.file_exists(store.path(1) + ".bak"), "Copia anterior conservada")
	var corrupt := FileAccess.open(store.path(1), FileAccess.WRITE)
	corrupt.store_string("{interrumpido")
	corrupt.close()
	var recovered := store.read_slot(1)
	_check(int(recovered["revision"]) == 1, "Se recupera copia anterior ante JSON incompleto")
	_check(store.save_slot(1, recovered) == OK, "Se puede guardar la partida recuperada")
	_check(JSON.parse_string(FileAccess.get_file_as_string(store.path(1) + ".bak")) is Dictionary, "La recuperación no reemplaza copia válida por archivo corrupto")
	_check(store.save_slot(2, profile) == ERR_INVALID_PARAMETER, "No se copia un perfil a otro espacio por accidente")
	_check(store.save_slot(0, profile) == ERR_INVALID_PARAMETER, "Rechazo de espacio inválido")
	_check(store.read_slot(4).is_empty(), "No se leen espacios fuera de rango")
	_check(store.remove_slot(1) == OK, "Borrado de partida y respaldos")
	_check(store.read_slot(1).is_empty(), "La copia no hace reaparecer una partida borrada")
	var legacy := FileAccess.open(directory + "/partida_2.json", FileAccess.WRITE)
	legacy.store_string(JSON.stringify({"mode": "solo", "player_name": "Antigua"}))
	legacy.close()
	_check(store.read_slot(2).get("player_name") == "Antigua", "Compatibilidad con nombre antiguo")
	_check(store.remove_slot(2) == OK, "Se borra también la partida antigua")
	var multi := FileAccess.open(directory + "/partida_3.json", FileAccess.WRITE)
	multi.store_string(JSON.stringify({"mode": "multi", "player_names": ["Anterior"]}))
	multi.close()
	_check(store.read_slot(3).is_empty(), "No se carga multijugador como estudiante")
	_check(store.remove_slot(3) == OK and FileAccess.file_exists(directory + "/partida_3.json"), "Se conserva el archivo histórico multijugador")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(directory + "/partida_3.json"))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(directory))
	for failure in failures:
		push_error(failure)
	print("SIMULATION_STORAGE_TESTS: %d assertions, %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)
