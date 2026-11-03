extends "res://tests/test_compact_navigation.gd"

const Board = preload("res://scripts/minigame_board.gd")
const Pieces = preload("res://scripts/chess_piece_art.gd")
const Sessions = preload("res://scripts/minigame_session_ui.gd")


func _mouse(board: Control, point: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = board._origin + point * board._scale
	event.pressed = pressed
	board._gui_input(event)


func _click(board: Control, point: Vector2) -> void:
	_mouse(board, point, true)
	_mouse(board, point, false)


func _motion(board: Control, point: Vector2) -> void:
	var event := InputEventMouseMotion.new()
	event.position = board._origin + point * board._scale
	board._gui_input(event)


func _run() -> void:
	var shapes := {}
	for piece in range(1, 7):
		var texture := Pieces.texture(piece)
		_check(texture.get_size() == Vector2(32, 40) and texture == Pieces.texture(piece), "Pieza con resolución propia y caché")
		shapes[hash(texture.get_image().get_data())] = true
	_check(shapes.size() == 6, "Seis dibujos diferentes, sin usar letras para las piezas")
	for a in range(20):
		_check(Rect2(Vector2.ZERO, Board.BASE).encloses(Board.tile_rect(a)), "Casilla dentro del tablero")
		for b in range(a + 1, 20):
			_check(not Board.tile_rect(a).intersects(Board.tile_rect(b)), "Casillas no se superponen")
	viewport = SubViewport.new()
	viewport.size = Vector2i(900, 640)
	root.add_child(viewport)
	game = TestGame.new()
	viewport.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game.active_slot = 1
	game.draft_player_name = "Prueba compacta"
	game._create_solo_save("sistemas", "gestion_sistemas")
	var academic := JSON.stringify(game.simulation.snapshot())
	game._show_exploration()
	var exploration = game.exploration_ui
	exploration.show_minigame("billar")
	await _inspect("billar directo")
	var ui = exploration.minigames
	var board = ui._board
	var model = ui.sessions["billar"]
	var aim: Vector2 = Board.COURT_ORIGIN + Vector2(410, 150) * Board.COURT_SCALE
	_click(board, aim)
	_check(model.shots == 0 and model.phase == "READY", "Clic apunta sin disparar accidentalmente")
	_mouse(board, aim, true)
	_motion(board, aim - Vector2(90 * Board.COURT_SCALE, 0))
	_mouse(board, aim - Vector2(90 * Board.COURT_SCALE, 0), false)
	_check(model.shots == 1 and model.phase == "MOVING" and is_equal_approx(model.power, 90), "Retirar taco y soltar transmite fuerza al motor")
	ui.restart()
	await _settle()
	board = ui._board
	model = ui.sessions["billar"]
	_mouse(board, aim, true)
	_motion(board, aim - Vector2(50, 0))
	var escape := InputEventKey.new()
	escape.physical_keycode = KEY_ESCAPE
	escape.pressed = true
	board._gui_input(escape)
	_mouse(board, aim - Vector2(50, 0), false)
	_check(model.shots == 0, "Escape cancela un tiro preparado")
	model.phase = "PLACEMENT"
	model.can_place = true
	model.break_shot = false
	_click(board, Board.COURT_ORIGIN + Vector2(250, 80) * Board.COURT_SCALE)
	_check(model.positions[0].is_equal_approx(Vector2(250, 80)) and model.phase == "READY", "Colocación de blanca desde la mesa")
	_click(board, Vector2(974, 157))
	_check(model.spin.x > 0.4 and model.spin.y > 0.4, "Diagrama de blanca elige contacto y efecto")
	_click(board, Board.COURT_ORIGIN + model.POCKETS[2] * Board.COURT_SCALE)
	_check(model.called_pocket == 2, "Elegir agujero anuncia tronera")
	var legacy := Sessions.LegacyPool.new(5)
	ui.sessions["billar"] = legacy
	ui.open("billar")
	await _inspect("billar conservado")
	_check(ui.sessions["billar"].positions.size() == 7, "Interfaz abre partida antigua sin borrarla")
	ui.restart()
	_check(ui.sessions["billar"].positions.size() == 16, "Reiniciar pasa explícitamente a ocho bolas")
	exploration.show_minigame("monopolio")
	await _inspect("ruta directa")
	board = ui._board
	model = ui.sessions["monopolio"]
	_click(board, Vector2(480, 260))
	_check(model.dice[0] >= 1 and model.phase != "READY", "Dados interactivos disparan el turno desde el tablero")
	_click(board, Board.tile_rect(12).get_center())
	_check(board.selected_tile == 12, "Cada propiedad se puede consultar con clic")
	model.positions[0] = 1
	model.phase = "BUY"
	board.selected_tile = 1
	board.queue_redraw()
	await _settle()
	var cash: int = model.cash[0]
	_click(board, Vector2(350, 436))
	_check(model.owners[1] == 1 and model.cash[0] == cash - 90, "Compra desde tarjeta central del tablero")
	model.phase = "UPGRADE"
	board.queue_redraw()
	await _settle()
	_click(board, Vector2(350, 436))
	_check(model.levels[1] == 1, "Construcción desde propiedad seleccionada")
	_click(board, Vector2(600, 436))
	_check(model.turn == -1, "Finalizar turno desde tablero")
	exploration.show_minigame("ping_pong")
	await _inspect("pong directo")
	model = ui.sessions["ping_pong"]
	model.turn = -1
	model.serve()
	_check(model.command({"type": "boost"})["ok"], "Impulso humano disponible aunque haya sacado el rival")
	_check(not model.command({"type": "boost"})["ok"], "No se repite impulso durante recuperación")
	var cooldown: float = model.boost_cooldown
	model.advance(0.1)
	_check(model.boost_cooldown < cooldown and model.boost_left > 0, "Impulso tiene duración y recuperación reales")
	model.paused = true
	cooldown = model.boost_cooldown
	model.advance(0.1)
	_check(model.boost_cooldown == cooldown, "Pausa también detiene recuperación de impulso")
	_check(academic == JSON.stringify(game.simulation.snapshot()), "Controles directos conservan el expediente")
	game.queue_free()
	viewport.queue_free()
	await process_frame
	for failure in failures:
		push_error(failure)
	print("RECREATION_SURFACE: %d assertions, %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)
