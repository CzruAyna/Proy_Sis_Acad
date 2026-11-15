extends "res://tests/test_compact_navigation.gd"

const Map = preload("res://scripts/campus_map.gd")
const World = preload("res://scripts/campus_world.gd")
const Scale = preload("res://scripts/campus_scale.gd")


func _open_station(station: Dictionary, code: int) -> void:
	game.exploration_ui.show_world()
	var world = game.find_child("CampusWorld", true, false)
	world.enter_building("sis_e")
	world.player = station["approach"]
	await _settle()
	var hint := game.find_child("ExplorationContext", true, false) as Label
	_check(hint != null and hint.text.begins_with("E ·"), "La indicación de la mesa es texto contextual.")
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
		var extent := Scale.OUTDOOR_SIZE
		_check(rect.position == sprite.player - Vector2(extent.x / 2, extent.y - extent.y / 16), "Mirar en cualquier dirección conserva el anclaje exterior")
		_check(rect.size.abs() == extent, "Reflejar conserva la escala exterior")
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
		for code in [KEY_E, KEY_ENTER]:
			await _open_station(station, code)
	for code in [KEY_P, KEY_M, KEY_TAB]:
		game.exploration_ui.show_world()
		await _settle()
		var key := InputEventKey.new()
		key.physical_keycode = code
		key.pressed = true
		viewport.push_input(key, true)
		await _settle()
		_check(game.find_child("CampusWorld", true, false) == null, "P, M o Tab cambia de pantalla al terminar el despacho de entrada")
		key.pressed = false
		viewport.push_input(key, true)
	game.queue_free()
	viewport.queue_free()
	await process_frame
	print("EXPLORATION_HANDOFF: %d assertions, %d failures" % [assertions, failures.size()])
	for failure in failures:
		push_error(failure)
	quit(0 if failures.is_empty() else 1)
