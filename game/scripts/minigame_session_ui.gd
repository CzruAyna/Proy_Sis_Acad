extends RefCounted

const Chess = preload("res://scripts/chess_game.gd")
const Pool = preload("res://scripts/pool_game.gd")
const LegacyPool = preload("res://scripts/legacy_pool_game.gd")
const Pong = preload("res://scripts/pong_game.gd")
const Property = preload("res://scripts/campus_property_game.gd")
const Board = preload("res://scripts/minigame_board.gd")
const CATALOG := {
	"billar": {"title": "Billar", "rules": "Ocho bolas: quince numeradas y la blanca. Tras la apertura, una embocada legal asigna lisas/rayadas. Embocar una propia conserva turno. Sin contacto, primer contacto incorrecto, blanca embocada o falta de banda/embocada tras contacto: bola en mano para el rival. Primero limpia tu grupo y luego elige tronera para la negra. Negra prematura, con falta o en otra tronera pierde. Negra en apertura se repone; apertura sin embocada exige cuatro bolas en banda. Efectos arcade, sin saltos ni tiros elevados.", "controls": "Clic apunta; mantén, retira el taco y suelta para tirar. Clic derecho/Escape cancela. Flechas afinan ángulo/fuerza; Espacio tira. Arrastra la blanca cuando esté en mano; en apertura sólo detrás de la línea. Elige efecto en el diagrama de blanca y tronera haciendo clic en su agujero."},
	"ping_pong": {"title": "Ping-pong", "rules": "Duelo arcade. Gana quien llegue a 7 con dos de ventaja; a 11 se decide sin ventaja. Servicio alterno cada dos puntos. El rival tiene velocidad limitada, reacción y error. Mover la paleta al contactar influye en la devolución. Impulso dura 0,28 s y se recupera en 3 s.", "controls": "W/S, ↑/↓ o ratón mueven tu paleta. Espacio o clic en la mesa saca. Shift, clic derecho o Impulso acelera brevemente la paleta."},
	"ajedrez": {"title": "Ajedrez", "rules": "Juegas con blancas, sin reloj. Jaque, mate, ahogado, enroque, captura al paso y promoción. Puedes reclamar tablas por tres repeticiones o 50 movimientos; cinco repeticiones/75 movimientos son automáticas. El rival busca dos medias jugadas, con presupuesto limitado.", "controls": "Selecciona origen y destino con ratón o flechas/Enter. Las seis piezas tienen siluetas propias y una leyenda visual. Elige la promoción junto al tablero."},
	"monopolio": {"title": "Monopolio · Ruta del campus", "rules": "Variante propia: 600 créditos iniciales, 20 casillas, dos dados, compras, rentas y dos mejoras de 70. Pasar Inicio da 100; servicios cuestan 45. Descanso salta un turno. Se venden propiedades por la mitad para cubrir deudas; bancarrota pierde. A los 40 turnos gana el mayor patrimonio.", "controls": "Haz clic en los dados del tablero para lanzar; consulta cualquier casilla con clic. Compra/construye o finaliza desde la tarjeta central. Espacio/Enter lanza o pasa. Los peones muestran el recorrido; el rival conserva una reserva antes de invertir."}
}

var host: WeakRef
var campus: WeakRef
var sessions: Dictionary = {}
var token := ""
var current_id := ""
var selected := -1
var promotion := Chess.QUEEN
var _status: Label
var _board: Control
var _saved_revision := -1
var _saved_session := ""


func _init(controller: Control, exploration: RefCounted) -> void:
	host = weakref(controller)
	campus = weakref(exploration)


func _ui() -> Control:
	return host.get_ref()


func _key() -> String:
	var profile: Dictionary = _ui().current_profile
	return "guest" if profile.is_empty() else "%s/%s/%s" % [profile.get("slot", 0), profile.get("created_at", ""), profile.get("player_name", "")]


static func create(id: String, seed_value: int, saved: Dictionary = {}) -> RefCounted:
	match id:
		"billar":
			var data: Variant = saved.get("data", {})
			if data is Dictionary and data.get("positions") is Array and data["positions"].size() == 7 and not data.has("rules"):
				return LegacyPool.new(seed_value)
			return Pool.new(seed_value)
		"ping_pong": return Pong.new(seed_value)
		"ajedrez": return Chess.new(seed_value)
		"monopolio": return Property.new(seed_value)
	return null


func _ensure() -> void:
	if token == _key():
		return
	token = _key()
	sessions.clear()
	var saved: Variant = _ui().current_profile.get("minigames", {})
	if not saved is Dictionary or int(saved.get("version", 0)) != 1 or not saved.get("sessions", {}) is Dictionary:
		return
	for id in CATALOG:
		if saved["sessions"].get(id) is Dictionary:
			var model := create(id, 1, saved["sessions"][id])
			if model.restore(saved["sessions"][id]):
				sessions[id] = model


func checkpoint() -> void:
	if token != _key() or _ui().current_profile.is_empty():
		return
	var saved := {}
	for id in sessions:
		saved[id] = sessions[id].serialize()
	_ui().current_profile["minigames"] = {"version": 1, "sessions": saved}


func suspend() -> void:
	for model in sessions.values():
		model.paused = true
	checkpoint()


func _save() -> void:
	checkpoint()
	if not _ui().current_profile.is_empty():
		_ui()._save_profile()


func open(id: String) -> void:
	if not CATALOG.has(id):
		return
	_ensure()
	current_id = id
	if not sessions.has(id):
		sessions[id] = create(id, randi() & 0x7fffffff)
	var model: RefCounted = sessions[id]
	model.paused = false
	selected = -1
	var owner = campus.get_ref()
	owner._save()
	owner._theme()
	var page: VBoxContainer = _ui()._make_page(str(CATALOG[id]["title"]), "Sala E · tú contra un rival automático · partida local", back, false, false)
	var workspace := VBoxContainer.new()
	workspace.name = "MinigameWorkspace"
	workspace.set_meta("page_atomic", true)
	workspace.add_theme_constant_override("separation", 5)
	page.add_child(workspace)
	_status = owner._text(workspace, "", 14)
	_status.name = "MinigameStatus"
	_board = Board.new()
	_board.name = "MinigameBoard"
	_board.model = model
	_board.animations = bool(_ui().settings["animations"]) and not bool(_ui().settings["low_performance"])
	_board.text_scale = float(_ui().settings["font_scale"])
	_board.custom_minimum_size = Vector2(0, 220)
	_board.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	workspace.add_child(_board)
	_board.cell_selected.connect(_select_cell)
	_board.state_changed.connect(_refresh)
	_board.pause_requested.connect(_pause)
	_board.action_requested.connect(action)
	_board.promotion_selected.connect(_promotion)
	var general: HFlowContainer = owner._actions(workspace)
	_button(general, "Pausa [P]", _pause)
	_button(general, "Reglas", rules)
	_button(general, "Reiniciar", restart)
	_button(general, "Volver a la sala", back)
	var pager = _ui().find_child("PageNavigator", true, false)
	pager.space_changed.connect(func(available: Vector2) -> void:
		if is_instance_valid(_board):
			var other := workspace.get_combined_minimum_size().y - _board.custom_minimum_size.y
			_board.custom_minimum_size.y = maxf(160, available.y - other - 8))
	_refresh()
	_ui()._focus_control.call_deferred(weakref(_board))


func _button(parent: Control, text: String, callback: Callable, enabled: bool = true) -> Button:
	var result: Button = _ui()._add_button(parent, text, callback, false, 34)
	result.add_theme_font_size_override("font_size", int(13 * float(_ui().settings["font_scale"])))
	result.custom_minimum_size.x = minf(200, maxf(80, text.length() * 9 * float(_ui().settings["font_scale"]) + 24))
	result.disabled = not enabled
	return result


func action(data: Dictionary) -> Dictionary:
	var model: RefCounted = sessions[current_id]
	var result: Dictionary = model.command(data, model.revision)
	if not result["ok"]:
		model.message = result["message"]
	_refresh()
	_ui()._focus_control.call_deferred(weakref(_board))
	return result


func _refresh() -> void:
	if not is_instance_valid(_status) or not _status.is_inside_tree():
		return
	var model: RefCounted = sessions[current_id]
	_status.text = ("EN PAUSA · " if model.paused else "") + str(model.message)
	if model.game_id == "billar" and model.positions.size() == 7:
		_status.text += " · Partida antigua de seis bolas; Reiniciar abre ocho bolas."
	if model.game_id == "ajedrez" and selected >= 0:
		_status.text += " · Selección " + Chess.coordinate(selected)
	_board.selected = selected
	_board.promotion = promotion
	_board.set_process(not model.paused and model.phase != "FINISHED")
	_board.queue_redraw()
	if _saved_revision != model.revision or _saved_session != model.session_id:
		_saved_revision = model.revision
		_saved_session = model.session_id
		_save()


func _promotion(value: int) -> void:
	promotion = value
	_refresh()


func _select_cell(index: int) -> void:
	var model: RefCounted = sessions[current_id]
	if model.paused or model.phase == "FINISHED" or model.turn != 1:
		return
	var legal: Array = model.legal_moves()
	if selected >= 0:
		for move in legal:
			if move["from"] == selected and move["to"] == index and (move["promotion"] == 0 or move["promotion"] == promotion):
				action({"type": "move", "from": selected, "to": index, "promotion": promotion})
				selected = -1
				_board.destinations.clear()
				_refresh()
				return
	selected = index if model.board[index] > 0 else -1
	_board.destinations.clear()
	for move in legal:
		if move["from"] == selected and not _board.destinations.has(int(move["to"])):
			_board.destinations.append(int(move["to"]))
	_refresh()


func _pause() -> void:
	action({"type": "pause"})


func restart() -> void:
	sessions[current_id] = create(current_id, randi() & 0x7fffffff)
	open(current_id)


func rules() -> void:
	suspend()
	var owner = campus.get_ref()
	var page: VBoxContainer = _ui()._make_page("Reglas · " + str(CATALOG[current_id]["title"]), "Partida pausada", open.bind(current_id), false, false)
	owner._text(page, "Partida conservada de seis bolas: cada embocada puntúa; faltas cambian turno y conceden las bolas al rival. Reiniciar comienza la variante de ocho bolas." if current_id == "billar" and sessions[current_id].positions.size() == 7 else str(CATALOG[current_id]["rules"]), 17)
	owner._text(page, str(CATALOG[current_id]["controls"]), 16)
	owner._text(page, "P o Pausa detiene también al rival. Reiniciar crea una partida nueva. Las partidas se conservan en el perfil académico, sin alterar materias, notas ni logros; en visita libre duran la sesión.", 15)
	_button(page, "Volver a jugar", open.bind(current_id))


func back() -> void:
	suspend()
	_save()
	campus.get_ref().show_games()
