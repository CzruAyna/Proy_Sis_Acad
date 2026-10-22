extends Control

const Catalog = preload("res://scripts/catalog.gd")
const SAVE_DIR := "user://partidas"
const SAVE_COUNT := 3
const INK := Color("#272b25")
const PAPER := Color("#f5f0e5")
const RULE := Color("#ddd5c5")
const GREEN := Color("#526b57")
const GOLD := Color("#b77a43")

const CV_SKILLS := [
	"Tutorías y apoyo académico",
	"Organización de actividades universitarias",
	"Manejo de registros y planillas",
	"Atención y orientación a estudiantes",
]

const ASSISTANT_CASES := [
	{"question": "En la tutoría, alguien memoriza una fórmula pero no entiende cuándo usarla. ¿Qué haces?", "options": ["Resolver todo por esa persona", "Proponer un ejemplo sencillo y pedirle que explique el paso", "Decir que vuelva cuando ya sepa"], "best": 1, "good": "La persona practica el razonamiento y puede detectar qué parte le cuesta.", "bad": "La tutoría sirve más cuando ayuda a entender el proceso, no solo a copiar el resultado."},
	{"question": "Dos estudiantes piden ayuda al mismo tiempo y queda poco de la hora. ¿Cómo organizas el apoyo?", "options": ["Acordar una prioridad y dejar un siguiente paso claro para ambas personas", "Atender solo a quien habla más fuerte", "Cerrar la tutoría sin avisar"], "best": 0, "good": "La prioridad queda clara y nadie se va sin saber qué hacer después.", "bad": "Coordinar tiempos y expectativas evita que el apoyo dependa de quién insiste más."},
	{"question": "Una respuesta de la guía parece tener un error. ¿Qué haces antes de difundirla?", "options": ["Verificar el procedimiento y consultar al docente si sigue la duda", "Cambiarla en silencio y repartir otra versión", "Decir al grupo que la guía no sirve"], "best": 0, "good": "Revisar la evidencia y avisar del cambio evita que el error se replique.", "bad": "Una duda se resuelve mejor comprobando el procedimiento y comunicando el resultado."},
]

const ADMIN_CASES := [
	{"question": "Dos solicitudes de inscripción aparecen duplicadas y una vence hoy. ¿Cuál es el primer paso?", "options": ["Revisar el historial, confirmar la solicitud válida y dejar registro", "Borrar las dos para empezar de cero", "Aprobar ambas para que nadie reclame"], "best": 0, "good": "La revisión conserva la trazabilidad y atiende primero el plazo cercano.", "bad": "Un trámite necesita verificación y registro antes de cambiar datos académicos."},
	{"question": "Hay pocos recursos para atender tres necesidades urgentes. ¿Cómo recomiendas priorizar?", "options": ["Usar criterios publicados, impacto y urgencia; luego explicar la decisión", "Elegir a quien conoces personalmente", "Dividir el dinero en partes iguales sin revisar cada caso"], "best": 0, "good": "Los criterios claros ayudan a usar recursos limitados con responsabilidad.", "bad": "La decisión debe poder explicarse y considerar el impacto de cada necesidad."},
	{"question": "Un formulario contiene datos personales que no hacen falta para resolver el caso. ¿Qué haces?", "options": ["Compartirlo en el grupo para acelerar el trámite", "Limitar el acceso y pedir solo los datos necesarios", "Imprimir copias para todas las oficinas"], "best": 1, "good": "Reducir datos y accesos protege a las personas y mantiene el trámite enfocado.", "bad": "Los datos deben limitarse a lo necesario y compartirse solo con quienes atienden el caso."},
]

const DEAN_CASES := [
	{"question": "El consejo debe repartir 100 puntos de presupuesto entre apoyo estudiantil, laboratorios y mantenimiento. ¿Qué propuesta presentas?", "options": ["35 apoyo, 35 laboratorios, 30 mantenimiento, con revisión trimestral", "90 para un evento y 10 para todo lo demás", "100 para compras sin evaluación de uso"], "best": 0, "good": "La propuesta equilibra necesidades y deja una fecha para revisar el uso del presupuesto.", "bad": "El presupuesto debe responder a necesidades comprobables y tener seguimiento."},
	{"question": "Un laboratorio pide renovar equipos. ¿Qué condición acompañaría la aprobación?", "options": ["Inventario, justificación académica y plan de mantenimiento", "Aprobar por presión y decidir después qué comprar", "Rechazar todo gasto para guardar el saldo"], "best": 0, "good": "La evidencia y el mantenimiento conectan la compra con el trabajo académico.", "bad": "Aprobar una compra requiere necesidad, uso previsto y cuidado posterior."},
	{"question": "Al cierre del periodo, parte del presupuesto no se ejecutó. ¿Qué haces?", "options": ["Publicar el resultado y proponer ajustes con las áreas involucradas", "Ocultar el saldo para evitar preguntas", "Gastar lo restante sin revisar necesidades"], "best": 0, "good": "Rendir cuentas permite corregir el plan y sostener la confianza.", "bad": "El cierre también requiere explicar resultados y decidir con evidencia."},
]

var page_content: VBoxContainer
var current_profile: Dictionary = {}
var active_slot := 0
var selected_faculty := ""
var draft_player_name := ""
var draft_source_slot := 0
var current_question: Dictionary = {}
var current_case_role := ""
var current_case_index := 0
var cv_draft: Array[String] = []
var settings := {"fullscreen": false, "animations": true, "font_scale": 1.0}
var system_font: SystemFont
var random := RandomNumberGenerator.new()


func _ready() -> void:
	random.randomize()
	_load_settings()
	_setup_theme()
	_show_main()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), PAPER)
	var y := 28.0
	while y < size.y:
		draw_line(Vector2(16, y), Vector2(size.x - 16, y), RULE, 1.0)
		y += 34.0
	draw_line(Vector2(92, 0), Vector2(92, size.y), Color("#d7b4a8"), 1.5)
	draw_rect(Rect2(Vector2(10, 10), size - Vector2(20, 20)), Color("#b7ab95"), false, 1.0)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _setup_theme() -> void:
	system_font = SystemFont.new()
	system_font.font_names = PackedStringArray(["Segoe Print", "Comic Sans MS", "Arial"])
	var game_theme := Theme.new()
	game_theme.default_font = system_font
	game_theme.default_font_size = 18
	theme = game_theme


func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		settings["fullscreen"] = config.get_value("game", "fullscreen", false)
		settings["animations"] = config.get_value("game", "animations", true)
		settings["font_scale"] = config.get_value("game", "font_scale", 1.0)
	if settings["fullscreen"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _save_settings() -> void:
	var config := ConfigFile.new()
	for setting in settings:
		config.set_value("game", setting, settings[setting])
	config.save("user://settings.cfg")


func _make_page(title: String, subtitle: String, back: Callable = Callable()) -> VBoxContainer:
	for child in get_children():
		remove_child(child)
		child.queue_free()

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 132)
	margin.add_theme_constant_override("margin_right", 64)
	margin.add_theme_constant_override("margin_top", 38)
	margin.add_theme_constant_override("margin_bottom", 30)
	add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 15)
	margin.add_child(layout)
	if not title.is_empty():
		var heading := _label(title, 32, INK, false)
		layout.add_child(heading)
	if not subtitle.is_empty():
		var subheading := _label(subtitle, 16, Color("#686a5d"), false)
		layout.add_child(subheading)

	page_content = VBoxContainer.new()
	page_content.add_theme_constant_override("separation", 13)
	page_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(page_content)
	if back.is_valid():
		var footer := HBoxContainer.new()
		footer.alignment = BoxContainer.ALIGNMENT_BEGIN
		layout.add_child(footer)
		_add_button(footer, "Volver", back, false, 48)
	return page_content


func _label(text: String, font_size: int = 18, color: Color = INK, centered: bool = false) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", int(round(font_size * float(settings["font_scale"]))))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if centered:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label


func _add_button(parent: Control, text: String, action: Callable, accent: bool = true, height: int = 56) -> Button:
	var button := Button.new()
	button.text = text
	button.icon = load("res://assets/leaf.svg")
	button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.icon_max_width = 26
	button.add_theme_constant_override("h_separation", 12)
	button.custom_minimum_size = Vector2(0, height)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", int(round(19 * float(settings["font_scale"]))))
	button.add_theme_color_override("font_color", Color("#fbf8ee") if accent else INK)
	button.add_theme_color_override("font_hover_color", Color("#fffdf4") if accent else GREEN)
	button.add_theme_stylebox_override("normal", _button_style(accent, false))
	button.add_theme_stylebox_override("hover", _button_style(accent, true))
	button.add_theme_stylebox_override("pressed", _button_style(accent, true))
	button.add_theme_stylebox_override("focus", _button_style(accent, true))
	if action.is_valid():
		button.pressed.connect(action)
	button.mouse_entered.connect(_animate_button.bind(button, true))
	button.mouse_exited.connect(_animate_button.bind(button, false))
	parent.add_child(button)
	return button


func _button_style(accent: bool, hovered: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#455d4b") if accent else Color("#eee8d8")
	if hovered:
		style.bg_color = Color("#617c64") if accent else Color("#e0e7d6")
	style.border_color = Color("#2e4033") if accent else Color("#8c927e")
	style.set_border_width_all(1)
	style.border_width_bottom = 4
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 7
	style.corner_radius_bottom_left = 7
	style.corner_radius_bottom_right = 12
	style.content_margin_left = 18
	style.content_margin_right = 18
	return style


func _animate_button(button: Button, hovering: bool) -> void:
	if not bool(settings["animations"]) or not is_instance_valid(button):
		return
	button.pivot_offset = button.size / 2.0
	var tween := button.create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2(1.025, 1.025) if hovering else Vector2.ONE, 0.14)
	tween.parallel().tween_property(button, "rotation_degrees", 0.6 if hovering else 0.0, 0.14)


func _add_scroll(parent: Control) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_content.add_child(scroll)
	var rows := VBoxContainer.new()
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows.add_theme_constant_override("separation", 11)
	scroll.add_child(rows)
	return rows


func _show_main() -> void:
	var content := _make_page("", "")
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(spacer)
	content.add_child(_label("UNI SIMULATOR", 54, INK, true))
	content.add_child(_label("Tu vida universitaria, con finales que dependen de lo que hagas.", 19, Color("#6c6859"), true))
	var leafline := _label("❧  cuaderno abierto · aulas · gente · decisiones  ❧", 16, GREEN, true)
	content.add_child(leafline)
	var menu := VBoxContainer.new()
	menu.add_theme_constant_override("separation", 12)
	menu.custom_minimum_size.x = 430
	menu.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	content.add_child(menu)
	_add_button(menu, "Jugar", _show_modes, true, 62)
	_add_button(menu, "Opciones", _show_options, false, 52)
	_add_button(menu, "Salir", _exit_game, false, 52)
	content.add_child(_label("Una partida a la vez. Lo que aprendes se queda guardado.", 14, Color("#797565"), true))
	var end_spacer := Control.new()
	end_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(end_spacer)


func _show_options() -> void:
	var content := _make_page("Opciones", "Ajustes simples para esta computadora.", _show_main)
	_add_button(content, "Pantalla completa: " + ("Sí" if settings["fullscreen"] else "No"), _toggle_fullscreen, false)
	_add_button(content, "Movimiento de hojas: " + ("Activado" if settings["animations"] else "Reducido"), _toggle_animations, false)
	content.add_child(_label("Tamaño del texto", 17))
	var slider := HSlider.new()
	slider.min_value = 0.9
	slider.max_value = 1.25
	slider.step = 0.05
	slider.value = settings["font_scale"]
	slider.custom_minimum_size.y = 28
	slider.value_changed.connect(_change_font_scale)
	content.add_child(slider)
	content.add_child(_label("Las preferencias se guardan en este equipo.", 15, Color("#6c6859")))
	_add_button(content, "Créditos y licencia del motor", _show_credits, false, 48)


func _show_credits() -> void:
	var content := _make_page("Créditos", "", _show_options)
	content.add_child(_label("UNI SIMULATOR funciona con Godot Engine.\nCopyright (c) 2014-present Godot Engine contributors.\nCopyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.\n\nGodot Engine se distribuye bajo la licencia MIT.\nTexto de licencia y componentes: https://godotengine.org/license/", 17, INK, true))


func _toggle_fullscreen() -> void:
	settings["fullscreen"] = not bool(settings["fullscreen"])
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if settings["fullscreen"] else DisplayServer.WINDOW_MODE_WINDOWED)
	_save_settings()
	_show_options()


func _toggle_animations() -> void:
	settings["animations"] = not bool(settings["animations"])
	_save_settings()
	_show_options()


func _change_font_scale(value: float) -> void:
	settings["font_scale"] = value
	_save_settings()


func _show_modes() -> void:
	var content := _make_page("Elige cómo jugar", "La partida individual y la de equipo se guardan por separado.", _show_main)
	content.add_child(_label("SOLO", 27, GREEN, true))
	content.add_child(_label("Avanza por materias, rinde tres parciales y termina una carrera. Después puedes probar la competencia para auxiliar.", 17, INK, true))
	_add_button(content, "Partida solo", _show_solo_slots, true, 62)
	content.add_child(_label("MULTIJUGADOR", 27, GREEN, true))
	content.add_child(_label("Pasa el turno entre jugadores en este equipo: auxiliar, administrativo y decano. Requiere una carrera terminada.", 17, INK, true))
	_add_button(content, "Partida de equipo", _show_multi_slots, true, 62)


func _show_solo_slots() -> void:
	_show_slots("solo")


func _show_multi_slots() -> void:
	_show_slots("multi")


func _show_slots(mode: String) -> void:
	var mode_label := "Solo" if mode == "solo" else "Equipo local"
	var content := _make_page("Partidas guardadas · " + mode_label, "Tres espacios guardados en este equipo.", _show_modes)
	var rows := _add_scroll(content)
	var found_matching := false
	var free_slot := _find_free_slot()
	for slot in range(1, SAVE_COUNT + 1):
		var save := _read_save(slot)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		rows.add_child(row)
		var description := "Espacio %d · vacío" % slot
		if not save.is_empty():
			var saved_mode := "solo" if save.get("mode", "solo") == "solo" else "multi"
			description = "Espacio %d · %s · %s" % [slot, str(save.get("player_name", "Estudiante")), "Solo" if saved_mode == "solo" else "Equipo"]
			if saved_mode == "solo":
				var program := Catalog.program_by_id(str(save.get("program_id", "")))
				description += " · " + str(program.get("name", "Carrera"))
			if saved_mode == "multi":
				description += " · %s" % str(save.get("role_label", "Auxiliar"))
			if saved_mode == mode:
				found_matching = true
			var name_label := _label(description, 16)
			name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(name_label)
			if saved_mode == mode:
				_add_button(row, "Continuar", _open_slot.bind(slot, mode), true, 44)
			_add_button(row, "Borrar", _delete_slot.bind(slot, mode), false, 44)
		else:
			var empty_label := _label(description, 16)
			empty_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(empty_label)
			if mode == "solo":
				_add_button(row, "Nueva", _begin_new_game.bind(slot, mode), true, 44)
	if mode == "multi":
		content.add_child(_label("Para abrir una partida de equipo, termina una carrera y aprueba su examen de competencia en Solo.", 15, Color("#686a5d")))
		if free_slot > 0 and _has_eligible_solo_save():
			_add_button(content, "Crear partida de equipo", _choose_team_source, true, 58)
		elif free_slot == 0:
			content.add_child(_label("No hay espacios libres. Borra una partida para crear otra.", 15, GOLD))
	elif not found_matching and free_slot == 0:
		content.add_child(_label("No hay espacios libres. Borra una partida para crear otra.", 15, GOLD))


func _begin_new_game(slot: int, mode: String) -> void:
	active_slot = slot
	if mode == "solo":
		_show_new_solo()
	else:
		_show_team_setup(0)


func _open_slot(slot: int, mode: String) -> void:
	current_profile = _read_save(slot)
	active_slot = slot
	if current_profile.is_empty():
		_show_slots(mode)
		return
	if mode == "solo":
		_show_solo_hub()
	else:
		_show_team_hub()


func _delete_slot(slot: int, mode: String) -> void:
	var save := _read_save(slot)
	var dialog := ConfirmationDialog.new()
	dialog.title = "Borrar partida"
	dialog.dialog_text = "¿Borrar la partida de %s del espacio %d? Esta acción no se puede deshacer." % [str(save.get("player_name", "Estudiante")), slot]
	dialog.confirmed.connect(_remove_slot.bind(slot, mode, dialog))
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered()


func _remove_slot(slot: int, mode: String, dialog: ConfirmationDialog) -> void:
	dialog.queue_free()
	var path := _save_path(slot)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	_show_slots(mode)


func _find_free_slot() -> int:
	for slot in range(1, SAVE_COUNT + 1):
		if _read_save(slot).is_empty():
			return slot
	return 0


func _show_new_solo() -> void:
	var content := _make_page("Una partida nueva", "Primero ponle nombre a tu estudiante.", _show_solo_slots)
	var name_field := LineEdit.new()
	name_field.placeholder_text = "Tu nombre o apodo"
	name_field.custom_minimum_size.y = 54
	name_field.text = "Estudiante"
	content.add_child(name_field)
	_add_button(content, "Elegir facultad", _choose_faculty_from_field.bind(name_field), true)


func _choose_faculty_from_field(name_field: LineEdit) -> void:
	draft_player_name = name_field.text.strip_edges()
	if draft_player_name.is_empty():
		draft_player_name = "Estudiante"
	_show_faculties()


func _show_faculties() -> void:
	var content := _make_page("Elige una facultad", "Las carreras y materias de esta primera partida son una muestra provisional.", _show_new_solo)
	var rows := _add_scroll(content)
	for faculty in Catalog.FACULTIES:
		var button := _add_button(rows, str(faculty["name"]) + "\n" + str(faculty["description"]), _select_faculty.bind(str(faculty["id"])), false, 82)
		button.add_theme_font_size_override("font_size", int(round(16 * float(settings["font_scale"]))))


func _select_faculty(faculty_id: String) -> void:
	selected_faculty = faculty_id
	_show_programs()


func _show_programs() -> void:
	var faculty := Catalog.faculty_by_id(selected_faculty)
	var content := _make_page(str(faculty.get("name", "Carreras")), "Malla de muestra: materias cortas y preguntas de nivel inicial.", _show_faculties)
	var rows := _add_scroll(content)
	for program in Catalog.programs_for_faculty(selected_faculty):
		var card := VBoxContainer.new()
		card.add_theme_constant_override("separation", 5)
		rows.add_child(card)
		card.add_child(_label(str(program["name"]), 21, GREEN))
		card.add_child(_label(str(program["summary"]), 15, Color("#5f6257")))
		card.add_child(_label("Título del juego: " + str(program["title"]) + " · 3 materias de muestra · menciones de ejemplo", 14, Color("#767262")))
		_add_button(card, "Ver enfoques de esta carrera", _show_mentions.bind(str(program["id"])), true, 46)


func _show_mentions(program_id: String) -> void:
	var program := Catalog.program_by_id(program_id)
	if program.is_empty():
		_show_programs()
		return
	var content := _make_page("Elige un enfoque", str(program["name"]) + " · opciones provisionales para probar la partida", _show_programs)
	var rows := _add_scroll(content)
	for mention in Catalog.mentions_for_program(program_id):
		var card := VBoxContainer.new()
		card.add_theme_constant_override("separation", 5)
		rows.add_child(card)
		card.add_child(_label(str(mention["name"]), 21, GREEN))
		card.add_child(_label(str(mention["focus"]), 15, Color("#5f6257")))
		card.add_child(_label("Actividad de muestra: " + str(mention["activity"]), 14, Color("#767262")))
		_add_button(card, "Empezar con este enfoque", _create_solo_save.bind(program_id, str(mention["id"])), true, 46)


func _create_solo_save(program_id: String, mention_id: String) -> void:
	var program := Catalog.program_by_id(program_id)
	var mention := Catalog.mention_by_id(program_id, mention_id)
	current_profile = {
		"slot": active_slot,
		"mode": "solo",
		"player_name": draft_player_name,
		"program_id": program_id,
		"mention_id": mention_id,
		"mention_name": mention.get("name", ""),
		"role_id": "estudiante",
		"completed_subjects": 0,
		"partial_index": 0,
		"career_complete": false,
		"competency_passed": false,
		"confidence": 60,
		"credits": 100,
		"titles": [],
		"chanchullo_used": [],
		"created_at": Time.get_datetime_string_from_system(),
	}
	if program.is_empty():
		_show_solo_slots()
		return
	_save_profile()
	_show_solo_hub()


func _show_solo_hub() -> void:
	var program := Catalog.program_by_id(str(current_profile.get("program_id", "")))
	if program.is_empty():
		_show_solo_slots()
		return
	var done := int(current_profile.get("completed_subjects", 0))
	var mention := Catalog.mention_by_id(str(program["id"]), str(current_profile.get("mention_id", "")))
	var subtitle := str(program["name"]) + " · " + str(program["faculty"])
	if not mention.is_empty():
		subtitle += " · " + str(mention["name"])
	var content := _make_page("Hola, " + str(current_profile.get("player_name", "Estudiante")), subtitle, _show_solo_slots)
	if not mention.is_empty():
		content.add_child(_label(str(mention["focus"]), 15, Color("#686a5d"), true))
	content.add_child(_label("Racha de la carrera", 24, GREEN, true))
	content.add_child(_label("Materias aprobadas: %d / %d    ·    Confianza: %d" % [done, program["subjects"].size(), int(current_profile.get("confidence", 60))], 17, INK, true))
	if not bool(current_profile.get("career_complete", false)):
		var course := Catalog.course(str(program["id"]), done)
		content.add_child(_label("Siguiente materia: " + str(course.get("name", "")), 21, INK, true))
		content.add_child(_label("Tres parciales, una pregunta corta en cada uno. Puedes volver a intentar los que no apruebes.", 16, Color("#686a5d"), true))
		_add_button(content, "Rendir parcial %d" % (int(current_profile.get("partial_index", 0)) + 1), _show_exam, true, 62)
	else:
		content.add_child(_label("Carrera completa: " + str(program["title"]), 21, GREEN, true))
		content.add_child(_label("Tu título del juego ya está en la partida guardada.", 16, Color("#686a5d"), true))
		if not bool(current_profile.get("competency_passed", false)):
			_add_button(content, "Rendir examen de competencia", _show_competency, true, 62)
		else:
			content.add_child(_label("Competencia aprobada · Auxiliar disponible en el modo de equipo.", 17, GREEN, true))
	_add_button(content, "Ver títulos y logros", _show_titles, false, 48)
	_add_button(content, "Guardar y volver al inicio", _return_to_menu, false, 48)


func _show_exam() -> void:
	var program := Catalog.program_by_id(str(current_profile.get("program_id", "")))
	var course_index := int(current_profile.get("completed_subjects", 0))
	var partial_index := int(current_profile.get("partial_index", 0))
	if course_index >= program.get("subjects", []).size():
		_show_solo_hub()
		return
	var course := Catalog.course(str(program["id"]), course_index)
	current_question = course["partials"][partial_index]
	var content := _make_page("Parcial %d · %s" % [partial_index + 1, str(course["name"])], "Dificultad %d de 3 · responde y revisa por qué." % int(current_question["difficulty"]), Callable(self, "_show_solo_hub"))
	content.add_child(_label(str(current_question["q"]), 25, INK, true))
	for option_index in range(current_question["options"].size()):
		_add_button(content, str(current_question["options"][option_index]), _answer_subject.bind(option_index), false, 55)
	var key := "%d:%d" % [course_index, partial_index]
	var used: Array = current_profile.get("chanchullo_used", [])
	var cheat_button := _add_button(content, "Chanchullo: mirar el apunte escondido", _try_chanchullo.bind(key), true, 50)
	if used.has(key):
		cheat_button.disabled = true
		content.add_child(_label("Ya usaste el chanchullo en este parcial. Si te pillaron, todavía puedes responder normal.", 14, GOLD, true))
	else:
		content.add_child(_label("La jugada puede salir bien o pillarse; solo hay una oportunidad por parcial.", 14, Color("#686a5d"), true))


func _answer_subject(option_index: int) -> void:
	_finish_subject_question(option_index == int(current_question["answer"]), false)


func _try_chanchullo(key: String) -> void:
	var used: Array = current_profile.get("chanchullo_used", [])
	if used.has(key):
		return
	used.append(key)
	current_profile["chanchullo_used"] = used
	if random.randi_range(1, 100) <= 55:
		_finish_subject_question(true, true)
	else:
		current_profile["confidence"] = maxi(0, int(current_profile.get("confidence", 60)) - 8)
		_save_profile()
		_show_result("Te pillaron", "El apunte no ayudó y bajó un poco tu confianza. Este parcial sigue pendiente; puedes volver a intentarlo sin hacer chanchullo.", false, _show_exam)


func _finish_subject_question(correct: bool, cheated: bool) -> void:
	var program := Catalog.program_by_id(str(current_profile.get("program_id", "")))
	var course_index := int(current_profile.get("completed_subjects", 0))
	var partial_index := int(current_profile.get("partial_index", 0))
	if correct:
		current_profile["confidence"] = mini(100, int(current_profile.get("confidence", 60)) + 4)
		partial_index += 1
		var message := str(current_question["why"])
		if cheated:
			message += " El apunte pasó esta vez, pero tu confianza no sube por una respuesta copiada."
		if partial_index >= 3:
			current_profile["completed_subjects"] = course_index + 1
			current_profile["partial_index"] = 0
			message += " Aprobaste los tres parciales de %s." % str(program["subjects"][course_index])
			if int(current_profile["completed_subjects"]) >= program["subjects"].size():
				current_profile["career_complete"] = true
				var titles: Array = current_profile.get("titles", [])
				titles.append("Título: " + str(program["title"]))
				current_profile["titles"] = titles
				message += " Completaste la carrera y ganaste el título «%s»." % str(program["title"])
		else:
			current_profile["partial_index"] = partial_index
			message += " Parcial aprobado. El siguiente es el %d." % (partial_index + 1)
		_save_profile()
		_show_result("Parcial aprobado", message, true, _show_solo_hub)
	else:
		current_profile["confidence"] = maxi(0, int(current_profile.get("confidence", 60)) - 3)
		_save_profile()
		_show_result("Parcial pendiente", str(current_question["why"]) + " Puedes probar de nuevo.", false, _show_exam)


func _show_competency() -> void:
	var program := Catalog.program_by_id(str(current_profile.get("program_id", "")))
	if not bool(current_profile.get("career_complete", false)):
		_show_solo_hub()
		return
	var questions: Array = program["questions"]
	var choice := random.randi_range(0, questions.size() - 1)
	current_question = questions[choice]
	var content := _make_page("Examen de competencia", "Un paso corto para demostrar que puedes apoyar a otra persona.", Callable(self, "_show_solo_hub"))
	content.add_child(_label(str(current_question["q"]), 24, INK, true))
	for option_index in range(current_question["options"].size()):
		_add_button(content, str(current_question["options"][option_index]), _answer_competency.bind(option_index), false, 56)
	content.add_child(_label("Si no sale, puedes volver a intentarlo.", 14, Color("#686a5d"), true))


func _answer_competency(option_index: int) -> void:
	if option_index == int(current_question["answer"]):
		current_profile["competency_passed"] = true
		current_profile["role_id"] = "auxiliar"
		var titles: Array = current_profile.get("titles", [])
		titles.append("Auxiliar docente · examen de competencia aprobado")
		current_profile["titles"] = titles
		_save_profile()
		_show_result("Competencia aprobada", "Ya puedes iniciar una partida de equipo como auxiliar docente.", true, _show_solo_hub)
	else:
		_show_result("Todavía no", str(current_question["why"]) + " Revisa la idea y vuelve a intentarlo.", false, _show_competency)


func _show_titles() -> void:
	var content := _make_page("Títulos y logros", "Lo que ya quedó registrado en esta partida.", _show_solo_hub)
	var titles: Array = current_profile.get("titles", [])
	if titles.is_empty():
		content.add_child(_label("Todavía no hay títulos. Cada materia aprobada acerca el siguiente.", 18, INK, true))
	else:
		for earned in titles:
			content.add_child(_label("✦  " + str(earned), 18, GREEN))
	_add_button(content, "Volver a la carrera", _show_solo_hub, true)


func _has_eligible_solo_save() -> bool:
	for slot in range(1, SAVE_COUNT + 1):
		var save := _read_save(slot)
		if save.get("mode", "") == "solo" and bool(save.get("career_complete", false)) and bool(save.get("competency_passed", false)):
			return true
	return false


func _choose_team_source() -> void:
	var content := _make_page("Elige a quién vas a representar", "Solo aparecen carreras completas con competencia aprobada.", _show_multi_slots)
	var rows := _add_scroll(content)
	for slot in range(1, SAVE_COUNT + 1):
		var save := _read_save(slot)
		if save.get("mode", "") == "solo" and bool(save.get("career_complete", false)) and bool(save.get("competency_passed", false)):
			var program := Catalog.program_by_id(str(save.get("program_id", "")))
			_add_button(rows, "%s · %s" % [str(save.get("player_name", "Estudiante")), str(program.get("name", "Carrera"))], _show_team_setup.bind(slot), false, 54)


func _show_team_setup(source_slot: int) -> void:
	if source_slot == 0:
		_show_multi_slots()
		return
	draft_source_slot = source_slot
	var source := _read_save(source_slot)
	var content := _make_page("Armen el equipo", "%s puede comenzar como auxiliar. El juego va pasando el turno entre participantes." % str(source.get("player_name", "Estudiante")), _show_multi_slots)
	content.add_child(_label("¿Cuántas personas van a turnarse en esta computadora?", 18, INK, true))
	var players := SpinBox.new()
	players.min_value = 1
	players.max_value = 4
	players.value = 2
	players.custom_minimum_size = Vector2(160, 48)
	players.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	content.add_child(players)
	content.add_child(_label("Modo local por turnos. La conexión por internet se podrá añadir después.", 14, Color("#686a5d"), true))
	_add_button(content, "Empezar partida de equipo", _create_team_save.bind(players), true, 60)


func _create_team_save(players: SpinBox) -> void:
	var slot := _find_free_slot()
	if slot == 0:
		_show_result("No hay espacio", "Borra una partida guardada antes de crear una partida de equipo.", false, _show_multi_slots)
		return
	var source := _read_save(draft_source_slot)
	var program := Catalog.program_by_id(str(source.get("program_id", "")))
	current_profile = {
		"slot": slot,
		"mode": "multi",
		"player_name": source.get("player_name", "Estudiante"),
		"program_id": source.get("program_id", ""),
		"source_slot": draft_source_slot,
		"players": int(players.value),
		"role_id": "auxiliar",
		"role_label": "Auxiliar docente",
		"assistant_cases": 0,
		"admin_cases": 0,
		"dean_cases": 0,
		"team_score": 0,
		"team_confidence": 60,
		"cv_items": [],
		"cv_submitted": false,
		"titles": [],
		"created_at": Time.get_datetime_string_from_system(),
	}
	if program.is_empty():
		_show_multi_slots()
		return
	_save_profile()
	_show_team_hub()


func _show_team_hub() -> void:
	if current_profile.is_empty() or current_profile.get("mode", "") != "multi":
		_show_multi_slots()
		return
	var role := str(current_profile.get("role_id", "auxiliar"))
	var role_name := "Auxiliar docente" if role == "auxiliar" else "Administrativo" if role == "administrativo" else "Decano"
	var program := Catalog.program_by_id(str(current_profile.get("program_id", "")))
	var content := _make_page("Equipo de " + str(program.get("name", "la universidad")), "%s personas · turno actual: %s" % [str(current_profile.get("players", 1)), role_name], _show_multi_slots)
	content.add_child(_label("Turno de " + str(current_profile.get("player_name", "Estudiante")), 18, INK, true))
	content.add_child(_label("Experiencia del equipo: %d · Confianza: %d" % [int(current_profile.get("team_score", 0)), int(current_profile.get("team_confidence", 60))], 16, Color("#686a5d"), true))
	if role == "auxiliar":
		var done := int(current_profile.get("assistant_cases", 0))
		if done < ASSISTANT_CASES.size():
			_show_team_case_content(content, ASSISTANT_CASES[done], role, done)
		else:
			content.add_child(_label("Tres tutorías completadas. Ya puedes armar tu CV para postular a un cargo administrativo.", 18, GREEN, true))
			_add_button(content, "Armar CV universitario", _show_cv_builder, true, 62)
	elif role == "administrativo":
		var done := int(current_profile.get("admin_cases", 0))
		if done < ADMIN_CASES.size():
			_show_team_case_content(content, ADMIN_CASES[done], role, done)
		else:
			content.add_child(_label("Has atendido tres casos y ahora puedes presentar una propuesta al consejo de facultad.", 18, GREEN, true))
			_add_button(content, "Presentar candidatura a decano", _start_dean_review, true, 62)
	else:
		var done := int(current_profile.get("dean_cases", 0))
		if done < DEAN_CASES.size():
			_show_team_case_content(content, DEAN_CASES[done], role, done)
		else:
			content.add_child(_label("Terminaste la gestión de facultad. El consejo recibió tus decisiones y su seguimiento.", 19, GREEN, true))
			content.add_child(_label("Puntaje final: %d · partidas de %d participante(s)" % [int(current_profile.get("team_score", 0)), int(current_profile.get("players", 1))], 16, INK, true))
			_add_button(content, "Ver logros", _show_team_titles, false, 48)
	_add_button(content, "Guardar y volver al inicio", _return_to_menu, false, 48)


func _show_team_case_content(content: VBoxContainer, simulation: Dictionary, role: String, case_index: int) -> void:
	var role_title := "Tutoría" if role == "auxiliar" else "Mesa administrativa" if role == "administrativo" else "Consejo de facultad"
	content.add_child(_label("%s · situación %d de 3" % [role_title, case_index + 1], 23, GREEN, true))
	content.add_child(_label(str(simulation["question"]), 19, INK, true))
	for option_index in range(simulation["options"].size()):
		_add_button(content, str(simulation["options"][option_index]), _choose_team_case.bind(role, case_index, option_index), false, 52)


func _choose_team_case(role: String, case_index: int, choice_index: int) -> void:
	var cases: Array = ASSISTANT_CASES if role == "auxiliar" else ADMIN_CASES if role == "administrativo" else DEAN_CASES
	var simulation: Dictionary = cases[case_index]
	var best := choice_index == int(simulation["best"])
	var feedback := str(simulation["good"] if best else simulation["bad"])
	if best:
		current_profile["team_score"] = int(current_profile.get("team_score", 0)) + 10
		current_profile["team_confidence"] = mini(100, int(current_profile.get("team_confidence", 60)) + 6)
	else:
		current_profile["team_confidence"] = maxi(0, int(current_profile.get("team_confidence", 60)) - 5)
	if role == "auxiliar":
		current_profile["assistant_cases"] = case_index + 1
	elif role == "administrativo":
		current_profile["admin_cases"] = case_index + 1
	else:
		current_profile["dean_cases"] = case_index + 1
		if int(current_profile["dean_cases"]) == DEAN_CASES.size():
			var titles: Array = current_profile.get("titles", [])
			titles.append("Decano de facultad · ciclo de gestión completado")
			current_profile["titles"] = titles
	_save_profile()
	var continuation := Callable(self, "_show_team_hub")
	_show_result("Decisión registrada", feedback, best, continuation)


func _show_cv_builder() -> void:
	cv_draft = current_profile.get("cv_items", []).duplicate()
	var content := _make_page("Arma tu CV", "Elige al menos tres experiencias que sí puedas respaldar en la partida.", Callable(self, "_show_team_hub"))
	for skill in CV_SKILLS:
		var prefix := "☑  " if cv_draft.has(skill) else "□  "
		_add_button(content, prefix + skill, _toggle_cv_item.bind(skill), false, 50)
	content.add_child(_label("Experiencias elegidas: %d / 4" % cv_draft.size(), 15, Color("#686a5d"), true))
	_add_button(content, "Enviar CV", _submit_cv, true, 58)


func _toggle_cv_item(skill: String) -> void:
	if cv_draft.has(skill):
		cv_draft.erase(skill)
	else:
		cv_draft.append(skill)
	_show_cv_builder()


func _submit_cv() -> void:
	if cv_draft.size() < 3:
		_show_result("CV incompleto", "La convocatoria pide al menos tres experiencias. Completa el CV y vuelve a enviarlo.", false, _show_cv_builder)
		return
	current_profile["cv_items"] = cv_draft.duplicate()
	current_profile["cv_submitted"] = true
	_save_profile()
	_show_admin_interview()


func _show_admin_interview() -> void:
	var content := _make_page("Entrevista administrativa", "La convocatoria revisa criterio, atención y cuidado de datos.", Callable(self, "_show_cv_builder"))
	content.add_child(_label("Llegan dos trámites con plazos distintos y a uno le faltan datos. ¿Cómo los atiendes?", 22, INK, true))
	_add_button(content, "Verifico lo necesario, priorizo el vencimiento y dejo registro de lo pendiente", _answer_admin_interview.bind(true), false, 58)
	_add_button(content, "Apruebo los dos sin revisar para terminar rápido", _answer_admin_interview.bind(false), false, 58)
	_add_button(content, "Pido los datos personales completos de todo el grupo", _answer_admin_interview.bind(false), false, 58)


func _answer_admin_interview(correct: bool) -> void:
	if not correct:
		_show_result("La entrevista sigue pendiente", "La convocatoria necesita una decisión verificable y centrada en el trámite. Puedes repasar tu CV e intentarlo otra vez.", false, _show_admin_interview)
		return
	current_profile["role_id"] = "administrativo"
	current_profile["role_label"] = "Administrativo"
	var titles: Array = current_profile.get("titles", [])
	titles.append("Cargo administrativo · CV y entrevista aprobados")
	current_profile["titles"] = titles
	_save_profile()
	_show_result("Te contrataron", "Tu CV y entrevista abrieron el cargo. Ahora vienen casos de registros, recursos y atención universitaria.", true, _show_team_hub)


func _start_dean_review() -> void:
	_show_dean_vote()


func _show_dean_vote() -> void:
	var content := _make_page("Consejo de facultad", "La experiencia administrativa te permite postular; el consejo revisa tu criterio.", Callable(self, "_show_team_hub"))
	content.add_child(_label("¿Cómo presentarías el presupuesto anual de 100 puntos?", 22, INK, true))
	_add_button(content, "Repartirlo con criterios públicos, revisar necesidades y fijar seguimiento", _answer_dean_vote.bind(true), false, 58)
	_add_button(content, "Asignarlo según popularidad y ver después qué falta", _answer_dean_vote.bind(false), false, 58)
	_add_button(content, "Gastar todo en una compra antes de comparar propuestas", _answer_dean_vote.bind(false), false, 58)


func _answer_dean_vote(approved: bool) -> void:
	if not approved:
		_show_result("La candidatura sigue en revisión", "El consejo pide una propuesta justificable y con seguimiento del dinero. Puedes ajustar el planteamiento e intentarlo otra vez.", false, _show_dean_vote)
		return
	current_profile["role_id"] = "decano"
	current_profile["role_label"] = "Decano"
	var titles: Array = current_profile.get("titles", [])
	titles.append("Decano electo · experiencia administrativa completada")
	current_profile["titles"] = titles
	_save_profile()
	_show_result("El consejo te eligió", "La candidatura fue aprobada. Ahora tendrás que tomar decisiones de presupuesto, revisar inversiones y rendir cuentas.", true, _show_team_hub)


func _show_team_titles() -> void:
	var content := _make_page("Logros del equipo", "Títulos guardados en esta partida local.", _show_team_hub)
	var titles: Array = current_profile.get("titles", [])
	if titles.is_empty():
		content.add_child(_label("Todavía no hay logros de equipo.", 18, INK, true))
	else:
		for earned in titles:
			content.add_child(_label("✦  " + str(earned), 17, GREEN))
	_add_button(content, "Volver a la partida", _show_team_hub, true)


func _return_to_menu() -> void:
	_save_profile()
	current_profile = {}
	_show_main()


func _exit_game() -> void:
	_save_profile()
	get_tree().quit()


func _show_result(title: String, body: String, positive: bool, next: Callable) -> void:
	var return_page := Callable(self, "_show_solo_hub") if current_profile.get("mode", "solo") == "solo" else Callable(self, "_show_team_hub")
	var content := _make_page(title, "", return_page)
	content.add_child(_label(body, 20, GREEN if positive else INK, true))
	_add_button(content, "Continuar", next, true, 62)


func _save_path(slot: int) -> String:
	return "%s/partida_%d.json" % [SAVE_DIR, slot]


func _read_save(slot: int) -> Dictionary:
	var path := _save_path(slot)
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed is Dictionary:
		return parsed
	return {}


func _save_profile() -> void:
	if current_profile.is_empty():
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SAVE_DIR))
	current_profile["slot"] = active_slot
	current_profile["updated_at"] = Time.get_datetime_string_from_system()
	var file := FileAccess.open(_save_path(active_slot), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(current_profile, "\t"))
		file.close()
