extends SceneTree

const Neon = preload("res://scripts/neon_visuals.gd")
const Sprites = preload("res://scripts/pixel_mention_sprite.gd")
class PreviewGame extends "res://tests/test_neon_visuals.gd".PreviewGame:
	func _save_settings() -> void:
		pass

var assertions := 0
var failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _check(value: bool, message: String) -> void:
	assertions += 1
	if not value:
		failures.append(message)


func _run() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1152, 720)
	root.add_child(viewport)
	var game := PreviewGame.new()
	viewport.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game.active_slot = 1
	game.draft_player_name = "Álex Ñúñez"
	for character in "áéíóúÁÉÍÓÚñÑüÜ¿¡←→↑↓↻−+✓":
		_check(Neon.PIXEL_FONT.has_char(character.unicode_at(0)), "La fuente incluye " + character)
	var small := Neon.PIXEL_FONT.get_string_size("Continuar", HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
	var large := Neon.PIXEL_FONT.get_string_size("Continuar", HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
	_check(large > small * 1.3, "El tamaño de las acciones cambia de verdad al ampliar el texto")
	var previous_width := 0.0
	for font_size in [14, 16, 18, 21]:
		var width := Neon.PIXEL_FONT.get_string_size("Continuar", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		_check(width > previous_width, "La fuente escala de forma continua a %d" % font_size)
		previous_width = width
	var images := {}
	for program in game.Catalog.PROGRAMS:
		for mention in game.Catalog.mentions_for_program(program["id"]):
			var texture := Sprites.texture(mention["id"], Neon.career(program["id"])["neon"])
			_check(texture.get_size() == Vector2(32, 24), "Sprite nativo de baja resolución")
			images[hash(texture.get_image().get_data())] = true
			game._create_solo_save(program["id"], mention["id"])
			var initial := JSON.stringify(game.simulation.snapshot())
			for section in ["resumen", "materias", "tramites", "historial", "auxiliatura", "graduacion", "malla"]:
				game._show_campus_section(section)
				await process_frame
				_check(game._card_style(false) is Neon.PixelStyle, "Marco pixel común en " + section)
				_check(game._card_style(false).bg_color.a == 1.0, "Contenido opaco en " + section)
				for button in game.find_children("*", "Button", true, false):
					_check(button.get_theme_font("font") == Neon.PIXEL_FONT, "Acciones con la fuente pixel en " + section)
			_check(JSON.stringify(game.simulation.snapshot()) == initial, "La presentación no cambia reglas ni resultados")
	_check(images.size() == 5, "Cinco sprites distintos")
	game._show_campus_section("malla")
	var graph = game.find_child("ExpandedCurriculumGraph", true, false)
	var sphere: Image = graph._sphere["image"]
	_check(sphere.get_pixel(64, 56) == sphere.get_pixel(71, 63), "La esfera contiene bloques de color, sin interpolación")
	_check(sphere.get_pixel(64, 56).get_luminance() > sphere.get_pixel(140, 145).get_luminance() * 2, "El pixel art conserva luz y profundidad")
	game.settings["animations"] = true
	game._show_options()
	_check(not game._ambient.visible and not game._ambient.is_processing(), "Opciones conserva fondo quieto con animaciones activas")
	var primary = game._button_style(true, "normal")
	var pressed = game._button_style(true, "pressed")
	_check(primary.raised and pressed.pressed and pressed.shadow_size == 0, "Presionar cambia el relieve del botón")
	viewport.queue_free()
	await process_frame
	for failure in failures:
		push_error(failure)
	print("PIXEL_UI_TESTS: %d assertions, %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)
