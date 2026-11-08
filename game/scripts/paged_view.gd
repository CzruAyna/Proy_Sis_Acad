class_name CampusPagedView
extends VBoxContainer

signal page_changed(index: int, count: int)
signal space_changed(available: Vector2)

var content: VBoxContainer
var viewport: Control
var _page_clip: Control
var navigation: HBoxContainer
var previous: Button
var next: Button
var counter: Label
var page_index := 0
var page_offsets: Array[float] = [0.0]
var page_ends: Array[float] = [0.0]
var _pending := false
var _running := false
var _focus_connections := {}


func configure(ui: Control) -> void:
	name = "PageNavigator"
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 8)
	viewport = Control.new()
	viewport.name = "PageViewport"
	viewport.clip_contents = true
	viewport.size_flags_vertical = Control.SIZE_EXPAND_FILL
	viewport.custom_minimum_size.y = 120
	add_child(viewport)
	_page_clip = Control.new()
	_page_clip.clip_contents = true
	_page_clip.mouse_filter = Control.MOUSE_FILTER_PASS
	viewport.add_child(_page_clip)
	content = VBoxContainer.new()
	content.name = "PageContent"
	content.add_theme_constant_override("separation", 12)
	_page_clip.add_child(content)
	navigation = HBoxContainer.new()
	navigation.name = "PageNavigation"
	navigation.add_theme_constant_override("separation", 12)
	add_child(navigation)
	navigation.visible = false
	navigation.alignment = BoxContainer.ALIGNMENT_CENTER
	previous = ui._add_button(navigation, "↑ Anterior", change_page.bind(-1), false, 36)
	previous.name = "PreviousPage"
	counter = ui._label("", 14, ui._current_theme.get("sub", Color.WHITE), true)
	counter.name = "PageCounter"
	navigation.add_child(counter)
	next = ui._add_button(navigation, "Siguiente ↓", change_page.bind(1), false, 36)
	next.name = "NextPage"
	for action in [previous, next]:
		action.custom_minimum_size = Vector2(128, 36)
		action.autowrap_mode = TextServer.AUTOWRAP_OFF
		action.add_theme_font_size_override("font_size", int(14 * float(ui.settings["font_scale"])))
	viewport.resized.connect(request_layout)
	content.minimum_size_changed.connect(request_layout)
	content.child_order_changed.connect(request_layout)
	request_layout()


func request_layout() -> void:
	if _pending or not is_inside_tree():
		return
	_pending = true
	_reflow.call_deferred()


func _reflow() -> void:
	if not is_inside_tree():
		_pending = false
		return
	if _running:
		return
	_running = true
	_pending = false
	content.size.x = maxf(viewport.size.x, 100)
	space_changed.emit(viewport.size)
	# Wrapped labels and nested cards settle before choosing semantic breaks.
	var tree := get_tree()
	await tree.process_frame
	if not is_inside_tree():
		_running = false
		return
	await tree.process_frame
	if not is_inside_tree():
		_running = false
		return
	var blocks: Array[Vector2] = []
	_collect(content, blocks)
	blocks.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.x < b.x)
	page_offsets = [0.0]
	page_ends = []
	var height := maxf(viewport.size.y - 4, 40)
	var origin := 0.0
	var previous_end := 0.0
	for block in blocks:
		if block.y - origin > height + 0.5 and block.x > origin + 0.5:
			page_ends.append(previous_end)
			origin = block.x
			page_offsets.append(origin)
		previous_end = maxf(previous_end, block.y)
	page_ends.append(previous_end)
	page_index = clampi(page_index, 0, page_offsets.size() - 1)
	_apply_page()
	_running = false
	if _pending:
		_pending = false
		request_layout()


func _collect(control: Control, blocks: Array[Vector2]) -> void:
	if control != content and not control.is_visible_in_tree():
		return
	var top := control.get_global_rect().position.y - content.get_global_rect().position.y
	var bottom := top + control.size.y
	var fits := control.size.y <= maxf(viewport.size.y - 4, 40)
	if control != content and fits and (control is PanelContainer or control is HBoxContainer or control is HFlowContainer or control is Button or control is Label or control is LineEdit or control.get_meta("page_atomic", false)):
		blocks.append(Vector2(top, bottom))
		return
	if control is GridContainer and not fits:
		var children := control.get_children()
		for first in range(0, children.size(), control.columns):
			var row_top := INF
			var row_bottom := 0.0
			for column in range(mini(control.columns, children.size() - first)):
				var cell: Control = children[first + column]
				row_top = minf(row_top, cell.get_global_rect().position.y - content.get_global_rect().position.y)
				row_bottom = maxf(row_bottom, cell.get_global_rect().end.y - content.get_global_rect().position.y)
			if row_bottom - row_top <= viewport.size.y - 4:
				blocks.append(Vector2(row_top, row_bottom))
			else:
				for column in range(mini(control.columns, children.size() - first)):
					_collect(children[first + column], blocks)
		return
	var controls := 0
	for child in control.get_children():
		if child is Control and child.visible:
			controls += 1
			_collect(child, blocks)
	if controls == 0 and control != content and control.visible:
		blocks.append(Vector2(top, bottom))


func change_page(direction: int) -> void:
	page_index = clampi(page_index + direction, 0, page_offsets.size() - 1)
	_apply_page()


func show_control(control: Control) -> void:
	if not is_instance_valid(control) or not content.is_ancestor_of(control):
		return
	var top := control.get_global_rect().position.y - content.get_global_rect().position.y
	var bottom := top + control.size.y
	for index in range(page_offsets.size()):
		if top >= page_offsets[index] - 1 and bottom <= page_offsets[index] + viewport.size.y + 1:
			page_index = index
			_apply_page()
			return


func _apply_page() -> void:
	navigation.visible = page_offsets.size() > 1
	_page_clip.size = Vector2(viewport.size.x, clampf(page_ends[page_index] - page_offsets[page_index] + 1, 0, viewport.size.y))
	content.position.y = -page_offsets[page_index]
	previous.disabled = page_index == 0
	next.disabled = page_index == page_offsets.size() - 1
	counter.text = _section_title()
	for control in content.find_children("*", "Control", true, false):
		if control.focus_mode == Control.FOCUS_NONE:
			continue
		var id := control.get_instance_id()
		if not _focus_connections.has(id):
			control.focus_entered.connect(show_control.bind(control))
			_focus_connections[id] = true
	page_changed.emit(page_index, page_offsets.size())


func _section_title() -> String:
	for label in content.find_children("*", "Label", true, false):
		var top: float = label.global_position.y - content.global_position.y
		if label.is_visible_in_tree() and top >= page_offsets[page_index] - 1 and top < page_ends[page_index]:
			return label.text.get_slice("\n", 0).left(38) + ("…" if label.text.length() > 38 else "")
	return "Contenido"


func current_range() -> Vector2:
	return Vector2(page_offsets[page_index], page_offsets[page_index] + viewport.size.y)
