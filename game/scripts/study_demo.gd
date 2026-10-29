extends VBoxContainer

const Model = preload("res://scripts/study_model.gd")
var subject_name := ""
var topic := ""
var factor := 0.5
var parameter := 50
var decrease: Button
var increase: Button
var value_label: Label
var model: Control


func setup(course: Dictionary, partial: int, font_scale: float = 1.0, visual_theme: Dictionary = {}) -> void:
	subject_name = str(course.get("name", "Materia"))
	var topics: Array = course.get("topics", [])
	topic = str(topics[posmod(partial, topics.size())]) if not topics.is_empty() else subject_name
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	set_meta("page_atomic", true)
	add_theme_constant_override("separation", 10)
	value_label = Label.new()
	value_label.add_theme_font_size_override("font_size", int(14 * font_scale))
	value_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(value_label)
	var controls := HBoxContainer.new()
	controls.name = "ModelParameter"
	controls.add_theme_constant_override("separation", 10)
	add_child(controls)
	decrease = _parameter_button(controls, "− Disminuir", -5, font_scale, visual_theme)
	increase = _parameter_button(controls, "+ Aumentar", 5, font_scale, visual_theme)
	model = Model.new()
	model.name = "InteractiveModel"
	model.visual_theme = visual_theme.duplicate()
	model.subject_name = subject_name
	model.font_scale = font_scale
	model.custom_minimum_size = Vector2(0, 170 * font_scale)
	model.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(model)
	_change_factor(parameter)


func _parameter_button(parent: Control, caption: String, step: int, scale: float, palette: Dictionary) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(130, 38)
	button.add_theme_font_size_override("font_size", int(14 * scale))
	if not palette.is_empty():
		var neon = preload("res://scripts/neon_visuals.gd")
		button.add_theme_stylebox_override("normal", neon.button(palette, false, "normal"))
		button.add_theme_stylebox_override("hover", neon.button(palette, false, "hover"))
		button.add_theme_stylebox_override("focus", neon.button(palette, true, "normal"))
	button.pressed.connect(func() -> void: _change_factor(parameter + step))
	parent.add_child(button)
	return button


func _change_factor(value: float) -> void:
	parameter = clampi(int(value), 10, 90)
	factor = float(parameter) / 100.0
	decrease.disabled = parameter == 10
	increase.disabled = parameter == 90
	if value_label:
		value_label.text = "Explora «%s» · parámetro %d%%. Usa −/+ para comparar el modelo." % [topic, parameter]
	if model:
		model.factor = factor
		model.queue_redraw()
