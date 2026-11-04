extends "res://tests/test_compact_navigation.gd"

const Map = preload("res://scripts/campus_map.gd")
const World = preload("res://scripts/campus_world.gd")


func _open_station(station: Dictionary, code: int) -> void:
	game.exploration_ui.show_world()
	var world = game.find_child("CampusWorld", true, false)
	world.enter_building("sis_e")
	world.player = station["approach"]
	await _settle()
	if code == 0:
		for control in game.find_children("*", "Button", true, false):
			if control.text == "Interactuar [E]":
				var click := InputEventMouseButton.new()
				click.position = control.get_global_rect().get_center()
				click.global_position = click.position
				click.button_index = MOUSE_BUTTON_LEFT
				click.pressed = true
				viewport.push_input(click, true)
				click.pressed = false
				viewport.push_input(click, true)
				break
	else:
		var key := InputEventKey.new()
		key.physical_keycode = code
		key.pressed = true
		viewport.push_input(key, true)
		key.pressed = false
		viewport.push_input(key, true)
	await _settle()
	var board = game.find_child("MinigameBoard", true, false)
	_check(board != null and board.model.game_id == station["id"], "Entrada %d abre %s" % [code, station["id"]])
	_check(game.exploration_ui.minigames.sessions[station["id"]].phase != "FINISHED", "La entrada no juega ni abandona la partida")


func _run() -> void:
	var sprite := World.new()
	sprite.player = Vector2(240, 180)
	for direction in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
		sprite.facing = direction
		var rect: Rect2 = sprite.player_sprite_rect()
		_check(rect.position == Vector2(228, 150), "Mirar en cualquier dirección conserva el anclaje ampliado del sprite")
		_check(absf(rect.size.x) == 24 and rect.size.y == 32, "Reflejar conserva el tamaño ampliado")
	sprite.free()
	viewport = SubViewport.new()
	viewport.size = Vector2i(1152, 720)
	root.add_child(viewport)
	game = TestGame.new()
	viewport.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game._show_exploration()
	game.exploration_ui.guest_name = "Prueba de entrada"
	for station in Map.game_stations():
		for code in [KEY_E, KEY_ENTER, 0]:
			await _open_station(station, code)
	for code in [KEY_P, KEY_M]:
		game.exploration_ui.show_world()
		await _settle()
		var key := InputEventKey.new()
		key.physical_keycode = code
		key.pressed = true
		viewport.push_input(key, true)
		await _settle()
		_check(game.find_child("CampusWorld", true, false) == null, "P/M cambia de pantalla al terminar el despacho de entrada")
		key.pressed = false
		viewport.push_input(key, true)
	game.queue_free()
	viewport.queue_free()
	await process_frame
	print("EXPLORATION_HANDOFF: %d assertions, %d failures" % [assertions, failures.size()])
	for failure in failures:
		push_error(failure)
	quit(0 if failures.is_empty() else 1)
