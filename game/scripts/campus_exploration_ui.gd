extends RefCounted

const World = preload("res://scripts/campus_world.gd")
const Map = preload("res://scripts/campus_map.gd")
const Overview = preload("res://scripts/campus_overview.gd")
const Neon = preload("res://scripts/neon_visuals.gd")
const MinigamePreview = preload("res://scripts/minigame_preview.gd")
const MinigameSessions = preload("res://scripts/minigame_session_ui.gd")

var host: WeakRef
var world_ref: WeakRef
var saved: Dictionary = {}
var session_key := ""
var guest_name := ""
var target_id := ""
var minigames: RefCounted


func _init(controller: Control) -> void:
	host = weakref(controller)


func _ui() -> Control:
	return host.get_ref()


func _text(parent: Control, value: String, size: int = 16) -> Label:
	var label: Label = _ui()._label(value, size, _ui()._current_theme.get("text", Color.WHITE))
	parent.add_child(label)
	return label


func _actions(parent: Control) -> HFlowContainer:
	var row := HFlowContainer.new()
	row.add_theme_constant_override("h_separation", 8)
	row.add_theme_constant_override("v_separation", 6)
	parent.add_child(row)
	return row


func _name() -> String:
	return str(_ui().current_profile.get("player_name", guest_name))


func _session() -> void:
	var profile: Dictionary = _ui().current_profile
	var key := "guest" if profile.is_empty() else "%s/%s/%s" % [profile.get("slot", 0), profile.get("created_at", ""), profile.get("player_name", "")]
	if key != session_key:
		session_key = key
		saved = profile.get("campus_exploration", {}).duplicate(true) if profile.get("campus_exploration", {}) is Dictionary else {}
		target_id = ""


func open() -> void:
	_session()
	if _name().strip_edges().is_empty():
		show_welcome()
	else:
		show_world()


func show_welcome(message: String = "") -> void:
	_ui()._use_neutral_theme()
	var page: VBoxContainer = _ui()._make_page("Explora la FNI", "SIS-INF · ciudad universitaria · recorrido pixel art", _ui()._show_main)
	var card: VBoxContainer = _ui()._card(page)
	_text(card, "Tu primera visita", 22)
	_text(card, "Recorre el campus con WASD o las flechas. Acércate a una puerta y pulsa E para entrar. P abre progreso y M abre el mapa.", 17)
	_text(card, "Nombre o apodo", 16)
	var name_field := LineEdit.new()
	name_field.name = "ExplorerName"
	name_field.text = guest_name
	name_field.max_length = 60
	name_field.custom_minimum_size.y = 42
	_ui()._style_input(name_field)
	card.add_child(name_field)
	if not message.is_empty():
		_text(card, message, 15)
	var start: Button = _ui()._add_button(card, "Entrar al campus", _start_guest.bind(name_field), true, 44)
	start.name = "StartExploration"
	start.disabled = guest_name.strip_edges().is_empty()
	name_field.text_changed.connect(func(value: String) -> void:
		guest_name = value
		start.disabled = value.strip_edges().is_empty())
	name_field.text_submitted.connect(func(_value: String) -> void: _start_guest(name_field))
	_text(page, "Adaptación del plano aportado. Interiores recreados para la demostración; distribución, accesos y usos actuales pendientes de verificación. La sede del centro se incorporará cuando se aporte su plano.", 14)


func _start_guest(field: LineEdit) -> void:
	guest_name = field.text.strip_edges()
	if guest_name.is_empty():
		show_welcome("Escribe un nombre o apodo antes de entrar.")
		return
	show_world()


func capture() -> void:
	if minigames != null:
		minigames.checkpoint()
	if world_ref != null:
		var world = world_ref.get_ref()
		if is_instance_valid(world) and world.is_inside_tree():
			_update(world.snapshot())


func _update(state: Dictionary) -> void:
	saved = state.duplicate(true)
	if not _ui().current_profile.is_empty():
		_ui().current_profile["campus_exploration"] = saved.duplicate(true)


func _theme() -> void:
	if _ui().current_profile.is_empty():
		_ui()._apply_career_theme("sistemas")
	else:
		_ui()._apply_career_theme(str(_ui().current_profile["program_id"]), str(_ui().current_profile["mention_id"]))


func show_world() -> void:
	_session()
	if _name().strip_edges().is_empty():
		show_welcome()
		return
	capture()
	_theme()
	var page: VBoxContainer = _ui()._make_page("Explorar FNI", "Recorrido espacial", leave)
	var workspace := VBoxContainer.new()
	workspace.name = "ExplorationWorkspace"
	workspace.set_meta("page_atomic", true)
	workspace.add_theme_constant_override("separation", 6)
	page.add_child(workspace)
	var location := _text(workspace, _name() + " · Ciudad universitaria FNI", 15)
	location.name = "ExplorerIdentity"
	var actions := _actions(workspace)
	_ui()._add_button(actions, "Progreso [P]", show_progress, false, 36)
	_ui()._add_button(actions, "Mapa [M]", show_map, false, 36)
	var world := World.new()
	world.name = "CampusWorld"
	world.custom_minimum_size = Vector2(0, 200)
	world.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	world.restore(saved)
	world_ref = weakref(world)
	_ui()._add_button(actions, "Interactuar [E]", world.interact, true, 36)
	_ui()._add_button(actions, "Ayuda", show_help, false, 36)
	for button in actions.get_children():
		if button is Button:
			var font_size := int(14 * float(_ui().settings["font_scale"]))
			button.add_theme_font_size_override("font_size", font_size)
			button.custom_minimum_size.x = maxf(120, Neon.PIXEL_FONT.get_string_size(button.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x + 32)
			button.autowrap_mode = TextServer.AUTOWRAP_OFF
	if not target_id.is_empty():
		var destination := Map.building(target_id)
		if not destination.is_empty():
			_text(workspace, "Destino señalado: " + str(destination["name"]) + " · pulsa M para localizarlo", 13)
	workspace.add_child(world)
	var hint := _text(workspace, world.interaction_text(), 15)
	hint.name = "ExplorationContext"
	world.context_changed.connect(func(value: String) -> void:
		hint.text = value
		var place := world.room_name if not world.room_name.is_empty() else str(Map.building(world.room_id).get("name", "")) + " · pasillo"
		location.text = _name() + " · " + (place + " · recreación" if not world.room_id.is_empty() else "Ciudad universitaria FNI"))
	world.progress_changed.connect(_update)
	world.menu_requested.connect(show_progress)
	world.map_requested.connect(show_map)
	world.activity_requested.connect(show_room)
	world.minigame_requested.connect(show_minigame)
	var pager = _ui().find_child("PageNavigator", true, false)
	pager.space_changed.connect(func(available: Vector2) -> void:
		var other := workspace.get_combined_minimum_size().y - world.custom_minimum_size.y
		world.custom_minimum_size.y = maxf(160, available.y - other - 8))


func _save() -> void:
	capture()
	if not _ui().current_profile.is_empty():
		_ui()._save_profile()


func leave() -> void:
	_save()
	if not _ui().current_profile.is_empty() and _ui()._save_failed:
		show_progress()
		return
	if _ui().current_profile.is_empty():
		_ui()._show_main()
	else:
		_ui()._show_solo_hub()


func show_progress() -> void:
	_save()
	_theme()
	var page: VBoxContainer = _ui()._make_page("Pausa y progreso", "El recorrido está detenido mientras consultas los menús", show_world)
	_text(page, _name() + " · %d espacios visitados" % saved.get("visited", []).size(), 20)
	_ui()._add_button(page, "Seguir explorando", show_world, true, 42)
	if not _ui().current_profile.is_empty():
		var snapshot: Dictionary = _ui().simulation.snapshot()
		var approved := 0
		for subject in snapshot["subjects"]:
			if subject["approved"]:
				approved += 1
		_text(page, "Periodo %d · %d materias aprobadas · Promedio %s" % [int(snapshot["term"]), approved, "%.2f" % float(snapshot["average"]) if snapshot["average"] != null else "pendiente"], 17)
		if _ui()._save_failed:
			_text(page, "No se pudo guardar: " + str(_ui()._save_feedback), 15)
		var row := _actions(page)
		for section in [["resumen", "Mi campus"], ["materias", "Materias"], ["malla", "Grafo curricular"], ["historial", "Historial"], ["tramites", "Trámites"], ["auxiliatura", "Auxiliatura"], ["graduacion", "Graduación"]]:
			_ui()._add_button(row, section[1], _ui()._show_campus_section.bind(section[0]), false, 40)
	else:
		_text(page, "Visita libre: el recorrido se conserva durante esta sesión. Para guardar posición y visitas junto con tu progreso académico, crea o continúa una carrera.", 16)
		_ui()._add_button(page, "Crear mi carrera", _ui()._new_available_game, false, 42)
	_text(page, "Las visitas registran exploración. Las materias y trámites avanzan mediante sus actividades y validaciones académicas.", 15)
	for id in saved.get("visited", []):
		_text(page, "Visitado · " + str(id).get_slice("/", 1), 15)


func show_map() -> void:
	capture()
	_theme()
	var page: VBoxContainer = _ui()._make_page("Mapa del campus", "Adaptación espacial del plano aportado · sin escala topográfica", show_world)
	_text(page, "Marca un destino y vuelve a caminar. El punto dorado es tu posición; el borde azul señala tu destino.", 15)
	var map := Overview.new()
	map.name = "CampusOverview"
	map.state = saved.duplicate(true)
	map.target_id = target_id
	map.custom_minimum_size = Vector2(0, 330)
	map.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map.set_meta("page_atomic", true)
	page.add_child(map)
	var row := _actions(page)
	_ui()._add_button(row, "Volver a caminar", show_world, true, 40)
	_ui()._add_button(row, "Ver plano aportado", show_reference, false, 40)
	for building in Map.buildings():
		var card: VBoxContainer = _ui()._card(page)
		_text(card, str(building["name"]), 18)
		_text(card, "Espacios del bloque: " + ", ".join(building["rooms"]), 14)
		_ui()._add_button(card, "Señalar destino", _select_target.bind(str(building["id"])), false, 38)


func _select_target(id: String) -> void:
	target_id = id
	show_map()


func show_reference() -> void:
	var page: VBoxContainer = _ui()._make_page("Plano aportado", "Fuente de referencia: AULAS-FNI.jpg · vigencia y derechos de redistribución pendientes de confirmar", show_map)
	var picture := TextureRect.new()
	picture.name = "OriginalCampusPlan"
	picture.texture = load("res://assets/reference/fni_plan.jpg")
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.custom_minimum_size = Vector2(0, 360)
	page.add_child(picture)
	_text(page, "Los rótulos se consultan también en el directorio del mapa. El recuadro de Aulas Básicas se ha adaptado a una zona jugable: su enlace espacial exacto requiere confirmación.", 15)


func show_room(building: Dictionary, room: String) -> void:
	_save()
	_theme()
	if building["kind"] == "games_room":
		show_games()
		return
	var page: VBoxContainer = _ui()._make_page(room, "Interior recreado · " + str(building["name"]), show_world)
	_text(page, "Estás en " + room + ". La decoración es una recreación didáctica; no representa todavía el mobiliario real.", 17)
	var actions := _actions(page)
	if not _ui().current_profile.is_empty():
		var section := "tramites" if building["kind"] == "office" else "materias"
		_ui()._add_button(actions, "Consultar trámites" if section == "tramites" else "Estudiar / repasar materias", _ui()._show_campus_section.bind(section), true, 42)
		_ui()._add_button(actions, "Ver mi progreso", show_progress, false, 42)
	else:
		_ui()._add_button(actions, "Ver visita y progreso", show_progress, true, 42)
	_text(page, "Otros espacios de este bloque", 20)
	if building["rooms"].size() > 1:
		_ui()._add_button(page, "Recorrer pasillo del bloque", _choose_hall.bind(str(building["id"])), false, 40)
	var rooms := _actions(page)
	for name in building["rooms"]:
		_ui()._add_button(rooms, str(name), _choose_room.bind(str(building["id"]), str(name)), str(name) == room, 40)
	_ui()._add_button(page, "Volver al interior", show_world, false, 40)


func show_games() -> void:
	if minigames != null:
		minigames.suspend()
	_save()
	_theme()
	var page: VBoxContainer = _ui()._make_page("Sala de juegos · Bloque E", "Elige una partida contra un rival automático", show_world, false, false)
	_text(page, "Cuatro juegos locales con pausa y revancha. Acércate a una mesa con WASD y pulsa E, o elige aquí.", 16)
	for station in Map.game_stations():
		var id := str(station["id"])
		var item: Dictionary = MinigamePreview.CATALOG[id]
		var card: VBoxContainer = _ui()._card(page)
		_text(card, str(item["title"]), 20)
		_text(card, str(item["description"]), 14)
		_ui()._add_button(card, "Jugar a " + str(item["title"]), show_minigame.bind(id), false, 38)
	_text(page, "La pausa conserva la partida. Los resultados recreativos no alteran tu expediente académico.", 14)
	_ui()._add_button(page, "Volver a la sala", show_world, true, 38)


func show_minigame(id: String) -> void:
	if not MinigamePreview.CATALOG.has(id):
		return
	if minigames == null:
		minigames = MinigameSessions.new(_ui(), self)
	minigames.open(id)


func _choose_room(id: String, room: String) -> void:
	var model := World.new()
	model.restore(saved)
	model.enter_room(id, room)
	_update(model.snapshot())
	model.free()
	show_world()


func _choose_hall(id: String) -> void:
	var model := World.new()
	model.restore(saved)
	model.enter_building(id)
	_update(model.snapshot())
	model.free()
	show_world()


func show_help() -> void:
	capture()
	var page: VBoxContainer = _ui()._make_page("Controles de exploración", "Controles clásicos y menús por botones", show_world)
	for line in ["WASD o flechas: moverte. Las diagonales mantienen la misma velocidad.", "Shift: correr. Las paredes, edificios y mesas bloquean el paso.", "E o Enter: entrar cerca de una puerta, salir o consultar el tablero del aula.", "Los bloques con varias aulas tienen un pasillo. Acércate a la puerta de cada ambiente y pulsa E. Desde el aula vuelves al pasillo; la salida del pasillo lleva al campus.", "P o Tab: pausar y consultar progreso, materias, grafo e historial.", "M: abrir el mapa, consultar el plano y señalar un destino.", "Escape: salir de esta vista. La exploración de una partida se guarda junto con su perfil.", "El aula tiene un tablero al fondo: acércate para ver actividades y otras aulas del bloque.", "Los controles por botones permanecen disponibles. El movimiento se detiene al cambiar de menú o perder el foco."]:
		_text(page, line, 17)
