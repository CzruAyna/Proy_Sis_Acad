extends RefCounted

const World = preload("res://scripts/campus_world.gd")
const Map = preload("res://scripts/campus_map.gd")
const Overview = preload("res://scripts/campus_overview.gd")
const MinigamePreview = preload("res://scripts/minigame_preview.gd")
const MinigameSessions = preload("res://scripts/minigame_session_ui.gd")
const Inspection = preload("res://scripts/campus_inspection_overlay.gd")
const Achievements = preload("res://scripts/achievement_catalog.gd")
const Geo = preload("res://scripts/campus_cartography.gd")

var host: WeakRef
var world_ref: WeakRef
var saved: Dictionary = {}
var session_key := ""
var guest_name := ""
var _lighting_minutes := World.MORNING
var _last_objective := ""
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
		_lighting_minutes = World.MORNING
		_last_objective = ""
		saved = profile.get("campus_exploration", {}).duplicate(true) if profile.get("campus_exploration", {}) is Dictionary else {}


func open() -> void:
	_session()
	if _name().strip_edges().is_empty():
		show_welcome()
	else:
		show_world()


func show_welcome(message: String = "") -> void:
	_ui()._use_neutral_theme()
	var page: VBoxContainer = _ui()._make_page("Explora la FNI", "SIS-INF · ciudad universitaria · recorrido pixel art", _ui()._show_play)
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
			_lighting_minutes = world.lighting_minutes
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
	var page: VBoxContainer = _ui()._make_page("Explorar FNI", "", leave, false, false, false)
	var workspace := VBoxContainer.new()
	workspace.name = "ExplorationWorkspace"
	workspace.size_flags_vertical = Control.SIZE_EXPAND_FILL
	workspace.add_theme_constant_override("separation", 6)
	page.add_child(workspace)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	workspace.add_child(header)
	var prefix := _name() + " · " if _ui().current_profile.is_empty() else ""
	var location := _text(header, "", 15)
	location.name = "ExplorerIdentity"
	var world := World.new()
	world.name = "CampusWorld"
	world.player_program = str(_ui().current_profile.get("program_id", ""))
	world.custom_minimum_size.y = 180
	world.size_flags_vertical = Control.SIZE_EXPAND_FILL
	world.animations_enabled = bool(_ui().settings["animations"]) and not bool(_ui().settings.get("low_performance", false))
	world.lighting_minutes = _lighting_minutes
	world.restore(saved)
	world_ref = weakref(world)
	var clock := _text(header, world.clock_text(), 14)
	clock.name = "CampusClock"
	clock.autowrap_mode = TextServer.AUTOWRAP_OFF
	clock.size_flags_horizontal = Control.SIZE_SHRINK_END
	world.clock_changed.connect(func(value: String) -> void: clock.text = value)
	if _ui().simulation != null and not _ui().current_profile.is_empty():
		_add_objective(workspace)
	workspace.add_child(world)
	var status := HBoxContainer.new()
	status.add_theme_constant_override("separation", 10)
	workspace.add_child(status)
	var hint := _text(status, world.interaction_text(), 14)
	hint.name = "ExplorationContext"
	var interact := LinkButton.new()
	interact.name = "ExplorationInteractHint"
	interact.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	interact.add_theme_font_size_override("font_size", roundi(14 * float(_ui().settings["font_scale"])))
	interact.add_theme_color_override("font_color", _ui()._current_theme["highlight"])
	interact.pressed.connect(world.interact)
	status.add_child(interact)
	for item in [["Mapa [M]", show_map], ["Pausa [P]", show_progress]]:
		var button: Button = _ui()._add_button(status, item[0], item[1], false, 36)
		button.custom_minimum_size.x = 112
		button.add_theme_font_size_override("font_size", roundi(13 * float(_ui().settings["font_scale"])))
		button.autowrap_mode = TextServer.AUTOWRAP_OFF
	var update_location := func(value: String) -> void:
		hint.text = value
		interact.text = value.left(51) + "…" if value.length() > 54 else value
		interact.tooltip_text = value
		interact.visible = value.begins_with("E ·")
		hint.visible = not interact.visible
		var place := world.room_name if not world.room_name.is_empty() else str(Map.building(world.room_id).get("name", "")) + " · pasillo"
		location.text = prefix + (place if not world.room_id.is_empty() else "Ciudad universitaria FNI")
	world.context_changed.connect(update_location)
	update_location.call(world.interaction_text())
	world.progress_changed.connect(_update)
	# Finish input dispatch before removing its Control hierarchy.
	world.menu_requested.connect(show_progress, CONNECT_DEFERRED)
	world.map_requested.connect(show_map, CONNECT_DEFERRED)
	world.activity_requested.connect(show_room, CONNECT_DEFERRED)
	world.minigame_requested.connect(show_minigame, CONNECT_DEFERRED)
	world.landmark_requested.connect(show_monument, CONNECT_DEFERRED)
	world.actor_requested.connect(show_actor, CONNECT_DEFERRED)
	world.stairs_requested.connect(show_floors, CONNECT_DEFERRED)


func _add_objective(parent: Control) -> void:
	var objective: Dictionary = _ui()._campus().exploration_objective(show_world)
	var colors: Dictionary = _ui()._current_theme
	var accent: Color = colors["highlight"]
	var panel := PanelContainer.new()
	panel.name = "CampusObjective"
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#101824").lerp(colors["panel"], 0.40)
	style.bg_color.a = 1.0
	style.border_color = accent
	style.border_width_left = 4
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 5
	style.content_margin_bottom = 6
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	panel.add_child(row)
	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.add_theme_constant_override("separation", 1)
	row.add_child(copy)
	copy.add_child(_ui()._label("MISIÓN · " + str(objective["title"]), 16, accent))
	_text(copy, str(objective["hint"]), 13)
	if objective.has("action"):
		var action: Button = _ui()._add_button(row, str(objective["label"]) + " [J]", objective["action"], true, 36)
		action.name = "CampusObjectiveAction"
		var key := InputEventKey.new()
		key.keycode = KEY_J
		action.shortcut = Shortcut.new()
		action.shortcut.events = [key]
	var completed := ""
	if _last_objective == "matricula" and objective["id"] == "start":
		completed = "Matrícula completada"
	elif _last_objective == "close" and objective["id"] != "close":
		completed = "Semestre cerrado"
	if not completed.is_empty():
		var toast: Label = _ui()._label("✓ %s · recompensa prevista: créditos virtuales y aprendizaje" % completed, 13, accent)
		toast.name = "CampusRewardPreview"
		copy.add_child(toast)
		toast.get_tree().create_timer(5.0).timeout.connect(toast.queue_free)
	_last_objective = str(objective["id"])


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
	var page: VBoxContainer = _ui()._make_page("Pausa y progreso", "El recorrido está detenido", show_world, false, false, false)
	_text(page, _name() + " · %d espacios visitados" % saved.get("visited", []).size(), 20)
	var row := _actions(page)
	if not _ui().current_profile.is_empty():
		var snapshot: Dictionary = _ui().simulation.snapshot()
		var approved := 0
		for subject in snapshot["subjects"]:
			if subject["approved"]:
				approved += 1
		_text(page, "Periodo %d · %d materias aprobadas" % [int(snapshot["term"]), approved], 17)
		if _ui()._save_failed:
			_text(page, "No se pudo guardar: " + str(_ui()._save_feedback), 15)
		_ui()._add_button(row, "Mi campus", _ui()._show_solo_hub, true, 40)
		_ui()._add_button(row, "Malla", _ui()._show_campus_section.bind("malla"), false, 40)
	else:
		_text(page, "Visita libre. El recorrido se conserva durante esta sesión.", 16)
	_ui()._add_button(row, "Controles", show_help, false, 40)


func show_map() -> void:
	capture()
	_theme()
	var page: VBoxContainer = _ui()._make_page("Mapa del campus", "", show_world, false, false, false)
	var map := Overview.new()
	map.name = "CampusOverview"
	map.state = saved.duplicate(true)
	map.label_size = roundi(14 * float(_ui().settings["font_scale"]))
	var frame := Control.new()
	frame.clip_contents = true
	frame.custom_minimum_size.y = 220
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(frame)
	frame.add_child(map)
	map.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	map.closed.connect(show_world, CONNECT_DEFERRED)
	var controls := HBoxContainer.new()
	page.add_child(controls)
	var hint := _text(controls, "Rueda o + / −: zoom · Arrastre o flechas: mover · Inicio: vista general", 13)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var credit := LinkButton.new()
	credit.text = "Licencia del mapa"
	credit.uri = Geo.COPYRIGHT_URL
	credit.add_theme_font_size_override("font_size", roundi(12 * float(_ui().settings["font_scale"])))
	controls.add_child(credit)
	_ui()._focus_control.call_deferred(weakref(map))


func _inspect(content: Array[Dictionary]) -> void:
	if _ui().find_child("CampusInspection", true, false) != null:
		return
	capture()
	var world = world_ref.get_ref() if world_ref != null else null
	if is_instance_valid(world):
		world.paused = true
		world._held.clear()
	var overlay := Inspection.new()
	overlay.action_requested.connect(_inspection_action, CONNECT_DEFERRED)
	overlay.closed.connect(func() -> void:
		if is_instance_valid(world) and world.is_inside_tree():
			world.paused = false
			world._take_focus.call_deferred())
	overlay.open(_ui(), content, _name() + " · Ciudad universitaria FNI")


func show_monument(id: String) -> void:
	var world = world_ref.get_ref() if world_ref != null else null
	if is_instance_valid(world) and world.ambient_cast.visit_monument(id, world.player):
		_record_life(world)
	_inspect(Inspection.monument_pages(id))


func show_designs() -> void:
	_inspect(Inspection.catalog_pages())


func show_actor(id: String) -> void:
	var world = world_ref.get_ref() if world_ref != null else null
	if is_instance_valid(world):
		var actor: Dictionary = world.ambient_cast.find_instance(id)
		if not actor.is_empty():
			var dog: bool = world.ambient_cast.is_dog(actor)
			var page := {"kind": "cast_grid", "title": "Compañero del campus" if dog else "Vida del campus", "items": [{"id": actor["id"], "label": "Compañero" if dog else "Personaje"}], "text": "Acércate y acaricia a este compañero. Su reacción forma parte de la simulación." if dog else "Rutina simulada: %s. Edificio %s; aula %s. Esta actividad no registra asistencia ni notas del jugador." % [actor["state"], actor["building_id"], actor["room_name"]], "source": "Personaje ficticio; horarios y aulas ilustrativos, sin asignación institucional verificada."}
			if dog:
				page["actions"] = [{"type": "pet", "instance_id": id, "label": "Acariciar", "enabled": world.player.distance_to(actor["point"]) <= 52}]
			_inspect([page])
			return
	var pages := Inspection.catalog_pages()
	for page in pages:
		for item in page.get("items", []):
			if item["id"] == id:
				_inspect([page])
				return


func show_floors(id: String) -> void:
	var world = world_ref.get_ref() if world_ref != null else null
	if not is_instance_valid(world) or world.room_id != id or not world._near_stairs():
		_inspect(Inspection.floor_pages(id))
		return
	var pages := Inspection.floor_pages(id)
	var page: Dictionary = pages[clampi(world.floor_level, 0, pages.size() - 1)]
	page["text"] = "Estás en %s. Usa la escalera para cambiar de nivel. La distribución es una recreación provisional." % ("PB" if world.floor_level == 0 else "el piso %d" % world.floor_level)
	page["actions"] = [{"type": "floor", "level": world.floor_level + 1, "label": "Subir un piso", "enabled": world.floor_level + 1 < Map.floor_count(id)}, {"type": "floor", "level": world.floor_level - 1, "label": "Bajar un piso", "enabled": world.floor_level > 0}]
	_inspect([page])


func _inspection_action(action: Dictionary) -> void:
	var world = world_ref.get_ref() if world_ref != null else null
	if not is_instance_valid(world) or not world.is_inside_tree():
		return
	var overlay = _ui().find_child("CampusInspection", true, false)
	if overlay != null:
		overlay.close()
	if action.get("type") == "floor":
		world.change_floor(int(action.get("level", -1)))
	elif action.get("type") == "pet":
		var result: Dictionary = world.ambient_cast.pet(str(action.get("instance_id", "")), world.player)
		if result.get("ok", false):
			_record_life(world)
			world.context_changed.emit(str(result["message"]))
			world.queue_redraw()
	_save()


func _record_life(world: Control) -> void:
	_update(world.snapshot())
	if _ui().current_profile.is_empty():
		return
	if Achievements.evaluate(_ui().global_profile, _ui().current_profile):
		_ui()._save_global_profile()


func show_room(building: Dictionary, room: String) -> void:
	_save()
	_theme()
	if building["kind"] == "games_room":
		show_games()
		return
	var in_partida: bool = not _ui().current_profile.is_empty()
	if building["id"] == World.PROVISIONAL_DESK and in_partida:
		_ui()._campus().open_office(show_world)
		return
	var page: VBoxContainer = _ui()._make_page(room, "Interior recreado · " + str(building["name"]), show_world, false, false, false)
	_text(page, "Estás en " + room + ". Este ambiente es una recreación didáctica.", 17)
	if Map.room_kind(str(building["id"]), room) == "restroom":
		_text(page, "Ambiente de servicios.", 15)
	elif building["id"] == World.PROVISIONAL_DESK:
		_text(page, "La ventanilla simulada está disponible durante una partida académica.", 15)
	elif in_partida and building["kind"] != "office":
		_ui()._add_button(page, "Estudiar o repasar", _ui()._show_campus_section.bind("materias"), true, 42)


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


func show_help() -> void:
	capture()
	var page: VBoxContainer = _ui()._make_page("Controles de exploración", "", show_progress, false, false, false)
	for line in ["WASD o flechas · Caminar. Shift · Correr.", "E o Enter · Usar la puerta, el tablero, la mesa o el elemento cercano.", "P o Tab · Pausa y progreso. M · Mapa.", "Esc · Volver. El recorrido se detiene durante los menús.", "En una partida, acércate al fondo de Administración de Sistemas y pulsa E para consultar la ventanilla simulada."]:
		_text(page, line, 16)
	_ui()._add_button(page, "Personajes del campus", show_designs, false, 40)
