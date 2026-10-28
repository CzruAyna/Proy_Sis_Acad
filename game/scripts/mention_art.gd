extends Control

const Neon = preload("res://scripts/neon_visuals.gd")

var mention_id := ""
var ink := Color("#78a9bc")


func setup(selected_id: String, accent: Color) -> void:
	mention_id = selected_id
	ink = accent
	custom_minimum_size = Vector2(148, 104)
	size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	queue_redraw()


func _draw() -> void:
	var bounds := Rect2(Vector2(2, 2), Vector2(maxf(size.x - 4, 120), maxf(size.y - 4, 88)))
	draw_style_box(_frame(), bounds)
	if mention_id == "desarrollo_sw":
		_draw_code(bounds)
	elif mention_id == "telematica":
		_draw_router(bounds)
	elif mention_id == "gestion_informacion":
		_draw_database(bounds)
	elif mention_id == "modelamiento_optimizacion":
		_draw_optimization(bounds)
	else:
		_draw_management(bounds)


func _frame() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#040a15")
	style.shadow_color = Color(ink, 0.32)
	style.shadow_size = 8
	style.border_color = Color(ink, 0.75)
	style.set_border_width_all(2)
	style.set_corner_radius_all(14)
	return style


func _draw_code(bounds: Rect2) -> void:
	var lines := ["C++  vector<int> a;", "PY   for x in datos:", "SQL  SELECT * FROM", "HTML <section>campus"]
	for index in range(lines.size()):
		var y := bounds.position.y + 23.0 + float(index) * 18.0
		draw_circle(Vector2(bounds.position.x + 12, y - 4), 2.5, ink if index == 0 else Color(ink, 0.6))
		draw_string(ThemeDB.fallback_font, Vector2(bounds.position.x + 21, y), lines[index], HORIZONTAL_ALIGNMENT_LEFT, bounds.size.x - 28, 9, ink.lightened(0.65))


func _draw_router(bounds: Rect2) -> void:
	var center := bounds.get_center() + Vector2(0, 14)
	var router := Rect2(center - Vector2(35, 12), Vector2(70, 26))
	var router_style := StyleBoxFlat.new()
	router_style.bg_color = Color(ink, 0.2)
	router_style.border_color = ink
	router_style.set_border_width_all(2)
	router_style.set_corner_radius_all(7)
	draw_style_box(router_style, router)
	draw_line(router.position + Vector2(13, 0), router.position + Vector2(4, -18), ink, 2.0)
	draw_line(router.position + Vector2(57, 0), router.position + Vector2(66, -18), ink, 2.0)
	for index in range(3):
		draw_circle(router.position + Vector2(20 + float(index) * 13, 14), 2.2, ink.lightened(0.3))
	for radius in [45.0, 58.0]:
		draw_arc(center, radius, PI * 1.16, PI * 1.84, 32, Color(ink, 0.7), 1.3, true)
		draw_arc(center, radius, -PI * 0.84, -PI * 0.16, 32, Color(ink, 0.7), 1.3, true)


func _draw_database(bounds: Rect2) -> void:
	var center := bounds.get_center()
	var width := 52.0
	var top := center.y - 28.0
	for layer in range(3):
		var y := top + float(layer) * 20.0
		draw_rect(Rect2(center.x - width * 0.5, y, width, 17), Color(ink, 0.15 + float(layer) * 0.04), true)
		draw_arc(Vector2(center.x, y + 1), width * 0.5, PI, TAU, 32, ink, 1.5, true)
		draw_arc(Vector2(center.x, y + 16), width * 0.5, 0, PI, 32, ink, 1.2, true)
	draw_string(ThemeDB.fallback_font, center + Vector2(37, 5), "SQL · datos", HORIZONTAL_ALIGNMENT_LEFT, 80, 10, ink.lightened(0.65))


func _draw_optimization(bounds: Rect2) -> void:
	var left := bounds.position + Vector2(22, bounds.size.y - 21)
	var width := bounds.size.x - 43.0
	var height := bounds.size.y - 47.0
	Neon.line(self, left, left + Vector2(width, 0), Color(ink, 0.7), 1.0)
	Neon.line(self, left, left - Vector2(0, height), Color(ink, 0.7), 1.0)
	var points := PackedVector2Array()
	for index in range(33):
		var t := float(index) / 32.0
		points.append(Vector2(left.x + t * width, left.y - (0.18 + (t - 0.62) * (t - 0.62) * 2.8) * height))
	Neon.path(self, points, ink, 2.0)
	draw_line(left + Vector2(width * 0.25, -height * 0.34), left + Vector2(width * 0.7, -height * 0.34), ink.lightened(0.35), 1.3)
	draw_circle(left + Vector2(width * 0.62, -height * 0.34), 4, ink.lightened(0.35))
	draw_string(ThemeDB.fallback_font, bounds.position + Vector2(9, 16), "minimizar costo · restricciones", HORIZONTAL_ALIGNMENT_LEFT, bounds.size.x - 18, 9, ink.lightened(0.65))


func _draw_management(bounds: Rect2) -> void:
	var left := bounds.position + Vector2(13, bounds.size.y - 19)
	var heights := [22.0, 39.0, 29.0, 54.0]
	for index in range(heights.size()):
		var x := left.x + float(index) * 25.0
		draw_rect(Rect2(x, left.y - heights[index], 13, heights[index]), Color(ink, 0.2), true)
		draw_rect(Rect2(x, left.y - heights[index], 13, heights[index]), ink, false, 1.0)
		if index > 0:
			draw_line(Vector2(x - 12, left.y - heights[index - 1] - 5), Vector2(x + 5, left.y - heights[index] - 5), ink.lightened(0.35), 1.5, true)
	draw_string(ThemeDB.fallback_font, bounds.position + Vector2(10, 16), "procesos · indicadores · decisiones", HORIZONTAL_ALIGNMENT_LEFT, bounds.size.x - 20, 9, ink.lightened(0.65))
