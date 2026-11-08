extends "res://tests/test_cave_visuals.gd"

const Cave = preload("res://scripts/menu_cave.gd")


func _run() -> void:
	var box := Rect2(0, 0, 352, 560)
	var last_count := 100000
	for phase in [0.0, 20.0, 36.0, 52.0, 76.0, 96.0]:
		var shape := Cave.frame(box, 32, 24, phase)
		_check(shape["cells"].size() <= last_count, "La abertura pierde bloques sin regenerarlos al esperar")
		last_count = shape["cells"].size()
		_check(shape["debris"].size() <= Cave.MAX_DEBRIS, "Los fragmentos tienen un límite fijo")
	_check(last_count == 0, "La espera prolongada acaba de desintegrar el fondo")
	_check(not Cave.frame(box, 32, 24, -1)["cells"].is_empty(), "Movimiento reducido conserva una silueta estática")
	var initial := Cave.frame(box, 32, 24, 0)
	var repeated := 0
	for row in range(3, initial["spans"].size() - 6):
		if initial["spans"][row] == initial["spans"][row + 6]:
			repeated += 1
	_check(repeated < initial["spans"].size() / 2, "El contorno no repite el antiguo periodo de tres filas")
	var prompt := Cave.stream_frame(560, 0.2)
	var typed := Cave.stream_frame(560, 1.4)
	_check(typed["lines"][0].length() > prompt["lines"][0].length(), "Primero se escribe la orden")
	var output := Cave.stream_frame(560, 20)
	_check(output["printed"] > 3000 and output["lines"].size() <= Cave.MAX_LINES, "Miles de líneas impresas con memoria visual limitada")
	_check(Cave.stream_frame(560, 20.1)["lines"] != output["lines"], "El árbol continúa imprimiéndose, sin quedarse en una lámina fija")
	_check(not Cave.stream_frame(560, 27)["linux"] and Cave.stream_frame(560, 27)["command"].contains("tree /F /A"), "Alterna a la orden de Windows")
	_check(Cave.stream_frame(560, 48.2)["lines"][0].length() < 30, "La siguiente ejecución vuelve a escribir la orden")
	viewport = SubViewport.new()
	root.add_child(viewport)
	game = RecentGame.new()
	viewport.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game.settings["animations"] = true
	for dimensions in [Vector2i(900, 640), Vector2i(1152, 720), Vector2i(1600, 900)]:
		viewport.size = dimensions
		for scale in [0.8, 1.0, 1.2]:
			game.settings["font_scale"] = scale
			game._show_main()
			await _inspect("inicio")
			game._effects.set_process(false)
			_check(game.find_child("MenuTerminalBackground", true, false) == null, "La terminal no añade un costado")
			var panel = game.find_child("MainMenuPanel", true, false)
			_check(panel.get_theme_stylebox("panel").animated_cave, "La terminal pertenece al fondo del mismo menú")
			_check(game._effects.actors.size() == 1, "Los símbolos utilizan el reloj común")
			var buttons := panel.find_children("*", "Button", true, false)
			var positions := {}
			for button in buttons:
				positions[button.get_instance_id()] = button.get_global_rect()
				for state in ["normal", "hover", "pressed", "disabled"]:
					var style = button.get_theme_stylebox(state)
					_check(style.translucent and style.bg_color.a >= 0.3 and style.bg_color.a < 0.75 and style.shadow_size == 0, "Botón translúcido sin relleno o sombra opaca debajo")
			for phase in [0.4, 18.0, 44.0, 78.0, 96.0]:
				game._effects.elapsed = phase
				game._effects._process(0.06)
				await process_frame
				for button in buttons:
					_check(button.get_global_rect() == positions[button.get_instance_id()] and button.is_visible_in_tree(), "La ruptura no mueve ni elimina una acción")
			await _inspect("inicio")
	var logo = game.find_child("SisInfLogo", true, false)
	_check(logo.effect_phase > 90, "La animación llega al emblema")
	game.settings["animations"] = false
	game._sync_ambient()
	_check(logo.effect_phase < 0 and not game._effects.running, "Movimiento reducido detiene emblema, escritura y destrucción")
	game.settings["animations"] = true
	game.settings["low_performance"] = true
	game._sync_ambient()
	_check(logo.effect_phase < 0 and not game._effects.is_processing(), "Bajo consumo mantiene estáticos todos los efectos nuevos")
	game.settings["low_performance"] = false
	game.settings["animations"] = false
	var options: Button
	for button in game.find_children("*", "Button", true, false):
		if button.text == "Opciones":
			options = button
	options.pressed.emit()
	await _settle()
	_check(game.find_child("OptionsCategories", true, false) != null, "La acción de opciones sigue funcionando tras la destrucción")
	game.queue_free()
	viewport.queue_free()
	await process_frame
	for failure in failures:
		push_error(failure)
	print("DYNAMIC_MENU_TESTS: %d assertions, %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)
