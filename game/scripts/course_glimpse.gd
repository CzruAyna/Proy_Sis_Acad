extends Control

var _theme: Dictionary
var _kind: String
var _phase := 0.0
var _tick := 0.0
var _animate := false


func configure(code: String, colors: Dictionary, animate: bool) -> void:
	_theme = colors
	_kind = code.get_slice(" ", 0)
	_animate = animate
	custom_minimum_size.y = 88
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _ready() -> void:
	set_process(_animate)


func _process(delta: float) -> void:
	_phase = fposmod(_phase + delta * 0.48, 1.0)
	_tick += delta
	if _tick >= 1.0 / 14.0:
		_tick = 0.0
		queue_redraw()


func _draw() -> void:
	var primary: Color = _theme["neon"]
	var secondary: Color = _theme["secondary"]
	var highlight: Color = _theme["highlight"]
	var area := Rect2(Vector2.ZERO, size)
	draw_rect(area, Color("#10141d"))
	for x in range(12, int(size.x), 16):
		for y in range(12, int(size.y), 16):
			draw_rect(Rect2(x, y, 2, 2), Color(secondary, 0.22))
	var extent := minf(size.x - 32, 310.0)
	var origin := Vector2((size.x - extent) / 2.0, size.y * 0.5)
	if _kind in ["MAT", "FIS"]:
		draw_line(origin, origin + Vector2(extent, 0), Color(secondary, 0.5), 1)
		var trace := PackedVector2Array()
		for index in range(33):
			var x := index / 32.0
			var y := sin(x * TAU - _phase * TAU) * 24
			trace.append((origin + Vector2(x * extent, y)).round())
		draw_polyline(trace, primary, 2)
		_pixel(trace[roundi(_phase * 31)], highlight)
	elif _kind == "QMC":
		var center := size * 0.5
		var neck := center + Vector2(-12, -29)
		var outline := PackedVector2Array([neck, neck + Vector2(24, 0), center + Vector2(9, -11), center + Vector2(27, 20), center + Vector2(23, 28), center + Vector2(-23, 28), center + Vector2(-27, 20), center + Vector2(-9, -11), neck])
		draw_polyline(outline, secondary, 2)
		draw_colored_polygon(PackedVector2Array([center + Vector2(-14, 4), center + Vector2(14, 4), center + Vector2(23, 22), center + Vector2(-23, 22)]), Color(primary, 0.58))
		for index in range(4):
			var height := fposmod(_phase + index * 0.23, 1.0)
			_pixel((center + Vector2(index * 9 - 13, 20 - height * 17)).round(), highlight)
	else:
		var points := PackedVector2Array([origin, origin + Vector2(extent * 0.25, -20), origin + Vector2(extent * 0.5, 13), origin + Vector2(extent * 0.75, -20), origin + Vector2(extent, 0)])
		draw_polyline(points, secondary, 2)
		for point in points:
			draw_rect(Rect2(point.round() - Vector2.ONE * 6, Vector2.ONE * 12), primary)
			draw_rect(Rect2(point.round() - Vector2.ONE * 4, Vector2.ONE * 8), Color("#151c25"))
		var step := _phase * 4.0
		_pixel(points[floori(step)].lerp(points[floori(step) + 1], fposmod(step, 1)).round(), highlight)


func _pixel(point: Vector2, color: Color) -> void:
	draw_rect(Rect2(point - Vector2.ONE * 3, Vector2.ONE * 6), color)
