extends RefCounted

const World = preload("res://scripts/campus_world.gd")
const Map = preload("res://scripts/campus_map.gd")
const Overview = preload("res://scripts/campus_overview.gd")
const MinigamePreview = preload("res://scripts/minigame_preview.gd")
const MinigameSessions = preload("res://scripts/minigame_session_ui.gd")
const Inspection = preload("res://scripts/campus_inspection_overlay.gd")
const Achievements = preload("res://scripts/achievement_catalog.gd")
const Geo = preload("res://scripts/campus_cartography.gd")
const Daily = preload("res://scripts/campus_daily.gd")
const Classes = preload("res://scripts/campus_classes.gd")

var host: WeakRef
var world_ref: WeakRef
var saved: Dictionary = {}
var session_key := ""
var guest_name := ""
var _last_objective := ""
var _destination := Vector2.INF
var _destination_name := ""
var minigames: RefCounted


func _init(controller: Control) -> void:
	host = weakref(controller)


func _ui() -> Control:
	return host.get_ref()


func _play_page(title: String, subtitle: String, back: Callable, menu_backdrop: bool = false, campus_navigation: bool = false, pager: bool = true) -> VBoxContainer:
	return _ui()._make_page(title, subtitle, back, menu_backdrop, campus_navigation, pager, true)


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
		_last_objective = ""
		_destination = Vector2.INF
		_destination_name = ""
		world_ref = null
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
	_text(card, "Recorre el campus con WASD o las flechas. Acércate a una puerta y pulsa E para entrar. Tab abre la mochila, M el mapa y Esc la pausa.", 17)
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
	var page: VBoxContainer = _play_page("Explorar FNI", "", show_progress, false, false, false)
	_ui()._bind_page_key(KEY_G, show_directions)
	_ui()._bind_page_key(KEY_C, show_phone)
	_ui()._bind_page_key(KEY_H, show_schedule.bind(show_world))
	_ui()._bind_page_key(KEY_F1, show_help.bind(show_world))
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
	world.set_meta("gameplay_surface", true)
	world.player_program = str(_ui().current_profile.get("program_id", ""))
	world.custom_minimum_size.y = 180
	world.size_flags_vertical = Control.SIZE_EXPAND_FILL
	world.animations_enabled = bool(_ui().settings["animations"]) and not bool(_ui().settings.get("low_performance", false))
	world.restore(saved)
	world.destination = _destination
	world.class_schedule = _schedule()
	world._update_lesson()
	world_ref = weakref(world)
	var clock := _text(header, world.clock_text(), 14)
	clock.name = "CampusClock"
	clock.autowrap_mode = TextServer.AUTOWRAP_OFF
	clock.size_flags_horizontal = Control.SIZE_SHRINK_END
	var supplies := _text(workspace, world.daily.status(), 13)
	supplies.name = "CampusSupplies"
	world.clock_changed.connect(func(value: String) -> void:
		clock.text = value
		supplies.text = world.daily.status()
	)
	if _ui().simulation != null and not _ui().current_profile.is_empty():
		_add_objective(workspace)
	workspace.add_child(world)
	var hint: Label = _ui()._key_hint(workspace, world.interaction_text())
	hint.name = "ExplorationContext"
	var controls: Label = _ui()._key_hint(workspace, "[WASD] Mover   [Tab] Mochila   [M] Mapa   [G] Guía   [H] Horario   [C] Celular")
	controls.name = "ExplorationKeys"
	var update_location := func(value: String) -> void:
		hint.text = value
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
	world.vendor_requested.connect(show_vendor, CONNECT_DEFERRED)
	world.backpack_requested.connect(show_backpack.bind("", show_world), CONNECT_DEFERRED)


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
	if objective.has("building"):
		_ui()._key_hint(row, "[J] Marcar en mapa")
		_ui()._bind_page_key(KEY_J, mark_building.bind(str(objective["building"])))
	elif objective.has("action"):
		var action: Label = _ui()._key_hint(row, str(objective["label"]) + " [J]")
		action.name = "CampusObjectiveAction"
		_ui()._bind_page_key(KEY_J, objective["action"])
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
	var page: VBoxContainer = _play_page("Pausa y progreso", "El recorrido está detenido", show_world, false, false, false)
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
	_ui()._add_button(page, "Salir del recorrido", leave, false, 34)
	_ui()._key_hint(page, "[G] Guía   [Tab] Mochila   [M] Mapa   [F1] Controles")
	_ui()._bind_page_key(KEY_G, show_directions)
	_ui()._bind_page_key(KEY_TAB, show_backpack.bind("", show_progress))
	_ui()._bind_page_key(KEY_M, show_map)
	_ui()._bind_page_key(KEY_F1, show_help.bind(show_progress))


func mark_building(id: String) -> void:
	var building := Map.building(id)
	if not building.is_empty():
		_mark(building["door"], str(building["name"]))


func _mark(point: Vector2, title: String) -> void:
	_session()
	_destination = point
	_destination_name = title
	show_map()


func _clear_marker() -> void:
	_destination = Vector2.INF
	_destination_name = ""
	show_directions()


func show_directions() -> void:
	_save()
	_theme()
	var page: VBoxContainer = _play_page("Adónde ir", "Elige un destino para marcarlo en el mapa.", show_progress, false, false)
	var routes := [
		[World.DEAN_OFFICE, "Decanato", "Matrícula, cartas, cambios de carrera o mención y titulación."],
		[World.ASSISTANT_OFFICE, "Dirección de Carrera", "Postula a Auxiliaturas y lleva el plan firmado o el permiso de aula."],
		[Classes.BUILDING, "Ciclo Básico", "Consulta el día, la hora y el piso. Entra al aula y acércate a la pizarra."]
	]
	for route in routes:
		var card: VBoxContainer = _ui()._card(page, true)
		_text(card, route[1], 20)
		_text(card, route[2], 15)
		_ui()._add_button(card, "Marcar " + str(route[1]), mark_building.bind(str(route[0])), false, 38)
	_ui()._add_button(page, "Ver horario de Ciclo Básico", show_schedule.bind(show_directions), true, 42)
	_ui()._add_button(page, "Dónde comer o beber", show_food_map, false, 40)
	if _destination.is_finite():
		_ui()._add_button(page, "Quitar marca del mapa", _clear_marker, false, 36)


func show_food_map() -> void:
	var page: VBoxContainer = _play_page("Puestos y comedor", "", show_directions, false, false)
	var positions := World.vendor_positions()
	for id in Daily.VENDORS:
		var card: VBoxContainer = _ui()._card(page)
		_text(card, Daily.VENDORS[id][1], 14)
		_ui()._add_button(card, "Marcar " + str(Daily.VENDORS[id][0]), _mark.bind(positions[id], Daily.VENDORS[id][0]), false, 40)


func show_map() -> void:
	capture()
	_theme()
	var page: VBoxContainer = _play_page("Mapa del campus", "", show_world, false, false, false)
	var map := Overview.new()
	map.name = "CampusOverview"
	map.set_meta("gameplay_surface", true)
	_ui()._bind_page_key(KEY_TAB, show_backpack.bind("", show_map))
	map.state = saved.duplicate(true)
	map.destination = _destination
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
	var hint := _text(controls, "[M] Cerrar · [+ / −] Zoom · Flechas para mover · Inicio para encuadrar", 13)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var credit := LinkButton.new()
	credit.text = "© OpenStreetMap contributors"
	credit.uri = Geo.COPYRIGHT_URL
	credit.add_theme_font_size_override("font_size", roundi(12 * float(_ui().settings["font_scale"])))
	controls.add_child(credit)
	if _destination.is_finite():
		_text(page, "Destino marcado · " + _destination_name, 15)
	_ui()._bind_page_key(KEY_M, show_world)
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
	overlay.set_meta("gameplay_overlay", true)
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
	var id := str(building["id"])
	if id in [World.DEAN_OFFICE, World.ASSISTANT_OFFICE] and in_partida:
		_ui()._campus().open_office(show_world, id)
		return
	if id == Classes.BUILDING and Map.room_kind(id, room) == "classroom":
		show_classroom(room)
		return
	var page: VBoxContainer = _play_page(room, "Interior recreado · " + str(building["name"]), show_world, false, false, false)
	_text(page, "Estás en " + room + ". Este ambiente es una recreación didáctica.", 17)
	if Map.room_kind(str(building["id"]), room) == "restroom":
		_text(page, "Ambiente de servicios.", 15)
	elif id in [World.DEAN_OFFICE, World.ASSISTANT_OFFICE]:
		_text(page, "La ventanilla simulada está disponible durante una partida académica.", 15)
	elif in_partida and building["kind"] != "office":
		_ui()._add_button(page, "Estudiar o repasar", _ui()._show_campus_section.bind("materias"), true, 42)


func _schedule() -> Array[Dictionary]:
	if _ui().simulation != null and not _ui().current_profile.is_empty():
		return Classes.schedule(_ui().simulation.snapshot())
	var empty: Array[Dictionary] = []
	return empty


func _daily() -> RefCounted:
	var routine := Daily.new()
	routine.restore(saved.get("daily"))
	return routine


func _save_daily(routine: RefCounted) -> void:
	saved["daily"] = routine.snapshot()
	_update(saved)
	if not _ui().current_profile.is_empty():
		_ui()._save_profile()


func show_schedule(back: Callable) -> void:
	_session()
	_save()
	_theme()
	var page: VBoxContainer = _play_page("Horario de Ciclo Básico", "Semanas del juego · horario simulado", back, false, false)
	var schedule := _schedule()
	if schedule.is_empty():
		_text(page, "Inicia una partida e inscríbete para ver tus clases.", 17)
		return
	_ui()._add_button(page, "Marcar Ciclo Básico", mark_building.bind(Classes.BUILDING), true, 38)
	var routine := _daily()
	schedule.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return Classes.next_start(a, routine.minutes) < Classes.next_start(b, routine.minutes))
	for row in schedule:
		var card: VBoxContainer = _ui()._card(page)
		_text(card, "%s · %s" % [row["code"], row["name"]], 17)
		_text(card, Classes.timing(row), 15)

		var clashes := Classes.conflicts(row, schedule)
		if not clashes.is_empty():
			_text(card, "Choque con " + ", ".join(clashes), 15)
		if _ui().simulation.planning_available():
			_ui()._add_button(card, "Cambiar paralelo", _change_parallel.bind(row["course"], back), false, 34)


func _change_parallel(course: String, back: Callable) -> void:
	if _ui().simulation.change_parallel(course):
		_ui()._save_profile()
	show_schedule(back)


func show_phone() -> void:
	_save()
	var page := _play_page("Celular", "Chat de tus materias", show_world)
	var routine := _daily()
	var week := floori(routine.minutes / Daily.WEEK)
	var rows := _schedule()
	if rows.is_empty():
		_text(page, "Tus grupos aparecen al inscribir materias.", 16)
	for row in rows:
		var card: VBoxContainer = _ui()._card(page)
		var session := Classes.appointment(row, week)
		var minute := int(session["start"])
		var weekdays := ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]
		_text(card, "Prof. %s · %s" % [row["teacher"], row["name"]], 18)
		_text(card, "%s %02d:%02d · %s · piso %d" % [weekdays[(minute / Daily.DAY) % 7], (minute / 60) % 24, minute % 60, row["room"], row["floor"]], 15)
		_text(card, str(session["message"]), 16)



func show_classroom(room: String) -> void:
	var routine := _daily()
	var page: VBoxContainer = _play_page(room, "Ciclo Básico · Piso %d" % Map.room_floor(Classes.BUILDING, room), show_world, false, false)
	var classes := _schedule()
	var active := Classes.active(classes, room, routine.minutes)
	if not active.is_empty():
		_live_class(page, active, routine)
		return
	var next: Dictionary = {}
	for row in classes:
		if row["room"] == room and (next.is_empty() or Classes.next_start(row, routine.minutes) < Classes.next_start(next, routine.minutes)):
			next = row
	if next.is_empty():
		_text(page, "No tienes clases asignadas a esta aula.", 17)
	else:
		var start := Classes.next_start(next, routine.minutes)
		_text(page, "Próxima clase · " + str(next["name"]), 20)
		_text(page, Classes.timing(next), 16)
		_text(page, "Siguiente sesión efectiva · día %d, %02d:%02d" % [floori(start / Daily.DAY) + 1, int(start / 60) % 24, int(start) % 60], 15)
		_ui()._add_button(page, "Esperar aquí hasta la clase", _wait_for_class.bind(next), true, 42)
	_ui()._add_button(page, "Ver todo mi horario", show_schedule.bind(show_world), false, 40)


func _wait_for_class(row: Dictionary) -> void:
	var routine := _daily()
	routine.advance(Classes.next_start(row, routine.minutes) - routine.minutes)
	_save_daily(routine)
	show_classroom(str(row["room"]))


func _live_class(page: VBoxContainer, row: Dictionary, routine: RefCounted) -> void:
	var board: VBoxContainer = _ui()._card(page, true)
	board.name = "LiveClassBoard"
	_text(board, "%s · %s" % [row["code"], row["name"]], 24)
	_text(board, Classes.timing(row), 15)
	var ink := _text(board, "", 21)
	ink.name = "LiveClassWriting"
	var feedback := _text(board, "", 15)
	var timer := Timer.new()
	timer.wait_time = 3.0
	board.add_child(timer)
	var sync := func() -> void:
		var count := Classes.visible_lines(row, routine.minutes)
		ink.text = "\n".join(row["lines"].slice(0, count))
		if count == row["lines"].size():
			timer.stop()
			routine.notes[row["key"]] = {"title": row["name"], "lines": row["lines"]}
			feedback.text = "Apunte guardado en tu mochila."
			_save_daily(routine)
		else:
			feedback.text = "El docente está escribiendo en la pizarra…"
	timer.timeout.connect(func() -> void:
		var end := Classes.next_start(row, routine.minutes) + Classes.DURATION
		routine.advance(minf(12.0, end - routine.minutes - 0.01))
		saved["daily"] = routine.snapshot()
		_update(saved)
		sync.call()
	)
	timer.start()
	sync.call()
	if _ui().simulation.state["phase"] == "CURSANDO":
		var entry: Dictionary = _ui().simulation.state["enrollments"].get(row["course"], {})
		if not entry.is_empty() and entry["score"] == null:
			var week := floori(routine.minutes / Daily.WEEK)
			var session := Classes.appointment(row, week)
			if session["exam"]:
				_ui()._add_button(page, "Rendir parcial", _ui()._start_subject.bind(row["course"], show_classroom.bind(row["room"])), true, 40)
			else:
				var exam_week := week + (2 - week % 3)
				var exam := Classes.appointment(row, exam_week)
				_ui()._add_button(page, "Esperar al examen · día %d" % (int(exam["start"]) / Daily.DAY + 1), _wait_for_exam.bind(row, exam["start"]), false, 40)
	_ui()._add_button(page, "Ver horario", show_schedule.bind(show_world), false, 40)


func _wait_for_exam(row: Dictionary, start: int) -> void:
	var routine := _daily()
	routine.advance(start - routine.minutes)
	_save_daily(routine)
	show_classroom(str(row["room"]))


func show_vendor(id: String, message: String = "") -> void:
	if message.is_empty():
		_save()
	_theme()
	var vendor: Array = Daily.VENDORS[id]
	var routine := _daily()
	var page: VBoxContainer = _play_page(vendor[0], vendor[1], show_world, false, false)
	_text(page, routine.status(), 16)
	if not message.is_empty():
		_text(page, message, 15)
	for item in vendor[2]:
		var goods: Array = Daily.ITEMS[item]
		var card: VBoxContainer = _ui()._card(page)
		_text(card, "%s · %d créditos" % [goods[0], goods[1]], 18)
		_text(card, "Al consumir · reduce hambre %d y sed %d" % [goods[2], goods[3]], 14)
		var button: Button = _ui()._add_button(card, "Tomar agua" if int(goods[1]) == 0 else "Comprar " + str(goods[0]), _buy.bind(id, item), false, 40)
		button.disabled = routine.balance < int(goods[1]) or routine.load_count() >= Daily.CAPACITY
	_ui()._key_hint(page, "[Tab] Mochila")
	_ui()._bind_page_key(KEY_TAB, show_backpack.bind("", show_vendor.bind(id)))


func _buy(vendor: String, item: String) -> void:
	var routine := _daily()
	var message: String = routine.buy(vendor, item)
	_save_daily(routine)
	show_vendor(vendor, message)


func show_backpack(message: String, back: Callable, section: int = 0) -> void:
	if message.is_empty():
		_save()
	_theme()
	var routine := _daily()
	var page: VBoxContainer = _play_page("Mochila", "%d/%d espacios · %s" % [routine.load_count(), Daily.CAPACITY, routine.status()], back)
	page.set_meta("backpack_section", section)
	_ui()._bind_page_key(KEY_TAB, back)
	_ui()._bind_page_key(KEY_LEFT, show_backpack.bind("", back, posmod(section - 1, 3)))
	_ui()._bind_page_key(KEY_RIGHT, show_backpack.bind("", back, posmod(section + 1, 3)))
	var tabs := HFlowContainer.new()
	tabs.add_theme_constant_override("h_separation", 16)
	page.add_child(tabs)
	var captions := ["Alimentos", "Carpetas", "Apuntes"]
	for index in captions.size():
		var title := "[%d] %s" % [index + 1, captions[index]]
		var colors: Dictionary = _ui()._current_theme
		var active_color: Color = colors["highlight"] if section == index else colors["sub"]
		_ui()._bind_page_key(KEY_1 + index, show_backpack.bind("", back, index))
		tabs.add_child(_ui()._label(("> " if section == index else "") + title, 15, active_color))
	_ui()._key_hint(page, "[←/→] Cambiar bolsillo   [Tab] Cerrar")
	if not message.is_empty():
		_text(page, message, 16)
	match section:
		0:
			var supplies: VBoxContainer = _ui()._card(page, true)
			_text(supplies, "Comida y bebida", 21)
			if routine.backpack.is_empty():
				_text(supplies, "Busca el kiosco o el comedor para abastecerte.", 15)
			for item in routine.backpack:
				var label := "Consumir %s (×%d)" % [Daily.ITEMS[item][0], routine.backpack[item]]
				_ui()._add_button(supplies, label, _consume.bind(item, back), false, 34)
		1:
			if _ui().simulation != null and not _ui().current_profile.is_empty():
				_ui()._campus().show_document_folder(page)
			else:
				_text(page, "Los expedientes se guardan aquí durante una partida de estudiante.", 15)
		2:
			var notes: VBoxContainer = _ui()._card(page, true)
			_text(notes, "Apuntes de clase", 21)
			if routine.notes.is_empty():
				_text(notes, "Asiste a una clase en Ciclo Básico para guardar el apunte.", 15)
			for note in routine.notes.values():
				if note is Dictionary and note.get("lines") is Array:
					_text(notes, str(note.get("title", "")), 17)
					_text(notes, "\n".join(note["lines"]), 15)


func _consume(item: String, back: Callable) -> void:
	var routine := _daily()
	var message: String = routine.consume(item)
	_save_daily(routine)
	show_backpack(message, back)


func show_games() -> void:
	if minigames != null:
		minigames.suspend()
	_save()
	_theme()
	var page: VBoxContainer = _play_page("Sala de juegos · Bloque E", "Elige una partida contra un rival automático", show_world, false, false)
	_text(page, "Cuatro juegos locales con pausa y revancha. Acércate a una mesa con WASD y pulsa E, o elige aquí.", 16)
	for station in Map.game_stations():
		var id := str(station["id"])
		var item: Dictionary = MinigamePreview.CATALOG[id]
		var card: VBoxContainer = _ui()._card(page)
		_text(card, str(item["title"]), 20)
		_text(card, str(item["description"]), 14)
		_ui()._add_button(card, "Jugar a " + str(item["title"]), show_minigame.bind(id), false, 38)
	_text(page, "La pausa conserva la partida. Los resultados recreativos no alteran tu expediente académico.", 14)


func show_minigame(id: String) -> void:
	if not MinigamePreview.CATALOG.has(id):
		return
	if minigames == null:
		minigames = MinigameSessions.new(_ui(), self)
	minigames.open(id)


func show_help(back: Callable = Callable()) -> void:
	capture()
	var page: VBoxContainer = _play_page("Controles de exploración", "", back if back.is_valid() else show_progress, false, false, false)
	for line in ["WASD o flechas · Caminar. Shift · Correr.", "E o Enter · Entrar, comprar o consultar el tablero cercano.", "Tab · Mochila. M · Mapa. Esc o P · Pausa.", "G · Guía. H · Horario. J · Misión.", "Flechas · Seleccionar. Enter · Confirmar. Esc · Volver. Re Pág y Av Pág · Recorrer listas extensas.", "Decanato · Trámites. Dirección de Carrera · Auxiliaturas. Ciclo Básico · Horarios y clases."]:
		_text(page, line, 16)
	_ui()._add_button(page, "Personajes del campus", show_designs, false, 40)
