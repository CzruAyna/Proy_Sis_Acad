extends "res://tests/capture_frontend.gd"
const Map = preload("res://scripts/campus_map.gd")
const RoomArt = preload("res://scripts/campus_room_art.gd")
const Roads = preload("res://scripts/campus_roads.gd")
const Land = preload("res://scripts/campus_landscape.gd")

class RoomPlate extends Control:
	var id := ""
	var room := ""
	func _draw() -> void:
		var layout := Map.room_layout(id, room)
		var extent: Vector2 = layout["size"]
		var factor := minf((size.x - 64) / extent.x, (size.y - 104) / extent.y)
		draw_rect(Rect2(Vector2.ZERO, size), Color("#10191f"))
		draw_string(RoomArt.FONT, Vector2(32, 32), Map.building(id)["name"] + " / " + room, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#e6e5c7"))
		draw_string(RoomArt.FONT, Vector2(32, 60), "Recreación pixel art · proporciones ilustrativas, no plano institucional", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#a9beb6"))
		draw_set_transform(Vector2(32, 84), 0, Vector2.ONE * factor)
		RoomArt.draw(self, layout, room)
		draw_set_transform(Vector2.ZERO)

class RoadPlate extends Control:
	var center := Land.at(47.7, 33)
	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color("#ad9b7c"))
		draw_set_transform(size * 0.5 - center, 0, Vector2.ONE)
		Roads.draw(self, Rect2(center - size * 0.5, size))


func _run() -> void:
	target = "res://.test-artifacts/nov6-diseno/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(target))
	root.size = Vector2i(1152, 720)
	root.content_scale_size = root.size
	game = PreviewGame.new()
	root.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game._show_main()
	await _capture("01-inicio")
	game._show_play()
	await _capture("02-jugar")
	game._show_simulate()
	await _capture("03-simular")
	game._show_exploration()
	game.exploration_ui.guest_name = "Visita FNI"
	game.exploration_ui.show_world()
	var world = game.find_child("CampusWorld", true, false)
	world.enter_room("sis_e", "SIS E")
	await _capture("06-sala-juegos")
	game.exploration_ui.show_map()
	await _capture("04-mapa-orientado")
	game.queue_free()
	await process_frame
	root.size = Vector2i(1600, 1120)
	root.content_scale_size = root.size
	for pair in [["matematicas", "CU-32"], ["sis_c", "CU-SIC4"], ["sis_a", "LSIA-1"], ["quimica_lab", "CU-L-3"], ["fisica", "CU-19"], ["biblioteca", "MEC-5"], ["comedor", "Comedor"], ["posta", "Posta sanitaria"], ["admin_sis", "Administración Sistemas"], ["fis_mat", "CU-106"]]:
		var plate := RoomPlate.new()
		plate.id = pair[0]
		plate.room = pair[1]
		plate.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		root.add_child(plate)
		plate.size = root.size
		await _capture("ambiente-" + pair[0])
		plate.queue_free()
		await process_frame
	root.size = Vector2i(1000, 600)
	root.content_scale_size = root.size
	var road := RoadPlate.new()
	root.add_child(road)
	road.size = root.size
	await _capture("05-empalme")
	var image := root.get_texture().get_image()
	var valid := true
	for offset in [Vector2.ZERO, Vector2(-18, -18), Vector2(18, 18), Vector2(26, 0)]:
		var sample: Color = image.get_pixelv(Vector2i(road.size * 0.5 + offset))
		valid = valid and sample.is_equal_approx(Roads.SURFACE)
	print("ROAD_JUNCTION_RASTER: ", valid)
	road.queue_free()
	await process_frame
	quit(0 if valid else 1)
