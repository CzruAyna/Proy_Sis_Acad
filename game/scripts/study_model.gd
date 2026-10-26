extends Control

var subject_name := ""
var factor := 0.5
var font_scale := 1.0


func _draw() -> void:
	if size.x < 60 or size.y < 20:
		return
	var bounds := Rect2(8, 4, size.x - 16, maxf(size.y - 12, 100))
	draw_rect(bounds, Color("#f6f0df"), true)
	draw_rect(bounds, Color("#d5c9b3"), false, 1.0)
	var name := subject_name.to_lower()
	var color := Color("#5d8c72")
	if name.contains("física") or name.contains("fisica") or name.contains("circuit"):
		color = Color("#c17650")
		_draw_physics(bounds, color)
	elif name.contains("red") or name.contains("telem") or name.contains("comunicación") or name.contains("comunicacion"):
		color = Color("#4e829c")
		_draw_network(bounds, color)
	elif name.contains("program") or name.contains("algorit") or name.contains("software") or name.contains("dato"):
		color = Color("#8871a1")
		_draw_steps(bounds, color)
	else:
		_draw_system(bounds, color)


func _draw_physics(bounds: Rect2, color: Color) -> void:
	var origin := bounds.position + Vector2(28, bounds.size.y - 13)
	draw_line(origin, origin + Vector2(bounds.size.x - 46, 0), Color("#92907f"), 1.0)
	draw_line(origin, origin - Vector2(0, bounds.size.y - 20), Color("#92907f"), 1.0)
	var points := PackedVector2Array()
	for index in range(41):
		var t := float(index) / 40.0
		points.append(origin + Vector2(t * (bounds.size.x - 50), -t * factor * (bounds.size.y - 27)))
	draw_polyline(points, color, 3.0, true)
	draw_string(ThemeDB.fallback_font, bounds.position + Vector2(8, 18), "Velocidad: %d · distancia / tiempo" % int(factor * 100), HORIZONTAL_ALIGNMENT_LEFT, size.x - 30, int(12 * font_scale), color)


func _draw_network(bounds: Rect2, color: Color) -> void:
	var center := bounds.get_center()
	var radius := 22.0
	var active := clampi(int(round(factor * 5.0)), 1, 4)
	var positions := [center, center + Vector2(-bounds.size.x * 0.3, -10), center + Vector2(bounds.size.x * 0.3, -10), center + Vector2(-bounds.size.x * 0.3, 18), center + Vector2(bounds.size.x * 0.3, 18)]
	for index in range(1, positions.size()):
		draw_line(positions[0], positions[index], Color(color, 0.8 if index <= active else 0.12), 2.0, true)
	for index in range(positions.size()):
		draw_circle(positions[index], radius * (0.48 if index == 0 else 0.34), color if index == 0 else color.lightened(0.35))
		draw_circle(positions[index], radius * (0.48 if index == 0 else 0.34), Color("#fffaf0"), false, 2.0)
	draw_string(ThemeDB.fallback_font, bounds.position + Vector2(8, 18), "%d enlaces activos" % active, HORIZONTAL_ALIGNMENT_LEFT, size.x - 30, int(12 * font_scale), color)


func _draw_steps(bounds: Rect2, color: Color) -> void:
	var gap := 12.0
	var box_width := (bounds.size.x - gap * 4.0 - 30.0) / 3.0
	var y := bounds.position.y + bounds.size.y * 0.5 - 15.0
	var input_value := int(round(factor * 10.0))
	var labels := ["Dato: %d" % input_value, "Multiplicar × 2", "Resultado: %d" % (input_value * 2)]
	for index in range(3):
		var rect := Rect2(bounds.position.x + 12.0 + float(index) * (box_width + gap), y, box_width, 30)
		draw_style_box(_box_style(color.lightened(float(index) * 0.12)), rect)
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(5, 19), labels[index], HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 10.0, int(12 * font_scale), Color("#fffaf0"))
		if index < 2:
			var arrow_start := Vector2(rect.end.x + 2, y + 15)
			var arrow_end := arrow_start + Vector2(gap - 4, 0)
			draw_line(arrow_start, arrow_end, color, 2.0)
			draw_colored_polygon(PackedVector2Array([arrow_end, arrow_end - Vector2(5, 3), arrow_end - Vector2(5, -3)]), color)
	draw_string(ThemeDB.fallback_font, bounds.position + Vector2(8, 18), "El mismo procedimiento transforma distintos datos", HORIZONTAL_ALIGNMENT_LEFT, size.x - 30, int(12 * font_scale), color)


func _draw_system(bounds: Rect2, color: Color) -> void:
	var center_y := bounds.position.y + bounds.size.y * 0.62
	var start_x := bounds.position.x + 34.0
	var width := bounds.size.x - 68.0
	var points := PackedVector2Array()
	for index in range(33):
		var t := float(index) / 32.0
		var demand := 0.25 + 0.12 * sin(t * TAU * (1.0 + factor * 2.0))
		var capacity := 0.2 + factor * 0.38
		var backlog := clampf(demand - capacity, -0.35, 0.35)
		points.append(Vector2(start_x + t * width, center_y - backlog * bounds.size.y))
	draw_line(Vector2(start_x, center_y), Vector2(start_x + width, center_y), Color("#aaa18f"), 1.0, true)
	draw_polyline(points, color, 3.0, true)
	draw_string(ThemeDB.fallback_font, bounds.position + Vector2(8, 18), "Capacidad disponible: %d%%" % int(factor * 100), HORIZONTAL_ALIGNMENT_LEFT, size.x - 30, int(12 * font_scale), color)


func _box_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(6)
	return style
