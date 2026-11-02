extends SceneTree

const Chess = preload("res://scripts/chess_game.gd")
const Pool = preload("res://scripts/pool_game.gd")
const Pong = preload("res://scripts/pong_game.gd")
const Property = preload("res://scripts/campus_property_game.gd")
const Sessions = preload("res://scripts/minigame_session_ui.gd")
const Map = preload("res://scripts/campus_map.gd")
var assertions := 0
var failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _check(value: bool, text: String) -> void:
	assertions += 1
	if not value:
		failures.append(text)


func _perft(model: RefCounted, depth: int) -> int:
	if depth == 0:
		return 1
	var count := 0
	for move in model.legal_moves():
		var undo: Array = model._push(move)
		count += _perft(model, depth - 1)
		model._pop(undo)
	return count


func _fen(value: String) -> RefCounted:
	var model := Chess.new(7)
	model.board.fill(0)
	var index := 0
	for token in value.split(" ")[0]:
		if token == "/":
			continue
		if token.is_valid_int():
			index += int(token)
		else:
			var type := " pnbrqk".find(token.to_lower())
			model.board[index] = type * (1 if token == token.to_upper() else -1)
			index += 1
	model.rights = 0
	model.ep = -1
	model.repetitions.clear()
	return model


func _move(model: RefCounted, from: String, to: String, promotion: int = Chess.QUEEN) -> bool:
	for move in model.legal_moves():
		if move["from"] == Chess.square(from) and move["to"] == Chess.square(to) and (move["promotion"] == 0 or move["promotion"] == promotion):
			model.play(move)
			return true
	return false


func _chess() -> void:
	var model := Chess.new(1)
	var initial := model.position_key()
	_check(_perft(model, 1) == 20, "Ajedrez: 20 movimientos iniciales")
	_check(_perft(model, 2) == 400, "Ajedrez: 400 posiciones en dos medias jugadas")
	_check(_perft(model, 3) == 8902, "Ajedrez: 8902 posiciones en tres medias jugadas")
	_check(initial == model.position_key(), "Generar movimientos y deshacer no altera el tablero")
	model.legal_moves()
	var cache_before := model.cache_hits
	var cached: Array = model.legal_moves()
	cached.clear()
	_check(model.cache_hits > cache_before and model.legal_moves().size() == 20, "La caché legal evita recalcular y sus copias son aisladas")
	_check(not model.command({"type": "move", "from": Chess.square("e2"), "to": Chess.square("e5")})["ok"], "No permite un movimiento ilegal")
	_check(model.command({"type": "move", "from": Chess.square("e2"), "to": Chess.square("e4")}, 0)["ok"], "Movimiento humano legal")
	_check(not model.command({"type": "pause"}, 0)["ok"], "Rechaza revisión obsoleta")
	var before := model.position_key()
	var started := Time.get_ticks_msec()
	var chosen := model.choose_move()
	print("CHESS_AI: ", Time.get_ticks_msec() - started, " ms, ", model.nodes, " nodes")
	_check(model.legal_moves().has(chosen), "La IA elige una jugada legal")
	_check(before == model.position_key() and model.nodes <= Chess.NODE_LIMIT, "La búsqueda es acotada y restaura el estado")
	model.play(chosen)
	_check(model.turn == 1, "La IA devuelve el turno")
	model = Chess.new(1)
	_move(model, "e2", "e4")
	for frame in range(100):
		model.advance(1.0 / 60)
		if model.turn == 1:
			break
	_check(model.turn == 1 and model.nodes <= Chess.NODE_LIMIT, "La búsqueda cooperativa termina y conserva el presupuesto")
	model = Chess.new(1)
	for pair in [["f2", "f3"], ["e7", "e5"], ["g2", "g4"], ["d8", "h4"]]:
		_check(_move(model, pair[0], pair[1]), "Jugada de mate del loco legal")
	_check(model.phase == "FINISHED" and model.winner == -1, "Detecta jaque mate sin capturar al rey")
	model = _fen("r3k2r/8/8/8/8/8/8/R3K2R")
	model.rights = 15
	_check(_move(model, "e1", "g1"), "Enroque corto disponible")
	_check(model.board[Chess.square("f1")] == Chess.ROOK and model.board[Chess.square("h1")] == 0 and model.rights & 3 == 0, "Enroque mueve la torre y elimina derechos")
	model = _fen("k4r2/8/8/8/8/8/8/4K2R")
	model.rights = 1
	_check(not _move(model, "e1", "g1"), "No permite enrocar atravesando jaque")
	model = _fen("4k3/8/8/3pP3/8/8/8/4K3")
	model.ep = Chess.square("d6")
	_check(_move(model, "e5", "d6") and model.board[Chess.square("d5")] == 0, "Captura al paso retira el peón correcto")
	model = _fen("k3r3/8/8/3pP3/8/8/8/4K3")
	model.ep = Chess.square("d6")
	_check(not _move(model, "e5", "d6"), "Al paso no puede dejar al propio rey en jaque")
	model = _fen("4k3/P7/8/8/8/8/8/4K3")
	var promotions := 0
	for move in model.legal_moves():
		if move["from"] == Chess.square("a7"):
			promotions += 1
	_check(promotions == 4 and _move(model, "a7", "a8", Chess.KNIGHT), "Cuatro promociones y subpromoción")
	_check(model.board[Chess.square("a8")] == Chess.KNIGHT, "La pieza promovida coincide con la elección")
	model = _fen("k7/2Q5/2K5/8/8/8/8/8")
	model.turn = -1
	_check(model.legal_moves().is_empty() and not model.in_check(-1), "Posición de ahogado")
	model = Chess.new(1)
	for cycle in range(2):
		for pair in [["g1", "f3"], ["g8", "f6"], ["f3", "g1"], ["f6", "g8"]]:
			_check(_move(model, pair[0], pair[1]), "Ciclo de repetición legal")
	_check(model.command({"type": "claim_draw"})["ok"] and model.winner == 0 and model.phase == "FINISHED", "Reclamo de tablas tras tres repeticiones")
	model = _fen("4k3/8/8/8/8/8/8/4K3")
	_check(model.insufficient_material(), "Detecta reyes solos")
	model = _fen("4k3/8/8/8/8/8/8/3BK3")
	_check(model.insufficient_material(), "Detecta rey/alfil contra rey")


func _physical() -> void:
	var pool := Pool.new(9)
	var revision := pool.revision
	_check(pool.command({"type": "aim", "angle": 0, "power": 80}, revision)["ok"], "Billar: puntería válida")
	_check(pool.command({"type": "shoot"}, pool.revision)["ok"], "Billar: tiro inicia física")
	_check(not pool.command({"type": "shoot"}, pool.revision)["ok"], "No permite disparar mientras se mueven bolas")
	for index in range(1000):
		pool.advance(1.0 / 60)
		if pool.phase != "MOVING":
			break
	_check(pool.phase == "READY" and pool._hit and pool.shots == 1, "Tiro alcanza el paquete y se detiene")
	for position in pool.positions:
		_check(position.is_finite(), "Física finita")
	var shot := pool.choose_shot()
	_check(shot.is_finite() and shot.y >= 20 and shot.y <= 100, "IA de billar produce fuerza y ángulo válidos")
	pool._scratch = true
	pool.active[0] = false
	pool._potted = [1]
	pool.active[1] = false
	pool._end_shot()
	_check(pool.active[0] and pool.positions[0].is_finite(), "Blanca repuesta tras falta")
	var duel := Pool.new(33)
	for shot_index in range(20):
		if duel.phase == "FINISHED":
			break
		var choice := duel.choose_shot()
		duel.shoot(choice.x, choice.y)
		for tick in range(100):
			duel.advance(0.1)
			if duel.phase != "MOVING":
				break
		_check(duel.phase != "MOVING", "Cada tiro de billar termina en tiempo acotado")
		_check(duel.scores[0] + duel.scores[1] == 7 - duel.active.count(true), "La puntuación coincide con las bolas retiradas")
	_check(duel.scores[0] + duel.scores[1] > 0, "El rival de billar puede embocar bolas con su cálculo de fuerza")
	var a := Pong.new(9)
	var b := Pong.new(9)
	a.serve()
	b.serve()
	for index in range(60):
		a.advance(1.0 / 60)
	for index in range(30):
		b.advance(1.0 / 30)
	_check(a.ball.distance_to(b.ball) < 0.001 and a.scores == b.scores, "Paso físico fijo independiente de FPS")
	a.paused = true
	var before: Vector2 = a.ball
	a.advance(0.1)
	_check(before == a.ball, "Pausa detiene pelota y rival")
	a.paused = false
	for index in range(7):
		a.point(0)
	_check(a.phase == "FINISHED" and a.winner == 1, "Ping-pong finaliza a siete con ventaja")
	var pong := Pong.new(83)
	pong.serve()
	for step in range(7200):
		pong.set_target(pong.ball.y)
		if pong.phase == "SERVE" and pong.turn == 1:
			pong.command({"type": "serve"})
		pong.advance(1.0 / 60)
		_check(pong.ball.is_finite() and pong.paddles[1] >= 34 and pong.paddles[1] <= 266, "Rival y pelota dentro de límites")
		if pong.phase == "FINISHED":
			break
	_check(pong.scores[0] > 0, "El rival imperfecto de ping-pong puede perder puntos")


func _economy() -> void:
	for seed_value in range(30):
		var model := Property.new(seed_value)
		for guard in range(1800):
			if model.phase == "FINISHED":
				break
			if model.turn == 1:
				var kind := "roll" if model.phase == "READY" else "end"
				if model.phase == "BUY" and model.cash[0] >= int(model.PRICES[model.positions[0]]) + 80:
					kind = "buy"
				if model.phase == "UPGRADE" and model.cash[0] > 180:
					kind = "upgrade"
				_check(model.command({"type": kind})["ok"], "Economía: acción humana admitida")
			else:
				model.advance(0.1)
		_check(model.phase == "FINISHED", "Economía finaliza con un presupuesto de turnos")
		_check(model.turns <= 40 and model.positions[0] >= 0 and model.positions[0] < 20, "Economía mantiene límites")
		for owner in model.owners:
			_check(owner in [-1, 0, 1], "Propiedades con dueño válido")


func _storage() -> void:
	for id in Sessions.CATALOG:
		var model := Sessions.create(id, 918)
		var saved: Dictionary = JSON.parse_string(JSON.stringify(model.serialize()))
		var recovered := Sessions.create(id, 3)
		_check(recovered.restore(saved) and recovered.paused, "Recuperación segura y pausada: " + id)
		_check(str(model.random.state) == str(recovered.random.state), "Estado RNG conservado sin perder enteros de 64 bits: " + id)
		_check(not recovered.restore({"version": 99}), "Rechaza versión incompatible")
		saved["phase"] = "INEXISTENTE"
		_check(not recovered.restore(saved), "Rechaza una fase inválida")
		var revision: int = model.revision
		_check(model.command({"type": "pause"}, revision)["ok"], "Pausa común")
		_check(not model.command({"type": "resign"}, revision)["ok"], "Comando obsoleto sin mutación")


func _run() -> void:
	var block := Map.building("sis_a")
	block["rooms"].append("No persistir")
	_check(not Map.building("sis_a")["rooms"].has("No persistir"), "Índice de edificios devuelve copias aisladas")
	_chess()
	_physical()
	_economy()
	_storage()
	for failure in failures:
		push_error(failure)
	print("RECREATION_MODEL_TESTS: %d assertions, %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)
