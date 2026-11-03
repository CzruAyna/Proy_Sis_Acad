extends SceneTree
## Review sheets generated from the current game's renderer and map data.
const Map = preload("res://scripts/campus_map.gd")
const Land = preload("res://scripts/campus_landscape.gd")
const Terrain = preload("res://scripts/campus_terrain.gd")
const FONT = preload("res://assets/fonts/campus_pixel.fnt")
const OUTPUT := "res://.test-artifacts/mapa-cuadrantes/"
const PAGE_SIZE := Vector2i(3200, 2760)
const MAP_ORIGIN := Vector2(64, 144)
const FACTOR := 0.5
const HALF := Map.SIZE / 2
const QUADRANTS := ["Q1 · superior izquierdo", "Q2 · superior derecho", "Q3 · inferior izquierdo", "Q4 · inferior derecho"]
var viewport: SubViewport
var sheet: Control


class AtlasCanvas extends "res://scripts/campus_world.gd":
	var region := Rect2(Vector2.ZERO, Map.SIZE / 2)
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
		draw_string(FONT, Vector2(64, 58), "SIS-INF / " + QUADRANTS[quadrant], HORIZONTAL_ALIGNMENT_LEFT, -1, 34, Color("#e7efdc"))
		draw_string(FONT, Vector2(64, 102), "Mapa actual del juego · 03/11/2026 · esquema por corregir, sin escala topográfica", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color("#acc4bd"))
		_draw_grid()
		occupied.clear()
		for item in features:
			_draw_pin(item)
		_draw_legend()


	func _draw_grid() -> void:
		var area := Rect2(MAP_ORIGIN, region.size * FACTOR)
		for step in range(6):
			var x := area.position.x + area.size.x * step / 5
			var y := area.position.y + area.size.y * step / 5
			draw_line(Vector2(x, area.position.y), Vector2(x, area.end.y), Color(1, 1, 1, 0.17), 2)
			draw_line(Vector2(area.position.x, y), Vector2(area.end.x, y), Color(1, 1, 1, 0.17), 2)
			var px := int(round((region.position.x + region.size.x * step / 5) / Map.SIZE.x * 100))
			var py := int(round((region.position.y + region.size.y * step / 5) / Map.SIZE.y * 100))
			var label_x := clampf(x - 25, area.position.x, area.end.x - 75)
			draw_rect(Rect2(label_x - 3, area.position.y + 4, 79, 27), Color(0, 0, 0, 0.8))
			draw_string(FONT, Vector2(label_x, area.position.y + 25), "%d%%" % px, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
			if step > 0:
				var label_y := minf(y, area.end.y - 5)
				draw_rect(Rect2(area.position.x + 4, label_y - 25, 79, 27), Color(0, 0, 0, 0.8))
				draw_string(FONT, Vector2(area.position.x + 8, label_y - 4), "%d%%" % py, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
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
		var top := MAP_ORIGIN.y + region.size.y * FACTOR + 40
		draw_string(FONT, Vector2(64, top), "REFERENCIAS / indica el cuadrante y el código para corregirlo", HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color("#e9efdb"))
		for index in range(features.size()):
			var column := index % 3
			var row := index / 3
			var p := Vector2(64 + column * 1024, top + 44 + row * 30)
			draw_string(FONT, p, str(features[index]["code"]) + "  " + str(features[index]["label"]), HORIZONTAL_ALIGNMENT_LEFT, 1005, 21, Color("#cbd7c7"))
		draw_string(FONT, Vector2(64, 2702), "X aumenta hacia la derecha; Y hacia abajo. Porcentajes del mapa. «continúa» cruza el corte.", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#a8beb8"))
		draw_string(FONT, Vector2(64, 2736), "La orientación sigue tu plano en pantalla; arriba/abajo no indican norte/sur geográfico.", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#a8beb8"))


	func _draw_preview() -> void:
		draw_string(FONT, Vector2(48, 52), "SIS-INF / MAPA ACTUAL POR CUADRANTES", HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color("#e6eedc"))
		draw_string(FONT, Vector2(48, 84), "Misma orientación del plano aportado · distribución por corregir", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#a9c2bb"))
		draw_texture_rect(preview, Rect2(48, 108, 1536, 1088), false)
		for index in range(4):
			var p := Vector2(48 + index % 2 * 768, 108 + index / 2 * 544)
			draw_rect(Rect2(p + Vector2(12, 12), Vector2(84, 43)), Color.BLACK)
			draw_string(FONT, p + Vector2(24, 44), "Q%d" % (index + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 31, Color.WHITE)
		draw_line(Vector2(816, 108), Vector2(816, 1196), Color("#ddedd5"), 2)
		draw_line(Vector2(48, 652), Vector2(1584, 652), Color("#ddedd5"), 2)
		draw_string(FONT, Vector2(48, 1234), "Q1/Q2: mitad superior · Q3/Q4: mitad inferior · ingreso en Q4", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#c3d4c8"))


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
	var full := Image.create(int(Map.SIZE.x * FACTOR), int(Map.SIZE.y * FACTOR), false, Image.FORMAT_RGBA8)
	var manifest: Dictionary = {"map_id": Map.ID, "date": "2026-11-03", "size": [Map.SIZE.x, Map.SIZE.y], "orientation": "screen coordinates, not geographic north", "quadrants": []}
	for index in range(4):
		sheet.quadrant = index
		sheet.region = Rect2(Vector2(index % 2, index / 2) * HALF, HALF)
		sheet.features = _features(sheet.region)
		var output := await _render()
		_save(output, "Q%d" % (index + 1))
		var map_pixels := output.get_region(Rect2i(Vector2i(MAP_ORIGIN), Vector2i(HALF * FACTOR)))
		full.blit_rect(map_pixels, Rect2i(Vector2i.ZERO, map_pixels.get_size()), Vector2i(Vector2(index % 2, index / 2) * HALF * FACTOR))
		manifest["quadrants"].append({"id": "Q%d" % (index + 1), "title": QUADRANTS[index], "features": sheet.features})
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
