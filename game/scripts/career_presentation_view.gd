extends HBoxContainer
## Presentation adapter. The read-only model owns sequencing and timing.
signal animation_cue(cue: Dictionary)

const Presentation = preload("res://scripts/career_presentation.gd")
var model := Presentation.new()
var reduced_motion := false
var _command: Label
var _body: Label
var _title: Label
var _example: Label
var _counter: Label
var _pause: Button
var _last_chars := -1


func build(ui: Control, parent: Control) -> void:
	name = "CareerPresentation"
	set_meta("page_atomic", true)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 20)
	parent.add_child(self)
	var terminal := VBoxContainer.new()
	terminal.name = "DemoTerminal"
	terminal.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	terminal.size_flags_stretch_ratio = 1.5
	add_child(terminal)
	var visual := VBoxContainer.new()
	visual.name = "DemoAnimationStage"
	visual.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(visual)
	_counter = ui._label("", 12, Color("#9fb4bd"))
	terminal.add_child(_counter)
	_command = ui._label("", 14, Color("#65ed9b"))
	terminal.add_child(_command)
	_title = ui._label("", 17, Color("#9bedff"))
	terminal.add_child(_title)
	_body = ui._label("", 15, Color("#e3f3ec"))
	_body.custom_minimum_size.y = 166
	terminal.add_child(_body)
	visual.add_child(ui._label("EN CONTEXTO", 13, Color("#9bedff")))
	_example = ui._label("", 14, Color("#e3f3ec"))
	visual.add_child(_example)
	visual.add_child(ui._label("Ejemplos didácticos. No representan resultados de tu partida.", 12, Color("#9fb4bd")))
	model.chapter_changed.connect(_chapter)
	model.execute(Presentation.COMMAND)
	var controls := HFlowContainer.new()
	controls.name = "DemoControls"
	controls.add_theme_constant_override("h_separation", 6)
	controls.add_theme_constant_override("v_separation", 6)
	parent.add_child(controls)
	for item in [["Anterior", model.previous], ["Pausa", toggle_pause], ["Siguiente", model.next], ["1x / 2x", toggle_speed], ["Resumen / completo", model.toggle_detail], ["Reiniciar", restart]]:
		var button: Button = ui._add_button(controls, item[0], item[1], false, 34)
		button.add_theme_font_size_override("font_size", int(13 * float(ui.settings["font_scale"])))
		var font_size: int = button.get_theme_font_size("font_size")
		button.custom_minimum_size.x = maxf(100, button.get_theme_font("font").get_string_size("Continuar" if item[0] == "Pausa" else item[0], HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x + 32)
		button.autowrap_mode = TextServer.AUTOWRAP_OFF
		if item[0] == "Pausa":
			_pause = button
	_sync()


func _chapter(cue: Dictionary) -> void:
	_counter.text = model.position_text()
	_command.text = "$ " + str(cue["command"])
	_title.text = str(cue["title"])
	_body.text = str(cue["text"])
	_last_chars = -1
	var examples := {
		"overview": "Problema → análisis → solución\n\nSistemas e Informática conectan conocimientos para construir y evaluar soluciones.",
		"systems_flow": "Solicitud → proceso → resultado\n\nIdentificar demoras, organizar tareas y evaluar una mejora.",
		"information": "Datos → validación → decisión\n\nOrganizar información y revisar su calidad antes de usarla.",
		"optimization": "Recursos + restricciones\n↓\nComparar alternativas\n↓\nEvaluar una asignación",
		"software": "Requisitos → diseño\n↓\nCódigo → pruebas\n↓\nRevisar resultados",
		"network": "Equipo → red → servicio\n\nSeguir un mensaje y comprobar que llega a su destino.",
		"curriculum": "Materia A → Materia B\n\nUna relación de requisitos conecta conocimientos. Consulta la malla interactiva para explorar sus enlaces.",
		"procedure": "Requisitos → documentos\n↓\nRevisión → resultado\n\nProceso simulado, pendiente de contraste institucional.",
		"graduation": "Materias completadas\n↓\nRevisar modalidad\n↓\nCumplir etapas de titulación"
	}
	_example.text = str(examples.get(cue["scene"], examples["overview"]))
	# FRONTEND TEMPORAL: consume animation_cue + model.progress() for the side
	# animations specified in docs/MODO_DEMOSTRATIVO.md. Remove after integration.
	animation_cue.emit(cue)
	_sync()


func _process(delta: float) -> void:
	model.advance(delta)
	_sync()


func _sync() -> void:
	if not is_instance_valid(_body):
		return
	var count := model.visible_text()
	if count != _last_chars:
		_last_chars = count
		_body.visible_characters = -1 if reduced_motion and model.phase != "COMMAND" else count
	_command.visible_characters = -1 if reduced_motion else 2 + model.visible_command()
	if _pause != null:
		_pause.text = "Continuar" if model.paused else "Pausa"


func toggle_pause() -> void:
	model.paused = not model.paused
	_sync()


func toggle_speed() -> void:
	model.speed = 2 if model.speed == 1 else 1
	_counter.text = model.position_text()


func restart() -> void:
	model.execute(Presentation.COMMAND)


func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_WM_WINDOW_FOCUS_OUT]:
		model.paused = true
		_sync()
