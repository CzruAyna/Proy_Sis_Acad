extends SceneTree

class PreviewGame extends "res://tests/test_neon_visuals.gd".PreviewGame:
	func _recent_slot() -> int:
		return 1

var assertions := 0
var failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _check(value: bool, message: String) -> void:
	assertions += 1
	if not value:
		failures.append(message)


func _settle() -> void:
	for frame in range(16):
		await process_frame


func _run() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1152, 720)
	root.add_child(viewport)
	var game := PreviewGame.new()
	viewport.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game.active_slot = 1
	game.draft_player_name = "Prueba visual"
	game._show_main()
	await _settle()
	var menu = game.find_child("PageContent", true, false)
	var widths := []
	var labels: Array[String] = []
	for button in menu.find_children("*", "Button", true, false):
		widths.append(button.size.x)
		labels.append(button.text)
	_check(labels == ["Jugar", "Simular", "Opciones", "Salir"], "El inicio conserva cuatro acciones con una partida reciente")
	for width in widths:
		_check(is_equal_approx(width, widths[0]), "Todos los botones del inicio tienen el mismo ancho")
	var motifs := {}
	for program in game.Catalog.PROGRAMS:
		for mention in game.Catalog.mentions_for_program(program["id"]):
			game._create_solo_save(program["id"], mention["id"])
			game.settings["animations"] = true
			game.settings["low_performance"] = false
			game._show_campus_section("resumen")
			await _settle()
			var initial := JSON.stringify(game.simulation.snapshot())
			var ambient = game.find_child("MentionAmbient", true, false)
			_check(ambient != null and ambient.visible, "Cada mención tiene una capa ambiental")
			_check(ambient.material is ShaderMaterial and ambient.surface.size == Vector2i(600, 340), "Desenfoque real sobre una superficie de resolución reducida")
			_check(ambient.find_children("*", "PanelContainer", true, false).is_empty() and ambient.find_children("*", "Window", true, false).is_empty(), "El fondo no contiene ventanas ni paneles falsos")
			_check(ambient.mouse_filter == Control.MOUSE_FILTER_IGNORE, "El fondo no captura acciones del jugador")
			var phase: float = ambient.motif.phase
			ambient._process(0.4)
			_check(ambient.motif.phase > phase and ambient.running, "La temática se anima cuando el movimiento está activado")
			motifs[ambient.motif.kind] = true
			_check(game._card_style(false).bg_color.a == 1.0, "Las tarjetas son opacas")
			game.settings["animations"] = false
			game._show_campus_section("resumen")
			_check(not ambient.running and not ambient.is_processing(), "Reducir movimiento detiene la animación ambiental")
			game.settings["animations"] = true
			game.settings["low_performance"] = true
			game._show_campus_section("resumen")
			_check(not ambient.running, "Bajo consumo conserva un fondo estático")
			_check(initial == JSON.stringify(game.simulation.snapshot()), "El ambiente no cambia la partida")
	_check(motifs.size() == 5, "Las cinco menciones tienen ambientes propios")
	game.settings["low_performance"] = false
	game.settings["animations"] = false
	game._show_campus_section("malla")
	await _settle()
	var graph = game.find_child("ExpandedCurriculumGraph", true, false)
	var node: Dictionary = graph.visible_nodes[-1].duplicate(true)
	graph.subject_selected.emit(str(node["sigla"]), node)
	await _settle()
	var details = game.find_child("GraphSubjectDetail", true, false)
	var cards = game.find_child("GraphSubjectCards", true, false)
	_check(details.get_parent().visible and not cards.visible, "La ficha seleccionada no se mezcla con la lista de materias")
	_check(details.get_parent().size.x <= 760, "La ficha utiliza un ancho de lectura contenido")
	game._campus()._return_graph_detail(details)
	await _settle()
	_check(not details.get_parent().visible and cards.visible, "Volver al grafo restablece la lista")
	game._show_main()
	_check(not game._ambient.visible and not game._ambient.is_processing(), "El menú principal conserva su fondo anterior")
	viewport.queue_free()
	await process_frame
	for failure in failures:
		push_error(failure)
	print("AMBIENT_LAYOUT_TESTS: %d assertions, %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)
