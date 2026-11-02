extends RefCounted

var game_id := ""
var revision := 0
var turn := 1
var phase := "READY"
var winner := 0
var paused := false
var message := "Tu turno."
var random := RandomNumberGenerator.new()
var session_id := ""
var ai_wait := 0.0


func _init(seed_value: int = 1) -> void:
	random.seed = seed_value
	session_id = "%d-%d" % [int(Time.get_unix_time_from_system() * 1000), seed_value]


func command(action: Dictionary, expected_revision: int = -1) -> Dictionary:
	if expected_revision >= 0 and expected_revision != revision:
		return {"ok": false, "message": "La acción pertenece a un estado anterior."}
	var kind := str(action.get("type", ""))
	if kind == "pause":
		paused = not paused
	elif kind == "resign" and phase != "FINISHED":
		finish(-1, "Abandonaste la partida. Gana el rival.")
	elif paused or phase == "FINISHED" or turn != 1:
		return {"ok": false, "message": "La acción no está disponible en este momento."}
	elif not _action(action):
		return {"ok": false, "message": "Acción no válida para el estado actual."}
	revision += 1
	return {"ok": true, "message": message, "revision": revision}


func _action(_action_data: Dictionary) -> bool:
	return false


func advance(_delta: float) -> void:
	pass


func finish(result: int, text: String) -> void:
	winner = result
	phase = "FINISHED"
	message = text
	revision += 1


func serialize() -> Dictionary:
	return {"version": 1, "game_id": game_id, "session_id": session_id, "revision": revision, "turn": turn, "phase": phase,
		"winner": winner, "message": message, "rng": str(random.state), "data": _data()}


func _data() -> Dictionary:
	return {}


func restore(saved: Dictionary) -> bool:
	if int(saved.get("version", 0)) != 1 or saved.get("game_id", "") != game_id or not saved.get("data") is Dictionary:
		return false
	if int(saved.get("turn", 0)) not in [-1, 1] or str(saved.get("phase", "")) not in allowed_phases():
		return false
	if not _load_data(saved["data"]):
		return false
	session_id = str(saved.get("session_id", session_id))
	revision = maxi(0, int(saved.get("revision", 0)))
	turn = int(saved["turn"])
	phase = str(saved["phase"])
	winner = clampi(int(saved.get("winner", 0)), -1, 1)
	message = str(saved.get("message", "Partida recuperada."))
	random.state = str(saved.get("rng", str(random.state))).to_int()
	paused = true
	return true


func _load_data(_data_value: Dictionary) -> bool:
	return false


func allowed_phases() -> Array:
	return ["READY", "FINISHED"]


static func numbers(value: Variant, count: int, limit: float = 1000000) -> bool:
	if not value is Array or value.size() != count:
		return false
	for item in value:
		if not (item is float or item is int) or not is_finite(float(item)) or absf(float(item)) > limit:
			return false
	return true
