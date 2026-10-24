extends Control

const Catalog = preload("res://scripts/catalog.gd")
const SAVE_DIR := "user://partidas"
const SAVE_COUNT := 3
const INK := Color("#272b25")
const PAPER := Color("#f5f0e5")
const RULE := Color("#ddd5c5")
const GREEN := Color("#526b57")
const GOLD := Color("#b77a43")

var _current_theme: Dictionary = {}

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

var current_profile: Dictionary = {}
var active_slot := 0
var selected_faculty := ""
var draft_player_name := ""
var draft_source_slot := 0
var current_question: Dictionary = {}
var cv_draft: Array = []
var team_name_drafts: Array = []
var team_name_fields: Array = []
var team_name_box: VBoxContainer
var settings := {"fullscreen": false, "animations": true, "font_scale": 1.0, "antialiasing": false}
var system_font: SystemFont
var random := RandomNumberGenerator.new()


func _ready() -> void:
	random.randomize()
	_load_settings()
	_setup_theme()
	if _current_theme.is_empty():
		_current_theme = Catalog.THEME.get("sistemas", {})
	get_window().min_size = Vector2i(800, 520)
	_apply_image_settings()
	if bool(settings["fullscreen"]):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	_show_main()
	queue_redraw()


func _draw() -> void:
	if _current_theme.is_empty():
		_current_theme = Catalog.THEME.get("sistemas", {})
	var bg: Color = _current_theme.get("bg", PAPER)
	draw_rect(Rect2(Vector2.ZERO, size), bg)
	var grid: Color = _current_theme.get("grid", Color("#e7e0d1"))
	var step := 20.0
	var w := size.x
	var h := size.y
	var x := 0.0
	while x < w:
		draw_line(Vector2(x, 0), Vector2(x, h), grid, 1.0)
		x += step
	var y := 0.0
	while y < h:
		draw_line(Vector2(0, y), Vector2(w, y), grid, 1.0)
		y += step
	var rule: Color = _current_theme.get("panel", Color("#ddd5c5"))
	draw_rect(Rect2(Vector2(0, 0), Vector2(6, h)), rule)
	draw_rect(Rect2(Vector2(12, 0), Vector2(2, h)), rule)
	draw_rect(Rect2(Vector2(10, 10), size - Vector2(20, 20)), Color("#c3b8a3"), false, 1.0)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _setup_theme() -> void:
	system_font = SystemFont.new()
	system_font.font_names = PackedStringArray(["Segoe Print", "Comic Sans MS", "Arial"])
	system_font.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	system_font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_AUTO
	var game_theme := Theme.new()
	game_theme.default_font = system_font
	game_theme.default_font_size = 18
	theme = game_theme


func _apply_image_settings() -> void:
	var viewport := get_viewport()
	if viewport:
		viewport.msaa_2d = Viewport.MSAA_4X if bool(settings["antialiasing"]) else Viewport.MSAA_DISABLED
	RenderingServer.set_default_clear_color(PAPER)


func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		settings["fullscreen"] = config.get_value("game", "fullscreen", false)
		settings["animations"] = config.get_value("game", "animations", true)
		settings["font_scale"] = config.get_value("game", "font_scale", 1.0)
		settings["antialiasing"] = config.get_value("game", "antialiasing", false)
	if settings["fullscreen"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


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
		var heading := _label(title, 28, _current_theme.get("text", INK), false)
		layout.add_child(heading)
		var accent_rule := ColorRect.new()
		accent_rule.color = _current_theme.get("accent", GOLD)
		accent_rule.custom_minimum_size = Vector2(58, 3)
		accent_rule.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		layout.add_child(accent_rule)
	if not subtitle.is_empty():
		var subheading := _label(subtitle, 15, _current_theme.get("sub", Color("#686a5d")), false)
		layout.add_child(subheading)

	var page_content := VBoxContainer.new()
	page_content.add_theme_constant_override("separation", 13)
	page_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(page_content)
	if back.is_valid():
		var footer := HBoxContainer.new()
		footer.alignment = BoxContainer.ALIGNMENT_BEGIN
		layout.add_child(footer)
		_add_button(footer, "← VOLVER ATRÁS", back, false, 52)
	if bool(settings["animations"]):
		margin.modulate.a = 0.0
		var intro := margin.create_tween()
		intro.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		intro.tween_property(margin, "modulate:a", 1.0, 0.16)
	return page_content


func _label(text: String, font_size: int = 18, color: Color = INK, centered: bool = false) -> Label:
	var label := Label.new()
	label.text = text
	if _current_theme.is_empty():
		_current_theme = Catalog.THEME.get("sistemas", {})
	var tcolor = color
	if color == INK:
		tcolor = _current_theme.get("text", INK)
	label.add_theme_color_override("font_color", tcolor)
	label.add_theme_font_size_override("font_size", int(round(font_size * float(settings["font_scale"]))))
	label.add_theme_constant_override("line_spacing", 3)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if centered:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label


func _add_button(parent: Control, text: String, action: Callable, accent: bool = true, height: int = 56) -> Button:
	var button := Button.new()
	button.text = text
	button.add_theme_constant_override("icon_max_width", 24)
	button.add_theme_constant_override("h_separation", 12)
	button.custom_minimum_size = Vector2(0, height)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_size_override("font_size", int(round(18 * float(settings["font_scale"]))))
	if accent:
		button.add_theme_color_override("font_color", _current_theme.get("text", Color("#fbf8ee")))
		button.add_theme_color_override("font_hover_color", Color("#ffffff"))
		button.add_theme_color_override("font_pressed_color", Color("#f0f0f0"))
		button.add_theme_color_override("font_focus_color", Color("#ffffff"))
		button.add_theme_color_override("font_disabled_color", Color("#b0b0b0"))
	else:
		button.add_theme_color_override("font_color", _current_theme.get("text", INK))
		button.add_theme_color_override("font_hover_color", _current_theme.get("accent", GREEN))
		button.add_theme_color_override("font_pressed_color", _current_theme.get("accent", GREEN))
		button.add_theme_color_override("font_focus_color", _current_theme.get("accent", GREEN))
		button.add_theme_color_override("font_disabled_color", Color("#9c9688"))
	button.add_theme_stylebox_override("normal", _button_style(accent, "normal"))
	button.add_theme_stylebox_override("hover", _button_style(accent, "hover"))
	button.add_theme_stylebox_override("pressed", _button_style(accent, "pressed"))
	button.add_theme_stylebox_override("disabled", _button_style(accent, "disabled"))
	button.add_theme_stylebox_override("focus", _focus_style())
	if accent:
		button.icon = null
		button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	if action.is_valid():
		button.pressed.connect(action)
	button.mouse_entered.connect(_animate_button.bind(button, true))
	button.mouse_exited.connect(_animate_button.bind(button, false))
	parent.add_child(button)
	return button


func _button_style(accent: bool, state: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var accent_color = _current_theme.get("accent", GREEN)
	if accent:
		style.bg_color = accent_color
		if state == "hover":
			style.bg_color = accent_color.lightened(0.15)
		elif state == "pressed":
			style.bg_color = accent_color.darkened(0.15)
		elif state == "disabled":
			style.bg_color = accent_color.darkened(0.4)
		style.border_color = accent_color.darkened(0.3)
	else:
		style.bg_color = _current_theme.get("panel", Color("#eee8d8"))
		if state == "hover":
			style.bg_color = style.bg_color.lightened(0.08)
		elif state == "pressed":
			style.bg_color = style.bg_color.darkened(0.05)
		elif state == "disabled":
			style.bg_color = style.bg_color.darkened(0.1)
		style.border_color = _current_theme.get("grid", Color("#8c927e"))
	style.set_border_width_all(2)
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	style.shadow_color = Color(0, 0, 0, 0.25)
	style.shadow_size = 2
	style.shadow_offset = Vector2(2, 2)
	return style


func _focus_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.draw_center = false
	style.border_color = _current_theme.get("accent", GOLD)
	style.set_border_width_all(2)
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 1
	style.shadow_offset = Vector2(1, 1)
	return style


func _card(parent: Control, tinted: bool = false) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _card_style(tinted))
	parent.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 7)
	panel.add_child(box)
	return box


func _card_style(tinted: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	if _current_theme.is_empty():
		_current_theme = Catalog.THEME.get("sistemas", {})
	style.bg_color = _current_theme.get("panel", Color("#fbf7ec"))
	style.border_color = _current_theme.get("grid", Color("#d8cdb8"))
	style.set_border_width_all(2)
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	style.shadow_color = Color(0, 0, 0, 0.25)
	style.shadow_size = 2
	style.shadow_offset = Vector2(2, 2)
	return style


func _input_style(focused: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#fffdf7")
	style.border_color = GREEN if focused else Color("#b9b09c")
	style.set_border_width_all(2 if focused else 1)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style


func _style_input(field: LineEdit) -> void:
	field.add_theme_stylebox_override("normal", _input_style(false))
	field.add_theme_stylebox_override("focus", _input_style(true))
	field.add_theme_color_override("font_color", INK)
	field.add_theme_color_override("font_placeholder_color", Color("#9b9381"))
	field.add_theme_color_override("caret_color", GREEN)
	field.add_theme_color_override("selection_color", Color("#d7e0cc"))
	field.add_theme_font_size_override("font_size", int(round(18 * float(settings["font_scale"]))))


func _animate_button(button: Button, hovering: bool) -> void:
	if not bool(settings["animations"]) or not is_instance_valid(button) or button.disabled:
		return
	button.pivot_offset = button.size / 2.0
	var tween := button.create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2(1.015, 1.015) if hovering else Vector2.ONE, 0.12)
	tween.parallel().tween_property(button, "rotation_degrees", 0.35 if hovering else 0.0, 0.12)


func _add_scroll(parent: Control) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(scroll)
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
	content.add_child(_label("·  CUADERNO DE CAMPO  ·", 13, GOLD, true))
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
	_add_button(content, "Bordes suaves: " + ("Activados" if settings["antialiasing"] else "Desactivados"), _toggle_antialiasing, false)
	var scale_label := _label("Tamaño del texto: %d%%" % int(round(float(settings["font_scale"]) * 100.0)), 17)
	content.add_child(scale_label)
	var slider := HSlider.new()
	slider.min_value = 0.8
	slider.max_value = 1.2
	slider.step = 0.05
	slider.value = settings["font_scale"]
	slider.custom_minimum_size.y = 28
	slider.value_changed.connect(_change_font_scale.bind(scale_label))
	slider.drag_ended.connect(_rebuild_options)
	content.add_child(slider)
	content.add_child(_label("Las preferencias se guardan en este equipo.", 15, Color("#6c6859")))
	_add_button(content, "Créditos", _show_credits, false, 48)


func _show_credits() -> void:
	var content := _make_page("Créditos", "", _show_options)
	content.add_child(_label("UNI SIMULATOR usa Godot Engine.\nCopyright (c) 2014-present Godot Engine contributors.\nCopyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.\n\nAviso y condiciones del motor: https://godotengine.org/license/", 17, INK, true))


func _toggle_fullscreen() -> void:
	settings["fullscreen"] = not bool(settings["fullscreen"])
	if settings["fullscreen"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	_save_settings()
	_show_options()


func _toggle_animations() -> void:
	settings["animations"] = not bool(settings["animations"])
	_save_settings()
	_show_options()


func _toggle_antialiasing() -> void:
	settings["antialiasing"] = not bool(settings["antialiasing"])
	_apply_image_settings()
	_save_settings()
	_show_options()


func _change_font_scale(value: float, scale_label: Label) -> void:
	settings["font_scale"] = value
	scale_label.text = "Tamaño del texto: %d%%" % int(round(value * 100.0))
	_save_settings()


func _rebuild_options(_changed: bool) -> void:
	_show_options.call_deferred()


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
	var content := _make_page("Partidas guardadas · " + mode_label, "Tres espacios para este modo, guardados en este equipo.", _show_modes)
	var rows := _add_scroll(content)
	var free_slot := _find_free_slot(mode)
	for slot in range(1, SAVE_COUNT + 1):
		var save := _read_save(slot, mode)
		var slot_card := _card(rows)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		slot_card.add_child(row)
		var description := "Espacio %d · vacío" % slot
		if not save.is_empty():
			description = "Espacio %d · %s · %s" % [slot, str(save.get("player_name", "Estudiante")), "Solo" if mode == "solo" else "Equipo"]
			if mode == "solo":
				var program := Catalog.program_by_id(str(save.get("program_id", "")))
				description += " · " + str(program.get("name", "Carrera"))
			else:
				description += " · %s" % str(save.get("role_label", "Auxiliar"))
				var names: Array = save.get("player_names", [])
				var turn_index := int(save.get("current_player", 0))
				if turn_index >= 0 and turn_index < names.size():
					description += " · turno de " + str(names[turn_index])
			var name_label := _label(description, 16)
			name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(name_label)
			_add_button(row, "Continuar", _open_slot.bind(slot, mode), true, 44)
			_add_button(row, "Borrar", _delete_slot.bind(slot, mode), false, 44)
		else:
			var empty_label := _label(description, 16)
			empty_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(empty_label)
			if mode == "solo":
				_add_button(row, "Nueva", _begin_new_game.bind(slot), true, 44)
	if mode == "multi":
		content.add_child(_label("Para abrir una partida de equipo, termina una carrera y aprueba su examen de competencia en Solo.", 15, Color("#686a5d")))
		if free_slot > 0 and _has_eligible_solo_save():
			_add_button(content, "Crear partida de equipo", _choose_team_source, true, 58)
		elif free_slot == 0:
			content.add_child(_label("No hay espacios libres. Borra una partida para crear otra.", 15, GOLD))
	elif free_slot == 0:
		content.add_child(_label("No hay espacios libres. Borra una partida para crear otra.", 15, GOLD))


func _begin_new_game(slot: int) -> void:
	active_slot = slot
	_show_new_solo()


func _open_slot(slot: int, mode: String) -> void:
	current_profile = _read_save(slot, mode)
	active_slot = slot
	if current_profile.is_empty():
		_show_slots(mode)
		return
	if mode == "solo":
		_show_solo_hub()
	else:
		_normalize_team_profile()
		_show_team_hub()


func _delete_slot(slot: int, mode: String) -> void:
	var save := _read_save(slot, mode)
	var dialog := ConfirmationDialog.new()
	dialog.title = "Borrar partida"
	dialog.dialog_text = "¿Borrar la partida de %s del espacio %d? Esta acción no se puede deshacer." % [str(save.get("player_name", "Estudiante")), slot]
	dialog.confirmed.connect(_remove_slot.bind(slot, mode, dialog))
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered()


func _remove_slot(slot: int, mode: String, dialog: ConfirmationDialog) -> void:
	dialog.queue_free()
	var path := _save_path(slot, mode)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	var legacy := _legacy_save_path(slot)
	if FileAccess.file_exists(legacy):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(legacy))
		if parsed is Dictionary and str(parsed.get("mode", "solo")) == mode:
			DirAccess.remove_absolute(ProjectSettings.globalize_path(legacy))
	_show_slots(mode)


func _find_free_slot(mode: String) -> int:
	for slot in range(1, SAVE_COUNT + 1):
		if _read_save(slot, mode).is_empty():
			return slot
	return 0


func _show_new_solo() -> void:
	var content := _make_page("Una partida nueva", "Primero ponle nombre a tu estudiante.", _show_solo_slots)
	var name_field := LineEdit.new()
	name_field.placeholder_text = "Tu nombre o apodo"
	name_field.custom_minimum_size.y = 54
	name_field.text = "Estudiante"
	_style_input(name_field)
	content.add_child(name_field)
	_add_button(content, "Elegir facultad", _choose_faculty_from_field.bind(name_field), true)


func _choose_faculty_from_field(name_field: LineEdit) -> void:
	draft_player_name = name_field.text.strip_edges()
	if draft_player_name.is_empty():
		draft_player_name = "Estudiante"
	_show_faculties()


func _show_faculties() -> void:
	if _current_theme.is_empty():
		_current_theme = Catalog.THEME.get("sistemas", {})
	var content := _make_page("Elige una facultad", "Facultad de Ingeniería · Ingeniería de Sistemas e Ingeniería Informática.", _show_new_solo)
	var rows := _add_scroll(content)
	for faculty in Catalog.FACULTIES:
		var button := _add_button(rows, str(faculty["name"]) + "\n" + str(faculty["description"]), _select_faculty.bind(str(faculty["id"])), false, 82)
		button.add_theme_font_size_override("font_size", int(round(16 * float(settings["font_scale"]))))


func _select_faculty(faculty_id: String) -> void:
	selected_faculty = faculty_id
	_show_programs()


func _show_programs() -> void:
	var faculty := Catalog.faculty_by_id(selected_faculty)
	var content := _make_page(str(faculty.get("name", "Carreras")), "Plan de estudios por semestres con prerrequisitos.", _show_faculties)
	var rows := _add_scroll(content)
	for program in Catalog.programs_for_faculty(selected_faculty):
		var card := _card(rows)
		var theme := Catalog.get_theme(str(program["id"]))
		var accent: Color = theme.get("accent", GREEN)
		card.add_child(_label(str(program["name"]), 21, accent))
		card.add_child(_label(str(program["summary"]), 15, _current_theme.get("sub", Color("#5f6257"))))
		card.add_child(_label(str(program.get("description", "")), 14, _current_theme.get("sub", Color("#6c6859"))))
		card.add_child(_label("Título al completar: " + str(program["title"]), 14, _current_theme.get("sub", Color("#767262"))))
		_add_button(card, "Ver menciones y actividades", _show_mentions.bind(str(program["id"])), true, 46)


func _show_mentions(program_id: String) -> void:
	var program := Catalog.program_by_id(program_id)
	if program.is_empty():
		_show_programs()
		return
	var theme := Catalog.get_theme(program_id)
	var accent: Color = theme.get("accent", GREEN)
	var content := _make_page("Menciones y enfoques", str(program["name"]) + " · planes FNI publicados en 2011; los temarios detallados requieren revisión", _show_programs)
	var rows := _add_scroll(content)
	var info_card := _card(rows)
	info_card.add_child(_label(str(program["name"]), 21, accent))
	info_card.add_child(_label(str(program.get("description", "")), 15, theme.get("sub", Color("#5f6257"))))
	for mention in Catalog.mentions_for_program(program_id):
		var card := _card(rows)
		card.add_child(_label(str(mention["name"]), 19, accent))
		card.add_child(_label(str(mention["focus"]), 15, theme.get("sub", Color("#5f6257"))))
		card.add_child(_label("Actividad de muestra: " + str(mention["activity"]), 14, theme.get("sub", Color("#767262"))))
		_add_button(card, "Empezar carrera", _create_solo_save.bind(program_id, str(mention["id"])), true, 46)
		_add_button(card, "Ver plan y demostración", Callable(self, "_show_curriculum").bind(program_id, str(mention["id"])), false, 46)


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
	var theme := Catalog.get_theme(str(program["id"]))
	var accent: Color = theme.get("accent", GREEN)
	_current_theme = theme
	queue_redraw()
	var passed: Array = current_profile.get("passed_subjects", []) as Array
	var failed: Array = current_profile.get("failed_subjects", []) as Array
	if passed == null: passed = []
	if failed == null: failed = []
	current_profile["passed_subjects"] = passed
	current_profile["failed_subjects"] = failed
	if not current_profile.has("subject_progress"):
		current_profile["subject_progress"] = {}
	var sprog: Dictionary = current_profile["subject_progress"]
	var mention := Catalog.mention_by_id(str(program["id"]), str(current_profile.get("mention_id", "")))
	var mention_id := str(current_profile.get("mention_id", ""))
	var subjects := Catalog.all_subjects(str(program["id"]), mention_id)
	if subjects.is_empty():
		var unavailable := _make_page("Plan no disponible", "Esta partida no tiene una mención válida para la malla seleccionada.", _show_solo_slots)
		_add_button(unavailable, "Volver a partidas guardadas", _show_solo_slots, true, 54)
		return
	var subtitle := str(program["name"])
	if not mention.is_empty():
		subtitle += " · " + str(mention["name"])
	var page := _make_page("Hola, " + str(current_profile.get("player_name", "Estudiante")), subtitle, _show_solo_slots)
	var content := _add_scroll(page)
	var header := _card(content)
	header.add_child(_label(str(program.get("description", "")), 15, theme.get("sub", Color("#5f6257"))))
	content.add_child(_label("Avance", 24, accent, true))
	content.add_child(_label("Materias aprobadas: %d / %d    ·    Confianza: %d" % [passed.size(), subjects.size(), int(current_profile.get("confidence", 60))], 17, theme.get("text", INK), true))
	var prog_card := _card(content)
	prog_card.add_child(_label("Progreso por materia", 19, accent))
	for sub in subjects:
		var sig := str(sub.get("sigla", ""))
		if passed.has(sig):
			prog_card.add_child(_label("✓ %s - %s (APROBADA - 3/3)" % [sig, sub.get("name","")], 15, GREEN))
			continue
		if failed.has(sig):
			var fp := 0
			if sprog.has(sig):
				fp = int((sprog[sig] as Dictionary).get("partial", 0)) + 1
			prog_card.add_child(_label("✗ %s - %s (REPROBADA - Parcial %d/3)" % [sig, sub.get("name",""), fp], 15, Color("#b77a43")))
			continue
		if sprog.has(sig):
			var spd: Dictionary = sprog[sig]
			if bool(spd.get("complete", false)):
				prog_card.add_child(_label("✓ %s - %s (APROBADA - 3/3)" % [sig, sub.get("name","")], 15, GREEN))
				continue
			var pp := int(spd.get("partial", 0))
			if pp > 0:
				prog_card.add_child(_label("◐ %s - %s (EN CURSO - Parcial %d/3)" % [sig, sub.get("name",""), pp], 15, accent))
				continue
		prog_card.add_child(_label("○ %s - %s (SIN INICIAR)" % [sig, sub.get("name","")], 15, theme.get("sub", Color("#686a5d"))))
	if not bool(current_profile.get("career_complete", false)):
		var current_sem := 1
		var semesters: Array = Catalog.semesters_for(str(program["id"]), mention_id)
		for sem in semesters:
			var sem_dict: Dictionary = sem
			if int(sem_dict.get("order", 0)) != current_sem:
				continue
			var all_passed := true
			var sem_subs: Array = sem_dict.get("subjects", [])
			for sub in sem_subs:
				var sd: Dictionary = sub
				if not passed.has(sd.get("sigla", "")):
					all_passed = false
					break
			if all_passed:
				current_sem += 1
			else:
				break
		if current_sem > semesters.size():
			current_profile["career_complete"] = true
			_save_profile()
			_show_solo_hub()
			return
		var sem_card := _card(content)
		sem_card.add_child(_label("Semestre actual: %d" % current_sem, 19, accent))
		sem_card.add_child(_label("Elige materias de este semestre para rendir parciales. Si repruebas, puedes repetirla más adelante cuando corresponda.", 14, theme.get("sub", Color("#686a5d"))))
		for sem in semesters:
			var sem_dict: Dictionary = sem
			if int(sem_dict.get("order", 0)) == current_sem:
				var sem_subs: Array = sem_dict.get("subjects", [])
				for sub in sem_subs:
					var sd: Dictionary = sub
					var sig := str(sd.get("sigla", ""))
					if passed.has(sig): continue
					if failed.has(sig):
						var fp := 0
						if sprog.has(sig):
							fp = int((sprog[sig] as Dictionary).get("partial", 0)) + 1
						sem_card.add_child(_label("• %s - %s (Reprobada - Parcial %d/3)" % [sig, sd.get("name",""), fp], 15, Color("#b77a43")))
						continue
					var prereq_ok := true
					var prereqs: Array = sd.get("prereq", [])
					for p in prereqs:
						var ps := str(p)
						if ps == "INGRESO": continue
						if not passed.has(ps):
							prereq_ok = false
							break
					if prereq_ok:
						var sp2 := 0
						if sprog.has(sig):
							sp2 = int((sprog[sig] as Dictionary).get("partial", 0))
						var btn_txt := "%s - %s" % [sig, sd.get("name","")]
						if sp2 > 0:
							btn_txt = "%s - %s (Parcial %d/3)" % [sig, sd.get("name",""), sp2]
						_add_button(sem_card, btn_txt, Callable(self, "_start_subject").bind(sig), false, 48)
					else:
						sem_card.add_child(_label("• %s - %s (Bloqueada por prerrequisitos)" % [sig, sd.get("name","")], 14, theme.get("sub", Color("#686a5d"))))
				break
		if failed.size() > 0:
			var rep := _card(content)
			rep.add_child(_label("Materias reprobadas para repetir", 17, Color("#b77a43")))
			for sig in failed:
				var sstr := str(sig)
				var sub := Catalog.subject_by_sigla(str(program["id"]), sstr, mention_id)
				if not sub.is_empty():
					var prereq_ok := true
					var prereqs2: Array = sub.get("prereq", [])
					for p in prereqs2:
						var ps := str(p)
						if ps == "INGRESO": continue
						if not passed.has(ps):
							prereq_ok = false
							break
					if prereq_ok and not passed.has(sstr):
						var fp2 := 0
						if sprog.has(sstr):
							fp2 = int((sprog[sstr] as Dictionary).get("partial", 0)) + 1
						_add_button(rep, "%s - %s (Repetir - Parcial %d/3)" % [sstr, sub.get("name",""), fp2], Callable(self, "_start_subject").bind(sstr), false, 46)
	else:
		content.add_child(_label("Carrera completa: " + str(program["title"]), 21, GREEN, true))
		content.add_child(_label("Tu título ya está registrado en la partida.", 16, theme.get("sub", Color("#686a5d")), true))
		if not bool(current_profile.get("competency_passed", false)):
			_add_button(content, "Rendir examen de competencia", _show_competency, true, 62)
		else:
			content.add_child(_label("Competencia aprobada · Auxiliar disponible en el modo de equipo.", 17, GREEN, true))
	_add_button(content, "Ver plan de estudios (GRAFO interactivo)", Callable(self, "_show_curriculum_graph").bind(str(program["id"]), true), false, 52)
	_add_button(content, "Ver títulos y logros", _show_titles, false, 48)
	_add_button(content, "Cambiar carrera o facultad", _show_solo_slots, false, 48)
	_add_button(content, "Guardar y volver al inicio", _return_to_menu, false, 48)


func _start_subject(sigla: String) -> void:
	current_profile["current_subject"] = sigla
	if not current_profile.has("subject_progress"):
		current_profile["subject_progress"] = {}
	if not current_profile.has("partial_index"):
		current_profile["partial_index"] = 0
	var sprog: Dictionary = current_profile["subject_progress"]
	var p := 0
	if sprog.has(sigla):
		var sp: Dictionary = sprog[sigla]
		if bool(sp.get("complete", false)):
			_show_solo_hub()
			return
		p = int(sp.get("partial", 0))
	current_profile["partial_index"] = p
	_save_profile()
	_show_exam()

func _show_exam() -> void:
	var program := Catalog.program_by_id(str(current_profile.get("program_id", "")))
	if program.is_empty():
		_show_solo_slots()
		return
	var sigla := str(current_profile.get("current_subject", ""))
	if sigla == "":
		_show_solo_hub()
		return
	if not current_profile.has("subject_progress"):
		current_profile["subject_progress"] = {}
	var sprog: Dictionary = current_profile["subject_progress"]
	if not current_profile.has("partial_index"):
		current_profile["partial_index"] = 0
	var mention_id := str(current_profile.get("mention_id", ""))
	var course := Catalog.course_for_sigla(str(program["id"]), sigla, mention_id)
	if course.is_empty():
		_show_solo_hub()
		return
	var partials: Array = course.get("partials", [])
	if partials.is_empty():
		_show_solo_hub()
		return
	var partial_index := int(current_profile.get("partial_index", 0))
	if sprog.has(sigla):
		var sp: Dictionary = sprog[sigla]
		if bool(sp.get("complete", false)):
			_show_solo_hub()
			return
		if int(sp.get("partial", 0)) > partial_index:
			partial_index = int(sp.get("partial", 0))
			current_profile["partial_index"] = partial_index
	if partial_index < 0 or partial_index >= partials.size():
		partial_index = 0
		current_profile["partial_index"] = partial_index
	current_question = partials[partial_index]
	var theme := Catalog.get_theme(str(program["id"]))
	var accent: Color = theme.get("accent", GREEN)
	_current_theme = theme
	queue_redraw()
	var content := _make_page("Parcial %d / 3 · %s (%s)" % [partial_index + 1, str(course["name"]), sigla], "Semestre %d · Progreso: Parcial %d de 3" % [int(course.get("semester",0)), partial_index + 1], Callable(self, "_show_solo_hub"))
	var info := _card(content)
	info.add_child(_label(str(course.get("desc","")), 15, theme.get("sub", Color("#5f6257"))))
	var topics: Array = course.get("topics", [])
	if not topics.is_empty():
		info.add_child(_label("Temas: " + ", ".join(topics), 14, theme.get("sub", Color("#686a5d"))))
	var prereq: Array = course.get("prereq", [])
	if not prereq.is_empty():
		info.add_child(_label("Prerrequisitos: " + ", ".join(prereq), 14, theme.get("sub", Color("#686a5d"))))
	info.add_child(_label("Progreso: Parcial %d/3" % (partial_index + 1), 14, accent))
	content.add_child(_label(str(current_question["q"]), 23, accent, true))
	for option_index in range(current_question["options"].size()):
		_add_button(content, str(current_question["options"][option_index]), _answer_subject.bind(option_index), false, 55)
	var key := "%s:%d" % [sigla, partial_index]
	var used: Array = current_profile.get("chanchullo_used", [])
	var cheat_button := _add_button(content, "Chanchullo: mirar el apunte escondido", _try_chanchullo.bind(key), true, 50)
	if used.has(key):
		cheat_button.disabled = true
		content.add_child(_label("Ya usaste el chanchullo en este parcial.", 14, GOLD, true))
	else:
		content.add_child(_label("La jugada puede salir bien o pillarse; solo hay una oportunidad por parcial.", 14, theme.get("sub", Color("#686a5d")), true))


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
	if program.is_empty():
		_show_solo_slots()
		return
	var mention_id := str(current_profile.get("mention_id", ""))
	var subjects := Catalog.all_subjects(str(program["id"]), mention_id)
	var sigla := str(current_profile.get("current_subject", ""))
	if sigla.is_empty() or Catalog.subject_by_sigla(str(program["id"]), sigla, mention_id).is_empty():
		_show_solo_hub()
		return
	var partial_index := int(current_profile.get("partial_index", 0))
	if not current_profile.has("passed_subjects"):
		current_profile["passed_subjects"] = []
	if not current_profile.has("failed_subjects"):
		current_profile["failed_subjects"] = []
	if not current_profile.has("subject_progress"):
		current_profile["subject_progress"] = {}
	var passed: Array = current_profile["passed_subjects"]
	var failed: Array = current_profile["failed_subjects"]
	var sprog: Dictionary = current_profile["subject_progress"]
	if correct:
		if not cheated:
			current_profile["confidence"] = mini(100, int(current_profile.get("confidence", 60)) + 4)
		partial_index += 1
		var message := str(current_question["why"])
		if cheated:
			message += " El apunte pasó esta vez, pero una respuesta copiada no suma confianza."
		if partial_index >= 3:
			current_profile["partial_index"] = 0
			sprog[sigla] = {"partial": 3, "complete": true}
			current_profile["subject_progress"] = sprog
			if not passed.has(sigla):
				passed.append(sigla)
			if failed.has(sigla):
				failed.erase(sigla)
			current_profile["passed_subjects"] = passed
			current_profile["failed_subjects"] = failed
			var course := Catalog.course_for_sigla(str(program["id"]), sigla, mention_id)
			if course.is_empty():
				course = Catalog.course(str(program["id"]), int(current_profile.get("completed_subjects", 0)), mention_id)
			message += " Aprobaste los tres parciales de %s (%s)." % [str(course.get("name","")), sigla]
			if passed.size() >= subjects.size():
				current_profile["career_complete"] = true
				var titles: Array = current_profile.get("titles", [])
				titles.append("Título: " + str(program["title"]))
				current_profile["titles"] = titles
				message += " Completaste el plan de estudios y ganaste el título «%s»." % str(program["title"])
			_save_profile()
			_show_result("Materia aprobada", message, true, _show_solo_hub)
		else:
			current_profile["partial_index"] = partial_index
			sprog[sigla] = {"partial": partial_index, "complete": false}
			current_profile["subject_progress"] = sprog
			message += " Parcial %d aprobado. Siguiente: Parcial %d." % [partial_index, partial_index + 1]
			_save_profile()
			_show_result("Parcial aprobado", message, true, _show_exam)
	else:
		current_profile["confidence"] = maxi(0, int(current_profile.get("confidence", 60)) - 3)
		if partial_index >= 2 and not failed.has(sigla):
			failed.append(sigla)
			current_profile["failed_subjects"] = failed
			sprog[sigla] = {"partial": partial_index, "complete": false, "failed": true}
			current_profile["subject_progress"] = sprog
		_save_profile()
		_show_result("Parcial pendiente", str(current_question["why"]) + " Puedes repasar y volver a intentarlo cuando quieras.", false, _show_exam)


func _show_competency() -> void:
	var program := Catalog.program_by_id(str(current_profile.get("program_id", "")))
	if program.is_empty() or not bool(current_profile.get("career_complete", false)):
		_show_solo_hub()
		return
	var subjects := Catalog.all_subjects(str(program["id"]), str(current_profile.get("mention_id", "")))
	var theme := Catalog.get_theme(str(program["id"]))
	var accent: Color = theme.get("accent", GREEN)
	var last: Dictionary = subjects.back()
	var questions: Array = [
		{"q": "Tienes una tarea para apoyar: ¿cómo priorizas para entender mejor un problema técnico?", "options": ["Identificar el problema, datos y restricciones antes de proponer solución", "Empezar a escribir sin entender el enunciado", "Copiar lo primero que encuentres sin analizar"], "answer": 0, "why": "Definir bien el problema es la base para cualquier solución."},
		{"q": "Ante un tema nuevo de %s, ¿qué estrategia te parece más efectiva?" % str(program["name"]), "options": ["Relacionarlo con lo visto antes y practicar con ejemplos", "Memorizar sin contexto", "Estudiar solo la noche antes"], "answer": 0, "why": "Conectar con conocimientos previos y practicar acelera el aprendizaje."},
		{"q": "Si trabajas con %s y hay un error, ¿cómo lo abordas?" % str(last.get("name", "la materia")), "options": ["Revisar paso a paso, aislar el fallo y validar", "Cambiar todo sin entender", "Ignorar el error"], "answer": 0, "why": "El enfoque sistemático permite encontrar la causa raíz."}
	]
	var choice := random.randi_range(0, questions.size() - 1)
	current_question = questions[choice]
	var content := _make_page("Examen de competencia", "Demuestra que puedes apoyar a otra persona con base en tu plan de estudios.", Callable(self, "_show_solo_hub"))
	content.add_child(_label(str(current_question["q"]), 24, accent, true))
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
		var save := _read_save(slot, "solo")
		if bool(save.get("career_complete", false)) and bool(save.get("competency_passed", false)):
			return true
	return false


func _choose_team_source() -> void:
	var content := _make_page("Elige a quién vas a representar", "Solo aparecen carreras completas con competencia aprobada.", _show_multi_slots)
	var rows := _add_scroll(content)
	for slot in range(1, SAVE_COUNT + 1):
		var save := _read_save(slot, "solo")
		if bool(save.get("career_complete", false)) and bool(save.get("competency_passed", false)):
			var program := Catalog.program_by_id(str(save.get("program_id", "")))
			_add_button(rows, "%s · %s" % [str(save.get("player_name", "Estudiante")), str(program.get("name", "Carrera"))], _show_team_setup.bind(slot), false, 54)


func _show_team_setup(source_slot: int) -> void:
	if source_slot == 0:
		_show_multi_slots()
		return
	draft_source_slot = source_slot
	var source := _read_save(source_slot, "solo")
	var content := _make_page("Armen el equipo", "%s abre la partida como auxiliar. El turno irá rotando entre las personas del equipo." % str(source.get("player_name", "Estudiante")), _show_multi_slots)
	var form := _card(content)
	form.add_child(_label("¿Cuántas personas van a turnarse en esta computadora?", 18, INK, true))
	var players := SpinBox.new()
	players.min_value = 1
	players.max_value = 4
	players.value = 2
	players.custom_minimum_size = Vector2(160, 48)
	players.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	form.add_child(players)
	players.get_line_edit().alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_input(players.get_line_edit())
	team_name_drafts = [
		str(source.get("player_name", "Estudiante")),
		"Jugador 2",
		"Jugador 3",
		"Jugador 4",
	]
	team_name_box = VBoxContainer.new()
	team_name_box.add_theme_constant_override("separation", 8)
	form.add_child(team_name_box)
	_fill_team_name_fields(int(players.value))
	players.value_changed.connect(_on_team_players_changed)
	content.add_child(_label("Cada caso lo resuelve quien tenga el turno. Al terminar, pasa al siguiente jugador.", 14, Color("#686a5d"), true))
	_add_button(content, "Empezar partida de equipo", _create_team_save.bind(players), true, 60)


func _fill_team_name_fields(count: int) -> void:
	if not is_instance_valid(team_name_box):
		return
	for child in team_name_box.get_children():
		team_name_box.remove_child(child)
		child.queue_free()
	team_name_fields.clear()
	for index in range(count):
		var field := LineEdit.new()
		field.placeholder_text = "Nombre del jugador %d" % (index + 1)
		field.text = str(team_name_drafts[index]) if index < team_name_drafts.size() else "Jugador %d" % (index + 1)
		field.custom_minimum_size.y = 46
		_style_input(field)
		team_name_box.add_child(field)
		team_name_fields.append(field)


func _store_team_names() -> void:
	for index in range(team_name_fields.size()):
		if index < team_name_drafts.size():
			var field: LineEdit = team_name_fields[index]
			team_name_drafts[index] = field.text


func _on_team_players_changed(value: float) -> void:
	_store_team_names()
	_fill_team_name_fields(int(value))


func _create_team_save(players: SpinBox) -> void:
	var slot := _find_free_slot("multi")
	if slot == 0:
		_show_result("No hay espacio", "Borra una partida guardada antes de crear una partida de equipo.", false, _show_multi_slots)
		return
	active_slot = slot
	_store_team_names()
	var count := int(players.value)
	var names: Array = []
	var scores: Array = []
	var confidence: Array = []
	for index in range(count):
		var candidate: String = str(team_name_drafts[index]).strip_edges() if index < team_name_drafts.size() else ""
		if candidate.is_empty():
			candidate = "Jugador %d" % (index + 1)
		names.append(candidate)
		scores.append(0)
		confidence.append(60)
	var source := _read_save(draft_source_slot, "solo")
	var program := Catalog.program_by_id(str(source.get("program_id", "")))
	current_profile = {
		"slot": slot,
		"mode": "multi",
		"player_name": names[0],
		"player_names": names,
		"player_scores": scores,
		"player_confidence": confidence,
		"current_player": 0,
		"program_id": source.get("program_id", ""),
		"source_slot": draft_source_slot,
		"players": count,
		"role_id": "auxiliar",
		"role_label": "Auxiliar docente",
		"assistant_cases": 0,
		"admin_cases": 0,
		"dean_cases": 0,
		"team_score": 0,
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


func _normalize_team_profile() -> void:
	var count := maxi(1, int(current_profile.get("players", 1)))
	current_profile["players"] = count
	var names: Array = current_profile.get("player_names", [])
	while names.size() < count:
		if names.is_empty():
			names.append(str(current_profile.get("player_name", "Jugador 1")))
		else:
			names.append("Jugador %d" % (names.size() + 1))
	while names.size() > count:
		names.pop_back()
	current_profile["player_names"] = names
	var scores: Array = current_profile.get("player_scores", [])
	while scores.size() < count:
		scores.append(0)
	current_profile["player_scores"] = scores
	var confidence: Array = current_profile.get("player_confidence", [])
	var base_confidence := int(current_profile.get("team_confidence", 60))
	while confidence.size() < count:
		confidence.append(base_confidence)
	current_profile["player_confidence"] = confidence
	var current := int(current_profile.get("current_player", 0))
	current_profile["current_player"] = ((current % count) + count) % count


func _current_player_name() -> String:
	var names: Array = current_profile.get("player_names", [])
	var index := int(current_profile.get("current_player", 0))
	if index >= 0 and index < names.size():
		return str(names[index])
	return str(current_profile.get("player_name", "Estudiante"))


func _advance_team_turn() -> void:
	var count := maxi(1, int(current_profile.get("players", 1)))
	current_profile["current_player"] = (int(current_profile.get("current_player", 0)) + 1) % count


func _award_team_case(best: bool) -> void:
	var index := int(current_profile.get("current_player", 0))
	var scores: Array = current_profile.get("player_scores", [])
	var confidence: Array = current_profile.get("player_confidence", [])
	while scores.size() <= index:
		scores.append(0)
	while confidence.size() <= index:
		confidence.append(60)
	if best:
		scores[index] = int(scores[index]) + 10
		confidence[index] = mini(100, int(confidence[index]) + 6)
	else:
		confidence[index] = maxi(0, int(confidence[index]) - 5)
	current_profile["player_scores"] = scores
	current_profile["player_confidence"] = confidence


func _add_team_scoreboard(content: VBoxContainer) -> void:
	var names: Array = current_profile.get("player_names", [])
	var scores: Array = current_profile.get("player_scores", [])
	var confidence: Array = current_profile.get("player_confidence", [])
	var current := int(current_profile.get("current_player", 0))
	var board := VBoxContainer.new()
	board.add_theme_constant_override("separation", 4)
	var board_card := _card(content, true)
	board_card.add_child(board)
	for index in range(names.size()):
		var active := index == current
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		var name_label := _label(("▶  " if active else "    ") + str(names[index]), 16, GREEN if active else INK)
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_label)
		var score := int(scores[index]) if index < scores.size() else 0
		var trust := int(confidence[index]) if index < confidence.size() else 60
		row.add_child(_label("%d pts · confianza %d" % [score, trust], 14, Color("#686a5d")))
		board.add_child(row)
	board.add_child(_label("Experiencia del equipo: %d" % int(current_profile.get("team_score", 0)), 15, INK, true))


func _team_mvp() -> Dictionary:
	var names: Array = current_profile.get("player_names", [])
	var scores: Array = current_profile.get("player_scores", [])
	if names.is_empty() or scores.is_empty():
		return {}
	var best_index := 0
	for index in range(scores.size()):
		if int(scores[index]) > int(scores[best_index]):
			best_index = index
	if best_index >= names.size():
		return {}
	return {"name": str(names[best_index]), "score": int(scores[best_index])}


func _show_team_hub() -> void:
	if current_profile.is_empty() or current_profile.get("mode", "") != "multi":
		_show_multi_slots()
		return
	_normalize_team_profile()
	var role := str(current_profile.get("role_id", "auxiliar"))
	var role_name := "Auxiliar docente" if role == "auxiliar" else "Administrativo" if role == "administrativo" else "Decano"
	var program := Catalog.program_by_id(str(current_profile.get("program_id", "")))
	var names: Array = current_profile.get("player_names", [])
	var content := _make_page("Equipo de " + str(program.get("name", "la universidad")), "%d participantes · turno de %s" % [names.size(), _current_player_name()], _show_multi_slots)
	content.add_child(_label("Turno de " + _current_player_name(), 22, GREEN, true))
	content.add_child(_label("Rol del equipo: " + role_name, 15, Color("#686a5d"), true))
	_add_team_scoreboard(content)
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
			_add_button(content, "Presentar candidatura a decano", _show_dean_vote, true, 62)
	else:
		var done := int(current_profile.get("dean_cases", 0))
		if done < DEAN_CASES.size():
			_show_team_case_content(content, DEAN_CASES[done], role, done)
		else:
			content.add_child(_label("Terminaste la gestión de facultad. El consejo recibió tus decisiones y su seguimiento.", 19, GREEN, true))
			content.add_child(_label("Puntaje final del equipo: %d" % int(current_profile.get("team_score", 0)), 16, INK, true))
			var mvp := _team_mvp()
			if not mvp.is_empty():
				content.add_child(_label("Mejor puntaje individual: %s (%d pts)" % [str(mvp["name"]), int(mvp["score"])], 15, GOLD, true))
			_add_button(content, "Ver logros", _show_team_titles, false, 48)
	_add_button(content, "Guardar y volver al inicio", _return_to_menu, false, 48)


func _show_team_case_content(content: VBoxContainer, simulation: Dictionary, role: String, case_index: int) -> void:
	var role_title := "Tutoría" if role == "auxiliar" else "Mesa administrativa" if role == "administrativo" else "Consejo de facultad"
	content.add_child(_label("%s · situación %d de 3" % [role_title, case_index + 1], 23, GREEN, true))
	content.add_child(_label("Decide " + _current_player_name(), 14, GOLD, true))
	content.add_child(_label(str(simulation["question"]), 19, INK, true))
	for option_index in range(simulation["options"].size()):
		_add_button(content, str(simulation["options"][option_index]), _choose_team_case.bind(role, case_index, option_index), false, 52)


func _choose_team_case(role: String, case_index: int, choice_index: int) -> void:
	var cases: Array = ASSISTANT_CASES if role == "auxiliar" else ADMIN_CASES if role == "administrativo" else DEAN_CASES
	var simulation: Dictionary = cases[case_index]
	var best := choice_index == int(simulation["best"])
	var feedback := str(simulation["good"] if best else simulation["bad"])
	var deciding_player := _current_player_name()
	_award_team_case(best)
	if best:
		current_profile["team_score"] = int(current_profile.get("team_score", 0)) + 10
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
	_advance_team_turn()
	_save_profile()
	_show_result("Decisión de " + deciding_player, feedback + " Turno de %s." % _current_player_name(), best, Callable(self, "_show_team_hub"))


func _show_cv_builder(reset: bool = true) -> void:
	if reset:
		cv_draft = current_profile.get("cv_items", []).duplicate()
	var content := _make_page("Arma tu CV", "Turno de %s · elige al menos tres experiencias que puedas respaldar." % _current_player_name(), Callable(self, "_show_team_hub"))
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
	_show_cv_builder(false)


func _submit_cv() -> void:
	if cv_draft.size() < 3:
		_show_result("CV incompleto", "La convocatoria pide al menos tres experiencias. Completa el CV y vuelve a enviarlo.", false, _show_cv_builder)
		return
	current_profile["cv_items"] = cv_draft.duplicate()
	current_profile["cv_submitted"] = true
	_save_profile()
	_show_admin_interview()


func _show_admin_interview() -> void:
	var content := _make_page("Entrevista administrativa", "Responde %s · criterio, atención y cuidado de datos." % _current_player_name(), Callable(self, "_show_cv_builder"))
	content.add_child(_label("Llegan dos trámites con plazos distintos y a uno le faltan datos. ¿Cómo los atiendes?", 22, INK, true))
	_add_button(content, "Verifico lo necesario, priorizo el vencimiento y dejo registro de lo pendiente", _answer_admin_interview.bind(true), false, 58)
	_add_button(content, "Apruebo los dos sin revisar para terminar rápido", _answer_admin_interview.bind(false), false, 58)
	_add_button(content, "Pido los datos personales completos de todo el grupo", _answer_admin_interview.bind(false), false, 58)


func _answer_admin_interview(correct: bool) -> void:
	if not correct:
		_show_result("La entrevista sigue pendiente", "La convocatoria necesita una decisión verificable y centrada en el trámite. Puedes repasar tu CV e intentarlo otra vez.", false, _show_admin_interview)
		return
	var deciding_player := _current_player_name()
	current_profile["role_id"] = "administrativo"
	current_profile["role_label"] = "Administrativo"
	var titles: Array = current_profile.get("titles", [])
	titles.append("Cargo administrativo · CV y entrevista aprobados por %s" % deciding_player)
	current_profile["titles"] = titles
	_advance_team_turn()
	_save_profile()
	_show_result("Te contrataron", "El CV y la entrevista abrieron el cargo. Ahora vienen casos de registros, recursos y atención universitaria. Turno de %s." % _current_player_name(), true, _show_team_hub)


func _show_dean_vote() -> void:
	var content := _make_page("Consejo de facultad", "Responde %s · la experiencia administrativa permite postular y el consejo revisa el criterio." % _current_player_name(), Callable(self, "_show_team_hub"))
	content.add_child(_label("¿Cómo presentarías el presupuesto anual de 100 puntos?", 22, INK, true))
	_add_button(content, "Repartirlo con criterios públicos, revisar necesidades y fijar seguimiento", _answer_dean_vote.bind(true), false, 58)
	_add_button(content, "Asignarlo según popularidad y ver después qué falta", _answer_dean_vote.bind(false), false, 58)
	_add_button(content, "Gastar todo en una compra antes de comparar propuestas", _answer_dean_vote.bind(false), false, 58)


func _answer_dean_vote(approved: bool) -> void:
	if not approved:
		_show_result("La candidatura sigue en revisión", "El consejo pide una propuesta justificable y con seguimiento del dinero. Puedes ajustar el planteamiento e intentarlo otra vez.", false, _show_dean_vote)
		return
	var deciding_player := _current_player_name()
	current_profile["role_id"] = "decano"
	current_profile["role_label"] = "Decano"
	var titles: Array = current_profile.get("titles", [])
	titles.append("Decano electo · candidatura presentada por %s" % deciding_player)
	current_profile["titles"] = titles
	_advance_team_turn()
	_save_profile()
	_show_result("El consejo te eligió", "La candidatura fue aprobada. Ahora tendrás que tomar decisiones de presupuesto, revisar inversiones y rendir cuentas. Turno de %s." % _current_player_name(), true, _show_team_hub)


func _show_team_titles() -> void:
	var content := _make_page("Logros del equipo", "Títulos guardados en esta partida local.", _show_team_hub)
	_add_team_scoreboard(content)
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
	var card := _card(content)
	card.add_child(_label(body, 20, GREEN if positive else INK, true))
	_add_button(content, "Continuar", next, true, 62)


func _save_path(slot: int, mode: String) -> String:
	return "%s/%s_partida_%d.json" % [SAVE_DIR, mode, slot]


func _legacy_save_path(slot: int) -> String:
	return "%s/partida_%d.json" % [SAVE_DIR, slot]


func _read_save(slot: int, mode: String) -> Dictionary:
	var path := _save_path(slot, mode)
	if not FileAccess.file_exists(path):
		var legacy := _legacy_save_path(slot)
		if not FileAccess.file_exists(legacy):
			return {}
		var legacy_parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(legacy))
		if legacy_parsed is Dictionary and str(legacy_parsed.get("mode", "solo")) == mode:
			return legacy_parsed
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
	var mode := str(current_profile.get("mode", "solo"))
	var file := FileAccess.open(_save_path(active_slot, mode), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(current_profile, "\t"))
		file.close()


const GraphScene := preload("res://scripts/curriculum_graph.gd")

func _show_curriculum_graph(program_id: String, return_to_hub: bool = false, selected_mention_id: String = "") -> void:
	var program := Catalog.program_by_id(program_id)
	if program.is_empty(): return
	var theme := Catalog.get_theme(program_id)
	_current_theme = theme
	queue_redraw()
	var mention_id := str(current_profile.get("mention_id", "")) if return_to_hub else selected_mention_id
	var mention := Catalog.mention_by_id(program_id, mention_id)
	var page_back := Callable(self, "_show_solo_hub") if return_to_hub else Callable(self, "_show_mentions").bind(program_id)
	var content := _make_page("Plan de estudios y recorrido", str(program.get("name", "")) + " · Plan publicado por la FNI en 2011", page_back)
	var intro := _card(content)
	intro.add_child(_label(str(program.get("description", "")), 15, theme.get("sub", Color("#9fb3c8"))))
	if not mention.is_empty():
		intro.add_child(_label("Enfoque: " + str(mention.get("name", "")) + "\nActividad de muestra: " + str(mention.get("activity", "")), 14, theme.get("sub", Color("#9fb3c8"))))
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 310)
	content.add_child(scroll)
	var graph := GraphScene.new()
	graph.setup(program_id, mention_id)
	scroll.add_child(graph)
	var details := _card(content)
	details.add_child(_label("Selecciona una materia del grafo para ver sus temas y requisitos.", 14, theme.get("sub", Color("#9fb3c8"))))
	graph.subject_selected.connect(_show_graph_subject.bind(details))

func _show_curriculum(program_id: String, mention_id: String) -> void:
	_show_curriculum_graph(program_id, false, mention_id)


func _show_graph_subject(sigla: String, data: Dictionary, details: VBoxContainer) -> void:
	for child in details.get_children():
		details.remove_child(child)
		child.queue_free()
	var prerequisites: Array = data.get("prereq", [])
	var topics: Array = data.get("topics", [])
	details.add_child(_label(str(data.get("name", "")) + " · " + sigla, 18, _current_theme.get("accent", GREEN)))
	details.add_child(_label(str(data.get("desc", "")), 15, _current_theme.get("sub", INK)))
	details.add_child(_label("Semestre %s · Prerrequisitos: %s" % [str(data.get("semester", "")), ", ".join(prerequisites) if not prerequisites.is_empty() else "Ingreso"], 14, _current_theme.get("sub", INK)))
	if not topics.is_empty():
		details.add_child(_label("Temas: " + ", ".join(topics), 14, _current_theme.get("sub", INK)))
