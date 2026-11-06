extends SceneTree
## Review sheets generated from the current game's renderer and map data.
const Map = preload("res://scripts/campus_map.gd")
const Land = preload("res://scripts/campus_landscape.gd")
const Terrain = preload("res://scripts/campus_terrain.gd")
const Grid = preload("res://scripts/campus_grid.gd")
const Compass = preload("res://scripts/campus_compass.gd")
const FONT = preload("res://assets/fonts/campus_pixel.fnt")
const OUTPUT := "res://.test-artifacts/mapa-8x8/"
const PAGE_SIZE := Vector2i(1600, 1520)
const MAP_ORIGIN := Vector2(32, 100)
const FACTOR := 1.0
const HALF := Grid.CELL_SIZE
var viewport: SubViewport
var sheet: Control


class AtlasCanvas extends "res://scripts/campus_world.gd":
	var region := Grid.bounds(0, 0)
	var quadrant := 0
	var features: Array[Dictionary] = []
	var preview: Texture2D
	var occupied: Array[Rect2] = []

	func _ready() -> void:
		super._ready()
		paused = true
		animations_enabled = false
		set_process(false)


	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color("#10191f"))
		if preview != null:
			_draw_preview()
			return
		draw_set_transform(MAP_ORIGIN - region.position * FACTOR, 0, Vector2.ONE * FACTOR)
		_draw_campus(region)
		draw_set_transform(Vector2.ZERO)
		var edge := MAP_ORIGIN + region.size * FACTOR
		for mask in [Rect2(0, 0, size.x, MAP_ORIGIN.y), Rect2(0, edge.y, size.x, size.y - edge.y), Rect2(0, 0, MAP_ORIGIN.x, size.y), Rect2(edge.x, 0, size.x - edge.x, size.y)]:
			draw_rect(mask, Color("#10191f"))
		draw_string(FONT, Vector2(32, 36), "SIS-INF / CELDA " + Grid.code(quadrant / 8, quadrant % 8) + " / MATRIZ 8×8", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#e7efdc"))
		draw_string(FONT, Vector2(32, 69), "1536 × 1088 unidades por celda · 06/11/2026 · diseño por corregir", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#acc4bd"))
		Compass.draw(self, Vector2(size.x - 54, 48), 12)
		_draw_grid()
		occupied.clear()
		for item in features:
			_draw_pin(item)
		_draw_legend()


	func _draw_grid() -> void:
		var area := Rect2(MAP_ORIGIN, region.size * FACTOR)
		for step in range(5):
			var x := area.position.x + area.size.x * step / 4
			var y := area.position.y + area.size.y * step / 4
			draw_line(Vector2(x, area.position.y), Vector2(x, area.end.y), Color(1, 1, 1, 0.17), 2)
			draw_line(Vector2(area.position.x, y), Vector2(area.end.x, y), Color(1, 1, 1, 0.17), 2)
			var px := int(region.position.x + region.size.x * step / 4)
			var py := int(region.position.y + region.size.y * step / 4)
			var label_x := clampf(x - 25, area.position.x, area.end.x - 75)
			draw_rect(Rect2(label_x - 3, area.position.y + 4, 79, 27), Color(0, 0, 0, 0.8))
			draw_string(FONT, Vector2(label_x, area.position.y + 25), str(px), HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.WHITE)
			if step > 0:
				var label_y := minf(y, area.end.y - 5)
				draw_rect(Rect2(area.position.x + 4, label_y - 25, 79, 27), Color(0, 0, 0, 0.8))
				draw_string(FONT, Vector2(area.position.x + 8, label_y - 4), str(py), HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.WHITE)
		draw_rect(area, Color("#a7c4bd"), false, 2)


	func _draw_pin(item: Dictionary) -> void:
		var point: Vector2 = MAP_ORIGIN + (Vector2(item["pin"]) - region.position) * FACTOR
		var extent := Vector2(78, 34)
		var area := Rect2(point - extent * 0.5, extent)
		for offset in [Vector2.ZERO, Vector2(0, -44), Vector2(0, 44), Vector2(88, 0), Vector2(-88, 0), Vector2(88, -44), Vector2(-88, 44)]:
			var trial := Rect2(area.position + offset, extent)
			if not Rect2(MAP_ORIGIN + Vector2(5, 36), region.size * FACTOR - Vector2(10, 42)).encloses(trial):
				continue
			var collision := false
			for previous in occupied:
				if previous.grow(5).intersects(trial):
					collision = true
					break
			if not collision:
				area = trial
				break
		occupied.append(area)
		draw_line(point, area.get_center(), Color("#f0ebc2"), 2)
		draw_rect(Rect2(point - Vector2.ONE * 4, Vector2.ONE * 8), Color("#fff8c9"))
		draw_rect(area, Color(0, 0, 0, 0.9))
		draw_rect(area, Color("#a9c5bc"), false, 2)
		draw_string(FONT, area.position + Vector2(8, 25), item["code"], HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color.WHITE)


	func _draw_legend() -> void:
		var top := MAP_ORIGIN.y + region.size.y * FACTOR + 34
		draw_string(FONT, Vector2(32, top), "REFERENCIAS / indica celda y código del elemento", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#e9efdb"))
		for index in range(features.size()):
			var column := index % 2
			var row := index / 2
			var p := Vector2(32 + column * 768, top + 38 + row * 24)
			draw_string(FONT, p, str(features[index]["code"]) + "  " + str(features[index]["label"]), HORIZONTAL_ALIGNMENT_LEFT, 748, 17, Color("#cbd7c7"))
		draw_string(FONT, Vector2(32, 1475), "Coordenadas en unidades de juego, no metros. X → derecha; Y → abajo.", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#a8beb8"))
		draw_string(FONT, Vector2(32, 1504), "«continúa» cruza el corte. N → derecha; S → izquierda; E → abajo; O → arriba.", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#a8beb8"))


	func _draw_preview() -> void:
		draw_string(FONT, Vector2(48, 52), "SIS-INF / MAPA ACTUAL / MATRIZ 8×8", HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color("#e6eedc"))
		draw_string(FONT, Vector2(48, 84), "Misma orientación del plano aportado · distribución por corregir", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#a9c2bb"))
		Compass.draw(self, Vector2(size.x - 54, 48), 12)
		draw_texture_rect(preview, Rect2(48, 108, 1536, 1088), false)
		for row in range(8):
			for column in range(8):
				var p := Vector2(48 + column * 192, 108 + row * 136)
				draw_rect(Rect2(p + Vector2(5, 5), Vector2(56, 30)), Color.BLACK)
				draw_string(FONT, p + Vector2(11, 29), Grid.code(row, column), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)
		for index in range(9):
			draw_line(Vector2(48 + index * 192, 108), Vector2(48 + index * 192, 1196), Color("#ddedd5"), 1)
			draw_line(Vector2(48, 108 + index * 136), Vector2(1584, 108 + index * 136), Color("#ddedd5"), 1)
		draw_string(FONT, Vector2(48, 1234), "A–H: arriba → abajo · 1–8: izquierda → derecha · 1536×1088 unidades/celda", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#c3d4c8"))


func _initialize() -> void:
	_run.call_deferred()


func _features(region: Rect2) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var index := 0
	for block in Map.buildings():
		index += 1
		_add_region(result, region, Rect2(block["rect"]), "B%02d" % index, block["name"], block["id"])
	index = 0
	for row in Map.COURTS:
		index += 1
		var area := Rect2(Vector2(row[1], row[2]) * Map.SIZE / 100, Vector2(row[3], row[4]) * Map.SIZE / 100)
		_add_region(result, region, area, "C%02d" % index, row[0], row[0])
	index = 0
	for shape in Land.LAWNS:
		index += 1
		_add_region(result, region, Terrain._bounds(Land.polygon(shape)), "G%02d" % index, "Jardín / pasto %d" % index, "garden_%d" % index)
	index = 0
	for shape in Land.PARKING:
		index += 1
		_add_region(result, region, Terrain._bounds(Land.polygon(shape)), "P%02d" % index, "Estacionamiento %d" % index, "parking_%d" % index)
	_add_region(result, region, Terrain._bounds(Land.polygon(Land.FOREST)), "V01", "Bosque del ingreso", "bosque")
	_add_region(result, region, Terrain._bounds(Land.polygon(Land.POND)), "A01", "Laguna de Civil", "laguna")
	index = 0
	for item in Land.landmarks():
		index += 1
		_add_point(result, region, item["point"], "M%02d" % index, item["title"], item["id"])
	index = 0
	for item in Land.fountains():
		index += 1
		_add_point(result, region, item["point"], "F%02d" % index, "Fuente " + str(index), item["id"])
	_add_point(result, region, Land.at(50.6, 35.5), "V02", "Asientos FNI", "asientos_fni")
	_add_point(result, region, Map.SPAWN, "I01", "Ingreso / aparición del jugador", "ingreso")
	return result


func _add_point(items: Array[Dictionary], region: Rect2, p: Vector2, code: String, label: String, id: String) -> void:
	if region.has_point(p):
		items.append({"code": code, "label": label, "id": id, "pin": p, "x_percent": snappedf(p.x / Map.SIZE.x * 100, 0.1), "y_percent": snappedf(p.y / Map.SIZE.y * 100, 0.1)})


func _add_region(items: Array[Dictionary], region: Rect2, area: Rect2, code: String, label: String, id: String) -> void:
	if region.intersects(area):
		_add_point(items, region, region.intersection(area).get_center(), code, label + (" (continúa)" if not region.encloses(area) else ""), id)


func _render() -> Image:
	sheet.queue_redraw()
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	for frame in range(3):
		await process_frame
	await RenderingServer.frame_post_draw
	return viewport.get_texture().get_image()


func _save(image: Image, name: String) -> void:
	var status := image.save_png(OUTPUT + name + ".png")
	if status != OK:
		push_error("No se pudo guardar " + name)
		quit(1)
	print("MAP_EXPORT ", name, " ", image.get_size())


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	viewport = SubViewport.new()
	viewport.size = PAGE_SIZE
	viewport.transparent_bg = false
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	root.add_child(viewport)
	sheet = AtlasCanvas.new()
	sheet.size = PAGE_SIZE
	sheet.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	viewport.add_child(sheet)
	var full := Image.create(int(Map.SIZE.x / 2), int(Map.SIZE.y / 2), false, Image.FORMAT_RGBA8)
	var manifest: Dictionary = {"map_id": Map.ID, "date": "2026-11-06", "grid": [8, 8], "cell_size": [HALF.x, HALF.y], "size": [Map.SIZE.x, Map.SIZE.y], "units": "game units, not metres", "orientation": "N right; S left; E down; W up, as specified by user", "cells": []}
	for index in range(64):
		sheet.quadrant = index
		sheet.region = Grid.bounds(index / 8, index % 8)
		sheet.features = _features(sheet.region)
		var output := await _render()
		var code := Grid.code(index / 8, index % 8)
		_save(output, code)
		var map_pixels := output.get_region(Rect2i(Vector2i(MAP_ORIGIN), Vector2i(HALF * FACTOR)))
		map_pixels.resize(int(HALF.x / 2), int(HALF.y / 2), Image.INTERPOLATE_NEAREST)
		full.blit_rect(map_pixels, Rect2i(Vector2i.ZERO, map_pixels.get_size()), Vector2i(Vector2(index % 8, index / 8) * HALF / 2))
		manifest["cells"].append({"id": code, "bounds": [sheet.region.position.x, sheet.region.position.y, HALF.x, HALF.y], "features": sheet.features})
	_save(full, "mapa-completo")
	full.resize(1536, 1088, Image.INTERPOLATE_NEAREST)
	sheet.preview = ImageTexture.create_from_image(full)
	viewport.size = Vector2i(1632, 1272)
	sheet.size = viewport.size
	_save(await _render(), "00-indice")
	var file := FileAccess.open(OUTPUT + "referencias.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest, "\t"))
	file.close()
	sheet.queue_free()
	viewport.queue_free()
	await process_frame
	quit(0)
