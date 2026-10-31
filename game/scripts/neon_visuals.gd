extends RefCounted

const PixelStyle = preload("res://scripts/pixel_style_box.gd")
const PIXEL_FONT = preload("res://assets/fonts/campus_pixel.fnt")

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
		canvas.draw_line(start, finish, Color(color, color.a * 0.10 * strength), width + 10.0, false)
	canvas.draw_line(start, finish, Color(color, color.a * 0.24 * strength), width + 4.0, false)
	canvas.draw_line(start, finish, Color(color, color.a * 0.86 * strength), width, false)
	canvas.draw_line(start, finish, Color(color.lerp(Color.WHITE, 0.75), color.a * 0.82 * strength), 1.0, false)


static func path(canvas: CanvasItem, points: PackedVector2Array, color: Color, width: float = 2.0, economical: bool = false) -> void:
	if points.size() < 2:
		return
	if not economical:
		canvas.draw_polyline(points, Color(color, color.a * 0.10), width + 10.0, false)
	canvas.draw_polyline(points, Color(color, color.a * 0.24), width + 4.0, false)
	canvas.draw_polyline(points, color, width, false)
	canvas.draw_polyline(points, Color(color.lerp(Color.WHITE, 0.7), color.a), 1.0, false)


static func ring(canvas: CanvasItem, center: Vector2, radius: float, color: Color, economical: bool = false) -> void:
	var points := PackedVector2Array()
	for step in range(65):
		var angle := float(step) * TAU / 64.0
		points.append(center + (Vector2(cos(angle), sin(angle)) * radius).snapped(Vector2(2, 2)))
	path(canvas, points, color, 2.0, economical)


static func text(canvas: CanvasItem, font: Font, position: Vector2, value: String, font_size: int, color: Color, economical: bool = false, width: float = -1) -> void:
	if not economical:
		canvas.draw_string_outline(font, position, value, HORIZONTAL_ALIGNMENT_LEFT, width, font_size, 9, Color(color, color.a * 0.09))
	canvas.draw_string_outline(font, position, value, HORIZONTAL_ALIGNMENT_LEFT, width, font_size, 4, Color(color, color.a * 0.25))
	canvas.draw_string_outline(font, position, value, HORIZONTAL_ALIGNMENT_LEFT, width, font_size, 1, Color(color, color.a * 0.85))
	canvas.draw_string(font, position, value, HORIZONTAL_ALIGNMENT_LEFT, width, font_size, Color(color.lerp(Color.WHITE, 0.64), color.a))


static func panel(theme: Dictionary, emphasized: bool = false, economical: bool = false) -> PixelStyle:
	var style := PixelStyle.new()
	var glow: Color = theme.get("neon", theme.get("accent", Color("#39bcff")))
	style.bg_color = Color(theme.get("panel", Color("#07172e")), 1.0)
	style.border_color = Color(glow, 0.82 if emphasized else 0.48)
	style.set_border_width_all(2 if emphasized else 1)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	style.shadow_color = Color(glow.darkened(0.65), 0.65)
	style.shadow_size = 0 if economical else 4
	style.shadow_offset = Vector2(4, 4)
	return style


static func button(theme: Dictionary, emphasized: bool, state: String, economical: bool = false) -> PixelStyle:
	var style := panel(theme, emphasized, economical)
	var glow: Color = theme.get("neon", theme.get("accent", Color("#39bcff")))
	style.bg_color = theme.get("fill", Color("#124a9a")) if emphasized else theme.get("panel", Color("#07172e"))
	style.border_color = Color(glow, 0.95 if emphasized else 0.58)
	style.bg_color.a = 1.0
	style.raised = true
	style.shadow_color = Color(glow.darkened(0.72), 0.8)
	if state == "hover":
		style.bg_color = style.bg_color.lightened(0.12)
		style.border_color = theme.get("core", Color.WHITE)
		style.border_color = theme.get("core", Color.WHITE)
	elif state == "pressed":
		style.bg_color = style.bg_color.darkened(0.15)
		style.pressed = true
		style.shadow_size = 0
	elif state == "disabled":
		style.bg_color = theme.get("panel", Color("#07172e"))
		style.border_color = Color(glow, 0.17)
		style.shadow_size = 0
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	return style


static func background(_canvas: CanvasItem, _extent: Vector2, _theme: Dictionary, _economical: bool = false) -> void:
	pass
