extends SceneTree

const Pool = preload("res://scripts/pool_game.gd")
const Sessions = preload("res://scripts/minigame_session_ui.gd")
var assertions := 0
var failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _check(value: bool, message: String) -> void:
	assertions += 1
	if not value:
		failures.append(message)


func _table(live: Array = [0, 1, 2, 8, 9]) -> RefCounted:
	var game := Pool.new(9)
	game.break_shot = false
	game.can_place = false
	game.active.fill(false)
	for number in live:
		game.active[number] = true
	game.groups = [1, 2]
	return game


func _resolve(game: RefCounted, first: int, potted: Array, pockets: Array = [], scratch: bool = false, rail: bool = true) -> void:
	game.shoot(0, 60)
	game.first_hit = first
	game._potted.assign(potted)
	game._pockets.assign(pockets if not pockets.is_empty() else potted.map(func(_v: int) -> int: return 0))
	for number in potted:
		game.active[number] = false
	game._scratch = scratch
	game._rail_after_contact = rail
	game.velocities.fill(Vector2.ZERO)
	game._end_shot()


func _run() -> void:
	var game := Pool.new(2)
	_check(game.positions.size() == 16 and game.active.count(true) == 16, "Quince bolas numeradas y blanca")
	for a in range(1, 16):
		for b in range(a + 1, 16):
			_check(game.positions[a].distance_to(game.positions[b]) >= 16, "Triángulo sin solapamientos")
	_check(game.positions[8] == Vector2(418.1, 150), "Negra en el centro del triángulo")
	_check(not game.command({"type": "place", "x": 200, "y": 100})["ok"], "Apertura restringe blanca detrás de línea")
	_check(game.command({"type": "place", "x": 100, "y": 100})["ok"], "Blanca libre detrás de línea")
	_check(not game.command({"type": "aim", "angle": NAN})["ok"], "Rechaza puntería no finita")
	game.command({"type": "place", "x": 140, "y": 150})
	var choice := game.choose_shot()
	game.shoot(choice.x, choice.y)
	for step in range(1200):
		game.advance(1.0 / 60)
		if game.phase != "MOVING":
			break
	_check(game.phase in ["READY", "PLACEMENT"] and game.first_hit == 1 and not game.break_shot, "Apertura física contacta y se detiene")
	for point in game.positions:
		_check(point.is_finite(), "Física finita con dieciséis cuerpos")
	game = Pool.new()
	game.break_shot = false
	_resolve(game, 1, [1], [], false, false)
	_check(game.groups == [1, 2] and game.turn == 1 and game.scores[0] == 1, "Embocada legal asigna grupos y conserva turno")
	game = _table()
	_resolve(game, 9, [])
	_check(game.turn == -1 and game.phase == "PLACEMENT" and game.can_place, "Primer contacto ajeno concede bola en mano")
	game.turn = 1
	_check(game.command({"type": "place", "x": 250, "y": 80})["ok"], "Tras falta la blanca puede colocarse fuera de la zona inicial")
	_check(not game.valid_placement(game.positions[8]), "No coloca blanca encima de otra bola")
	game = _table()
	_resolve(game, 1, [], [], false, false)
	_check(game.phase == "PLACEMENT", "Sin banda ni embocada después de contacto es falta")
	game = Pool.new()
	game.shoot(0, 100)
	game.first_hit = 1
	game._rail_after_contact = true
	game._break_rails = [1, 2, 3]
	game._end_shot()
	_check(game.phase == "PLACEMENT", "Apertura sin embocada exige cuatro bolas a banda")
	game = Pool.new()
	_resolve(game, 1, [8])
	_check(game.phase != "FINISHED" and game.active[8], "Negra en apertura se repone")
	game = _table()
	_resolve(game, 8, [8])
	_check(game.phase == "FINISHED" and game.winner == -1, "Negra prematura pierde")
	game = _table([0, 8, 9])
	_check(not game.command({"type": "shoot"})["ok"] and game.shots == 0, "Negra exige tronera elegida")
	game.called_pocket = 2
	_resolve(game, 8, [8], [2])
	_check(game.winner == 1, "Negra legal con grupo limpio y tronera correcta gana")
	game = _table([0, 8, 9])
	game.called_pocket = 2
	_resolve(game, 8, [8], [1])
	_check(game.winner == -1, "Tronera equivocada pierde")
	game = _table([0, 8, 9])
	game.called_pocket = 2
	_resolve(game, 8, [8], [2], true)
	_check(game.winner == -1, "Negra con blanca embocada pierde")
	game = _table([0, 1, 8, 9])
	game.called_pocket = 2
	_resolve(game, 1, [1, 8], [0, 2])
	_check(game.winner == -1, "No permite última propia y negra en el mismo tiro")
	game = _table()
	_resolve(game, 1, [1, 9])
	_check(game.turn == 1 and not game.active[9], "Embocar ajena no devuelve bola ni anula propia legal")
	game = _table()
	_resolve(game, 1, [9])
	_check(game.turn == -1 and game.phase == "READY", "Sólo embocar ajena termina turno sin falta adicional")
	var original := Pool.new(73)
	original.command({"type": "spin", "x": 0.5, "y": -0.6})
	original.shoot(0.01, 93)
	for step in range(25):
		original.advance(1.0 / 60)
	var saved: Dictionary = JSON.parse_string(JSON.stringify(original.serialize()))
	var restored := Pool.new(1)
	_check(restored.restore(saved), "JSON recupera tiro en movimiento, efectos y contactos")
	restored.paused = false
	for step in range(300):
		original.advance(1.0 / 60)
		restored.advance(1.0 / 60)
	_check(original.positions == restored.positions and original.active == restored.active and original.turn == restored.turn, "Reanudación reproduce física y resolución")
	saved["data"]["groups"] = [1, 1]
	_check(not Pool.new().restore(saved), "Rechaza grupos incompatibles")
	var legacy := Sessions.LegacyPool.new(7)
	var old_save := legacy.serialize()
	var old_model := Sessions.create("billar", 1, old_save)
	_check(old_model.positions.size() == 7 and old_model.restore(old_save), "Partidas antiguas conservan sus reglas")
	_check(Sessions.create("billar", 1).positions.size() == 16, "Nuevas partidas usan ocho bolas")
	var duel := Pool.new(33)
	var removed := 0
	for shot in range(45):
		if duel.phase == "FINISHED":
			break
		if duel.phase == "PLACEMENT":
			duel._ai_place()
		choice = duel.choose_shot()
		duel.shoot(choice.x, choice.y)
		for step in range(130):
			duel.advance(0.1)
			if duel.phase != "MOVING":
				break
		_check(duel.phase != "MOVING", "Tiro de IA se detiene en presupuesto físico")
		removed = maxi(removed, 16 - duel.active.count(true))
	_check(removed > 0, "IA puede embocar con física de ocho bolas")
	for failure in failures:
		push_error(failure)
	print("EIGHT_BALL: %d assertions, %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)
