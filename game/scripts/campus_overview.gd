extends Control

const Map = preload("res://scripts/campus_map.gd")
const Neon = preload("res://scripts/neon_visuals.gd")
const Architecture = preload("res://scripts/campus_architecture.gd")
var state: Dictionary = {}
var target_id := ""


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#172c30"))
	var scale_factor := minf((size.x - 30) / Map.SIZE.x, (size.y - 30) / Map.SIZE.y)
	var offset := (size - Map.SIZE * scale_factor) * 0.5
	draw_set_transform(offset, 0, Vector2.ONE * scale_factor)
	draw_rect(Rect2(Vector2.ZERO, Map.SIZE), Color("#617860"))
	for route in Map.routes():
		draw_polyline(route, Color("#bac0aa"), 22, false)
	for row in Map.COURTS:
		var rect := Architecture.court_rect(row)
		draw_rect(rect, Color("#92a06e") if str(row[0]).begins_with("FÚTBOL") else Color("#758f8b"))
		draw_rect(rect.grow(-6), Color("#c6ceb1"), false, 4)
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
		point = Vector2(float(coordinates[0]), float(coordinates[1]))
	draw_rect(Rect2(point - Vector2.ONE * 12, Vector2.ONE * 24), Color("#fff49b"))
	draw_set_transform(Vector2.ZERO)
	draw_string(Neon.PIXEL_FONT, Vector2(14, 20), "FNI · ESQUEMA DE EXPLORACIÓN", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#ecedcf"))
