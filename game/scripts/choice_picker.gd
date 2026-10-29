class_name CampusChoicePicker
extends Button

signal item_selected(index: int)
var selected := 0
var entries: Array[Dictionary] = []
var item_count: int:
	get: return entries.size()
var _host: WeakRef
var _popup: PopupPanel
var _results: VBoxContainer
var _counter: Label
var _previous: Button
var _next: Button
var _page := 0
var _query := ""
var _matches: Array[int] = []


func configure(ui: Control) -> void:
	_host = weakref(ui)
	if not pressed.is_connected(_open):
		pressed.connect(_open)


func add_item(caption: String) -> void:
	entries.append({"label": caption, "metadata": null})
	if entries.size() == 1:
		select(0)


func select(index: int) -> void:
	selected = clampi(index, 0, maxi(entries.size() - 1, 0))
	if not entries.is_empty():
		text = entries[selected]["label"] + "  ▾"
		tooltip_text = entries[selected]["label"]


func set_item_metadata(index: int, value: Variant) -> void:
	entries[index]["metadata"] = value


func get_item_metadata(index: int) -> Variant:
	return entries[index]["metadata"]


func _open() -> void:
	if is_instance_valid(_popup):
		_popup.popup_centered()
		return
	var ui: Control = _host.get_ref()
	_popup = PopupPanel.new()
	_popup.name = "ChoicePopup"
	_popup.add_theme_stylebox_override("panel", ui._card_style(true))
	add_child(_popup)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	_popup.add_child(box)
	box.add_child(ui._label("Elige una opción", 19))
	var search := LineEdit.new()
	search.placeholder_text = "Buscar en las opciones"
	ui._style_input(search)
	search.text_changed.connect(func(value: String) -> void:
		_query = value
		_page = 0
		_render())
	box.add_child(search)
	_results = VBoxContainer.new()
	_results.custom_minimum_size = Vector2(480, 200)
	box.add_child(_results)
	var actions := HBoxContainer.new()
	box.add_child(actions)
	_previous = ui._add_button(actions, "← Anteriores", _change.bind(-1), false, 36)
	_counter = ui._label("", 14, ui._current_theme["sub"], true)
	actions.add_child(_counter)
	_next = ui._add_button(actions, "Siguientes →", _change.bind(1), false, 36)
	ui._add_button(box, "Cerrar", _popup.hide, false, 36)
	_render()
	_popup.popup_centered(Vector2i(560, 420))
	search.grab_focus()


func _change(step: int) -> void:
	_page += step
	_render()


func _render() -> void:
	var ui: Control = _host.get_ref()
	for child in _results.get_children():
		_results.remove_child(child)
		child.queue_free()
	_matches.clear()
	for index in range(entries.size()):
		if _query.is_empty() or str(entries[index]["label"]).to_lower().contains(_query.to_lower()):
			_matches.append(index)
	var pages := maxi(1, ceili(float(_matches.size()) / 4.0))
	_page = clampi(_page, 0, pages - 1)
	for index in _matches.slice(_page * 4, _page * 4 + 4):
		var button: Button = ui._add_button(_results, str(entries[index]["label"]), _choose.bind(index), index == selected, 40)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size.x = 0
		button.add_theme_font_size_override("font_size", int(14 * float(ui.settings["font_scale"])))
	if _matches.is_empty():
		_results.add_child(ui._label("Sin coincidencias. Cambia la búsqueda.", 15))
	_previous.disabled = _page == 0
	_next.disabled = _page == pages - 1
	_counter.text = "%d / %d" % [_page + 1, pages]


func _choose(index: int) -> void:
	select(index)
	_popup.hide()
	item_selected.emit(index)
