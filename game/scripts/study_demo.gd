extends VBoxContainer

const Model = preload("res://scripts/study_model.gd")
var subject_name := ""
var topic := ""
var factor := 0.5
var slider: HSlider
var value_label: Label
var model: Control


func setup(course: Dictionary, partial: int, font_scale: float = 1.0) -> void:
	subject_name = str(course.get("name", "Materia"))
	var topics: Array = course.get("topics", [])
	topic = str(topics[posmod(partial, topics.size())]) if not topics.is_empty() else subject_name
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 10)
	value_label = Label.new()
	value_label.add_theme_font_size_override("font_size", int(14 * font_scale))
	value_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(value_label)
	slider = HSlider.new()
	slider.name = "ModelParameter"
	slider.tooltip_text = "Modifica el parámetro con el ratón o las flechas del teclado."
	slider.min_value = 10
	slider.max_value = 90
	slider.step = 5
	slider.value = 50
	slider.custom_minimum_size.y = 32
	slider.value_changed.connect(_change_factor)
	add_child(slider)
	model = Model.new()
	model.name = "InteractiveModel"
	model.subject_name = subject_name
	model.font_scale = font_scale
	model.custom_minimum_size = Vector2(0, 170 * font_scale)
	model.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(model)
	_change_factor(slider.value)


func _change_factor(value: float) -> void:
	factor = value / 100.0
	if value_label:
		value_label.text = "Explora «%s» · parámetro %d%%. Compara el modelo al mover el control." % [topic, int(value)]
	if model:
		model.factor = factor
		model.queue_redraw()
