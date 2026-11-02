extends "res://scripts/recreation_game.gd"

const TILES := ["Inicio", "Apuntes", "Biblioteca", "Suceso", "Taller", "Descanso", "Proyecto", "Servicio", "Redes", "Suceso", "Plaza", "Modelos", "Datos", "Servicio", "Software", "Descanso", "Diseño", "Suceso", "Ciencia", "Impuesto"]
const PRICES := {1: 90, 2: 100, 4: 110, 6: 120, 8: 130, 11: 140, 12: 150, 14: 160, 16: 170, 18: 180}
var cash := [600, 600]
var positions := [0, 0]
var owners: Array[int] = []
var levels: Array[int] = []
var rests := [0, 0]
var dice := [0, 0]
var turns := 0


func _init(seed_value: int = 1) -> void:
	super(seed_value)
	game_id = "monopolio"
	owners.resize(20)
	levels.resize(20)
	phase = "READY"
	message = "Ruta del campus: variante propia. Lanza los dados."


func _index() -> int:
	return 0 if turn == 1 else 1


func _action(action: Dictionary) -> bool:
	var kind := str(action.get("type", ""))
	if kind == "roll" and phase == "READY":
		roll()
	elif kind == "buy" and phase == "BUY" and cash[_index()] >= int(PRICES[positions[_index()]]):
		var tile := int(positions[_index()])
		cash[_index()] -= int(PRICES[tile])
		owners[tile] = turn
		phase = "END"
		message = "Compraste %s por %d créditos." % [TILES[tile], PRICES[tile]]
	elif kind == "upgrade" and phase == "UPGRADE" and cash[_index()] >= 70:
		cash[_index()] -= 70
		levels[positions[_index()]] += 1
		phase = "END"
		message = "Mejora construida: la renta aumenta."
	elif kind == "end" and phase in ["BUY", "UPGRADE", "END"]:
		end_turn()
	else:
		return false
	return true


func roll() -> void:
	var index := _index()
	dice = [random.randi_range(1, 6), random.randi_range(1, 6)]
	var next := int(positions[index]) + int(dice[0]) + int(dice[1])
	if next >= 20:
		cash[index] += 100
	positions[index] = next % 20
	var tile := int(positions[index])
	phase = "END"
	message = "%s: %d + %d → %s." % ["Tú" if turn == 1 else "Rival", dice[0], dice[1], TILES[tile]]
	if PRICES.has(tile):
		if owners[tile] == 0:
			phase = "BUY"
		elif owners[tile] == turn:
			if levels[tile] < 2:
				phase = "UPGRADE"
		else:
			var rent := int(PRICES[tile]) / 5 * (1 + levels[tile])
			cash[index] -= rent
			cash[1 - index] += rent
			message += " Pagas %d de renta." % rent
	elif tile in [3, 9, 17]:
		var amount: int = [60, 80, -40, -60][random.randi_range(0, 3)]
		cash[index] += amount
		message += " Suceso: %+d créditos." % amount
	elif tile in [7, 13, 19]:
		cash[index] -= 45
		message += " Servicio/impuesto: 45 créditos."
	elif tile in [5, 15]:
		rests[index] = 1
		message += " Descanso: saltas el próximo turno."
	_settle(index)
	revision += 1


func _settle(index: int) -> void:
	if cash[index] >= 0:
		return
	var side := 1 if index == 0 else -1
	for tile in range(20):
		if owners[tile] == side:
			cash[index] += int(PRICES[tile]) / 2 + levels[tile] * 35
			owners[tile] = 0
			levels[tile] = 0
			message += " Vendiste %s para cubrir la deuda." % TILES[tile]
			if cash[index] >= 0:
				return
	finish(-side, "Bancarrota: " + ("gana el rival." if side == 1 else "ganaste la partida."))


func wealth(index: int) -> int:
	var result := int(cash[index])
	var side := 1 if index == 0 else -1
	for tile in PRICES:
		if owners[tile] == side:
			result += int(PRICES[tile]) + levels[tile] * 70
	return result


func end_turn() -> void:
	turns += 1
	if turns >= 40:
		var difference := wealth(0) - wealth(1)
		finish(signi(difference), "Fin de 40 turnos. Patrimonio: tú %d · rival %d. %s" % [wealth(0), wealth(1), "Empate." if difference == 0 else ("Ganaste." if difference > 0 else "Gana el rival.")])
		return
	turn *= -1
	if rests[_index()] > 0:
		rests[_index()] -= 1
		turns += 1
		if turns >= 40:
			var difference := wealth(0) - wealth(1)
			finish(signi(difference), "Fin de 40 turnos. Patrimonio: tú %d · rival %d." % [wealth(0), wealth(1)])
			return
		turn *= -1
	phase = "READY"
	message = "Tu turno: lanza los dados." if turn == 1 else "El rival prepara su turno."
	revision += 1


func advance(delta: float) -> void:
	if paused or phase == "FINISHED" or turn != -1 or not is_finite(delta) or delta <= 0:
		return
	ai_wait += minf(delta, 0.1)
	if ai_wait < 0.65:
		return
	ai_wait = 0
	if phase == "READY":
		roll()
	elif phase == "BUY":
		var tile := int(positions[1])
		if cash[1] - int(PRICES[tile]) >= 130:
			_action({"type": "buy"})
		else:
			end_turn()
	elif phase == "UPGRADE":
		if cash[1] >= 240:
			_action({"type": "upgrade"})
		else:
			end_turn()
	else:
		end_turn()
	revision += 1


func _data() -> Dictionary:
	return {"cash": cash.duplicate(), "positions": positions.duplicate(), "owners": owners.duplicate(), "levels": levels.duplicate(), "rests": rests.duplicate(), "dice": dice.duplicate(), "turns": turns}


func allowed_phases() -> Array:
	return ["READY", "BUY", "UPGRADE", "END", "FINISHED"]


func _load_data(data: Dictionary) -> bool:
	for entry in [["cash", 2, 10000], ["positions", 2, 19], ["owners", 20, 1], ["levels", 20, 2], ["rests", 2, 1], ["dice", 2, 6]]:
		if not numbers(data.get(entry[0]), entry[1], entry[2]):
			return false
	for index in range(20):
		if int(data["levels"][index]) < 0 or int(data["owners"][index]) not in [-1, 0, 1] or (not PRICES.has(index) and int(data["owners"][index]) != 0):
			return false
	for position in data["positions"]:
		if int(position) < 0:
			return false
	cash = [int(data["cash"][0]), int(data["cash"][1])]
	positions = [int(data["positions"][0]), int(data["positions"][1])]
	owners.assign(data["owners"].map(func(value: Variant) -> int: return int(value)))
	levels.assign(data["levels"].map(func(value: Variant) -> int: return int(value)))
	rests = data["rests"].duplicate()
	dice = data["dice"].duplicate()
	turns = clampi(int(data.get("turns", 0)), 0, 40)
	return true
