extends Control
## Presentation and intent surfaces only. No NPC AI, rewards or floor traversal.
signal closed
const Landmarks = preload("res://scripts/campus_landmark_art.gd")
const Cast = preload("res://scripts/campus_cast.gd")
const Floors = preload("res://scripts/campus_floor_plan.gd")
const Broken = preload("res://scripts/broken_pixel_panel.gd")
var host: WeakRef
var pages: Array[Dictionary] = []
var page_index := 0
var panel: PanelContainer
var previous_back := Callable()
var reveal := 0.0:
	set(value):
		reveal = value
		queue_redraw()

class Illustration extends Control:
	var page: Dictionary = {}
	func _draw() -> void:
		if page.get("kind", "statue") == "floor":
			Floors.draw(self, Rect2(Vector2.ZERO, size), page["id"], page["level"])
		elif page.get("kind", "statue") == "cast_grid":
			var items: Array = page["items"]
			for index in range(items.size()):
				var cell := Vector2(size.x / 3, size.y / 2)
				var extent := Vector2(24, 32) * minf(cell.x / 30, cell.y / 38)
				var point := Vector2(index % 3, index / 3) * cell + (cell - extent) * 0.5
				draw_texture_rect(Cast.texture(str(items[index]["id"])), Rect2(point.round(), extent.round()), false)
		else:
			var texture := Landmarks.texture(str(page.get("id", "piedritas")))
			var extent := texture.get_size() * minf(size.x / texture.get_width(), size.y / texture.get_height())
			draw_texture_rect(texture, Rect2(((size - extent) * 0.5).round(), extent.round()), false)


func open(controller: Control, content: Array[Dictionary], identity: String) -> void:
	host = weakref(controller)
	pages = content
	set_meta("identity", identity)
	name = "CampusInspection"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	theme = controller.theme
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	previous_back = controller._active_back
	controller._active_back = close
	controller.add_child(self)
	resized.connect(_rebuild)
	_rebuild()
	if bool(controller.settings["animations"]) and not bool(controller.settings.get("low_performance", false)):
		create_tween().tween_property(self, "reveal", 1.0, 0.35)
	else:
		reveal = 1


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.01, 0.02, 0.03, 0.78))
	var reach := Vector2(minf(840, size.x - 64), minf(580, size.y - 64)) * reveal
	var origin := ((size - reach) * 0.5).snapped(Vector2(16, 16))
	for y in range(0, ceili(reach.y), 24):
		var notch := posmod(y * 13, 5) * 8
		draw_rect(Rect2(origin + Vector2(notch, y), Vector2(maxf(0, reach.x - notch * 2), minf(24, reach.y - y))), Color.BLACK)
	if panel != null:
		panel.modulate.a = clampf((reveal - 0.35) / 0.65, 0, 1)


func _rebuild() -> void:
	if not is_inside_tree() or pages.is_empty():
		return
	if panel != null:
		remove_child(panel)
		panel.queue_free()
	var ui: Control = host.get_ref()
	panel = PanelContainer.new()
	panel.name = "InspectionPanel"
	var style := Broken.new()
	style.content_margin_left = 24
	style.content_margin_right = 24
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	panel.size.x = minf(840, size.x - 72)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)
	var page: Dictionary = pages[page_index]
	box.add_child(ui._label(str(get_meta("identity", "Campus FNI")), 12))
	box.add_child(ui._label(str(page["title"]), 22))
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 20)
	box.add_child(body)
	var art := Illustration.new()
	art.name = "InspectionArtwork"
	art.page = page
	art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	art.custom_minimum_size = Vector2(240 if size.x >= 1000 else 190, 270)
	body.add_child(art)
	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.add_theme_constant_override("separation", 12)
	body.add_child(copy)
	copy.add_child(ui._label(str(page["text"]), 16))
	copy.add_child(ui._label(str(page.get("source", "Recreación visual · distribución por confirmar")), 12, Color("#b0c2bc")))
	if page.get("kind", "") == "cast_grid":
		var labels := PackedStringArray()
		for item in page["items"]:
			labels.append(item["label"])
		copy.add_child(ui._label(" · ".join(labels), 13))
	if page.get("planned_action", "") != "":
		var action: Button = ui._add_button(copy, str(page["planned_action"]), Callable(), false, 38)
		action.disabled = true
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	box.add_child(actions)
	var previous: Button = ui._add_button(actions, "←", _change.bind(-1), false, 36)
	previous.custom_minimum_size.x = 44
	previous.disabled = page_index == 0
	actions.add_child(ui._label("%d / %d" % [page_index + 1, pages.size()], 13, Color.WHITE, true))
	var next: Button = ui._add_button(actions, "→", _change.bind(1), false, 36)
	next.custom_minimum_size.x = 44
	next.disabled = page_index == pages.size() - 1
	ui._add_button(actions, "Volver", close, true, 38)
	_fit.call_deferred()
	queue_redraw()


func _fit() -> void:
	if not is_instance_valid(panel):
		return
	panel.size.y = panel.get_combined_minimum_size().y
	panel.position = ((size - panel.size) * 0.5).floor()
	var buttons: Array[Button] = []
	for control in panel.find_children("*", "Button", true, false):
		if not control.disabled:
			buttons.append(control)
	for index in range(buttons.size()):
		var previous := buttons[posmod(index - 1, buttons.size())].get_path()
		var next := buttons[(index + 1) % buttons.size()].get_path()
		buttons[index].focus_previous = previous
		buttons[index].focus_next = next
		buttons[index].focus_neighbor_left = previous
		buttons[index].focus_neighbor_top = previous
		buttons[index].focus_neighbor_right = next
		buttons[index].focus_neighbor_bottom = next
	if not buttons.is_empty():
		buttons.back().grab_focus()
	queue_redraw()


func _change(direction: int) -> void:
	page_index = clampi(page_index + direction, 0, pages.size() - 1)
	_rebuild()


func close() -> void:
	var ui = host.get_ref()
	if is_instance_valid(ui) and ui._active_back == Callable(self, "close"):
		ui._active_back = previous_back
	closed.emit()
	queue_free()


static func monument_pages(id: String) -> Array[Dictionary]:
	if id == "chivato":
		return [
			{"id": id, "title": "El Chivato de la FNI", "text": "El Chivato acompaña la memoria del campus. Esta recreación pixel art toma como referencia la escultura de piedra sobre rocas que aportaste.", "source": "Plano y fotografía aportados por el usuario. Autor y fecha de la escultura por confirmar."},
			{"id": id, "title": "3 de julio de 1906", "text": "La FNI sitúa su creación como Escuela de Minas el 3 de julio de 1906. Su historia se vincula a la formación para la actividad minera del país.", "source": "Fuente: FNI-UTO · Nosotros / Misión y Visión. Consulta: 03/11/2026."},
			{"id": id, "title": "3 de julio · ¡Salud!", "text": "Cada 3 de julio recuerda el aniversario de la FNI. En 2026 se cumplen 120 años desde 1906. «¡Salud!» se incorpora como frase de celebración solicitada por el usuario.", "source": "Fecha institucional; aniversario calculado. La frase no se presenta como lema oficial."}
		]
	return [
		{"id": id, "title": "Piedritas · memoria del campus", "text": "Piedritas fue una mascota querida de la facultad que ya falleció. Este homenaje recuerda el afecto de la comunidad hacia los animales que comparten el campus.", "source": "Relato del usuario. La prensa consultada también emplea el nombre «Piedrita»; datos biográficos por confirmar."},
		{"id": id, "title": "Un nombre para seguir cuidando", "text": "Según el relato del usuario, una organización creada en su nombre ayuda a los animales de la facultad. Su recuerdo invita a cuidar a quienes siguen recorriendo estos jardines.", "source": "Nombre, fecha de creación y fuente original de la organización pendientes de verificación."}
	]


static func floor_pages(id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for level in range(Floors.Map.floor_count(id)):
		var labels := PackedStringArray()
		for room in Floors.Map.floor_rooms(id, level):
			labels.append(room["label"])
		result.append({"kind": "floor", "id": id, "level": level, "title": ("Bloque 100" if id == "fis_mat" else "Aulas Básicas · bloque en cruz") + (" · PB" if level == 0 else " · Piso %d" % level), "text": " · ".join(labels), "source": "Plano provisional según el relato del usuario. Escaleras con descanso y retorno en U; recorrido entre pisos en preparación.", "planned_action": "Recorrer escaleras · en preparación"})
	return result


static func catalog_pages() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var people: Array[Dictionary] = []
	for row in Cast.PROFESSIONS:
		people.append({"id": row[0], "label": row[1]})
	for start in range(0, people.size(), 6):
		result.append({"kind": "cast_grid", "title": "Profesionales del campus", "items": people.slice(start, start + 6), "text": "Vestuario, herramientas y poses para la vida del campus.", "source": "Personajes ficticios con paseos ambientales. No representan personas reales ni una oferta oficial de carreras. Clases y horarios por integrar."})
	var students: Array[Dictionary] = []
	for index in range(Cast.STUDENT_COUNT):
		students.append({"id": "estudiante_%d" % index, "label": "Estudiante %d" % (index + 1)})
	for start in range(0, students.size(), 6):
		result.append({"kind": "cast_grid", "title": "Estudiantes del campus", "items": students.slice(start, start + 6), "text": "Ropa, piel, cabello, gafas y mochilas variadas. Cada diseño tiene poses de frente, espalda y paso.", "source": "Personajes ficticios con paseos de ambientación. Sus horarios y entrada a clases están por integrar."})
	var staff: Array[Dictionary] = []
	for row in Cast.STAFF:
		staff.append({"id": row[0], "label": row[1]})
	for start in range(0, staff.size(), 6):
		result.append({"kind": "cast_grid", "title": "Personal y visitantes", "items": staff.slice(start, start + 6), "text": "Biblioteca, docencia, laboratorios, mantenimiento, jardines, administración y visitas.", "source": "Diseños ficticios de ambientación; no identifican trabajadores reales ni puestos disponibles."})
	var dogs: Array[Dictionary] = []
	for row in Cast.DOGS:
		dogs.append({"id": row[0], "label": row[1]})
	result.append({"kind": "cast_grid", "title": "Compañeros del campus", "items": dogs, "text": "Diseños de perros y una variante especial en recuerdo de Piedritas. Encuentros, caricias y logros están en preparación.", "source": "La aparición muy rara de Piedritas está prevista; todavía no se aplica una probabilidad ni se otorgan logros.", "planned_action": "Acariciar · en preparación"})
	return result
