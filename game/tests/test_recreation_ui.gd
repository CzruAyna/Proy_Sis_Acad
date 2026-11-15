extends "res://tests/test_compact_navigation.gd"

const Sessions = preload("res://scripts/minigame_session_ui.gd")
const Chess = preload("res://scripts/chess_game.gd")
const Store = preload("res://scripts/simulation_save_store.gd")


func _send_key(code: Key) -> void:
	var key := InputEventKey.new()
	key.keycode = code
	key.pressed = true
	viewport.push_input(key, true)
	key.pressed = false
	viewport.push_input(key, true)


func _run() -> void:
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
	for id in Sessions.CATALOG:
		exploration.show_minigame(id)
		await _inspect(id)
		var ui = exploration.minigames
		var model = ui.sessions[id]
		_check(game.find_child("MinigameBoard", true, false) != null, "Tablero disponible: " + id)
		if id == "ajedrez":
			_send_key(KEY_2)
			_check(ui.promotion == Chess.ROOK, "2 selecciona la torre para la promoción")
			var click := InputEventMouseButton.new()
			click.button_index = MOUSE_BUTTON_LEFT
			click.pressed = true
			click.position = ui._board._origin + ui._board.chess_cell_centre(Chess.square("e2")) * ui._board._scale
			ui._board._gui_input(click)
			_check(ui._board.destinations.has(Chess.square("e4")), "Interfaz muestra destinos legales")
			click.position = ui._board._origin + ui._board.chess_cell_centre(Chess.square("e4")) * ui._board._scale
			ui._board._gui_input(click)
			_check(model.board[Chess.square("e4")] == Chess.PAWN and model.turn == -1, "Clic de origen/destino juega una pieza")
		elif id == "billar":
			_send_key(KEY_C)
			_send_key(KEY_DOWN)
			_send_key(KEY_ENTER)
			_check(ui._board._drag.is_empty() and model.positions[0].y > 150, "C, flechas y Enter colocan la blanca")
			_send_key(KEY_2)
			_send_key(KEY_I)
			_check(model.called_pocket == 1 and model.spin.y > 0, "2 anuncia tronera e I aplica efecto")
			_send_key(KEY_SPACE)
			_check(model.phase == "MOVING", "Espacio dispara la blanca")
		elif id == "ping_pong":
			_send_key(KEY_SPACE)
			_check(model.phase == "PLAY", "Espacio saca")
			var key := InputEventKey.new()
			key.physical_keycode = KEY_W
			key.pressed = true
			ui._board._gui_input(key)
			var previous: float = model.paddles[0]
			ui._board._process(0.05)
			_check(model.paddles[0] < previous, "W mueve la paleta durante el juego")
			key.pressed = false
			ui._board._gui_input(key)
		elif id == "monopolio":
			_send_key(KEY_RIGHT)
			_check(ui._board.selected_tile == 1, "Flecha consulta la siguiente casilla")
			_send_key(KEY_SPACE)
			_check(model.phase != "READY", "Espacio lanza los dados")
		_send_key(KEY_P)
		_check(model.paused, "P detiene la partida")
		_check(game.find_children("*", "Button", true, false).all(func(control: Control) -> bool: return not control.is_visible_in_tree()), "El tablero usa atajos sin botones en pantalla")
		var saved: Dictionary = model.serialize()
		_send_key(KEY_F1)
		await _inspect("reglas " + id)
		_check(game.find_child("MinigameBoard", true, false) == null, "F1 abre las reglas")
		ui.open(id)
		_check(model == ui.sessions[id] and not model.paused, "Reanudar conserva la misma sesión")
		ui.suspend()
		var profile_copy: Dictionary = JSON.parse_string(JSON.stringify(game.current_profile))
		var reconstructed := Sessions.new(game, exploration)
		reconstructed._ensure()
		_check(reconstructed.sessions.has(id), "Sesión serializada recuperable")
		_check(reconstructed.sessions[id].phase == saved["phase"], "Recupera fase correcta")
		_check(profile_copy.has("minigames") and profile_copy["minigames"]["sessions"].has(id), "Estado recreativo en perfil separado")
		_check(academic == JSON.stringify(game.simulation.snapshot()), "No cambia el expediente académico")
		var old_session: String = model.session_id
		ui.restart()
		_check(ui.sessions[id].session_id != old_session, "Reiniciar crea una sesión nueva")
		exploration.show_games()
		_check(ui.sessions[id].paused, "Salir al catálogo pausa el rival")
	var store := Store.new("res://.test-artifacts/recreation-storage", 1)
	_check(store.save_slot(1, game.current_profile) == OK, "Guarda perfil recreativo con el almacén existente")
	_check(store.read_slot(1).get("minigames", {}).get("sessions", {}).size() == 4, "Recarga los cuatro estados")
	store.remove_slot(1)
	var final_academic := JSON.stringify(game.simulation.snapshot())
	game.current_profile = {}
	game.simulation = null
	exploration.guest_name = "Visita"
	exploration.show_minigame("ajedrez")
	_check(exploration.minigames.sessions.size() == 1 and game.current_profile.is_empty(), "La visita libre no hereda partidas ni escribe perfil")
	_check(final_academic == academic, "Ningún minijuego altera materias o trámites")
	game.queue_free()
	viewport.queue_free()
	await process_frame
	for failure in failures:
		push_error(failure)
	print("RECREATION_UI_TESTS: %d assertions, %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)
