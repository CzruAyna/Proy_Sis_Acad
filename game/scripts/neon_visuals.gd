extends RefCounted

const MOTIFS := {
	"gestion_sistemas": {"name": "Procesos y decisiones", "formula": "entrada → proceso → resultado", "kind": "management"},
	"gestion_informacion": {"name": "Datos e información", "formula": "datos → información → decisión", "kind": "data"},
	"modelamiento_optimizacion": {"name": "Modelos y optimización", "formula": "min Z = cᵀx     Ax ≤ b", "kind": "optimization"},
	"desarrollo_sw": {"name": "Desarrollo de software", "formula": "idea → código → solución", "kind": "software"},
	"telematica": {"name": "Redes y comunicaciones", "formula": "origen → enlace → destino", "kind": "network"}
}


static func career(program_id: String, mention_id: String = "") -> Dictionary:
	var red := program_id == "informatica"
	return {
		"bg": Color("#100303") if red else Color("#020813"),
		"panel": Color("#240909", 0.95) if red else Color("#07172e", 0.95),
		"accent": Color("#ff2934") if red else Color("#338aff"),
		"neon": Color("#ff393d") if red else Color("#39bcff"),
		"core": Color("#fff0ec") if red else Color("#e4f6ff"),
		"fill": Color("#8f141a") if red else Color("#124a9a"),
		"text": Color("#fff3f1") if red else Color("#edf8ff"),
		"sub": Color("#eebdb8") if red else Color("#b3cde6"),
		"grid": Color("#702322") if red else Color("#1b4975"),
		"program_id": program_id,
		"mention_id": mention_id,
		"motif": MOTIFS.get(mention_id, {"name": "Informática" if red else "Sistemas", "formula": "conecta · explora · construye", "kind": "network" if red else "management"}).duplicate()
	}


static func line(canvas: CanvasItem, start: Vector2, finish: Vector2, color: Color, width: float = 2.0, strength: float = 1.0, economical: bool = false) -> void:
	if not economical:
		canvas.draw_line(start, finish, Color(color, color.a * 0.08 * strength), width + 12.0, true)
	canvas.draw_line(start, finish, Color(color, color.a * 0.22 * strength), width + 5.0, true)
	canvas.draw_line(start, finish, Color(color, color.a * 0.86 * strength), width, true)
	canvas.draw_line(start, finish, Color(color.lerp(Color.WHITE, 0.75), color.a * 0.82 * strength), maxf(0.8, width * 0.32), true)


static func path(canvas: CanvasItem, points: PackedVector2Array, color: Color, width: float = 2.0, economical: bool = false) -> void:
	if points.size() < 2:
		return
	if not economical:
		canvas.draw_polyline(points, Color(color, color.a * 0.08), width + 12.0, true)
	canvas.draw_polyline(points, Color(color, color.a * 0.24), width + 5.0, true)
	canvas.draw_polyline(points, color, width, true)
	canvas.draw_polyline(points, Color(color.lerp(Color.WHITE, 0.7), color.a), maxf(width * 0.3, 0.8), true)


static func ring(canvas: CanvasItem, center: Vector2, radius: float, color: Color, economical: bool = false) -> void:
	if not economical:
		canvas.draw_arc(center, radius, 0, TAU, 48, Color(color, color.a * 0.09), 17.0, true)
	canvas.draw_arc(center, radius, 0, TAU, 48, Color(color, color.a * 0.22), 8.0, true)
	canvas.draw_arc(center, radius, 0, TAU, 48, color, 2.5, true)
	canvas.draw_arc(center, radius - 1.3, 0, TAU, 48, Color(color.lerp(Color.WHITE, 0.8), color.a * 0.8), 0.9, true)


static func text(canvas: CanvasItem, font: Font, position: Vector2, value: String, font_size: int, color: Color, economical: bool = false, width: float = -1) -> void:
	if not economical:
		canvas.draw_string_outline(font, position, value, HORIZONTAL_ALIGNMENT_LEFT, width, font_size, 9, Color(color, color.a * 0.09))
	canvas.draw_string_outline(font, position, value, HORIZONTAL_ALIGNMENT_LEFT, width, font_size, 4, Color(color, color.a * 0.25))
	canvas.draw_string_outline(font, position, value, HORIZONTAL_ALIGNMENT_LEFT, width, font_size, 1, Color(color, color.a * 0.85))
	canvas.draw_string(font, position, value, HORIZONTAL_ALIGNMENT_LEFT, width, font_size, Color(color.lerp(Color.WHITE, 0.64), color.a))


static func panel(theme: Dictionary, emphasized: bool = false, economical: bool = false) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var glow: Color = theme.get("neon", theme.get("accent", Color("#39bcff")))
	style.bg_color = theme.get("panel", Color("#07172e"))
	style.border_color = Color(glow, 0.82 if emphasized else 0.48)
	style.set_border_width_all(2 if emphasized else 1)
	style.set_corner_radius_all(14)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	style.shadow_color = Color(glow, 0.24 if emphasized else 0.13)
	style.shadow_size = 4 if economical else (16 if emphasized else 10)
	style.shadow_offset = Vector2.ZERO
	return style


static func button(theme: Dictionary, emphasized: bool, state: String, economical: bool = false) -> StyleBoxFlat:
	var style := panel(theme, emphasized, economical)
	var glow: Color = theme.get("neon", theme.get("accent", Color("#39bcff")))
	style.bg_color = theme.get("fill", Color("#124a9a")) if emphasized else theme.get("panel", Color("#07172e"))
	style.border_color = Color(glow, 0.95 if emphasized else 0.58)
	style.shadow_color = Color(glow, 0.30 if emphasized else 0.12)
	style.shadow_size = 4 if economical else (14 if emphasized else 6)
	if state == "hover":
		style.bg_color = style.bg_color.lightened(0.12)
		style.border_color = theme.get("core", Color.WHITE)
		style.shadow_color = Color(glow, 0.48)
	elif state == "pressed":
		style.bg_color = style.bg_color.darkened(0.15)
		style.shadow_size = 3
	elif state == "disabled":
		style.bg_color = theme.get("panel", Color("#07172e"))
		style.border_color = Color(glow, 0.17)
		style.shadow_size = 0
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	return style


static func background(canvas: CanvasItem, extent: Vector2, theme: Dictionary, economical: bool = false) -> void:
	var glow: Color = theme.get("neon", Color("#39bcff"))
	var motif: Dictionary = theme.get("motif", {})
	var bounds := Rect2(Vector2(extent.x * 0.53, extent.y * 0.30), Vector2(extent.x * 0.43, extent.y * 0.53))
	for layer in range(3 if economical else 7):
		canvas.draw_circle(bounds.get_center(), (290.0 - float(layer) * 30.0), Color(glow, 0.012))
	for index in range(5 if economical else 9):
		var y := 90.0 + float(index) * 78.0
		var x := extent.x - 26.0 - float(index % 3) * 19.0
		path(canvas, PackedVector2Array([Vector2(x, y), Vector2(x - 55, y), Vector2(x - 85, y + 30), Vector2(x - 130, y + 30)]), Color(glow, 0.15), 1.2, economical)
		canvas.draw_circle(Vector2(x - 130, y + 30), 2.5, Color(glow, 0.55))
	var color := Color(glow, 0.45)
	match str(motif.get("kind", "management")):
		"management": _management(canvas, bounds, color, economical)
		"data": _data(canvas, bounds, color, economical)
		"optimization": _optimization(canvas, bounds, color, economical)
		"software": _software(canvas, bounds, color, economical)
		"network": _network(canvas, bounds, color, economical)
	var font := ThemeDB.fallback_font
	text(canvas, font, Vector2(maxf(260.0, extent.x - 480.0), extent.y - 43.0), str(motif.get("name", "")).to_upper(), 12, Color(glow, 0.8), economical, 450)
	text(canvas, font, Vector2(maxf(260.0, extent.x - 480.0), extent.y - 20.0), str(motif.get("formula", "")), 17, Color(glow, 0.8), economical, 450)


static func _box(canvas: CanvasItem, rect: Rect2, color: Color, economical: bool) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(color, 0.025)
	style.border_color = color
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.shadow_color = Color(color, color.a * 0.25)
	style.shadow_size = 3 if economical else 10
	canvas.draw_style_box(style, rect)


static func _management(canvas: CanvasItem, rect: Rect2, color: Color, economical: bool) -> void:
	var centers := [Vector2(0.12, 0.50), Vector2(0.40, 0.22), Vector2(0.69, 0.50), Vector2(0.40, 0.80), Vector2(0.91, 0.22)]
	for edge in [[0, 1], [1, 2], [2, 3], [3, 0], [2, 4]]:
		line(canvas, rect.position + centers[edge[0]] * rect.size, rect.position + centers[edge[1]] * rect.size, color, 1.8, 1.0, economical)
	for index in range(centers.size()):
		var center: Vector2 = rect.position + centers[index] * rect.size
		_box(canvas, Rect2(center - Vector2(40, 24), Vector2(80, 48)), color, economical)
		text(canvas, ThemeDB.fallback_font, center + Vector2(-28, 4), ["ENTRADA", "ANÁLISIS", "DECISIÓN", "CONTROL", "META"][index], 11, color, economical)


static func _ellipse(canvas: CanvasItem, center: Vector2, radius: Vector2, color: Color, economical: bool) -> void:
	var points := PackedVector2Array()
	for index in range(49):
		var angle := float(index) / 48.0 * TAU
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	path(canvas, points, color, 1.7, economical)


static func _data(canvas: CanvasItem, rect: Rect2, color: Color, economical: bool) -> void:
	for database in range(3):
		var center := rect.position + Vector2(rect.size.x * (0.18 + float(database) * 0.32), rect.size.y * (0.40 + float(database % 2) * 0.28))
		for layer in range(3):
			_ellipse(canvas, center + Vector2(0, float(layer) * 27), Vector2(43, 14), color, economical)
		line(canvas, center + Vector2(-43, 0), center + Vector2(-43, 54), color, 1.7, 1.0, economical)
		line(canvas, center + Vector2(43, 0), center + Vector2(43, 54), color, 1.7, 1.0, economical)
		text(canvas, ThemeDB.fallback_font, center + Vector2(-30, -27), ["CAPTURA", "MODELO", "ANÁLISIS"][database], 12, color, economical)
	path(canvas, PackedVector2Array([rect.position + rect.size * Vector2(0.18, 0.26), rect.position + rect.size * Vector2(0.50, 0.16), rect.position + rect.size * Vector2(0.82, 0.26)]), color, 1.6, economical)


static func _optimization(canvas: CanvasItem, rect: Rect2, color: Color, economical: bool) -> void:
	var origin := rect.position + Vector2(25, rect.size.y - 25)
	line(canvas, origin, origin + Vector2(rect.size.x - 40, 0), color, 1.5, 1.0, economical)
	line(canvas, origin, origin - Vector2(0, rect.size.y - 40), color, 1.5, 1.0, economical)
	var curve := PackedVector2Array()
	for index in range(65):
		var x := float(index) / 64.0
		curve.append(origin + Vector2(x * (rect.size.x - 55), -(0.15 + 2.2 * pow(x - 0.55, 2)) * rect.size.y))
	path(canvas, curve, color, 2.4, economical)
	line(canvas, origin + Vector2(30, -rect.size.y * 0.70), origin + Vector2(rect.size.x * 0.83, -25), Color(color, 0.3), 1.4, 1.0, economical)
	ring(canvas, origin + Vector2((rect.size.x - 55) * 0.55, -rect.size.y * 0.15), 10, color, economical)


static func _software(canvas: CanvasItem, rect: Rect2, color: Color, economical: bool) -> void:
	_box(canvas, rect.grow(-18), color, economical)
	var snippets := ["function resolver(datos) {", "  const modelo = analizar(datos);", "  return validar(modelo);", "}", "test(entrada) → resultado ✓"]
	for index in range(snippets.size()):
		text(canvas, ThemeDB.fallback_font, rect.position + Vector2(36, 65 + index * 37), snippets[index], 16, color, economical, rect.size.x - 65)
	for index in range(3):
		canvas.draw_circle(rect.position + Vector2(40 + index * 17, 32), 3, color)


static func _network(canvas: CanvasItem, rect: Rect2, color: Color, economical: bool) -> void:
	var points := [Vector2(0.50, 0.47), Vector2(0.12, 0.22), Vector2(0.87, 0.19), Vector2(0.18, 0.82), Vector2(0.83, 0.81), Vector2(0.50, 0.12)]
	for index in range(1, points.size()):
		line(canvas, rect.position + points[0] * rect.size, rect.position + points[index] * rect.size, color, 2, 1.0, economical)
	for index in range(points.size()):
		var center: Vector2 = rect.position + points[index] * rect.size
		ring(canvas, center, 19 if index == 0 else 11, color, economical)
		canvas.draw_circle(center, 3, Color(color.lerp(Color.WHITE, 0.7), color.a))
