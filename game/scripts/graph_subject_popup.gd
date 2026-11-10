extends Control

var _host: Control
var _return_focus: Control
var _panel: PanelContainer
var _back: Callable
var _motion: bool
var _closing := false
var _reveal := 0.0:
	set(value):
		_reveal = value
		_panel.modulate.a = smoothstep(0.3, 0.86, value)
		queue_redraw()
var _transition: Tween


func open(controller: Control, focus_target: Control) -> VBoxContainer:
	_host = controller
	_return_focus = focus_target
	_back = controller._active_back
	_motion = bool(controller.settings["animations"]) and not bool(controller.settings["low_performance"])
	name = "GraphSubjectPopup"
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	accessibility_name = "Ficha de materia · Escape para cerrar"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	controller.add_child(self)
	controller._active_back = close
	_panel = PanelContainer.new()
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var style := StyleBoxFlat.new()
	style.bg_color = Color.BLACK
	style.content_margin_left = 30
	style.content_margin_right = 30
	style.content_margin_top = 24
	style.content_margin_bottom = 24
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 14)
	_panel.add_child(layout)
	var body := VBoxContainer.new()
	body.name = "GraphSubjectDetail"
	body.add_theme_constant_override("separation", 10)
	layout.add_child(body)
	layout.add_child(controller._label("Esc o clic fuera · Cerrar ficha", 13, controller._current_theme["sub"], true))
	_panel.minimum_size_changed.connect(_place)
	resized.connect(_place)
	_place()
	grab_focus()
	if _motion:
		_reveal = 0.0
		_transition = create_tween()
		_transition.tween_property(self, "_reveal", 1.0, 0.27)
	else:
		_reveal = 1.0
	return body


func _place() -> void:
	var extent := Vector2(minf(680, size.x - 72), _panel.get_combined_minimum_size().y)
	_panel.size = extent
	_panel.position = ((size - extent) * 0.5).round()
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not _panel.get_rect().has_point(event.position):
		close()
		accept_event()


func _input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and event.keycode in [KEY_TAB, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT]):
		return
	var actions := _panel.find_children("*", "Button", true, false)
	if not _closing and not actions.is_empty():
		var backward: bool = event.shift_pressed or event.keycode in [KEY_UP, KEY_LEFT]
		var current := actions.find(get_viewport().gui_get_focus_owner())
		if current < 0:
			var target: Control = actions.back() if backward else actions.front()
			target.grab_focus()
		else:
			actions[posmod(current + (-1 if backward else 1), actions.size())].grab_focus()
	get_viewport().set_input_as_handled()


func _draw() -> void:
	if not is_instance_valid(_panel):
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.025, 0.038, 0.06, _reveal * 0.66))
	var box := _panel.get_rect()
	var opening := box.size * _reveal
	var origin := box.get_center() - opening * 0.5
	for y in range(0, ceili(opening.y), 16):
		var left := 8 * (1 + posmod(y * 11 / 16, 4))
		var right := 8 * (1 + posmod(y * 7 / 16 + 1, 5))
		draw_rect(Rect2(origin + Vector2(-left, y), Vector2(opening.x + left + right, minf(16, opening.y - y))), Color.BLACK)


func close() -> void:
	if _closing:
		return
	_closing = true
	if _transition != null:
		_transition.kill()
	if _motion:
		_transition = create_tween()
		_transition.tween_property(self, "_reveal", 0.0, 0.23)
		_transition.tween_callback(_finish)
	else:
		_finish()


func _finish() -> void:
	if is_instance_valid(_host) and _host._active_back == Callable(self, "close"):
		_host._active_back = _back
	if is_instance_valid(_return_focus) and _return_focus.is_inside_tree():
		_return_focus.grab_focus()
	hide()
	queue_free()
