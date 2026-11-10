extends SceneTree

const Graph = preload("res://scripts/curriculum_graph.gd")
const Catalog = preload("res://scripts/catalog.gd")

var assertions := 0
var failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _check(condition: bool, message: String) -> void:
	assertions += 1
	if not condition:
		failures.append(message)


func _run() -> void:
	var graph := Graph.new()
	graph.animations_enabled = false
	root.add_child(graph)
	graph.size = Vector2(1090, 420)
	for program in Catalog.PROGRAMS:
		for mention in Catalog.mentions_for_program(program["id"]):
			graph.setup(program["id"], mention["id"], 1090)
			var sphere: Image = graph._sphere_resource(graph._node_color(0))["image"]
			_check(sphere.get_pixel(65, 55).get_luminance() > sphere.get_pixel(140, 145).get_luminance() * 2, "La esfera tiene luz y sombra con relieve")
			_check(sphere.get_pixel(0, 0).a == 0 and sphere.get_pixel(96, 96).a == 1, "Textura esférica transparente fuera del volumen")
			for semester in range(graph.semesters.size()):
				graph.semester_index = semester
				graph._build_semester()
				_check(graph.edges.size() == graph.edge_paths.size(), "Cada arista tiene una ruta")
				for index in range(graph.visible_nodes.size()):
					var point: Vector2 = graph.visible_nodes[index]["pos"]
					var radius: float = graph._radius(index)
					_check(point.x >= radius and point.x + radius <= graph.graph_width and point.y >= radius and point.y + radius + 32 < graph._graph_height, "Esfera y rótulo dentro del lienzo: %s %s, %s r=%f h=%f" % [mention["id"], graph.visible_nodes[index]["sigla"], point, radius, graph._graph_height])
					_check(graph._node_at(point) == index, "Selección coincide con la esfera")
				for edge in graph.edges:
					var points := graph._edge_points(edge, 0)
					_check(points.size() > 2 and points[0].distance_to(graph.visible_nodes[edge.x]["pos"]) >= graph._radius(edge.x), "Arista comienza fuera del volumen")
				graph.fit_view()
				for index in range(graph.visible_nodes.size()):
					var center := Vector2(graph.visible_nodes[index]["pos"]) * graph.view_zoom + graph.view_offset
					var extent := Vector2.ONE * graph._radius(index) * graph.view_zoom
					_check(Rect2(Vector2.ZERO, graph.size).encloses(Rect2(center - extent, extent * 2)), "El encuadre inicial muestra la esfera completa")
				graph.reset_view()
	graph.setup("sistemas", "gestion_sistemas", 1090)
	var original: Vector2 = graph.visible_nodes[1]["pos"]
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = original
	graph._gui_input(press)
	var motion := InputEventMouseMotion.new()
	motion.position = original + Vector2(8, 5)
	motion.relative = motion.position - original
	graph._gui_input(motion)
	press.pressed = false
	graph._gui_input(press)
	_check(graph.visible_nodes[1]["pos"].is_equal_approx(motion.position) and graph._dragging == -1, "Arrastrar mueve la esfera y soltar termina el movimiento")
	_check(graph.manual_positions.size() == 1, "La distribución manual se conserva como presentación")
	graph.move_semester(1)
	graph.move_semester(-1)
	_check(graph.visible_nodes[1]["pos"].is_equal_approx(motion.position), "Volver al semestre conserva la posición manual")
	var anchor := Vector2(380, 180)
	graph._set_zoom(1.4, anchor)
	_check(((anchor - graph.view_offset) / graph.view_zoom).is_equal_approx(anchor), "Zoom mantiene fijo el punto bajo el cursor")
	var screen_point: Vector2 = graph.visible_nodes[1]["pos"] * graph.view_zoom + graph.view_offset
	_check(graph._node_at(screen_point) == 1, "La selección respeta el zoom y el desplazamiento")
	graph._set_zoom(100, anchor)
	_check(is_equal_approx(graph.view_zoom, 1.65), "Acercamiento limitado")
	graph._set_zoom(0.001, anchor)
	_check(is_equal_approx(graph.view_zoom, 0.08), "Alejamiento limitado")
	graph.reset_view()
	press.position = Vector2(40, 40)
	press.pressed = true
	graph._gui_input(press)
	motion.position = Vector2(70, 60)
	motion.relative = Vector2(30, 20)
	graph._gui_input(motion)
	press.pressed = false
	graph._gui_input(press)
	_check(graph.view_offset == motion.relative and graph._dragging == -1 and not graph._panning, "Arrastrar el fondo desplaza la vista")
	graph.reset_layout()
	_check(graph.manual_positions.is_empty() and graph.view_offset == Vector2.ZERO and graph.view_zoom == 1, "Restablecer recupera el encuadre y la distribución")
	_check(graph.visible_nodes[1]["pos"].is_equal_approx(original), "Restablecer recupera la posición inicial")
	_check(graph.rotate_branch(PI / 3), "Gira una rama manteniendo las conexiones")
	_check(graph._move_branch(0, Vector2(graph.visible_nodes[0]["pos"]) + Vector2(650, 350)), "Traslada una rama completa fuera del área inicial")
	var moved: Vector2 = graph.visible_nodes[1]["pos"]
	graph.move_semester(1)
	graph.move_semester(-1)
	_check(Vector2(graph.visible_nodes[1]["pos"]).is_equal_approx(moved), "Conserva conjuntamente las posiciones giradas y trasladadas al volver")
	graph.reset_layout()
	_check(Vector2(graph.visible_nodes[1]["pos"]).is_equal_approx(original), "Restablecer también recupera una rama girada")
	_check(graph.clip_contents and not graph.is_processing(), "El zoom no desborda y la reducción de movimiento se respeta")
	graph.queue_free()
	await process_frame
	for failure in failures:
		push_error(failure)
	print("GRAPH_INTERACTION_TESTS: %d assertions, %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)
