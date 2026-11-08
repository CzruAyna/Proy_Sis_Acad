extends Control

const Map = preload("res://scripts/campus_map.gd")
const Neon = preload("res://scripts/neon_visuals.gd")
const Architecture = preload("res://scripts/campus_architecture.gd")
const Land = preload("res://scripts/campus_landscape.gd")
const Grid = preload("res://scripts/campus_grid.gd")
const Terrain = preload("res://scripts/campus_terrain.gd")
const Compass = preload("res://scripts/campus_compass.gd")
const Geo = preload("res://scripts/campus_cartography.gd")
const Scale = preload("res://scripts/campus_scale.gd")
var state: Dictionary = {}
var target_id := ""
var grid_font_size := 11


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#172c30"))
	var scale_factor := minf((size.x - 110) / Map.SIZE.x, (size.y - 30) / Map.SIZE.y)
	var offset := (size - Vector2(90, 0) - Map.SIZE * scale_factor) * 0.5
	draw_set_transform(offset, 0, Vector2.ONE * scale_factor)
	Terrain.draw(self, Rect2(Vector2.ZERO, Map.SIZE), 0, false)
	for row in Map.COURTS:
		var rect := Architecture.court_rect(row)
		var polygon := Geo.shape("courts", row[0])
		var color := Color("#92a06e") if str(row[0]).begins_with("FÚTBOL") else Color("#758f8b")
		if polygon.is_empty():
			draw_rect(rect, color)
		else:
			draw_colored_polygon(polygon, color)
	for building in Map.buildings():
		var color := Color("#99a9a1")
		for id in state.get("visited", []):
			if str(id).begins_with(str(building["id"]) + "/"):
				color = Color("#70cfae")
				break
		draw_colored_polygon(building["footprint"], color)
		if building["id"] == target_id:
			draw_rect(Rect2(building["rect"]).grow(12), Color("#64c8ff"), false, 10)
	var point := Map.SPAWN
	var coordinates: Variant = state.get("position", [])
	if coordinates is Array and coordinates.size() == 2:
		point = Map.migrate_outside(Vector2(float(coordinates[0]), float(coordinates[1])), str(state.get("map_id", Map.ID)))
	draw_set_transform(Vector2.ZERO)
	for index in range(9):
		var x := offset.x + Map.SIZE.x * scale_factor * index / 8
		var y := offset.y + Map.SIZE.y * scale_factor * index / 8
		draw_line(Vector2(x, offset.y), Vector2(x, offset.y + Map.SIZE.y * scale_factor), Color(1, 1, 1, 0.22), 1)
		draw_line(Vector2(offset.x, y), Vector2(offset.x + Map.SIZE.x * scale_factor, y), Color(1, 1, 1, 0.22), 1)
	for row in range(8):
		for column in range(8):
			var p := offset + Vector2(column, row) * Grid.CELL_SIZE * scale_factor + Vector2(3, grid_font_size + 2)
			draw_string(Neon.PIXEL_FONT, p, Grid.code(row, column), HORIZONTAL_ALIGNMENT_LEFT, -1, grid_font_size, Color("#f1edcf"))
	for item in Land.landmarks():
		var marker: Vector2 = offset + Vector2(item["point"]) * scale_factor
		draw_rect(Rect2(marker - Vector2.ONE * 3, Vector2.ONE * 6), Color("#d7ad72"))
	var destination := Land.destination(target_id)
	if not destination.is_empty():
		var marker: Vector2 = offset + Vector2(destination["point"]) * scale_factor
		draw_rect(Rect2(marker - Vector2.ONE * 6, Vector2.ONE * 12), Color("#64c8ff"), false, 2)
	var player_point := offset + point * scale_factor
	draw_rect(Rect2(player_point - Vector2.ONE * 4, Vector2.ONE * 8), Color("#fff49b"))
	draw_string(Neon.PIXEL_FONT, Vector2(14, 20), "FNI · CUADRÍCULA 8×8 · " + Grid.at(point), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#ecedcf"))
	Compass.draw(self, Vector2(size.x - 47, 51), grid_font_size)
	var ruler := Vector2(size.x - 84, size.y - 27)
	var ruler_end := ruler + Vector2(50 * Scale.UNITS_PER_METRE * scale_factor, 0)
	draw_line(ruler, ruler_end, Color("#ecedcf"), 2)
	for tick in [ruler, ruler_end]:
		draw_line(tick - Vector2(0, 4), tick + Vector2(0, 4), Color("#ecedcf"), 1)
	draw_string(Neon.PIXEL_FONT, ruler + Vector2(0, 14), "50 m aprox.", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#ecedcf"))
	draw_string(Neon.PIXEL_FONT, Vector2(14, size.y - 5), Geo.CREDIT, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#ecedcf"))
