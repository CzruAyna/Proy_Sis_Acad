extends SceneTree

const Graph = preload("res://scripts/curriculum_graph.gd")
const Routing = preload("res://scripts/graph_routing.gd")
const Catalog = preload("res://scripts/catalog.gd")

var assertions := 0
var failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _check(value: bool, message: String) -> void:
	assertions += 1
	if not value:
		failures.append(message)


func _independent_clearance(paths: Array[PackedVector2Array]) -> bool:
	# Brute-force oracle, independent of the production broad-phase validator.
	for a in range(paths.size()):
		for b in range(a + 1, paths.size()):
			for i in range(paths[a].size() - 1):
				for j in range(paths[b].size() - 1):
					var p := paths[a][i]
					var q := paths[a][i + 1]
					var r := paths[b][j]
					var s := paths[b][j + 1]
					if Geometry2D.segment_intersects_segment(p, q, r, s) != null:
						return false
					for point in [p, q]:
						if point.distance_to(Geometry2D.get_closest_point_to_segment(point, r, s)) < Routing.CLEARANCE - 0.001:
							return false
					for point in [r, s]:
						if point.distance_to(Geometry2D.get_closest_point_to_segment(point, p, q)) < Routing.CLEARANCE - 0.001:
							return false
	return true


func _run() -> void:
	_check(Routing.segment_distance_squared(Vector2.ZERO, Vector2(20, 20), Vector2(0, 20), Vector2(20, 0)) == 0, "Detecta cruces diagonales")
	_check(Routing.segment_distance_squared(Vector2.ZERO, Vector2(20, 0), Vector2(10, 0), Vector2(30, 0)) == 0, "Detecta tramos colineales superpuestos")
	_check(Routing.segment_distance_squared(Vector2.ZERO, Vector2(20, 0), Vector2(20, 0), Vector2(30, 20)) == 0, "Detecta aristas que se tocan")
	_check(is_equal_approx(Routing.segment_distance_squared(Vector2.ZERO, Vector2(20, 0), Vector2(0, 24), Vector2(20, 24)), 576), "Mide separación incluso sin cruce")
	var graph := Graph.new()
	graph.animations_enabled = true
	root.add_child(graph)
	var random := RandomNumberGenerator.new()
	random.seed = 948372
	for width in [500.0, 840.0, 1090.0]:
		for scale in [0.8, 1.2]:
			graph.font_scale = scale
			for program in Catalog.PROGRAMS:
				for mention in Catalog.mentions_for_program(program["id"]):
					graph.manual_positions.clear()
					graph.setup(program["id"], mention["id"], width)
					for semester in range(graph.semesters.size()):
						graph.semester_index = semester
						graph._build_semester()
						_check(not graph.reference_layout, "El plan actual conserva una esfera por materia")
						_check(_independent_clearance(graph.edge_paths), "Sin cruces, contactos o halos unidos en el plan inicial")
						for attempt in range(8):
							var index := random.randi_range(0, graph.visible_nodes.size() - 1)
							var old: Vector2 = graph.visible_nodes[index]["pos"]
							var point := Vector2(random.randf_range(-100, width + 100), random.randf_range(-100, graph._graph_height + 100))
							var accepted := graph._move_node(index, point)
							_check(Routing.valid(graph.visible_nodes, graph.edges, graph.edge_paths, graph._radii()), "Cada arrastre deja una distribución protegida")
							_check(accepted or graph.visible_nodes[index]["pos"] == old, "El arrastre inválido no altera la posición")
						graph.motion_time = 1234.5
						_check(graph._animated_position(0) == graph.visible_nodes[0]["pos"], "La animación nunca mueve los extremos comprobados")
						graph.reset_layout()
					await process_frame
	# Restoring a layout from an older release must not bypass the guard.
	graph.font_scale = 1.0
	graph.setup("sistemas", "gestion_sistemas", 1090)
	for node in graph.visible_nodes:
		graph.manual_positions[graph._layout_key(node["sigla"])] = Vector2(0.5, 0.5)
	graph._build_semester()
	_check(_independent_clearance(graph.edge_paths), "Descarta posiciones antiguas que juntarían conexiones")
	var original: Vector2 = graph.visible_nodes[0]["pos"]
	_check(not graph._move_node(0, graph.visible_nodes[1]["pos"]) and graph.visible_nodes[0]["pos"] == original, "No permite apilar esferas conectadas")
	_check(not graph._move_node(0, Vector2(INF, NAN)), "Rechaza coordenadas no finitas")
	# Future data can describe a graph with no planar embedding. All nine
	# relationships remain visible as explicitly labelled visual references.
	graph.visible_nodes.clear()
	graph.edges.clear()
	for index in range(6):
		graph.visible_nodes.append({"sigla": "TEST%d" % index, "name": "Materia %d" % index, "source": index < 3, "pos": Vector2.ZERO})
	for a in range(3):
		for b in range(3, 6):
			graph.edges.append(Vector2i(a, b))
	graph._layout_nodes()
	_check(graph.reference_layout and graph.edges.size() == 9, "Vista por conexiones conserva todas las relaciones de un grafo complejo")
	_check(_independent_clearance(graph.edge_paths), "Las referencias no cruzan ni unen aristas")
	var pairs := {}
	for edge in graph.edges:
		pairs[graph.visible_nodes[edge.x]["sigla"] + "/" + graph.visible_nodes[edge.y]["sigla"]] = true
	_check(pairs.size() == 9, "No se pierde ni inventa ninguna relación al repetir referencias")
	graph.queue_free()
	await process_frame
	for failure in failures:
		push_error(failure)
	print("GRAPH_CLEARANCE_TESTS: %d assertions, %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)
