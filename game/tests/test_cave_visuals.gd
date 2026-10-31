extends "res://tests/test_compact_navigation.gd"

const Logo = preload("res://scripts/procedural_career_logo.gd")
class RecentGame extends "res://tests/test_compact_navigation.gd".TestGame:
	func _recent_slot() -> int:
		return 1
	func _read_save(_slot: int, _mode: String) -> Dictionary:
		return {"player_name": "Prueba compacta con nombre de partida prolongado"}


func _run() -> void:
	var mesh := Logo.emblem()
	_check(mesh is ArrayMesh and mesh == Logo.emblem(), "Logo es geometría compartida y almacenada una sola vez")
	var arrays := mesh.surface_get_arrays(0)
	var red := false
	var cyan := false
	for color in arrays[Mesh.ARRAY_COLOR]:
		red = red or (color.r > color.b * 1.5)
		cyan = cyan or (color.b > color.r * 1.5 and color.g > color.r * 1.5)
	_check(red and cyan, "La geometría conserva los elementos rojos y celestes del emblema")
	var in_bounds := true
	for vertex in arrays[Mesh.ARRAY_VERTEX]:
		in_bounds = in_bounds and vertex.x >= 0 and vertex.y >= 0 and vertex.x <= Logo.SIDE and vertex.y <= Logo.SIDE
	_check(in_bounds, "El emblema respeta su rejilla de píxeles")
	viewport = SubViewport.new()
	root.add_child(viewport)
	game = RecentGame.new()
	viewport.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for dimensions in [Vector2i(900, 640), Vector2i(1152, 720), Vector2i(1600, 900)]:
		viewport.size = dimensions
		for scale in [0.8, 1.0, 1.2]:
			game.settings["font_scale"] = scale
			game._show_main()
			await _inspect("inicio")
			var logo = game.find_child("SisInfLogo", true, false)
			_check(logo.get_script() == Logo and not logo is TextureRect, "Logo de fondo sin imagen")
			var panel = game.find_child("MainMenuPanel", true, false)
			var style = panel.get_theme_stylebox("panel")
			_check(style.chunk_size >= 32 and style.fracture_depth >= 24, "Ruptura con bloques grandes y profundidad")
			var max_width := 0.0
			var buttons := []
			for node in panel.find_children("*", "Button", true, false):
				max_width = maxf(max_width, node.get_theme_font("font").get_string_size(node.text, HORIZONTAL_ALIGNMENT_LEFT, -1, node.get_theme_font_size("font_size")).x + 36)
				buttons.append(node)
			for button in buttons:
				_check(absf(button.size.x - max_width) < 2, "Botón limitado al contenido más largo")
	game.settings["font_scale"] = 1.0
	game.draft_player_name = "Prueba compacta"
	game.active_slot = 1
	game._create_solo_save("sistemas", "gestion_sistemas")
	var before := JSON.stringify(game.simulation.snapshot())
	for section in ["resumen", "materias", "malla", "tramites", "historial", "auxiliatura", "graduacion"]:
		game._show_campus_section(section)
		await process_frame
		_check(game._card_style(false).fractured, "Ruptura compartida en " + section)
		_check(not game._button_style(false, "normal").fractured and not game._input_style(false).fractured, "Los controles conservan límites legibles")
		_check(game.find_children("FractureEffects", "Node", true, false).size() == 1, "Un único reloj para los efectos")
		game.settings["animations"] = true
		game._sync_ambient()
		game._effects._process(0.2)
		var visible_phase := false
		for entry in game._effects.surfaces:
			visible_phase = visible_phase or entry["style"].terminal_phase >= 0
		_check(visible_phase and game._effects.running, "Las letras ambientales avanzan con animación")
		game.settings["animations"] = false
		game._sync_ambient()
		var stopped := true
		for entry in game._effects.surfaces:
			stopped = stopped and entry["style"].terminal_phase < 0
		_check(stopped and not game._effects.is_processing(), "Movimiento reducido detiene todos los fondos verdes")
	game.settings["animations"] = true
	game.settings["low_performance"] = true
	game._sync_ambient()
	_check(not game._effects.running and not game._effects.is_processing(), "Bajo consumo apaga el reloj de efectos")
	_check(before == JSON.stringify(game.simulation.snapshot()), "El diseño no altera notas ni trámites")
	_check(not FileAccess.file_exists("res://assets/campus_vector.svg"), "Recurso antiguo sin uso eliminado")
	game.queue_free()
	viewport.queue_free()
	await process_frame
	for failure in failures:
		push_error(failure)
	print("CAVE_VISUALS_TESTS: %d assertions, %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)
