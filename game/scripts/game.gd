extends Control

const Catalog = preload("res://scripts/catalog.gd")
const SAVE_DIR := "user://partidas"
const SAVE_COUNT := 3
const GLOBAL_PROFILE_PATH := "user://perfil_global.json"
const INK := Color("#272b25")
const PAPER := Color("#f5f0e5")
const RULE := Color("#ddd5c5")
const GREEN := Color("#526b57")
const GOLD := Color("#b77a43")
const NEUTRAL_THEME := {"bg": Color("#101216"), "panel": Color("#1b1f25"), "accent": Color("#56636d"), "text": Color("#ece9e2"), "sub": Color("#a2a8ad"), "grid": Color("#30353b")}
const NEON_THEME := {"bg": Color("#050713"), "panel": Color("#0b1322"), "accent": Color("#42eaff"), "text": Color("#e9fbff"), "sub": Color("#adc4d5"), "grid": Color("#18324a")}
const HOME_NAME := "CAMPUS EN JUEGO"
const HOME_CURVE_DURATION := 5.5
const HOME_VISIBLE_FORMULAS := 24
const HOME_FORMULAS := [
	{"text": "E = mc²", "subject": "physics"}, {"text": "a² + b² = c²", "subject": "math"},
	{"text": "eⁱπ + 1 = 0", "subject": "math"}, {"text": "x = (−b ± √(b²−4ac))/2a", "subject": "math"},
	{"text": "(a+b)² = a² + 2ab + b²", "subject": "math"}, {"text": "Σ 1/n² = π²/6", "subject": "math"},
	{"text": "eˣ = Σ xⁿ/n!", "subject": "math"}, {"text": "sin²x + cos²x = 1", "subject": "math"},
	{"text": "d/dx sin x = cos x", "subject": "math"}, {"subject": "math", "kind": "integral", "integrand": "1/x dx", "result": "= ln|x| + C"},
	{"text": "∇²φ = 0", "subject": "physics"}, {"text": "F = ma", "subject": "physics"},
	{"text": "F = Gm₁m₂/r²", "subject": "physics"}, {"text": "p = mv", "subject": "physics"},
	{"text": "K = ½mv²", "subject": "physics"}, {"text": "W = F·d", "subject": "physics"},
	{"text": "V = IR", "subject": "physics"}, {"text": "P = IV", "subject": "physics"},
	{"text": "F = q(E + v×B)", "subject": "physics"}, {"text": "∇·E = ρ/ε₀", "subject": "physics"},
	{"text": "∇·B = 0", "subject": "physics"}, {"text": "∇×E = −∂B/∂t", "subject": "physics"},
	{"text": "∇×B = μ₀J + μ₀ε₀∂E/∂t", "subject": "physics"}, {"text": "v = fλ", "subject": "physics"},
	{"text": "PV = nRT", "subject": "chemistry"}, {"text": "p + ½ρv² + ρgh = cte.", "subject": "physics"},
	{"text": "x(t) = A cos(ωt + φ)", "subject": "physics"}, {"text": "θ = θ₀ + ω₀t + ½αt²", "subject": "physics"},
	{"text": "τ = Iα", "subject": "physics"}, {"text": "Q = mcΔT", "subject": "physics"},
	{"text": "∮ E·dA = Q/ε₀", "subject": "physics"}, {"text": "n₁ sin θ₁ = n₂ sin θ₂", "subject": "physics"},
	{"text": "f = 1/T", "subject": "physics"}, {"text": "∂²u/∂t² = c²∇²u", "subject": "physics"},
	{"text": "F = −kx", "subject": "physics"}, {"text": "Eₖ + Eₚ = cte.", "subject": "physics"},
	{"text": "∑ F = dp/dt", "subject": "physics"}, {"text": "sₙ = n(a₁+aₙ)/2", "subject": "math"},
	{"text": "φ = (1+√5)/2", "subject": "math"}, {"text": "limₓ→₀ sin x/x = 1", "subject": "math"},
	{"subject": "math", "kind": "definite_integral", "integrand": "sin(x) dx", "upper": "π", "lower": "0", "result": "= 2"},
	{"subject": "math", "kind": "definite_integral", "integrand": "e⁻ˣ dx", "upper": "∞", "lower": "0", "result": "= 1"},
	{"text": "∇·(∇×A) = 0", "subject": "math"},
	{"text": "x̄ = Σxᵢ/n", "subject": "math"}, {"text": "pH = −log₁₀[H₃O⁺]", "subject": "chemistry"},
	{"text": "ΔG = ΔH − TΔS", "subject": "chemistry"}, {"text": "Kₐ = [H⁺][A⁻]/[HA]", "subject": "chemistry"},
	{"text": "C₁V₁ = C₂V₂", "subject": "chemistry"}, {"text": "n = m/M", "subject": "chemistry"},
	{"text": "rate = k[A]ᵐ[B]ⁿ", "subject": "chemistry"}, {"text": "Q = mcΔT", "subject": "physics"},
	{"text": "T(n) = T(n/2) + 1", "subject": "computing"}, {"text": "f(n) = O(n log n)", "subject": "computing"},
	{"text": "SELECT * FROM datos", "subject": "computing"}, {"text": "∑ᵢ₌₀ⁿ xᵢ", "subject": "math"}
]
const HOME_QUOTES := [
	{"text": "La naturaleza está escrita en lenguaje matemático.", "by": "Galileo Galilei · Il Saggiatore (1623)"},
	{"text": "La imaginación es más importante que el conocimiento.", "by": "Albert Einstein · Saturday Evening Post (1929)"},
	{"text": "El motor analítico teje patrones algebraicos como el telar teje flores.", "by": "Ada Lovelace · Nota A (1843)"},
	{"text": "El progreso no es rápido ni sencillo.", "by": "Marie Curie · Notas autobiográficas (1923)"},
	{"text": "Si he visto más lejos, es por estar sobre hombros de gigantes.", "by": "Isaac Newton · carta a Robert Hooke (1676)"},
	{"text": "No debes engañarte a ti mismo; eres quien más fácilmente puedes engañar.", "by": "Richard Feynman · Cargo Cult Science (1974)"}
]
const HOME_CURVES := ["sin", "cos", "tan", "parabola", "cubic", "sqrt", "log", "exp", "gaussian", "heart", "rose", "lissajous", "spiral", "butterfly"]
const HOME_COSMIC_EVENTS := ["black_hole", "sun", "nebula", "eclipse", "pulsar"]


class MenuTransitionEffect extends Control:
	var progress: float = 0.0:
		set(value):
			progress = value
			queue_redraw()
	var center := Vector2.ZERO

	func _draw() -> void:
		var radius := Vector2(size.x, size.y).length() * 1.35 * progress
		for layer in range(8, 0, -1):
			draw_circle(center, radius * (1.0 + float(layer) * 0.055), Color("#ff582c", 0.025 + progress * 0.025))
		draw_circle(center, radius, Color("#ff862e", 0.96 * progress))
		draw_circle(center, radius * 0.72, Color("#ffd76d", 0.68 * progress))
		draw_circle(center, radius * 0.46, Color("#fff4c4", 0.8 * progress))
		if progress > 0.08:
			for ray in range(12):
				var angle := TAU * float(ray) / 12.0 + progress * 0.18
				var direction := Vector2(cos(angle), sin(angle))
				draw_line(center + direction * radius * 0.84, center + direction * radius * 1.12, Color("#fff0b0", 0.72 * progress), 2.0 + progress * 2.0, true)

var _current_theme: Dictionary = {}

const CV_SKILLS := [
	"Tutorías y apoyo académico",
	"Organización de actividades universitarias",
	"Manejo de registros y planillas",
	"Atención y orientación a estudiantes",
]

const ASSISTANT_CASES := [
	{"question": "En la tutoría, alguien memoriza una fórmula pero no entiende cuándo usarla. ¿Qué haces?", "options": ["Resolver todo por esa persona", "Proponer un ejemplo sencillo y pedirle que explique el paso", "Decir que vuelva cuando ya sepa"], "best": 1, "good": "La persona practica el razonamiento y puede detectar qué parte le cuesta.", "bad": "La tutoría sirve más cuando ayuda a entender el proceso, no solo a copiar el resultado."},
	{"question": "Dos estudiantes piden ayuda al mismo tiempo y queda poco de la hora. ¿Cómo organizas el apoyo?", "options": ["Acordar una prioridad y dejar un siguiente paso claro para ambas personas", "Atender solo a quien habla más fuerte", "Cerrar la tutoría sin avisar"], "best": 0, "good": "La prioridad queda clara y nadie se va sin saber qué hacer después.", "bad": "Coordinar tiempos y expectativas evita que el apoyo dependa de quién insiste más."},
	{"question": "Una respuesta de la guía parece tener un error. ¿Qué haces antes de difundirla?", "options": ["Verificar el procedimiento y consultar al docente si sigue la duda", "Cambiarla en silencio y repartir otra versión", "Decir al grupo que la guía no sirve"], "best": 0, "good": "Revisar la evidencia y avisar del cambio evita que el error se replique.", "bad": "Una duda se resuelve mejor comprobando el procedimiento y comunicando el resultado."},
]

const ADMIN_CASES := [
	{"question": "Dos solicitudes de inscripción aparecen duplicadas y una vence hoy. ¿Cuál es el primer paso?", "options": ["Revisar el historial, confirmar la solicitud válida y dejar registro", "Borrar las dos para empezar de cero", "Aprobar ambas para que nadie reclame"], "best": 0, "good": "La revisión conserva la trazabilidad y atiende primero el plazo cercano.", "bad": "Un trámite necesita verificación y registro antes de cambiar datos académicos."},
	{"question": "Hay pocos recursos para atender tres necesidades urgentes. ¿Cómo recomiendas priorizar?", "options": ["Usar criterios publicados, impacto y urgencia; luego explicar la decisión", "Elegir a quien conoces personalmente", "Dividir el dinero en partes iguales sin revisar cada caso"], "best": 0, "good": "Los criterios claros ayudan a usar recursos limitados con responsabilidad.", "bad": "La decisión debe poder explicarse y considerar el impacto de cada necesidad."},
	{"question": "Un formulario contiene datos personales que no hacen falta para resolver el caso. ¿Qué haces?", "options": ["Compartirlo en el grupo para acelerar el trámite", "Limitar el acceso y pedir solo los datos necesarios", "Imprimir copias para todas las oficinas"], "best": 1, "good": "Reducir datos y accesos protege a las personas y mantiene el trámite enfocado.", "bad": "Los datos deben limitarse a lo necesario y compartirse solo con quienes atienden el caso."},
]

const DEAN_CASES := [
	{"question": "El consejo debe repartir 100 puntos de presupuesto entre apoyo estudiantil, laboratorios y mantenimiento. ¿Qué propuesta presentas?", "options": ["35 apoyo, 35 laboratorios, 30 mantenimiento, con revisión trimestral", "90 para un evento y 10 para todo lo demás", "100 para compras sin evaluación de uso"], "best": 0, "good": "La propuesta equilibra necesidades y deja una fecha para revisar el uso del presupuesto.", "bad": "El presupuesto debe responder a necesidades comprobables y tener seguimiento."},
	{"question": "Un laboratorio pide renovar equipos. ¿Qué condición acompañaría la aprobación?", "options": ["Inventario, justificación académica y plan de mantenimiento", "Aprobar por presión y decidir después qué comprar", "Rechazar todo gasto para guardar el saldo"], "best": 0, "good": "La evidencia y el mantenimiento conectan la compra con el trabajo académico.", "bad": "Aprobar una compra requiere necesidad, uso previsto y cuidado posterior."},
	{"question": "Al cierre del periodo, parte del presupuesto no se ejecutó. ¿Qué haces?", "options": ["Publicar el resultado y proponer ajustes con las áreas involucradas", "Ocultar el saldo para evitar preguntas", "Gastar lo restante sin revisar necesidades"], "best": 0, "good": "Rendir cuentas permite corregir el plan y sostener la confianza.", "bad": "El cierre también requiere explicar resultados y decidir con evidencia."},
]

var current_profile: Dictionary = {}
var global_profile: Dictionary = {"achievements": [], "completed_programs": [], "completed_subjects": []}
var active_slot := 0
var selected_faculty := ""
var draft_player_name := ""
var draft_source_slot := 0
var current_question: Dictionary = {}
var cv_draft: Array = []
var team_name_drafts: Array = []
var team_name_fields: Array = []
var team_name_box: VBoxContainer
var settings := {"fullscreen": true, "animations": true, "font_scale": 1.0, "antialiasing": false, "low_performance": false}
var system_font: SystemFont
var formula_font: SystemFont
var random := RandomNumberGenerator.new()
var _active_back := Callable()
var _home_art := false
var _menu_backdrop_active := false
var _transitioning := false
var _transition_revealing := false
var _transition_overlay: Control
var _home_curve_index := 0
var _home_curve_time := 0.0
var _home_curve_forward: Array[PackedVector2Array] = []
var _home_curve_backward: Array[PackedVector2Array] = []
var _home_formula_bodies: Array[Dictionary] = []
var _home_formula_order: Array = []
var _home_formula_cursor := 0
var _home_formula_time := 0.0
var _home_quote_label: Label
var _home_quote_index := 0
var _home_quote_time := 0.0
var _home_stars: Array[Dictionary] = []
var _home_nebulae: Array[Dictionary] = []
var _home_sparks: Array[Dictionary] = []
var _home_cosmic_event := "nebula"
var _home_cosmic_center := Vector2(0.75, 0.5)
var _home_cosmic_time := 0.0


func _ready() -> void:
	random.randomize()
	_load_settings()
	settings["fullscreen"] = true
	_load_global_profile()
	_setup_theme()
	_use_menu_theme()
	get_window().min_size = Vector2i(900, 640)
	_apply_image_settings()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	_show_main()
	queue_redraw()


func _draw() -> void:
	if _current_theme.is_empty():
		_current_theme = NEUTRAL_THEME
	var bg: Color = _current_theme.get("bg", PAPER)
	draw_rect(Rect2(Vector2.ZERO, size), bg)
	var grid: Color = _current_theme.get("grid", Color("#292e34"))
	if not _home_art:
		for y in range(42, int(size.y), 44):
			draw_line(Vector2(0, y), Vector2(size.x, y), Color(grid, 0.15), 1.0)
	if _home_art:
		_draw_home_science()


func _draw_home_cosmos() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#050714"))
	for cloud in _home_nebulae:
		var cloud_center: Vector2 = cloud["position"] * size
		var radius := minf(size.x, size.y) * float(cloud["radius"])
		var tint: Color = cloud["color"]
		for layer in range(8, 0, -1):
			var layer_color := tint
			layer_color.a = 0.018 + (8 - layer) * 0.004
			draw_circle(cloud_center, radius * float(layer) / 5.0, layer_color)
	for star in _home_stars:
		var position: Vector2 = star["position"] * size
		var radius := float(star["radius"])
		var pulse := 0.62 + 0.38 * sin(_home_cosmic_time * float(star["speed"]) + float(star["phase"]))
		var star_color: Color = star["color"]
		star_color.a *= pulse
		draw_circle(position, radius, star_color)
		if radius > 1.65:
			var sparkle := Color(star_color, star_color.a * 0.48)
			draw_line(position - Vector2(3.0, 0.0), position + Vector2(3.0, 0.0), sparkle, 0.8)
			draw_line(position - Vector2(0.0, 3.0), position + Vector2(0.0, 3.0), sparkle, 0.8)
	var center := _home_cosmic_center * size
	match _home_cosmic_event:
		"black_hole": _draw_home_black_hole(center)
		"sun": _draw_home_sun(center)
		"eclipse": _draw_home_eclipse(center)
		"pulsar": _draw_home_pulsar(center)
		_: pass


func _draw_home_black_hole(center: Vector2) -> void:
	var rotation := _home_cosmic_time * 0.16
	_draw_cosmic_ellipse(center, 118.0, 0.27, rotation, Color("#ff6d34", 0.24), 14.0)
	_draw_cosmic_ellipse(center, 91.0, 0.32, -rotation * 1.35, Color("#ffba62", 0.68), 5.0)
	_draw_cosmic_ellipse(center, 62.0, 0.39, rotation * 1.8, Color("#71dfff", 0.72), 3.0)
	draw_circle(center, 44.0, Color("#8f45ff", 0.09))
	draw_circle(center, 34.0, Color("#010107"))
	draw_circle(center, 29.0, Color("#000004"))
	draw_arc(center, 34.0, PI * 1.05, PI * 1.95, 52, Color("#fff0bf", 0.94), 2.0, true)


func _draw_home_sun(center: Vector2) -> void:
	var pulse := 1.0 + 0.045 * sin(_home_cosmic_time * 2.1)
	var detail_layers := 6 if bool(settings.get("low_performance", false)) else 12
	for layer in range(detail_layers, 0, -1):
		var radius := (26.0 + layer * 11.0) * pulse
		var glow := Color("#ff4a20", 0.016 + float(detail_layers - layer) * 0.002)
		if layer < 5:
			glow = Color("#ff9d26", 0.03 + float(5 - layer) * 0.012)
		draw_circle(center, radius, glow)
	draw_circle(center, 30.0 * pulse, Color("#ff7a19"))
	draw_circle(center, 23.0 * pulse, Color("#ffe88a"))
	var ray_count := 8 if bool(settings.get("low_performance", false)) else 12
	for ray in range(ray_count):
		var angle := TAU * float(ray) / float(ray_count) + _home_cosmic_time * 0.11
		var direction := Vector2(cos(angle), sin(angle))
		draw_line(center + direction * 36.0, center + direction * (54.0 + 8.0 * sin(_home_cosmic_time + ray)), Color("#ffad39", 0.42), 2.0, true)
	for flare in range(5):
		var angle := TAU * float(flare) / 5.0 + _home_cosmic_time * 0.08
		var direction := Vector2(cos(angle), sin(angle))
		var tangent := Vector2(-direction.y, direction.x)
		var height := 10.0 + 17.0 * (0.5 + 0.5 * sin(_home_cosmic_time * 1.7 + float(flare) * 2.1))
		var base := center + direction * 27.0 * pulse
		var flare_points := PackedVector2Array([
			base - tangent * 3.5,
			base + direction * height * 0.45 - tangent * 1.8,
			base + direction * height + tangent * 1.2,
			base + direction * height * 0.45 + tangent * 4.0,
			base + tangent * 3.5
		])
		draw_polyline(flare_points, Color("#ffb34c", 0.72), 2.2, true)


func _draw_home_eclipse(center: Vector2) -> void:
	for layer in range(10, 0, -1):
		draw_circle(center, 32.0 + layer * 9.0, Color("#53d9ff", 0.018 + float(10 - layer) * 0.003))
	draw_circle(center, 38.0, Color("#ffe996", 0.9))
	var moon_orbit := Vector2(cos(_home_cosmic_time * 0.52), sin(_home_cosmic_time * 0.52) * 0.22)
	draw_circle(center + moon_orbit * 28.0, 34.0, Color("#030612"))
	draw_arc(center, 43.0, -0.38, PI + 0.38, 72, Color("#bdefff", 0.9), 2.0, true)


func _draw_home_pulsar(center: Vector2) -> void:
	var pulse := pow(maxf(0.0, sin(_home_cosmic_time * 2.3)), 7.0)
	for layer in range(9, 0, -1):
		draw_circle(center, 18.0 + layer * 9.0, Color("#5f75ff", 0.014 + pulse * 0.012))
	var angle := _home_cosmic_time * 0.42
	for beam in [-1.0, 1.0]:
		var direction: Vector2 = Vector2(cos(angle), sin(angle)) * beam
		draw_line(center - direction * 190.0, center + direction * 190.0, Color("#8fc9ff", 0.05 + pulse * 0.36), 3.0 + pulse * 8.0, true)
	draw_circle(center, 11.0, Color("#e9f5ff"))
	draw_circle(center, 5.0, Color("#ffffff"))


func _draw_cosmic_ellipse(center: Vector2, radius: float, flattening: float, rotation: float, color: Color, width: float) -> void:
	var points := PackedVector2Array()
	var steps := 48 if bool(settings.get("low_performance", false)) else 96
	for step in range(steps + 1):
		var angle := TAU * float(step) / float(steps)
		var local := Vector2(cos(angle) * radius, sin(angle) * radius * flattening).rotated(rotation)
		points.append(center + local)
	draw_polyline(points, color, width, true)


func _draw_home_science() -> void:
	_draw_home_cosmos()
	var center := size * 0.5
	var scale_px := minf(size.x, size.y) / 24.0
	var grid_color := Color("#d8e0e6", 0.14)
	var major_grid_color := Color("#f0f4f6", 0.27)
	var axis_color := Color("#ffffff", 0.78)
	var step := scale_px
	var x := fmod(center.x, step)
	while x < size.x:
		var vertical_step := int(round((x - center.x) / step))
		draw_line(Vector2(x, 0), Vector2(x, size.y), major_grid_color if vertical_step % 5 == 0 else grid_color, 1.0)
		x += step
	var y := fmod(center.y, step)
	while y < size.y:
		var horizontal_step := int(round((y - center.y) / step))
		draw_line(Vector2(0, y), Vector2(size.x, y), major_grid_color if horizontal_step % 5 == 0 else grid_color, 1.0)
		y += step
	var horizontal_range := int(ceil(center.x / scale_px))
	var vertical_range := int(ceil(center.y / scale_px))
	for tick in range(-maxi(horizontal_range, vertical_range), maxi(horizontal_range, vertical_range) + 1):
		if tick == 0:
			continue
		var tx := center.x + float(tick) * scale_px
		if tx >= 0 and tx <= size.x:
			if tick % 5 == 0:
				draw_string(ThemeDB.fallback_font, Vector2(tx + 3, center.y + 15), str(tick), HORIZONTAL_ALIGNMENT_LEFT, 26, 9, Color("#aab6bb", 0.62))
		var ty := center.y - float(tick) * scale_px
		if ty >= 0 and ty <= size.y:
			if tick % 5 == 0:
				draw_string(ThemeDB.fallback_font, Vector2(center.x + 7, ty - 3), str(tick), HORIZONTAL_ALIGNMENT_LEFT, 26, 9, Color("#ffffff", 0.72))
	var curve_color := Color("#ffffff", 0.94) if str(HOME_CURVES[_home_curve_index]) not in ["heart", "rose", "lissajous", "spiral", "butterfly"] else _home_curve_color()
	_draw_home_axes(center, axis_color)
	_draw_home_trace(_home_curve_forward, curve_color)
	_draw_home_trace(_home_curve_backward, curve_color)
	for body in _home_formula_bodies:
		_draw_home_formula(body)
	for spark in _home_sparks:
		var life_ratio := clampf(float(spark["life"]) / float(spark["duration"]), 0.0, 1.0)
		var spark_color: Color = spark["color"]
		spark_color.a *= 1.0 - life_ratio
		var spark_position: Vector2 = spark["position"]
		draw_line(spark_position, spark_position - Vector2(0.0, 5.0 + 8.0 * (1.0 - life_ratio)), spark_color, 1.5, true)
		draw_circle(spark_position, 1.0 + (1.0 - life_ratio), spark_color)


func _draw_home_axes(center: Vector2, axis_color: Color) -> void:
	draw_line(Vector2(0, center.y), Vector2(size.x - 14, center.y), axis_color, 1.8, true)
	draw_line(Vector2(center.x, size.y), Vector2(center.x, 14), axis_color, 1.8, true)
	draw_colored_polygon(PackedVector2Array([Vector2(size.x - 3, center.y), Vector2(size.x - 15, center.y - 5), Vector2(size.x - 15, center.y + 5)]), axis_color)
	draw_colored_polygon(PackedVector2Array([Vector2(center.x, 3), Vector2(center.x - 5, 15), Vector2(center.x + 5, 15)]), axis_color)
	draw_string(ThemeDB.fallback_font, Vector2(size.x - 25, center.y - 10), "x", HORIZONTAL_ALIGNMENT_LEFT, 16, 13, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(center.x + 9, 18), "y", HORIZONTAL_ALIGNMENT_LEFT, 16, 13, Color.WHITE)
	draw_string(ThemeDB.fallback_font, center + Vector2(8, 17), "0", HORIZONTAL_ALIGNMENT_LEFT, 12, 10, Color("#ffffff", 0.78))
	var scale_px := minf(size.x, size.y) / 24.0
	var tick_range := int(ceil(maxf(center.x, center.y) / scale_px))
	for tick in range(-tick_range, tick_range + 1):
		if tick == 0:
			continue
		var tx := center.x + float(tick) * scale_px
		if tx >= 0 and tx <= size.x:
			draw_line(Vector2(tx, center.y - 4), Vector2(tx, center.y + 4), axis_color, 1.0, true)
		var ty := center.y - float(tick) * scale_px
		if ty >= 0 and ty <= size.y:
			draw_line(Vector2(center.x - 4, ty), Vector2(center.x + 4, ty), axis_color, 1.0, true)


func _draw_home_formula(body: Dictionary) -> void:
	var position: Vector2 = body["pos"]
	var font_size := int(body["font_size"])
	var color: Color = body["color"]
	var burn := clampf(float(body.get("burn", 0.0)), 0.0, 1.0)
	if burn > 0.0:
		color = color.lerp(Color("#ff3d16"), burn * 0.92)
		color.a *= 1.0 - burn * 0.35
	var glow := Color(color, color.a * 0.17)
	if _home_cosmic_event == "sun" and burn > 0.08:
		_draw_home_flames(body, burn)
	var kind := str(body.get("kind", "text"))
	if kind in ["integral", "definite_integral"]:
		var symbol_size := int(round(font_size * 1.58))
		var limit_size := maxi(9, int(round(font_size * 0.58)))
		var symbol_width := formula_font.get_string_size("∫", HORIZONTAL_ALIGNMENT_LEFT, -1, symbol_size).x
		var symbol_baseline := position + Vector2(0.0, font_size * 1.72)
		var text_baseline := position + Vector2(symbol_width + 7.0, font_size * 1.35)
		var integrand := str(body["integrand"])
		var result := str(body["result"])
		draw_string(formula_font, symbol_baseline, "∫", HORIZONTAL_ALIGNMENT_LEFT, -1, symbol_size + 2, glow)
		draw_string(formula_font, symbol_baseline, "∫", HORIZONTAL_ALIGNMENT_LEFT, -1, symbol_size, color)
		if kind == "definite_integral":
			var limit_position := position + Vector2(symbol_width * 0.72, font_size * 0.67)
			var lower_position := position + Vector2(symbol_width * 0.78, font_size * 2.05)
			draw_string(formula_font, limit_position, str(body["upper"]), HORIZONTAL_ALIGNMENT_LEFT, -1, limit_size, color)
			draw_string(formula_font, lower_position, str(body["lower"]), HORIZONTAL_ALIGNMENT_LEFT, -1, limit_size, color)
		draw_string(formula_font, text_baseline + Vector2(0.0, 1.0), integrand + " " + result, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, glow)
		draw_string(formula_font, text_baseline, integrand + " " + result, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
		return
	var baseline := position + Vector2(0.0, font_size)
	draw_string(formula_font, baseline + Vector2(0.0, 1.0), str(body["text"]), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size + 2, glow)
	draw_string(formula_font, baseline, str(body["text"]), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


func _draw_home_flames(body: Dictionary, burn: float) -> void:
	var position: Vector2 = body["pos"]
	var extent: Vector2 = body["extent"]
	var flame_count := clampi(int(extent.x / 20.0), 2, 8)
	for flame in range(flame_count):
		var phase := _home_cosmic_time * 8.0 + float(flame) * 1.71 + float(body["font_size"])
		var x := position.x + extent.x * (float(flame) + 0.5) / float(flame_count)
		var base := position.y + extent.y - 1.0
		var height := burn * (4.0 + 8.0 * (0.5 + 0.5 * sin(phase)))
		var tip := Vector2(x + sin(phase * 0.7) * height * 0.22, base - height)
		draw_line(Vector2(x, base), tip, Color("#ff682b", 0.72 * burn), 1.6, true)
		draw_circle(tip, 1.2 + burn, Color("#ffd46b", 0.68 * burn))


func _draw_home_trace(segments: Array[PackedVector2Array], color: Color) -> void:
	var aura := _home_curve_aura()
	for segment in segments:
		if segment.size() < 2:
			continue
		var visible_points := PackedVector2Array()
		for point in segment:
			visible_points.append(_home_curve_visual_point(point))
		if str(HOME_CURVES[_home_curve_index]) != "tan":
			draw_polyline(visible_points, Color(aura, 0.2), 8.0, true)
			draw_polyline(visible_points, color, 2.4, true)
			continue
		for i in range(1, visible_points.size()):
			if absf(visible_points[i].y - visible_points[i - 1].y) < minf(size.y * 0.15, 120.0):
				draw_line(visible_points[i - 1], visible_points[i], Color(aura, 0.2), 8.0, true)
				draw_line(visible_points[i - 1], visible_points[i], color, 2.4, true)


func _home_curve_aura() -> Color:
	match _home_cosmic_event:
		"black_hole": return Color("#9e73ff")
		"sun": return Color("#ff9138")
		"eclipse": return Color("#65dcff")
		"pulsar": return Color("#8aa5ff")
	return Color("#63d7ff")


func _home_curve_visual_point(point: Vector2) -> Vector2:
	var center := _home_cosmic_center * size
	var delta := point - center
	var distance := delta.length()
	var influence := clampf(1.0 - distance / (minf(size.x, size.y) * 0.44), 0.0, 1.0)
	if influence <= 0.0:
		return point
	var perpendicular := Vector2(-delta.y, delta.x).normalized()
	match _home_cosmic_event:
		"black_hole":
			return point + perpendicular * influence * influence * (30.0 + 12.0 * sin(_home_cosmic_time + distance * 0.016))
		"sun":
			return point + delta.normalized() * influence * 18.0 * sin(_home_cosmic_time * 1.7 + distance * 0.02)
		"eclipse":
			return point + perpendicular * influence * 16.0 * sin(_home_cosmic_time * 0.55)
		"pulsar":
			return point + perpendicular * influence * 23.0 * sin(_home_cosmic_time * 2.3)
	return point


func _process(delta: float) -> void:
	if (_transitioning and not _transition_revealing) or not _home_art or not bool(settings.get("animations", true)):
		return
	_home_formula_time += delta
	if _home_formula_time >= 2.4 and not _home_formula_order.is_empty():
		_home_formula_time = 0.0
		if _home_formula_cursor >= _home_formula_order.size():
			_home_formula_order.shuffle()
			_home_formula_cursor = 0
		var body_slot := _home_formula_cursor % _home_formula_bodies.size()
		_home_formula_bodies[body_slot] = _make_home_body(_home_formula_order[_home_formula_cursor])
		_home_formula_cursor += 1
	_home_quote_time += delta
	_home_cosmic_time += delta
	if _home_quote_time >= 12.0:
		_home_quote_time = 0.0
		_home_quote_index = (_home_quote_index + 1) % HOME_QUOTES.size()
		_update_home_quote()
	_home_curve_time += delta
	if _home_curve_time >= HOME_CURVE_DURATION:
		_home_curve_time = 0.0
		_home_curve_index = (_home_curve_index + 1) % HOME_CURVES.size()
		_home_curve_forward.clear()
		_home_curve_backward.clear()
	for body_index in range(_home_formula_bodies.size()):
		var body: Dictionary = _home_formula_bodies[body_index]
		body["collision_cooldown"] = maxf(0.0, float(body.get("collision_cooldown", 0.0)) - delta)
		var pos: Vector2 = body["pos"]
		var velocity: Vector2 = body["velocity"]
		var extent: Vector2 = body["extent"]
		pos += velocity * minf(delta, 0.05)
		if pos.x < 6.0 or pos.x + extent.x > size.x - 6.0:
			velocity.x *= -1.0
			pos.x = clampf(pos.x, 6.0, maxf(6.0, size.x - extent.x - 6.0))
		if pos.y < 6.0 or pos.y + extent.y > size.y - 6.0:
			velocity.y *= -1.0
			pos.y = clampf(pos.y, 6.0, maxf(6.0, size.y - extent.y - 6.0))
		body["pos"] = pos
		body["velocity"] = velocity
		body = _apply_home_cosmic_effect(body, delta)
		_home_formula_bodies[body_index] = body
	_resolve_formula_collisions()
	_advance_home_sparks(delta)
	_advance_home_curve(delta)
	queue_redraw()


func _advance_home_curve(delta: float) -> void:
	var name := str(HOME_CURVES[_home_curve_index])
	var scale_px := minf(size.x, size.y) / 24.0
	var x_extent := size.x * 0.5 / scale_px
	var y_extent := size.y * 0.5 / scale_px
	var old_fraction := clampf((_home_curve_time - delta) / HOME_CURVE_DURATION, 0.0, 1.0)
	var new_fraction := clampf(_home_curve_time / HOME_CURVE_DURATION, 0.0, 1.0)
	var old_progress := old_fraction * x_extent
	var new_progress := new_fraction * x_extent
	if name in ["heart", "rose", "lissajous", "spiral", "butterfly"]:
		var angle_range := TAU * (3.0 if name == "spiral" else (12.0 if name == "butterfly" else 1.0))
		var start_angle := old_fraction * angle_range
		var end_angle := minf(angle_range, maxf(start_angle + 0.005, new_fraction * angle_range))
		var curve_points := PackedVector2Array()
		var sample_rate := 38.0 if bool(settings.get("low_performance", false)) else 70.0
		var samples := maxi(2, int((end_angle - start_angle) * sample_rate))
		for j in range(samples + 1):
			var angle := lerpf(start_angle, end_angle, float(j) / samples)
			curve_points.append(_home_parametric_point(name, angle, scale_px))
		if curve_points.size() > 1:
			if _home_curve_forward.is_empty() or _home_curve_forward.back().is_empty():
				_home_curve_forward.append(curve_points)
			else:
				var segment: PackedVector2Array = _home_curve_forward.back()
				segment.append_array(curve_points.slice(1))
				_home_curve_forward[_home_curve_forward.size() - 1] = segment
		return
	var first_x := maxf(0.0, old_progress)
	var last_x := new_progress
	var sample_step := 0.02 if bool(settings.get("low_performance", false)) else 0.012
	var samples_count := maxi(1, int((last_x - first_x) / sample_step))
	for j in range(samples_count + 1):
		var x_value := lerpf(first_x, last_x, float(j) / samples_count)
		var y_value := _home_function_value(name, x_value)
		if is_finite(y_value) and absf(y_value) < y_extent:
			_append_home_curve_point(_home_curve_forward, Vector2(size.x * 0.5 + x_value * scale_px, size.y * 0.5 - y_value * scale_px))
		else:
			_break_home_curve(_home_curve_forward)
		if name != "log":
			var back_y := _home_function_value(name, -x_value)
			if is_finite(back_y) and absf(back_y) < y_extent:
				_append_home_curve_point(_home_curve_backward, Vector2(size.x * 0.5 - x_value * scale_px, size.y * 0.5 - back_y * scale_px))
			else:
				_break_home_curve(_home_curve_backward)
	while _home_curve_forward.size() > 4:
		_home_curve_forward.remove_at(0)
	while _home_curve_backward.size() > 4:
		_home_curve_backward.remove_at(0)


func _append_home_curve_point(segments: Array[PackedVector2Array], point: Vector2) -> void:
	if segments.is_empty() or segments.back().is_empty():
		segments.append(PackedVector2Array())
	var segment: PackedVector2Array = segments.back()
	segment.append(point)
	segments[segments.size() - 1] = segment


func _break_home_curve(segments: Array[PackedVector2Array]) -> void:
	if not segments.is_empty() and not segments.back().is_empty():
		segments.append(PackedVector2Array())


func _home_function_value(name: String, x: float) -> float:
	match name:
		"sin": return sin(x)
		"cos": return cos(x)
		"tan": return tan(x)
		"parabola": return x * x * 0.16
		"cubic": return x * x * x * 0.025
		"sqrt": return sqrt(absf(x)) * 0.62
		"log": return log(maxf(x, 0.035)) * 1.15
		"exp": return exp(x * 0.28) - 1.0
		"gaussian": return 3.2 * exp(-x * x * 0.16) - 0.75
	return 0.0


func _home_parametric_point(name: String, t: float, scale_px: float) -> Vector2:
	var x := 0.0
	var y := 0.0
	match name:
		"heart":
			x = 16.0 * pow(sin(t), 3.0) * 0.48
			y = (13.0 * cos(t) - 5.0 * cos(2.0 * t) - 2.0 * cos(3.0 * t) - cos(4.0 * t)) * 0.48
		"rose":
			var r := 5.5 * cos(4.0 * t)
			x = r * cos(t)
			y = r * sin(t)
		"lissajous":
			x = 6.0 * sin(3.0 * t)
			y = 6.0 * sin(2.0 * t + PI / 2.0)
		"spiral":
			var r := 0.29 * t
			x = r * cos(t)
			y = r * sin(t)
		"butterfly":
			var r := exp(cos(t)) - 2.0 * cos(4.0 * t) + pow(sin(t / 12.0), 5.0)
			x = sin(t) * r * 1.45
			y = cos(t) * r * 1.45
	return Vector2(size.x * 0.5 + x * scale_px, size.y * 0.5 - y * scale_px)


func _home_curve_color() -> Color:
	match str(HOME_CURVES[_home_curve_index]):
		"heart": return Color("#ff6b91")
		"rose": return Color("#c7a6ff")
		"lissajous": return Color("#56d8cc")
		"spiral": return Color("#ffc66d")
		"butterfly": return Color("#ff9b64")
	return Color.WHITE


func _initialize_home_formulas() -> void:
	_home_formula_bodies.clear()
	_home_formula_order = HOME_FORMULAS.duplicate()
	_home_formula_order.shuffle()
	_home_formula_cursor = 0
	_home_formula_time = 0.0
	var formula_limit := 10 if bool(settings.get("low_performance", false)) else HOME_VISIBLE_FORMULAS
	var count := mini(formula_limit, _home_formula_order.size())
	for i in range(count):
		_home_formula_bodies.append(_make_home_body(_home_formula_order[i]))
	_home_formula_cursor = count


func _initialize_home_cosmos() -> void:
	var previous_event := _home_cosmic_event
	_home_cosmic_event = HOME_COSMIC_EVENTS[random.randi_range(0, HOME_COSMIC_EVENTS.size() - 1)]
	if HOME_COSMIC_EVENTS.size() > 1 and _home_cosmic_event == previous_event:
		_home_cosmic_event = HOME_COSMIC_EVENTS[(HOME_COSMIC_EVENTS.find(_home_cosmic_event) + 1) % HOME_COSMIC_EVENTS.size()]
	_home_cosmic_center = Vector2(random.randf_range(0.18, 0.82), random.randf_range(0.18, 0.82))
	_home_cosmic_time = 0.0
	_home_stars.clear()
	_home_nebulae.clear()
	_home_sparks.clear()
	var star_colors := [Color("#ffffff"), Color("#bde8ff"), Color("#ffe3bd"), Color("#d4c5ff")]
	var star_count := 52 if bool(settings.get("low_performance", false)) else (96 if size.x < 900.0 else 150)
	for i in range(star_count):
		_home_stars.append({
			"position": Vector2(random.randf(), random.randf()),
			"radius": random.randf_range(0.55, 2.0),
			"phase": random.randf_range(0.0, TAU),
			"speed": random.randf_range(0.35, 1.6),
			"color": star_colors[random.randi_range(0, star_colors.size() - 1)]
		})
	var cloud_colors := [Color("#633cff"), Color("#008ce0"), Color("#ff3d95"), Color("#15bfa7")]
	var cloud_count := 2 if bool(settings.get("low_performance", false)) else 5
	for i in range(cloud_count):
		_home_nebulae.append({
			"position": Vector2(random.randf(), random.randf()),
			"radius": random.randf_range(0.17, 0.34),
			"color": cloud_colors[random.randi_range(0, cloud_colors.size() - 1)]
		})


func _make_home_body(formula: Dictionary) -> Dictionary:
	var kind := str(formula.get("kind", "text"))
	var text := str(formula.get("text", "∫ " + str(formula.get("integrand", "")) + " " + str(formula.get("result", ""))))
	var subject := str(formula["subject"])
	var font_size := random.randi_range(20, 25)
	if text.length() > 25:
		font_size = random.randi_range(16, 20)
	var extent: Vector2
	if kind in ["integral", "definite_integral"]:
		var symbol_width := formula_font.get_string_size("∫", HORIZONTAL_ALIGNMENT_LEFT, -1, int(font_size * 1.58)).x
		var main_text := str(formula["integrand"]) + " " + str(formula["result"])
		extent = Vector2(symbol_width + formula_font.get_string_size(main_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x + 10.0, font_size * 2.45)
	else:
		extent = formula_font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size) + Vector2(6, font_size + 8)
	var viewport_size := get_viewport_rect().size
	var pos := _home_random_formula_position(extent, viewport_size)
	var velocity := Vector2(random.randf_range(19.0, 36.0) * (-1.0 if random.randf() < 0.5 else 1.0), random.randf_range(16.0, 31.0) * (-1.0 if random.randf() < 0.5 else 1.0))
	var body := {"text": text, "kind": kind, "pos": pos, "velocity": velocity, "extent": extent, "font_size": font_size, "color": _home_subject_color(subject), "subject": subject, "collision_cooldown": 0.0, "burn": 0.0}
	for key in ["integrand", "result", "upper", "lower"]:
		if formula.has(key):
			body[key] = formula[key]
	return body


func _home_random_formula_position(extent: Vector2, viewport_size: Vector2) -> Vector2:
	return Vector2(
		random.randf_range(8.0, maxf(8.0, viewport_size.x - extent.x - 8.0)),
		random.randf_range(8.0, maxf(8.0, viewport_size.y - extent.y - 8.0))
	)


func _home_subject_color(subject: String) -> Color:
	match subject:
		"physics": return Color("#35c8ff", 0.98)
		"chemistry": return Color("#75ff4c", 0.98)
		"computing": return Color("#ff65d4", 0.98)
	return Color("#fff0a0", 0.98)


func _random_home_formula(excluding: String) -> Dictionary:
	for attempt in range(8):
		var formula: Dictionary = HOME_FORMULAS[random.randi_range(0, HOME_FORMULAS.size() - 1)]
		var candidate_text := str(formula.get("text", "∫ " + str(formula.get("integrand", "")) + " " + str(formula.get("result", ""))))
		if candidate_text != excluding:
			return formula
	return HOME_FORMULAS[random.randi_range(0, HOME_FORMULAS.size() - 1)]


func _recompose_home_body(body: Dictionary, respawn: bool) -> Dictionary:
	var replacement := _make_home_body(_random_home_formula(str(body["text"])))
	var old_position: Vector2 = body["pos"]
	var old_extent: Vector2 = body["extent"]
	if respawn:
		replacement["pos"] = _home_random_formula_position(replacement["extent"], size)
		for attempt in range(10):
			var center: Vector2 = replacement["pos"] + replacement["extent"] * 0.5
			var cosmic_center: Vector2 = _home_cosmic_center * size
			var minimum_distance := minf(size.x, size.y) * (0.26 if _home_cosmic_event == "black_hole" else 0.2)
			if center.distance_to(cosmic_center) >= minimum_distance:
				break
			replacement["pos"] = _home_random_formula_position(replacement["extent"], size)
		if replacement["pos"].distance_to(_home_cosmic_center * size) < minf(size.x, size.y) * 0.12:
			var left_side := _home_cosmic_center.x > 0.5
			replacement["pos"].x = 10.0 if left_side else maxf(10.0, size.x - replacement["extent"].x - 10.0)
	else:
		replacement["pos"] = old_position + (old_extent - replacement["extent"]) * 0.5
		replacement["pos"].x = clampf(replacement["pos"].x, 6.0, maxf(6.0, size.x - replacement["extent"].x - 6.0))
		replacement["pos"].y = clampf(replacement["pos"].y, 6.0, maxf(6.0, size.y - replacement["extent"].y - 6.0))
	var velocity: Vector2 = body["velocity"]
	if velocity.length_squared() > 0.0:
		replacement["velocity"] = velocity.rotated(random.randf_range(-0.55, 0.55)).normalized() * random.randf_range(23.0, 42.0)
	replacement["collision_cooldown"] = 0.8
	return replacement


func _apply_home_cosmic_effect(body: Dictionary, delta: float) -> Dictionary:
	var position: Vector2 = body["pos"] + body["extent"] * 0.5
	var center := _home_cosmic_center * size
	var distance := position.distance_to(center)
	var cosmic_scale := minf(size.x, size.y)
	if _home_cosmic_event == "black_hole":
		var radius := cosmic_scale * 0.48
		if distance < 38.0:
			return _recompose_home_body(body, true)
		if distance < radius:
			var influence := 1.0 - distance / radius
			var velocity: Vector2 = body["velocity"]
			velocity += (center - position).normalized() * 250.0 * influence * influence * delta
			if velocity.length() > 94.0:
				velocity = velocity.normalized() * 94.0
			body["velocity"] = velocity
	elif _home_cosmic_event in ["sun", "eclipse"]:
		var radius := cosmic_scale * (0.29 if _home_cosmic_event == "sun" else 0.18)
		var burn := float(body.get("burn", 0.0))
		if distance < radius:
			var heat := 1.0 - distance / radius
			burn += delta * (0.8 + heat * 0.8)
			if _home_cosmic_event == "sun" and random.randf() < 0.28:
				var body_position: Vector2 = body["pos"]
				var body_extent: Vector2 = body["extent"]
				_spawn_home_spark(body_position + Vector2(random.randf_range(0.0, body_extent.x), random.randf_range(0.0, body_extent.y)))
			if burn >= 1.0:
				return _recompose_home_body(body, true)
		else:
			burn = maxf(0.0, burn - delta * 0.72)
		body["burn"] = burn
	elif _home_cosmic_event == "pulsar" and distance < cosmic_scale * 0.3:
		var pulse := pow(maxf(0.0, sin(_home_cosmic_time * 2.3)), 10.0)
		var velocity: Vector2 = body["velocity"]
		velocity += Vector2(-(position - center).y, (position - center).x).normalized() * pulse * 180.0 * delta
		body["velocity"] = velocity
	return body


func _spawn_home_spark(position: Vector2) -> void:
	var spark_limit := 24 if bool(settings.get("low_performance", false)) else 72
	if _home_sparks.size() >= spark_limit:
		return
	_home_sparks.append({
		"position": position,
		"velocity": Vector2(random.randf_range(-16.0, 16.0), random.randf_range(-28.0, -8.0)),
		"life": 0.0,
		"duration": random.randf_range(0.28, 0.7),
		"color": Color("#ffb750") if random.randf() < 0.5 else Color("#fff0a2")
	})


func _advance_home_sparks(delta: float) -> void:
	for index in range(_home_sparks.size() - 1, -1, -1):
		var spark: Dictionary = _home_sparks[index]
		spark["life"] = float(spark["life"]) + delta
		if float(spark["life"]) >= float(spark["duration"]):
			_home_sparks.remove_at(index)
			continue
		spark["position"] = Vector2(spark["position"]) + Vector2(spark["velocity"]) * delta
		spark["velocity"] = Vector2(spark["velocity"]) + Vector2(0.0, 18.0 * delta)
		_home_sparks[index] = spark


func _resolve_formula_collisions() -> void:
	for i in range(_home_formula_bodies.size()):
		for j in range(i + 1, _home_formula_bodies.size()):
			var a: Dictionary = _home_formula_bodies[i]
			var b: Dictionary = _home_formula_bodies[j]
			var rect_a := Rect2(a["pos"], a["extent"])
			var rect_b := Rect2(b["pos"], b["extent"])
			if not rect_a.intersects(rect_b):
				continue
			var velocity_a: Vector2 = a["velocity"]
			var velocity_b: Vector2 = b["velocity"]
			var overlap := rect_a.intersection(rect_b).size
			if overlap.x < overlap.y:
				velocity_a.x = -velocity_a.x
				velocity_b.x = -velocity_b.x
				var push_x := overlap.x * 0.5 + 1.0
				a["pos"] = Vector2(a["pos"].x - push_x, a["pos"].y)
				b["pos"] = Vector2(b["pos"].x + push_x, b["pos"].y)
			else:
				velocity_a.y = -velocity_a.y
				velocity_b.y = -velocity_b.y
				var push_y := overlap.y * 0.5 + 1.0
				a["pos"] = Vector2(a["pos"].x, a["pos"].y - push_y)
				b["pos"] = Vector2(b["pos"].x, b["pos"].y + push_y)
			a["velocity"] = velocity_a
			b["velocity"] = velocity_b
			if float(a.get("collision_cooldown", 0.0)) <= 0.0 and float(b.get("collision_cooldown", 0.0)) <= 0.0:
				a = _recompose_home_body(a, false)
				b = _recompose_home_body(b, false)
			_home_formula_bodies[i] = a
			_home_formula_bodies[j] = b


func _update_home_quote() -> void:
	if not is_instance_valid(_home_quote_label):
		return
	var quote: Dictionary = HOME_QUOTES[_home_quote_index]
	_home_quote_label.text = "“%s”\n— %s" % [quote["text"], quote["by"]]


func _use_neutral_theme() -> void:
	_current_theme = NEUTRAL_THEME.duplicate()
	RenderingServer.set_default_clear_color(NEUTRAL_THEME["bg"])
	queue_redraw()


func _use_menu_theme() -> void:
	_current_theme = NEON_THEME.duplicate()
	match _home_cosmic_event:
		"sun": _current_theme["accent"] = Color("#ffae48")
		"black_hole": _current_theme["accent"] = Color("#b78aff")
		"eclipse": _current_theme["accent"] = Color("#43eaff")
		"pulsar": _current_theme["accent"] = Color("#91a9ff")
		_: _current_theme["accent"] = Color("#ff67d8")
	RenderingServer.set_default_clear_color(NEON_THEME["bg"])
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _input(event: InputEvent) -> void:
	if _transitioning:
		return
	if event.is_action_pressed("ui_cancel") and _active_back.is_valid():
		if _menu_backdrop_active:
			_transition_to(_active_back)
		else:
			_active_back.call()
		get_viewport().set_input_as_handled()


func _setup_theme() -> void:
	system_font = SystemFont.new()
	system_font.font_names = PackedStringArray(["Trebuchet MS", "Segoe UI", "Arial"])
	system_font.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	system_font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_AUTO
	formula_font = SystemFont.new()
	formula_font.font_names = PackedStringArray(["Segoe Print", "Cambria Math", "STIX Two Math", "Segoe UI Symbol", "Arial"])
	formula_font.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	formula_font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_AUTO
	var game_theme := Theme.new()
	game_theme.default_font = system_font
	game_theme.default_font_size = 18
	theme = game_theme


func _apply_image_settings() -> void:
	var viewport := get_viewport()
	if viewport:
		viewport.msaa_2d = Viewport.MSAA_4X if bool(settings["antialiasing"]) else Viewport.MSAA_DISABLED
	Engine.max_fps = 30 if bool(settings.get("low_performance", false)) else 0
	RenderingServer.set_default_clear_color(_current_theme.get("bg", PAPER))


func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		settings["fullscreen"] = config.get_value("game", "fullscreen", false)
		settings["animations"] = config.get_value("game", "animations", true)
		settings["font_scale"] = config.get_value("game", "font_scale", 1.0)
		settings["antialiasing"] = config.get_value("game", "antialiasing", false)
		settings["low_performance"] = config.get_value("game", "low_performance", false)


func _save_settings() -> void:
	var config := ConfigFile.new()
	for setting in settings:
		config.set_value("game", setting, settings[setting])
	config.save("user://settings.cfg")


func _load_global_profile() -> void:
	global_profile = {"achievements": [], "completed_programs": [], "completed_subjects": []}
	if FileAccess.file_exists(GLOBAL_PROFILE_PATH):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(GLOBAL_PROFILE_PATH))
		if parsed is Dictionary:
			global_profile = parsed
	for key in ["achievements", "completed_programs", "completed_subjects"]:
		if not (global_profile.get(key, []) is Array):
			global_profile[key] = []
	var changed := false
	for mode in ["solo", "multi"]:
		for slot in range(1, SAVE_COUNT + 1):
			var save := _read_save(slot, mode)
			if save.is_empty():
				continue
			for title in save.get("titles", []):
				changed = _append_global_achievement(str(title)) or changed
			if mode == "solo":
				var program_id := str(save.get("program_id", ""))
				var program := Catalog.program_by_id(program_id)
				if bool(save.get("career_complete", false)) and not program.is_empty():
					changed = _record_completed_career(program_id, str(program.get("title", program.get("name", "Carrera"))), false) or changed
				var passed: Array = save.get("passed_subjects", [])
				for sigla in passed:
					changed = _record_completed_subject(program_id, str(save.get("mention_id", "")), str(sigla), false) or changed
				if bool(save.get("competency_passed", false)):
					changed = _append_global_achievement("Auxiliar docente · examen de competencia aprobado") or changed
	if global_profile["completed_subjects"].size() >= 5:
		changed = _append_global_achievement("Ritmo constante · aprobaste cinco materias en total") or changed
	if global_profile["completed_subjects"].size() >= 20:
		changed = _append_global_achievement("Estudiante incansable · aprobaste veinte materias distintas") or changed
	if global_profile["completed_programs"].size() >= 3:
		changed = _append_global_achievement("Explorador académico · completaste tres carreras diferentes") or changed
	if changed:
		_save_global_profile()


func _append_global_achievement(title: String) -> bool:
	var achievements: Array = global_profile.get("achievements", [])
	if achievements.has(title):
		return false
	achievements.append(title)
	global_profile["achievements"] = achievements
	return true


func _award_title_once(title: String) -> void:
	if _append_global_achievement(title):
		_save_global_profile()


func _record_completed_subject(program_id: String, mention_id: String, sigla: String, persist: bool = true) -> bool:
	var completed: Array = global_profile.get("completed_subjects", [])
	var key := "%s:%s:%s" % [program_id, mention_id, sigla]
	var changed := false
	if not completed.has(key):
		completed.append(key)
		global_profile["completed_subjects"] = completed
		changed = true
	if completed.size() >= 5:
		changed = _append_global_achievement("Ritmo constante · aprobaste cinco materias en total") or changed
	if completed.size() >= 20:
		changed = _append_global_achievement("Estudiante incansable · aprobaste veinte materias distintas") or changed
	if persist and changed:
		_save_global_profile()
	return changed


func _record_completed_career(program_id: String, career_title: String, persist: bool = true) -> bool:
	var completed: Array = global_profile.get("completed_programs", [])
	var changed := false
	if not completed.has(program_id):
		completed.append(program_id)
		global_profile["completed_programs"] = completed
		changed = true
	changed = _append_global_achievement("Título: " + career_title) or changed
	if completed.size() >= 3:
		changed = _append_global_achievement("Explorador académico · completaste tres carreras diferentes") or changed
	if persist and changed:
		_save_global_profile()
	return changed


func _save_global_profile() -> void:
	var file := FileAccess.open(GLOBAL_PROFILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(global_profile, "\t"))
		file.close()


func _show_global_achievements(back: Callable = Callable(), menu_backdrop: bool = true) -> void:
	if not back.is_valid():
		back = Callable(self, "_show_main")
	var content := _make_page("Logros globales", "Se conservan entre partidas y no se borran al eliminar una partida guardada.", back, menu_backdrop)
	var achievements: Array = global_profile.get("achievements", [])
	content.add_child(_label("%d logros desbloqueados" % achievements.size(), 17, _current_theme.get("accent", GREEN), true))
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size.y = 300
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 7)
	scroll.add_child(list)
	if achievements.is_empty():
		list.add_child(_label("Todavía no hay logros. Los progresos de tus partidas cuentan para este perfil general.", 16, _current_theme.get("sub", INK), true))
	else:
		for title in achievements:
			var card := _card(list, true)
			card.add_child(_label("✦  " + str(title), 16, _current_theme.get("accent", GREEN)))
	if menu_backdrop:
		_add_menu_button(content, "Volver", back, false, 42)
	else:
		_add_button(content, "Volver", back, false, 42)


func _make_page(title: String, subtitle: String, back: Callable = Callable(), menu_backdrop: bool = false) -> VBoxContainer:
	if menu_backdrop:
		_activate_menu_backdrop()
	else:
		_menu_backdrop_active = false
		_home_art = false
		set_process(false)
	_active_back = back
	for child in get_children():
		if child == _transition_overlay:
			continue
		remove_child(child)
		child.queue_free()

	var margin := MarginContainer.new()
	if menu_backdrop:
		var centering := CenterContainer.new()
		centering.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(centering)
		var shell := PanelContainer.new()
		shell.custom_minimum_size = Vector2(minf(size.x - 56.0, 820.0), 0.0)
		shell.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		shell.add_theme_stylebox_override("panel", _home_panel_style())
		centering.add_child(shell)
		shell.add_child(margin)
	else:
		margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(margin)
	margin.add_theme_constant_override("margin_left", 22 if menu_backdrop else 42)
	margin.add_theme_constant_override("margin_right", 22 if menu_backdrop else 42)
	margin.add_theme_constant_override("margin_top", 20 if menu_backdrop else 26)
	margin.add_theme_constant_override("margin_bottom", 18 if menu_backdrop else 22)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 11 if menu_backdrop else 15)
	margin.add_child(layout)
	if not title.is_empty():
		var heading := _label(title, 28, _current_theme.get("text", INK), false)
		layout.add_child(heading)
		var accent_rule := ColorRect.new()
		accent_rule.color = _current_theme.get("accent", GOLD)
		accent_rule.custom_minimum_size = Vector2(58, 3)
		accent_rule.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		layout.add_child(accent_rule)
	if not subtitle.is_empty():
		var subheading := _label(subtitle, 15, _current_theme.get("sub", Color("#686a5d")), false)
		layout.add_child(subheading)

	var page_content := VBoxContainer.new()
	page_content.add_theme_constant_override("separation", 13)
	page_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(page_content)
	if back.is_valid():
		var footer := HBoxContainer.new()
		footer.alignment = BoxContainer.ALIGNMENT_BEGIN
		layout.add_child(footer)
		var back_action := Callable(self, "_transition_to").bind(back) if menu_backdrop else back
		_add_button(footer, "← Atrás", back_action, false, 42)
	if bool(settings["animations"]):
		margin.modulate.a = 0.0
		var intro := margin.create_tween()
		intro.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		intro.tween_property(margin, "modulate:a", 1.0, 0.24 if menu_backdrop else 0.16)
	return page_content


func _label(text: String, font_size: int = 18, color: Color = INK, centered: bool = false) -> Label:
	var label := Label.new()
	label.text = text
	if _current_theme.is_empty():
		_current_theme = Catalog.THEME.get("sistemas", {})
	var tcolor = color
	if color == INK:
		tcolor = _current_theme.get("text", INK)
	label.add_theme_color_override("font_color", tcolor)
	label.add_theme_font_size_override("font_size", int(round(font_size * float(settings["font_scale"]))))
	label.add_theme_constant_override("line_spacing", 3)
	if _menu_backdrop_active:
		label.add_theme_color_override("font_outline_color", Color(_current_theme.get("accent", NEON_THEME["accent"]), 0.38))
		label.add_theme_constant_override("outline_size", 1)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if centered:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label


func _add_button(parent: Control, text: String, action: Callable, accent: bool = true, height: int = 56) -> Button:
	var button := Button.new()
	button.text = text
	button.add_theme_constant_override("icon_max_width", 24)
	button.add_theme_constant_override("h_separation", 12)
	button.custom_minimum_size = Vector2(0, height)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.custom_minimum_size.x = 168
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_size_override("font_size", int(round(18 * float(settings["font_scale"]))))
	if accent:
		button.add_theme_color_override("font_color", _current_theme.get("text", Color("#fbf8ee")))
		button.add_theme_color_override("font_hover_color", Color("#ffffff"))
		button.add_theme_color_override("font_pressed_color", Color("#f0f0f0"))
		button.add_theme_color_override("font_focus_color", Color("#ffffff"))
		button.add_theme_color_override("font_disabled_color", Color("#b0b0b0"))
	else:
		button.add_theme_color_override("font_color", _current_theme.get("text", INK))
		button.add_theme_color_override("font_hover_color", _current_theme.get("accent", GREEN))
		button.add_theme_color_override("font_pressed_color", _current_theme.get("accent", GREEN))
		button.add_theme_color_override("font_focus_color", _current_theme.get("accent", GREEN))
		button.add_theme_color_override("font_disabled_color", Color("#9c9688"))
	button.add_theme_stylebox_override("normal", _button_style(accent, "normal"))
	button.add_theme_stylebox_override("hover", _button_style(accent, "hover"))
	button.add_theme_stylebox_override("pressed", _button_style(accent, "pressed"))
	button.add_theme_stylebox_override("disabled", _button_style(accent, "disabled"))
	button.add_theme_stylebox_override("focus", _focus_style())
	if accent:
		button.icon = null
		button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	if action.is_valid():
		button.pressed.connect(action)
	button.mouse_entered.connect(_animate_button.bind(button, true))
	button.mouse_exited.connect(_animate_button.bind(button, false))
	parent.add_child(button)
	return button


func _add_menu_button(parent: Control, text: String, action: Callable, accent: bool = true, height: int = 48) -> Button:
	return _add_button(parent, text, Callable(self, "_transition_to").bind(action), accent, height)


func _button_style(accent: bool, state: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var accent_color = _current_theme.get("accent", GREEN)
	if _menu_backdrop_active:
		style.bg_color = Color(accent_color, 0.19 if accent else 0.12)
		if state == "hover":
			style.bg_color = Color(accent_color, 0.32)
		elif state == "pressed":
			style.bg_color = Color(accent_color, 0.46)
		elif state == "disabled":
			style.bg_color = Color(accent_color, 0.07)
		style.border_color = Color(accent_color, 0.92 if state == "hover" else 0.64)
		style.set_border_width_all(2 if accent else 1)
		style.set_corner_radius_all(18)
		style.content_margin_left = 15
		style.content_margin_right = 15
		style.content_margin_top = 5
		style.content_margin_bottom = 5
		style.shadow_color = Color(accent_color, 0.28 if state == "hover" else 0.12)
		style.shadow_size = 9 if state == "hover" else 4
		style.shadow_offset = Vector2.ZERO
		return style
	if accent:
		style.bg_color = accent_color
		if state == "hover":
			style.bg_color = accent_color.lightened(0.15)
		elif state == "pressed":
			style.bg_color = accent_color.darkened(0.15)
		elif state == "disabled":
			style.bg_color = accent_color.darkened(0.4)
		style.border_color = accent_color.darkened(0.3)
	else:
		style.bg_color = _current_theme.get("panel", Color("#eee8d8"))
		if state == "hover":
			style.bg_color = style.bg_color.lightened(0.08)
		elif state == "pressed":
			style.bg_color = style.bg_color.darkened(0.05)
		elif state == "disabled":
			style.bg_color = style.bg_color.darkened(0.1)
		style.border_color = _current_theme.get("grid", Color("#8c927e"))
	style.set_border_width_all(2)
	style.set_corner_radius_all(14)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	style.shadow_color = Color(0, 0, 0, 0.25)
	style.shadow_size = 2
	style.shadow_offset = Vector2(2, 2)
	return style


func _focus_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.draw_center = false
	style.border_color = _current_theme.get("accent", GOLD)
	style.set_border_width_all(2)
	style.set_corner_radius_all(16)
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 1
	style.shadow_offset = Vector2(1, 1)
	if _menu_backdrop_active:
		style.shadow_color = Color(_current_theme.get("accent", NEON_THEME["accent"]), 0.42)
		style.shadow_size = 7
	return style


func _card(parent: Control, tinted: bool = false) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _card_style(tinted))
	parent.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 7)
	panel.add_child(box)
	return box


func _card_style(tinted: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	if _current_theme.is_empty():
		_current_theme = Catalog.THEME.get("sistemas", {})
	style.bg_color = _current_theme.get("panel", Color("#fbf7ec"))
	style.border_color = _current_theme.get("grid", Color("#d8cdb8"))
	if _menu_backdrop_active:
		style.bg_color = Color("#09111d", 0.82)
		style.border_color = Color(_current_theme.get("accent", NEON_THEME["accent"]), 0.5)
	style.set_border_width_all(2)
	style.set_corner_radius_all(14)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	style.shadow_color = Color(0, 0, 0, 0.25)
	style.shadow_size = 2
	style.shadow_offset = Vector2(2, 2)
	if _menu_backdrop_active:
		style.shadow_color = Color(_current_theme.get("accent", NEON_THEME["accent"]), 0.12)
		style.shadow_size = 8
	return style


func _input_style(focused: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#fffdf7")
	style.border_color = GREEN if focused else Color("#b9b09c")
	style.set_border_width_all(2 if focused else 1)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style


func _style_input(field: LineEdit) -> void:
	field.add_theme_stylebox_override("normal", _input_style(false))
	field.add_theme_stylebox_override("focus", _input_style(true))
	field.add_theme_color_override("font_color", INK)
	field.add_theme_color_override("font_placeholder_color", Color("#9b9381"))
	field.add_theme_color_override("caret_color", GREEN)
	field.add_theme_color_override("selection_color", Color("#d7e0cc"))
	field.add_theme_font_size_override("font_size", int(round(18 * float(settings["font_scale"]))))


func _animate_button(button: Button, hovering: bool) -> void:
	if not bool(settings["animations"]) or not is_instance_valid(button) or button.disabled:
		return
	button.pivot_offset = button.size / 2.0
	var tween := button.create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2(1.015, 1.015) if hovering else Vector2.ONE, 0.12)
	tween.parallel().tween_property(button, "rotation_degrees", 0.35 if hovering else 0.0, 0.12)


func _add_compact_list(parent: Control) -> VBoxContainer:
	var rows := VBoxContainer.new()
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows.add_theme_constant_override("separation", 11)
	rows.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(rows)
	return rows


func _show_main() -> void:
	_active_back = Callable()
	for child in get_children():
		if child == _transition_overlay:
			continue
		remove_child(child)
		child.queue_free()
	var stage := Control.new()
	stage.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(stage)
	_home_quote_index = randi_range(0, HOME_QUOTES.size() - 1)
	_home_quote_time = 0.0
	_activate_menu_backdrop()
	var menu_panel := PanelContainer.new()
	menu_panel.position = Vector2(24, 24)
	menu_panel.custom_minimum_size = Vector2(332, 0)
	menu_panel.add_theme_stylebox_override("panel", _home_panel_style())
	stage.add_child(menu_panel)
	var menu := VBoxContainer.new()
	menu.add_theme_constant_override("separation", 10)
	menu_panel.add_child(menu)
	var eyebrow := _label("CIENCIA · CAMPUS · DECISIONES", 12, Color("#8ff5ff"))
	menu.add_child(eyebrow)
	var title := _label(HOME_NAME, 32, Color("#f4fdff"))
	title.autowrap_mode = TextServer.AUTOWRAP_OFF
	menu.add_child(title)
	menu.add_child(_label("Una vida universitaria para explorar, materia a materia.", 15, Color("#c6d0d4")))
	var menu_gap := Control.new()
	menu_gap.custom_minimum_size.y = 5
	menu.add_child(menu_gap)
	var play_button := _add_menu_button(menu, "Jugar", _show_modes, true, 48)
	play_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	play_button.custom_minimum_size.x = 0
	var options_button := _add_menu_button(menu, "Opciones", _show_options, false, 43)
	options_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	options_button.custom_minimum_size.x = 0
	var achievements_button := _add_menu_button(menu, "Logros globales", _show_global_achievements.bind(Callable(self, "_show_main")), false, 43)
	achievements_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	achievements_button.custom_minimum_size.x = 0
	var exit_button := _add_button(menu, "Salir", Callable(self, "_exit_game"), false, 43)
	exit_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	exit_button.custom_minimum_size.x = 0
	_home_quote_label = _label("", 14, Color("#d1d4d2"), true)
	_home_quote_label.custom_minimum_size = Vector2(310, 58)
	_home_quote_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	var quote_panel := PanelContainer.new()
	quote_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	quote_panel.offset_left = -370
	quote_panel.offset_top = -112
	quote_panel.offset_right = -24
	quote_panel.offset_bottom = -22
	quote_panel.custom_minimum_size = Vector2(346, 90)
	quote_panel.add_theme_stylebox_override("panel", _home_panel_style())
	quote_panel.add_child(_home_quote_label)
	stage.add_child(quote_panel)
	_update_home_quote()


func _home_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#07101b", 0.82)
	var accent: Color = _current_theme.get("accent", NEON_THEME["accent"])
	style.border_color = Color(accent, 0.76)
	style.set_border_width_all(2)
	style.set_corner_radius_all(22)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 17
	style.content_margin_bottom = 17
	style.shadow_color = Color(accent, 0.18)
	style.shadow_size = 18
	style.shadow_offset = Vector2.ZERO
	return style


func _activate_menu_backdrop() -> void:
	_menu_backdrop_active = true
	_home_art = true
	_home_curve_index = random.randi_range(0, HOME_CURVES.size() - 1)
	_home_curve_time = 0.0
	_home_curve_forward.clear()
	_home_curve_backward.clear()
	_initialize_home_cosmos()
	_initialize_home_formulas()
	_use_menu_theme()
	set_process(bool(settings.get("animations", true)))
	queue_redraw()


func _transition_to(action: Callable) -> void:
	if _transitioning or not action.is_valid():
		return
	if not _menu_backdrop_active or not bool(settings.get("animations", true)):
		action.call()
		return
	_transitioning = true
	_home_cosmic_event = "sun"
	_home_cosmic_center = Vector2(random.randf_range(0.18, 0.82), random.randf_range(0.18, 0.82))
	var effect := MenuTransitionEffect.new()
	effect.center = _home_cosmic_center * size
	effect.z_index = 4096
	effect.mouse_filter = Control.MOUSE_FILTER_STOP
	effect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(effect)
	_transition_overlay = effect
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(effect, "progress", 1.0, 0.34)
	tween.tween_callback(Callable(self, "_reveal_menu_target").bind(action, effect))


func _reveal_menu_target(action: Callable, effect: Control) -> void:
	if action.is_valid():
		action.call()
	if not is_instance_valid(effect):
		_complete_menu_transition(effect)
		return
	_transition_revealing = true
	var reveal := create_tween()
	reveal.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	reveal.tween_property(effect, "progress", 0.0, 0.48)
	reveal.tween_callback(Callable(self, "_complete_menu_transition").bind(effect))


func _complete_menu_transition(effect: Control) -> void:
	if is_instance_valid(effect):
		effect.queue_free()
	if _transition_overlay == effect:
		_transition_overlay = null
	_transition_revealing = false
	_transitioning = false
	set_process(_home_art and bool(settings.get("animations", true)))
	queue_redraw()


func _show_options() -> void:
	_use_neutral_theme()
	var content := _make_page("Opciones", "Ajustes visuales para este equipo.", Callable(self, "_show_main"), true)
	var options_grid := GridContainer.new()
	options_grid.columns = 2
	options_grid.add_theme_constant_override("h_separation", 10)
	options_grid.add_theme_constant_override("v_separation", 8)
	content.add_child(options_grid)
	_add_button(options_grid, "Pantalla completa: " + ("Sí" if settings["fullscreen"] else "No"), _toggle_fullscreen, false, 42)
	_add_button(options_grid, "Animaciones: " + ("Activadas" if settings["animations"] else "Reducidas"), _toggle_animations, false, 42)
	_add_button(options_grid, "Suavizado: " + ("Activado" if settings["antialiasing"] else "Desactivado"), _toggle_antialiasing, false, 42)
	_add_button(options_grid, "Bajo consumo: " + ("Sí" if settings["low_performance"] else "No"), _toggle_low_performance, false, 42)
	content.add_child(_label("Bajo consumo reduce partículas y detalles, y limita la animación a 30 FPS.", 13, Color("#9db6c8"), true))
	var scale_label := _label("Tamaño del texto: %d%%" % int(round(float(settings["font_scale"]) * 100.0)), 17)
	content.add_child(scale_label)
	var slider := HSlider.new()
	slider.min_value = 0.8
	slider.max_value = 1.2
	slider.step = 0.05
	slider.value = settings["font_scale"]
	slider.custom_minimum_size.y = 28
	slider.value_changed.connect(_change_font_scale.bind(scale_label))
	slider.drag_ended.connect(_rebuild_options)
	content.add_child(slider)
	content.add_child(_label("Las preferencias se guardan en este equipo.", 14, Color("#9db6c8"), true))
	_add_menu_button(content, "Ver logros globales", _show_global_achievements.bind(Callable(self, "_show_options")), false, 42)


func _toggle_fullscreen() -> void:
	settings["fullscreen"] = not bool(settings["fullscreen"])
	if settings["fullscreen"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	_save_settings()
	_show_options()


func _toggle_animations() -> void:
	settings["animations"] = not bool(settings["animations"])
	_save_settings()
	_show_options()


func _toggle_antialiasing() -> void:
	settings["antialiasing"] = not bool(settings["antialiasing"])
	_apply_image_settings()
	_save_settings()
	_show_options()


func _toggle_low_performance() -> void:
	settings["low_performance"] = not bool(settings["low_performance"])
	_apply_image_settings()
	_save_settings()
	_show_options()


func _change_font_scale(value: float, scale_label: Label) -> void:
	settings["font_scale"] = value
	scale_label.text = "Tamaño del texto: %d%%" % int(round(value * 100.0))
	_save_settings()


func _rebuild_options(_changed: bool) -> void:
	_show_options.call_deferred()


func _show_modes() -> void:
	_use_neutral_theme()
	var content := _make_page("Elige cómo jugar", "Elige una forma de recorrer el campus.", Callable(self, "_show_main"), true)
	var modes := HBoxContainer.new()
	modes.add_theme_constant_override("separation", 14)
	content.add_child(modes)
	var solo_card := _card(modes, true)
	solo_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	solo_card.add_child(_label("SOLO", 24, _current_theme["accent"], true))
	solo_card.add_child(_label("Avanza por materias, rinde tres parciales y completa una carrera. Después puedes postular a auxiliar.", 15, Color("#b9cad5"), true))
	_add_menu_button(solo_card, "Partida solo", _show_solo_slots, true, 46)
	var team_card := _card(modes, true)
	team_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	team_card.add_child(_label("EQUIPO", 24, _current_theme["accent"], true))
	team_card.add_child(_label("Comparte los turnos para resolver tutorías, trámites y decisiones de facultad.", 15, Color("#b9cad5"), true))
	_add_menu_button(team_card, "Partida de equipo", _show_multi_slots, true, 46)


func _show_solo_slots() -> void:
	_show_slots("solo")


func _show_multi_slots() -> void:
	_show_slots("multi")


func _show_slots(mode: String) -> void:
	_use_neutral_theme()
	var mode_label := "Solo" if mode == "solo" else "Equipo local"
	var content := _make_page("Partidas guardadas · " + mode_label, "Tres espacios para este modo, guardados en este equipo.", Callable(self, "_show_modes"), true)
	var rows := _add_compact_list(content)
	var free_slot := _find_free_slot(mode)
	for slot in range(1, SAVE_COUNT + 1):
		var save := _read_save(slot, mode)
		var slot_card := _card(rows)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		slot_card.add_child(row)
		var description := "Espacio %d · vacío" % slot
		if not save.is_empty():
			description = "Espacio %d · %s · %s" % [slot, str(save.get("player_name", "Estudiante")), "Solo" if mode == "solo" else "Equipo"]
			if mode == "solo":
				var program := Catalog.program_by_id(str(save.get("program_id", "")))
				description += " · " + str(program.get("name", "Carrera"))
			else:
				description += " · %s" % str(save.get("role_label", "Auxiliar"))
				var names: Array = save.get("player_names", [])
				var turn_index := int(save.get("current_player", 0))
				if turn_index >= 0 and turn_index < names.size():
					description += " · turno de " + str(names[turn_index])
			var name_label := _label(description, 16)
			name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(name_label)
			_add_menu_button(row, "Continuar", _open_slot.bind(slot, mode), true, 42)
			_add_button(row, "Borrar", _delete_slot.bind(slot, mode), false, 44)
		else:
			var empty_label := _label(description, 16)
			empty_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(empty_label)
			if mode == "solo":
				_add_menu_button(row, "Nueva", _begin_new_game.bind(slot), true, 42)
	if mode == "multi":
		content.add_child(_label("Para abrir una partida de equipo, termina una carrera y aprueba su examen de competencia en Solo.", 15, Color("#686a5d")))
		if free_slot > 0 and _has_eligible_solo_save():
			_add_menu_button(content, "Crear partida de equipo", _choose_team_source, true, 46)
		elif free_slot == 0:
			content.add_child(_label("No hay espacios libres. Borra una partida para crear otra.", 15, GOLD))
	elif free_slot == 0:
		content.add_child(_label("No hay espacios libres. Borra una partida para crear otra.", 15, GOLD))


func _begin_new_game(slot: int) -> void:
	active_slot = slot
	_show_new_solo()


func _open_slot(slot: int, mode: String) -> void:
	current_profile = _read_save(slot, mode)
	active_slot = slot
	if current_profile.is_empty():
		_show_slots(mode)
		return
	if mode == "solo":
		_show_solo_hub()
	else:
		_normalize_team_profile()
		_show_team_hub()


func _delete_slot(slot: int, mode: String) -> void:
	var save := _read_save(slot, mode)
	var dialog := ConfirmationDialog.new()
	dialog.title = "Borrar partida"
	dialog.dialog_text = "¿Borrar la partida de %s del espacio %d? Esta acción no se puede deshacer." % [str(save.get("player_name", "Estudiante")), slot]
	dialog.confirmed.connect(_remove_slot.bind(slot, mode, dialog))
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered()


func _remove_slot(slot: int, mode: String, dialog: ConfirmationDialog) -> void:
	dialog.queue_free()
	var path := _save_path(slot, mode)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	var legacy := _legacy_save_path(slot)
	if FileAccess.file_exists(legacy):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(legacy))
		if parsed is Dictionary and str(parsed.get("mode", "solo")) == mode:
			DirAccess.remove_absolute(ProjectSettings.globalize_path(legacy))
	_show_slots(mode)


func _find_free_slot(mode: String) -> int:
	for slot in range(1, SAVE_COUNT + 1):
		if _read_save(slot, mode).is_empty():
			return slot
	return 0


func _show_new_solo() -> void:
	_use_neutral_theme()
	var content := _make_page("Una partida nueva", "Primero ponle nombre a tu estudiante.", _show_solo_slots)
	var name_field := LineEdit.new()
	name_field.placeholder_text = "Tu nombre o apodo"
	name_field.custom_minimum_size.y = 54
	name_field.text = "Estudiante"
	_style_input(name_field)
	content.add_child(name_field)
	_add_button(content, "Elegir facultad", _choose_faculty_from_field.bind(name_field), true)


func _choose_faculty_from_field(name_field: LineEdit) -> void:
	draft_player_name = name_field.text.strip_edges()
	if draft_player_name.is_empty():
		draft_player_name = "Estudiante"
	_show_faculties()


func _show_faculties() -> void:
	_use_neutral_theme()
	var content := _make_page("Elige una facultad", "Facultad de Ingeniería · Ingeniería de Sistemas e Ingeniería Informática.", _show_new_solo)
	var rows := _add_compact_list(content)
	for faculty in Catalog.FACULTIES:
		var button := _add_button(rows, str(faculty["name"]) + "\n" + str(faculty["description"]), _select_faculty.bind(str(faculty["id"])), false, 82)
		button.add_theme_font_size_override("font_size", int(round(16 * float(settings["font_scale"]))))


func _select_faculty(faculty_id: String) -> void:
	selected_faculty = faculty_id
	_show_programs()


func _show_programs() -> void:
	_use_neutral_theme()
	var faculty := Catalog.faculty_by_id(selected_faculty)
	var content := _make_page(str(faculty.get("name", "Carreras")), "Plan de estudios por semestres con prerrequisitos.", _show_faculties)
	var rows := _add_compact_list(content)
	for program in Catalog.programs_for_faculty(selected_faculty):
		var card := _card(rows)
		var theme := Catalog.get_theme(str(program["id"]))
		var accent: Color = theme.get("accent", GREEN)
		card.add_child(_label(str(program["name"]), 21, accent))
		card.add_child(_label(str(program["summary"]), 15, _current_theme.get("sub", Color("#5f6257"))))
		card.add_child(_label(str(program.get("description", "")), 14, _current_theme.get("sub", Color("#6c6859"))))
		card.add_child(_label("Título al completar: " + str(program["title"]), 14, _current_theme.get("sub", Color("#767262"))))
		_add_button(card, "Ver menciones y actividades", _show_mentions.bind(str(program["id"])), true, 46)


func _show_mentions(program_id: String) -> void:
	_use_neutral_theme()
	var program := Catalog.program_by_id(program_id)
	if program.is_empty():
		_show_programs()
		return
	var theme := Catalog.get_theme(program_id)
	var accent: Color = theme.get("accent", GREEN)
	var content := _make_page("Menciones y enfoques", str(program["name"]) + " · planes FNI publicados en 2011; los temarios detallados requieren revisión", _show_programs)
	var info_card := _card(content)
	info_card.add_child(_label(str(program["name"]), 21, accent))
	info_card.add_child(_label(str(program.get("description", "")), 15, theme.get("sub", Color("#5f6257"))))
	var rows := GridContainer.new()
	rows.columns = 2
	rows.add_theme_constant_override("h_separation", 10)
	rows.add_theme_constant_override("v_separation", 10)
	content.add_child(rows)
	var art_colors := [Color("#5d8975"), Color("#57859a"), Color("#b87754"), Color("#8b70a0"), Color("#bd9b50")]
	var mention_index := 0
	for mention in Catalog.mentions_for_program(program_id):
		var card := _card(rows)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 14)
		card.add_child(row)
		var color: Color = art_colors[mention_index % art_colors.size()]
		var illustration := MentionArt.new()
		illustration.setup(str(mention["id"]), color)
		row.add_child(illustration)
		var copy := VBoxContainer.new()
		copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(copy)
		copy.add_child(_label(str(mention["name"]), 18, color))
		copy.add_child(_label(str(mention["focus"]), 14, theme.get("sub", Color("#5f6257"))))
		copy.add_child(_label("Proyecto de muestra: " + str(mention["activity"]), 13, theme.get("sub", Color("#767262"))))
		var actions := HFlowContainer.new()
		actions.add_theme_constant_override("h_separation", 8)
		card.add_child(actions)
		_add_button(actions, "Empezar carrera", _create_solo_save.bind(program_id, str(mention["id"])), true, 42)
		_add_button(actions, "Plan y simulación", Callable(self, "_show_curriculum").bind(program_id, str(mention["id"])), false, 42)
		mention_index += 1


func _create_solo_save(program_id: String, mention_id: String) -> void:
	var program := Catalog.program_by_id(program_id)
	var mention := Catalog.mention_by_id(program_id, mention_id)
	current_profile = {
		"slot": active_slot,
		"mode": "solo",
		"player_name": draft_player_name,
		"program_id": program_id,
		"mention_id": mention_id,
		"mention_name": mention.get("name", ""),
		"role_id": "estudiante",
		"completed_subjects": 0,
		"partial_index": 0,
		"career_complete": false,
		"competency_passed": false,
		"confidence": 60,
		"credits": 100,
		"chanchullo_used": [],
		"created_at": Time.get_datetime_string_from_system(),
	}
	if program.is_empty():
		_show_solo_slots()
		return
	_save_profile()
	_show_solo_hub()


func _show_solo_hub() -> void:
	var program := Catalog.program_by_id(str(current_profile.get("program_id", "")))
	if program.is_empty():
		_show_solo_slots()
		return
	var theme := Catalog.get_theme(str(program["id"]))
	var accent: Color = theme.get("accent", GREEN)
	_current_theme = theme
	queue_redraw()
	var passed: Array = current_profile.get("passed_subjects", [])
	var failed: Array = current_profile.get("failed_subjects", [])
	current_profile["passed_subjects"] = passed
	current_profile["failed_subjects"] = failed
	if not current_profile.has("subject_progress"):
		current_profile["subject_progress"] = {}
	var sprog: Dictionary = current_profile["subject_progress"]
	var mention := Catalog.mention_by_id(str(program["id"]), str(current_profile.get("mention_id", "")))
	var mention_id := str(current_profile.get("mention_id", ""))
	var subjects := Catalog.all_subjects(str(program["id"]), mention_id)
	if subjects.is_empty():
		var unavailable := _make_page("Plan no disponible", "Esta partida no tiene una mención válida para la malla seleccionada.", _show_solo_slots)
		_add_button(unavailable, "Volver a partidas guardadas", _show_solo_slots, true, 54)
		return
	var subtitle := str(program["name"])
	if not mention.is_empty():
		subtitle += " · " + str(mention["name"])
	var page := _make_page("Hola, " + str(current_profile.get("player_name", "Estudiante")), subtitle, _show_solo_slots)
	var semesters: Array = Catalog.semesters_for(str(program["id"]), mention_id)
	var current_sem := 1
	for semester in semesters:
		var all_passed := true
		for subject in semester.get("subjects", []):
			if not passed.has(subject.get("sigla", "")):
				all_passed = false
				break
		if all_passed:
			current_sem = int(semester.get("order", 0)) + 1
		else:
			current_sem = int(semester.get("order", 1))
			break
	if current_sem > semesters.size() and not bool(current_profile.get("career_complete", false)):
		current_profile["career_complete"] = true
		_record_completed_career(str(program["id"]), str(program["title"]))
		_save_profile()
		_show_solo_hub()
		return
	var progress_card := _card(page, true)
	var completed_semesters := clampi(current_sem - 1, 0, semesters.size())
	progress_card.add_child(_label("RECORRIDO  ·  %d de %d semestres" % [completed_semesters, semesters.size()], 17, accent, true))
	var progress := ProgressBar.new()
	progress.max_value = maxf(semesters.size(), 1)
	progress.value = completed_semesters
	progress.show_percentage = false
	progress.custom_minimum_size.y = 12
	progress_card.add_child(progress)
	progress_card.add_child(_label("%d / %d materias aprobadas   ·   Confianza %d" % [passed.size(), subjects.size(), int(current_profile.get("confidence", 60))], 14, theme.get("sub", INK), true))
	if not bool(current_profile.get("career_complete", false)):
		var current_data: Dictionary = semesters[current_sem - 1]
		var active_card := _card(page)
		active_card.add_child(_label("SEMESTRE %02d  ·  %s" % [current_sem, str(current_data.get("name", ""))], 21, accent, true))
		active_card.add_child(_label("Toca una tarjeta para estudiar. El progreso queda guardado por materia.", 14, theme.get("sub", INK), true))
		var grid := GridContainer.new()
		grid.columns = 3 if size.x >= 1100 else 2
		grid.add_theme_constant_override("h_separation", 10)
		grid.add_theme_constant_override("v_separation", 8)
		active_card.add_child(grid)
		for subject in current_data.get("subjects", []):
			var sigla := str(subject.get("sigla", ""))
			var is_passed := passed.has(sigla)
			var detail: Dictionary = sprog.get(sigla, {})
			var partial := 3 if is_passed else clampi(int(detail.get("partial", 0)), 0, 3)
			var subject_color := Color("#678c6d")
			if sigla.begins_with("MAT"):
				subject_color = Color("#ad8b43")
			elif sigla.begins_with("FIS") or sigla.begins_with("QMC"):
				subject_color = Color("#b87552")
			elif sigla.begins_with("INF") or sigla.begins_with("ELT"):
				subject_color = Color("#51849a")
			var card_button := Button.new()
			card_button.custom_minimum_size = Vector2(220, 92)
			card_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			card_button.text = "%s\n%s\n%s" % [sigla, str(subject.get("name", "")), "APROBADA" if is_passed else ("Parcial %d/3" % (partial + 1) if partial > 0 else "Lista para empezar")]
			card_button.disabled = is_passed
			card_button.add_theme_font_size_override("font_size", int(round(14 * float(settings["font_scale"]))))
			var card_style := StyleBoxFlat.new()
			card_style.bg_color = Color("#dbe8d8") if is_passed else Color(subject_color, 0.14)
			card_style.border_color = Color("#6b8f71") if is_passed else subject_color
			card_style.set_border_width_all(2)
			card_style.set_corner_radius_all(12)
			card_button.add_theme_stylebox_override("normal", card_style)
			card_button.add_theme_stylebox_override("hover", card_style)
			card_button.add_theme_stylebox_override("disabled", card_style)
			card_button.pressed.connect(_start_subject.bind(sigla))
			grid.add_child(card_button)
		var retryable: Array[String] = []
		for sigla in failed:
			var subject := Catalog.subject_by_sigla(str(program["id"]), str(sigla), mention_id)
			if not subject.is_empty():
				retryable.append(str(sigla))
		if not retryable.is_empty():
			var retry_row := HFlowContainer.new()
			retry_row.add_theme_constant_override("h_separation", 8)
			page.add_child(retry_row)
			for sigla in retryable:
				var subject := Catalog.subject_by_sigla(str(program["id"]), sigla, mention_id)
				_add_button(retry_row, "Reintentar " + sigla + " · " + str(subject.get("name", "")), Callable(self, "_start_subject").bind(sigla), false, 42)
	else:
		var finished := _card(page, true)
		finished.add_child(_label("CARRERA COMPLETADA", 23, GREEN, true))
		finished.add_child(_label(str(program["title"]) + " · auxiliar disponible al aprobar competencia", 16, theme.get("sub", INK), true))
		if not bool(current_profile.get("competency_passed", false)):
			_add_button(finished, "Rendir examen de competencia", _show_competency, true, 48)
	var actions := HFlowContainer.new()
	actions.add_theme_constant_override("h_separation", 8)
	page.add_child(actions)
	_add_button(actions, "Ver recorrido por semestres", Callable(self, "_show_curriculum_graph").bind(str(program["id"]), true), false, 42)
	_add_button(actions, "Logros", _show_titles, false, 42)
	_add_button(actions, "Cambiar carrera", _show_solo_slots, false, 42)
	_add_button(actions, "Guardar y salir", _return_to_menu, false, 42)


func _start_subject(sigla: String) -> void:
	current_profile["current_subject"] = sigla
	if not current_profile.has("subject_progress"):
		current_profile["subject_progress"] = {}
	if not current_profile.has("partial_index"):
		current_profile["partial_index"] = 0
	var sprog: Dictionary = current_profile["subject_progress"]
	var p := 0
	if sprog.has(sigla):
		var sp: Dictionary = sprog[sigla]
		if bool(sp.get("complete", false)):
			_show_solo_hub()
			return
		p = int(sp.get("partial", 0))
	current_profile["partial_index"] = p
	_save_profile()
	_show_exam()

func _show_exam() -> void:
	var program := Catalog.program_by_id(str(current_profile.get("program_id", "")))
	if program.is_empty():
		_show_solo_slots()
		return
	var sigla := str(current_profile.get("current_subject", ""))
	if sigla == "":
		_show_solo_hub()
		return
	if not current_profile.has("subject_progress"):
		current_profile["subject_progress"] = {}
	var sprog: Dictionary = current_profile["subject_progress"]
	if not current_profile.has("partial_index"):
		current_profile["partial_index"] = 0
	var mention_id := str(current_profile.get("mention_id", ""))
	var course := Catalog.course_for_sigla(str(program["id"]), sigla, mention_id)
	if course.is_empty():
		_show_solo_hub()
		return
	var partials: Array = course.get("partials", [])
	if partials.is_empty():
		_show_solo_hub()
		return
	var partial_index := int(current_profile.get("partial_index", 0))
	if sprog.has(sigla):
		var sp: Dictionary = sprog[sigla]
		if bool(sp.get("complete", false)):
			_show_solo_hub()
			return
		if int(sp.get("partial", 0)) > partial_index:
			partial_index = int(sp.get("partial", 0))
			current_profile["partial_index"] = partial_index
	if partial_index < 0 or partial_index >= partials.size():
		partial_index = 0
		current_profile["partial_index"] = partial_index
	current_question = partials[partial_index]
	var theme := Catalog.get_theme(str(program["id"]))
	var accent: Color = theme.get("accent", GREEN)
	_current_theme = theme
	queue_redraw()
	var content := _make_page("Parcial %d / 3 · %s (%s)" % [partial_index + 1, str(course["name"]), sigla], "Semestre %d · Progreso: Parcial %d de 3" % [int(course.get("semester",0)), partial_index + 1], Callable(self, "_show_solo_hub"))
	var topics: Array = course.get("topics", [])
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 18)
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(columns)
	var lesson := _card(columns, true)
	lesson.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lesson.add_child(_label("APUNTE RÁPIDO", 13, accent))
	lesson.add_child(_label("Idea clave: %s parte de «%s» y la aplica en situaciones concretas." % [str(course.get("name", "La materia")).to_lower(), str(topics[0]) if not topics.is_empty() else str(course.get("name", "la materia"))], 13, theme.get("sub", INK)))
	lesson.add_child(_label("Temas de la materia: " + ", ".join(topics), 12, theme.get("sub", INK)))
	var demo := StudyDemo.new()
	demo.setup(course, partial_index)
	lesson.add_child(demo)
	var exam_column := VBoxContainer.new()
	exam_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	exam_column.add_theme_constant_override("separation", 7)
	columns.add_child(exam_column)
	exam_column.add_child(_label("COMPRUEBA TU IDEA · PARCIAL %d/3" % (partial_index + 1), 13, accent, true))
	exam_column.add_child(_label(str(current_question["q"]), 19, accent, true))
	for option_index in range(current_question["options"].size()):
		_add_button(exam_column, str(current_question["options"][option_index]), _answer_subject.bind(option_index), false, 48)
	var key := "%s:%d" % [sigla, partial_index]
	var used: Array = current_profile.get("chanchullo_used", [])
	var cheat_button := _add_button(exam_column, "Chanchullo · usar apunte", _try_chanchullo.bind(key), true, 42)
	if used.has(key):
		cheat_button.disabled = true
		cheat_button.tooltip_text = "Ya usaste el chanchullo en este parcial."
	else:
		cheat_button.tooltip_text = "Una oportunidad por parcial. Puede salir bien o pillarte."


func _answer_subject(option_index: int) -> void:
	_finish_subject_question(option_index == int(current_question["answer"]), false)


func _try_chanchullo(key: String) -> void:
	var used: Array = current_profile.get("chanchullo_used", [])
	if used.has(key):
		return
	used.append(key)
	current_profile["chanchullo_used"] = used
	if random.randi_range(1, 100) <= 55:
		_finish_subject_question(true, true)
	else:
		current_profile["confidence"] = maxi(0, int(current_profile.get("confidence", 60)) - 8)
		_save_profile()
		_show_result("Te pillaron", "El apunte no ayudó y bajó un poco tu confianza. Este parcial sigue pendiente; puedes volver a intentarlo sin hacer chanchullo.", false, _show_exam)


func _finish_subject_question(correct: bool, cheated: bool) -> void:
	var program := Catalog.program_by_id(str(current_profile.get("program_id", "")))
	if program.is_empty():
		_show_solo_slots()
		return
	var mention_id := str(current_profile.get("mention_id", ""))
	var subjects := Catalog.all_subjects(str(program["id"]), mention_id)
	var sigla := str(current_profile.get("current_subject", ""))
	if sigla.is_empty() or Catalog.subject_by_sigla(str(program["id"]), sigla, mention_id).is_empty():
		_show_solo_hub()
		return
	var partial_index := int(current_profile.get("partial_index", 0))
	if not current_profile.has("passed_subjects"):
		current_profile["passed_subjects"] = []
	if not current_profile.has("failed_subjects"):
		current_profile["failed_subjects"] = []
	if not current_profile.has("subject_progress"):
		current_profile["subject_progress"] = {}
	var passed: Array = current_profile["passed_subjects"]
	var failed: Array = current_profile["failed_subjects"]
	var sprog: Dictionary = current_profile["subject_progress"]
	if correct:
		if partial_index == 0:
			_award_title_once("Primer paso · aprobaste tu primer parcial")
		if not cheated:
			current_profile["confidence"] = mini(100, int(current_profile.get("confidence", 60)) + 4)
		partial_index += 1
		var message := str(current_question["why"])
		if cheated:
			message += " El apunte pasó esta vez, pero una respuesta copiada no suma confianza."
		if partial_index >= 3:
			current_profile["partial_index"] = 0
			sprog[sigla] = {"partial": 3, "complete": true}
			current_profile["subject_progress"] = sprog
			if not passed.has(sigla):
				passed.append(sigla)
				_record_completed_subject(str(program["id"]), mention_id, sigla)
			var used_partials: Array = current_profile.get("chanchullo_used", [])
			var subject_used_cheat := false
			for partial_number in range(3):
				if used_partials.has("%s:%d" % [sigla, partial_number]):
					subject_used_cheat = true
			if not subject_used_cheat:
				_award_title_once("A pulso · aprobaste una materia sin chanchullo")
			if failed.has(sigla):
				failed.erase(sigla)
			current_profile["passed_subjects"] = passed
			current_profile["failed_subjects"] = failed
			var course := Catalog.course_for_sigla(str(program["id"]), sigla, mention_id)
			if course.is_empty():
				course = Catalog.course(str(program["id"]), int(current_profile.get("completed_subjects", 0)), mention_id)
			message += " Aprobaste los tres parciales de %s (%s)." % [str(course.get("name","")), sigla]
			if passed.size() >= subjects.size():
				current_profile["career_complete"] = true
				_record_completed_career(str(program["id"]), str(program["title"]))
				message += " Completaste el plan de estudios y ganaste el título «%s»." % str(program["title"])
			_save_profile()
			_show_result("Materia aprobada", message, true, _show_solo_hub)
		else:
			current_profile["partial_index"] = partial_index
			sprog[sigla] = {"partial": partial_index, "complete": false}
			current_profile["subject_progress"] = sprog
			message += " Parcial %d aprobado. Siguiente: Parcial %d." % [partial_index, partial_index + 1]
			_save_profile()
			_show_result("Parcial aprobado", message, true, _show_exam)
	else:
		current_profile["confidence"] = maxi(0, int(current_profile.get("confidence", 60)) - 3)
		if partial_index >= 2 and not failed.has(sigla):
			failed.append(sigla)
			current_profile["failed_subjects"] = failed
			sprog[sigla] = {"partial": partial_index, "complete": false, "failed": true}
			current_profile["subject_progress"] = sprog
		_save_profile()
		_show_result("Parcial pendiente", str(current_question["why"]) + " Puedes repasar y volver a intentarlo cuando quieras.", false, _show_exam)


func _show_competency() -> void:
	var program := Catalog.program_by_id(str(current_profile.get("program_id", "")))
	if program.is_empty() or not bool(current_profile.get("career_complete", false)):
		_show_solo_hub()
		return
	var subjects := Catalog.all_subjects(str(program["id"]), str(current_profile.get("mention_id", "")))
	var theme := Catalog.get_theme(str(program["id"]))
	var accent: Color = theme.get("accent", GREEN)
	var last: Dictionary = subjects.back()
	var questions: Array = [
		{"q": "Tienes una tarea para apoyar: ¿cómo priorizas para entender mejor un problema técnico?", "options": ["Identificar el problema, datos y restricciones antes de proponer solución", "Empezar a escribir sin entender el enunciado", "Copiar lo primero que encuentres sin analizar"], "answer": 0, "why": "Definir bien el problema es la base para cualquier solución."},
		{"q": "Ante un tema nuevo de %s, ¿qué estrategia te parece más efectiva?" % str(program["name"]), "options": ["Relacionarlo con lo visto antes y practicar con ejemplos", "Memorizar sin contexto", "Estudiar solo la noche antes"], "answer": 0, "why": "Conectar con conocimientos previos y practicar acelera el aprendizaje."},
		{"q": "Si trabajas con %s y hay un error, ¿cómo lo abordas?" % str(last.get("name", "la materia")), "options": ["Revisar paso a paso, aislar el fallo y validar", "Cambiar todo sin entender", "Ignorar el error"], "answer": 0, "why": "El enfoque sistemático permite encontrar la causa raíz."}
	]
	var choice := random.randi_range(0, questions.size() - 1)
	current_question = questions[choice]
	var content := _make_page("Examen de competencia", "Demuestra que puedes apoyar a otra persona con base en tu plan de estudios.", Callable(self, "_show_solo_hub"))
	content.add_child(_label(str(current_question["q"]), 24, accent, true))
	for option_index in range(current_question["options"].size()):
		_add_button(content, str(current_question["options"][option_index]), _answer_competency.bind(option_index), false, 56)
	content.add_child(_label("Si no sale, puedes volver a intentarlo.", 14, Color("#686a5d"), true))


func _answer_competency(option_index: int) -> void:
	if option_index == int(current_question["answer"]):
		current_profile["competency_passed"] = true
		current_profile["role_id"] = "auxiliar"
		_award_title_once("Auxiliar docente · examen de competencia aprobado")
		_save_profile()
		_show_result("Competencia aprobada", "Ya puedes iniciar una partida de equipo como auxiliar docente.", true, _show_solo_hub)
	else:
		_show_result("Todavía no", str(current_question["why"]) + " Revisa la idea y vuelve a intentarlo.", false, _show_competency)


func _show_titles() -> void:
	_show_global_achievements(Callable(self, "_show_solo_hub"), false)


func _has_eligible_solo_save() -> bool:
	for slot in range(1, SAVE_COUNT + 1):
		var save := _read_save(slot, "solo")
		if bool(save.get("career_complete", false)) and bool(save.get("competency_passed", false)):
			return true
	return false


func _choose_team_source() -> void:
	var content := _make_page("Elige a quién vas a representar", "Solo aparecen carreras completas con competencia aprobada.", _show_multi_slots)
	var rows := _add_compact_list(content)
	for slot in range(1, SAVE_COUNT + 1):
		var save := _read_save(slot, "solo")
		if bool(save.get("career_complete", false)) and bool(save.get("competency_passed", false)):
			var program := Catalog.program_by_id(str(save.get("program_id", "")))
			_add_button(rows, "%s · %s" % [str(save.get("player_name", "Estudiante")), str(program.get("name", "Carrera"))], _show_team_setup.bind(slot), false, 54)


func _show_team_setup(source_slot: int) -> void:
	if source_slot == 0:
		_show_multi_slots()
		return
	draft_source_slot = source_slot
	var source := _read_save(source_slot, "solo")
	var content := _make_page("Armen el equipo", "%s abre la partida como auxiliar. El turno irá rotando entre las personas del equipo." % str(source.get("player_name", "Estudiante")), _show_multi_slots)
	var form := _card(content)
	form.add_child(_label("¿Cuántas personas van a turnarse en esta computadora?", 18, INK, true))
	var players := SpinBox.new()
	players.min_value = 1
	players.max_value = 4
	players.value = 2
	players.custom_minimum_size = Vector2(160, 48)
	players.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	form.add_child(players)
	players.get_line_edit().alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_input(players.get_line_edit())
	team_name_drafts = [
		str(source.get("player_name", "Estudiante")),
		"Jugador 2",
		"Jugador 3",
		"Jugador 4",
	]
	team_name_box = VBoxContainer.new()
	team_name_box.add_theme_constant_override("separation", 8)
	form.add_child(team_name_box)
	_fill_team_name_fields(int(players.value))
	players.value_changed.connect(_on_team_players_changed)
	content.add_child(_label("Cada caso lo resuelve quien tenga el turno. Al terminar, pasa al siguiente jugador.", 14, Color("#686a5d"), true))
	_add_button(content, "Empezar partida de equipo", _create_team_save.bind(players), true, 60)


func _fill_team_name_fields(count: int) -> void:
	if not is_instance_valid(team_name_box):
		return
	for child in team_name_box.get_children():
		team_name_box.remove_child(child)
		child.queue_free()
	team_name_fields.clear()
	for index in range(count):
		var field := LineEdit.new()
		field.placeholder_text = "Nombre del jugador %d" % (index + 1)
		field.text = str(team_name_drafts[index]) if index < team_name_drafts.size() else "Jugador %d" % (index + 1)
		field.custom_minimum_size.y = 46
		_style_input(field)
		team_name_box.add_child(field)
		team_name_fields.append(field)


func _store_team_names() -> void:
	for index in range(team_name_fields.size()):
		if index < team_name_drafts.size():
			var field: LineEdit = team_name_fields[index]
			team_name_drafts[index] = field.text


func _on_team_players_changed(value: float) -> void:
	_store_team_names()
	_fill_team_name_fields(int(value))


func _create_team_save(players: SpinBox) -> void:
	var slot := _find_free_slot("multi")
	if slot == 0:
		_show_result("No hay espacio", "Borra una partida guardada antes de crear una partida de equipo.", false, _show_multi_slots)
		return
	active_slot = slot
	_store_team_names()
	var count := int(players.value)
	var names: Array = []
	var scores: Array = []
	var confidence: Array = []
	for index in range(count):
		var candidate: String = str(team_name_drafts[index]).strip_edges() if index < team_name_drafts.size() else ""
		if candidate.is_empty():
			candidate = "Jugador %d" % (index + 1)
		names.append(candidate)
		scores.append(0)
		confidence.append(60)
	var source := _read_save(draft_source_slot, "solo")
	var program := Catalog.program_by_id(str(source.get("program_id", "")))
	current_profile = {
		"slot": slot,
		"mode": "multi",
		"player_name": names[0],
		"player_names": names,
		"player_scores": scores,
		"player_confidence": confidence,
		"current_player": 0,
		"program_id": source.get("program_id", ""),
		"source_slot": draft_source_slot,
		"players": count,
		"role_id": "auxiliar",
		"role_label": "Auxiliar docente",
		"assistant_cases": 0,
		"admin_cases": 0,
		"dean_cases": 0,
		"team_score": 0,
		"cv_items": [],
		"cv_submitted": false,
		"created_at": Time.get_datetime_string_from_system(),
	}
	if program.is_empty():
		_show_multi_slots()
		return
	_save_profile()
	_show_team_hub()


func _normalize_team_profile() -> void:
	var count := maxi(1, int(current_profile.get("players", 1)))
	current_profile["players"] = count
	var names: Array = current_profile.get("player_names", [])
	while names.size() < count:
		if names.is_empty():
			names.append(str(current_profile.get("player_name", "Jugador 1")))
		else:
			names.append("Jugador %d" % (names.size() + 1))
	while names.size() > count:
		names.pop_back()
	current_profile["player_names"] = names
	var scores: Array = current_profile.get("player_scores", [])
	while scores.size() < count:
		scores.append(0)
	current_profile["player_scores"] = scores
	var confidence: Array = current_profile.get("player_confidence", [])
	var base_confidence := int(current_profile.get("team_confidence", 60))
	while confidence.size() < count:
		confidence.append(base_confidence)
	current_profile["player_confidence"] = confidence
	var current := int(current_profile.get("current_player", 0))
	current_profile["current_player"] = ((current % count) + count) % count


func _current_player_name() -> String:
	var names: Array = current_profile.get("player_names", [])
	var index := int(current_profile.get("current_player", 0))
	if index >= 0 and index < names.size():
		return str(names[index])
	return str(current_profile.get("player_name", "Estudiante"))


func _advance_team_turn() -> void:
	var count := maxi(1, int(current_profile.get("players", 1)))
	current_profile["current_player"] = (int(current_profile.get("current_player", 0)) + 1) % count


func _award_team_case(best: bool) -> void:
	var index := int(current_profile.get("current_player", 0))
	var scores: Array = current_profile.get("player_scores", [])
	var confidence: Array = current_profile.get("player_confidence", [])
	while scores.size() <= index:
		scores.append(0)
	while confidence.size() <= index:
		confidence.append(60)
	if best:
		scores[index] = int(scores[index]) + 10
		confidence[index] = mini(100, int(confidence[index]) + 6)
	else:
		confidence[index] = maxi(0, int(confidence[index]) - 5)
	current_profile["player_scores"] = scores
	current_profile["player_confidence"] = confidence


func _add_team_scoreboard(content: VBoxContainer) -> void:
	var names: Array = current_profile.get("player_names", [])
	var scores: Array = current_profile.get("player_scores", [])
	var confidence: Array = current_profile.get("player_confidence", [])
	var current := int(current_profile.get("current_player", 0))
	var board := VBoxContainer.new()
	board.add_theme_constant_override("separation", 4)
	var board_card := _card(content, true)
	board_card.add_child(board)
	for index in range(names.size()):
		var active := index == current
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		var name_label := _label(("▶  " if active else "    ") + str(names[index]), 16, GREEN if active else INK)
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_label)
		var score := int(scores[index]) if index < scores.size() else 0
		var trust := int(confidence[index]) if index < confidence.size() else 60
		row.add_child(_label("%d pts · confianza %d" % [score, trust], 14, Color("#686a5d")))
		board.add_child(row)
	board.add_child(_label("Experiencia del equipo: %d" % int(current_profile.get("team_score", 0)), 15, INK, true))


func _team_mvp() -> Dictionary:
	var names: Array = current_profile.get("player_names", [])
	var scores: Array = current_profile.get("player_scores", [])
	if names.is_empty() or scores.is_empty():
		return {}
	var best_index := 0
	for index in range(scores.size()):
		if int(scores[index]) > int(scores[best_index]):
			best_index = index
	if best_index >= names.size():
		return {}
	return {"name": str(names[best_index]), "score": int(scores[best_index])}


func _show_team_hub() -> void:
	if current_profile.is_empty() or current_profile.get("mode", "") != "multi":
		_show_multi_slots()
		return
	_normalize_team_profile()
	var role := str(current_profile.get("role_id", "auxiliar"))
	var role_name := "Auxiliar docente" if role == "auxiliar" else "Administrativo" if role == "administrativo" else "Decano"
	var program := Catalog.program_by_id(str(current_profile.get("program_id", "")))
	var names: Array = current_profile.get("player_names", [])
	var content := _make_page("Equipo de " + str(program.get("name", "la universidad")), "%d participantes · turno de %s" % [names.size(), _current_player_name()], _show_multi_slots)
	content.add_child(_label("Turno de " + _current_player_name(), 22, GREEN, true))
	content.add_child(_label("Rol del equipo: " + role_name, 15, Color("#686a5d"), true))
	_add_team_scoreboard(content)
	if role == "auxiliar":
		var done := int(current_profile.get("assistant_cases", 0))
		if done < ASSISTANT_CASES.size():
			_show_team_case_content(content, ASSISTANT_CASES[done], role, done)
		else:
			content.add_child(_label("Tres tutorías completadas. Ya puedes armar tu CV para postular a un cargo administrativo.", 18, GREEN, true))
			_add_button(content, "Armar CV universitario", _show_cv_builder, true, 62)
	elif role == "administrativo":
		var done := int(current_profile.get("admin_cases", 0))
		if done < ADMIN_CASES.size():
			_show_team_case_content(content, ADMIN_CASES[done], role, done)
		else:
			content.add_child(_label("Has atendido tres casos y ahora puedes presentar una propuesta al consejo de facultad.", 18, GREEN, true))
			_add_button(content, "Presentar candidatura a decano", _show_dean_vote, true, 62)
	else:
		var done := int(current_profile.get("dean_cases", 0))
		if done < DEAN_CASES.size():
			_show_team_case_content(content, DEAN_CASES[done], role, done)
		else:
			content.add_child(_label("Terminaste la gestión de facultad. El consejo recibió tus decisiones y su seguimiento.", 19, GREEN, true))
			content.add_child(_label("Puntaje final del equipo: %d" % int(current_profile.get("team_score", 0)), 16, INK, true))
			var mvp := _team_mvp()
			if not mvp.is_empty():
				content.add_child(_label("Mejor puntaje individual: %s (%d pts)" % [str(mvp["name"]), int(mvp["score"])], 15, GOLD, true))
			_add_button(content, "Ver logros", _show_team_titles, false, 48)
	_add_button(content, "Guardar y volver al inicio", _return_to_menu, false, 48)


func _show_team_case_content(content: VBoxContainer, simulation: Dictionary, role: String, case_index: int) -> void:
	var role_title := "Tutoría" if role == "auxiliar" else "Mesa administrativa" if role == "administrativo" else "Consejo de facultad"
	content.add_child(_label("%s · situación %d de 3" % [role_title, case_index + 1], 23, GREEN, true))
	content.add_child(_label("Decide " + _current_player_name(), 14, GOLD, true))
	content.add_child(_label(str(simulation["question"]), 19, INK, true))
	for option_index in range(simulation["options"].size()):
		_add_button(content, str(simulation["options"][option_index]), _choose_team_case.bind(role, case_index, option_index), false, 52)


func _choose_team_case(role: String, case_index: int, choice_index: int) -> void:
	var cases: Array = ASSISTANT_CASES if role == "auxiliar" else ADMIN_CASES if role == "administrativo" else DEAN_CASES
	var simulation: Dictionary = cases[case_index]
	var best := choice_index == int(simulation["best"])
	var feedback := str(simulation["good"] if best else simulation["bad"])
	var deciding_player := _current_player_name()
	_award_team_case(best)
	if best:
		current_profile["team_score"] = int(current_profile.get("team_score", 0)) + 10
	if role == "auxiliar":
		current_profile["assistant_cases"] = case_index + 1
		if int(current_profile["assistant_cases"]) == ASSISTANT_CASES.size():
			_award_title_once("Auxiliar atento · completaste las tres tutorías")
	elif role == "administrativo":
		current_profile["admin_cases"] = case_index + 1
		if int(current_profile["admin_cases"]) == ADMIN_CASES.size():
			_award_title_once("Gestión universitaria · resolviste tres trámites")
	else:
		current_profile["dean_cases"] = case_index + 1
		if int(current_profile["dean_cases"]) == DEAN_CASES.size():
			_award_title_once("Decano de facultad · ciclo de gestión completado")
	_advance_team_turn()
	_save_profile()
	_show_result("Decisión de " + deciding_player, feedback + " Turno de %s." % _current_player_name(), best, Callable(self, "_show_team_hub"))


func _show_cv_builder(reset: bool = true) -> void:
	if reset:
		cv_draft = current_profile.get("cv_items", []).duplicate()
	var content := _make_page("Arma tu CV", "Turno de %s · elige al menos tres experiencias que puedas respaldar." % _current_player_name(), Callable(self, "_show_team_hub"))
	for skill in CV_SKILLS:
		var prefix := "☑  " if cv_draft.has(skill) else "□  "
		_add_button(content, prefix + skill, _toggle_cv_item.bind(skill), false, 50)
	content.add_child(_label("Experiencias elegidas: %d / 4" % cv_draft.size(), 15, Color("#686a5d"), true))
	_add_button(content, "Enviar CV", _submit_cv, true, 58)


func _toggle_cv_item(skill: String) -> void:
	if cv_draft.has(skill):
		cv_draft.erase(skill)
	else:
		cv_draft.append(skill)
	_show_cv_builder(false)


func _submit_cv() -> void:
	if cv_draft.size() < 3:
		_show_result("CV incompleto", "La convocatoria pide al menos tres experiencias. Completa el CV y vuelve a enviarlo.", false, _show_cv_builder)
		return
	current_profile["cv_items"] = cv_draft.duplicate()
	current_profile["cv_submitted"] = true
	_save_profile()
	_show_admin_interview()


func _show_admin_interview() -> void:
	var content := _make_page("Entrevista administrativa", "Responde %s · criterio, atención y cuidado de datos." % _current_player_name(), Callable(self, "_show_cv_builder"))
	content.add_child(_label("Llegan dos trámites con plazos distintos y a uno le faltan datos. ¿Cómo los atiendes?", 22, INK, true))
	_add_button(content, "Verifico lo necesario, priorizo el vencimiento y dejo registro de lo pendiente", _answer_admin_interview.bind(true), false, 58)
	_add_button(content, "Apruebo los dos sin revisar para terminar rápido", _answer_admin_interview.bind(false), false, 58)
	_add_button(content, "Pido los datos personales completos de todo el grupo", _answer_admin_interview.bind(false), false, 58)


func _answer_admin_interview(correct: bool) -> void:
	if not correct:
		_show_result("La entrevista sigue pendiente", "La convocatoria necesita una decisión verificable y centrada en el trámite. Puedes repasar tu CV e intentarlo otra vez.", false, _show_admin_interview)
		return
	current_profile["role_id"] = "administrativo"
	current_profile["role_label"] = "Administrativo"
	_award_title_once("Gestión responsable · CV y entrevista aprobados")
	_advance_team_turn()
	_save_profile()
	_show_result("Te contrataron", "El CV y la entrevista abrieron el cargo. Ahora vienen casos de registros, recursos y atención universitaria. Turno de %s." % _current_player_name(), true, _show_team_hub)


func _show_dean_vote() -> void:
	var content := _make_page("Consejo de facultad", "Responde %s · la experiencia administrativa permite postular y el consejo revisa el criterio." % _current_player_name(), Callable(self, "_show_team_hub"))
	content.add_child(_label("¿Cómo presentarías el presupuesto anual de 100 puntos?", 22, INK, true))
	_add_button(content, "Repartirlo con criterios públicos, revisar necesidades y fijar seguimiento", _answer_dean_vote.bind(true), false, 58)
	_add_button(content, "Asignarlo según popularidad y ver después qué falta", _answer_dean_vote.bind(false), false, 58)
	_add_button(content, "Gastar todo en una compra antes de comparar propuestas", _answer_dean_vote.bind(false), false, 58)


func _answer_dean_vote(approved: bool) -> void:
	if not approved:
		_show_result("La candidatura sigue en revisión", "El consejo pide una propuesta justificable y con seguimiento del dinero. Puedes ajustar el planteamiento e intentarlo otra vez.", false, _show_dean_vote)
		return
	current_profile["role_id"] = "decano"
	current_profile["role_label"] = "Decano"
	_award_title_once("Decano electo · candidatura aprobada")
	_advance_team_turn()
	_save_profile()
	_show_result("El consejo te eligió", "La candidatura fue aprobada. Ahora tendrás que tomar decisiones de presupuesto, revisar inversiones y rendir cuentas. Turno de %s." % _current_player_name(), true, _show_team_hub)


func _show_team_titles() -> void:
	_show_global_achievements(Callable(self, "_show_team_hub"), false)


func _return_to_menu() -> void:
	_save_profile()
	current_profile = {}
	_show_main()


func _exit_game() -> void:
	_save_profile()
	get_tree().quit()


func _show_result(title: String, body: String, positive: bool, next: Callable) -> void:
	var return_page := Callable(self, "_show_solo_hub") if current_profile.get("mode", "solo") == "solo" else Callable(self, "_show_team_hub")
	var content := _make_page(title, "", return_page)
	var card := _card(content)
	card.add_child(_label(body, 20, GREEN if positive else INK, true))
	_add_button(content, "Continuar", next, true, 62)


func _save_path(slot: int, mode: String) -> String:
	return "%s/%s_partida_%d.json" % [SAVE_DIR, mode, slot]


func _legacy_save_path(slot: int) -> String:
	return "%s/partida_%d.json" % [SAVE_DIR, slot]


func _read_save(slot: int, mode: String) -> Dictionary:
	var path := _save_path(slot, mode)
	if not FileAccess.file_exists(path):
		var legacy := _legacy_save_path(slot)
		if not FileAccess.file_exists(legacy):
			return {}
		var legacy_parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(legacy))
		if legacy_parsed is Dictionary and str(legacy_parsed.get("mode", "solo")) == mode:
			return legacy_parsed
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed is Dictionary:
		return parsed
	return {}


func _save_profile() -> void:
	if current_profile.is_empty():
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SAVE_DIR))
	current_profile["slot"] = active_slot
	current_profile["updated_at"] = Time.get_datetime_string_from_system()
	var mode := str(current_profile.get("mode", "solo"))
	var file := FileAccess.open(_save_path(active_slot, mode), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(current_profile, "\t"))
		file.close()


const GraphScene := preload("res://scripts/curriculum_graph.gd")
const StudyDemo := preload("res://scripts/study_demo.gd")
const MentionArt := preload("res://scripts/mention_art.gd")

func _show_curriculum_graph(program_id: String, return_to_hub: bool = false, selected_mention_id: String = "") -> void:
	var program := Catalog.program_by_id(program_id)
	if program.is_empty(): return
	var theme := Catalog.get_theme(program_id)
	_current_theme = theme
	queue_redraw()
	var mention_id := str(current_profile.get("mention_id", "")) if return_to_hub else selected_mention_id
	var mention := Catalog.mention_by_id(program_id, mention_id)
	var page_back := Callable(self, "_show_solo_hub") if return_to_hub else Callable(self, "_show_mentions").bind(program_id)
	var page_subtitle := str(program.get("name", "")) + " · Plan FNI 2011"
	if not mention.is_empty():
		page_subtitle += " · " + str(mention.get("name", ""))
	var content := _make_page("Plan de estudios y recorrido", page_subtitle, page_back)
	var graph := GraphScene.new()
	var graph_width := minf(660.0, size.x - 42.0 * 2.0 - 310.0)
	graph.setup(program_id, mention_id, graph_width)
	var semester := HBoxContainer.new()
	semester.alignment = BoxContainer.ALIGNMENT_CENTER
	semester.add_theme_constant_override("separation", 10)
	content.add_child(semester)
	var back_semester := _add_button(semester, "← Semestre anterior", Callable(graph, "move_semester").bind(-1), false, 42)
	var counter := _label("SEMESTRE 1 / 10", 18, theme.get("accent", GREEN), true)
	counter.custom_minimum_size.x = 230
	semester.add_child(counter)
	var next_semester := _add_button(semester, "Siguiente semestre →", Callable(graph, "move_semester").bind(1), true, 42)
	var overview := HBoxContainer.new()
	overview.add_theme_constant_override("separation", 14)
	overview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(overview)
	graph.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	overview.add_child(graph)
	var details := _card(overview)
	details.custom_minimum_size.x = 280
	var pager := HBoxContainer.new()
	pager.alignment = BoxContainer.ALIGNMENT_CENTER
	pager.add_theme_constant_override("separation", 5)
	content.add_child(pager)
	var dots: Array[Label] = []
	for index in range(Catalog.semesters_for(program_id, mention_id).size()):
		var dot := _label("●" if index == 0 else "·", 17 if index == 0 else 14, theme.get("accent", GREEN), true)
		dot.custom_minimum_size.x = 18
		pager.add_child(dot)
		dots.append(dot)
	details.add_child(_label("Elige una materia para consultar su descripción, temas y prerrequisitos.", 13, theme.get("sub", Color("#9fb3c8"))))
	back_semester.disabled = true
	graph.semester_changed.connect(_update_graph_pager.bind(counter, dots, back_semester, next_semester))
	graph.subject_selected.connect(_show_graph_subject.bind(details))


func _update_graph_pager(index: int, count: int, counter: Label, dots: Array[Label], previous: Button, next: Button) -> void:
	counter.text = "SEMESTRE %d / %d" % [index + 1, count]
	previous.disabled = index <= 0
	next.disabled = index >= count - 1
	for dot_index in range(dots.size()):
		dots[dot_index].text = "●" if dot_index == index else "·"
		dots[dot_index].add_theme_font_size_override("font_size", 17 if dot_index == index else 14)

func _show_curriculum(program_id: String, mention_id: String) -> void:
	_show_curriculum_graph(program_id, false, mention_id)


func _show_graph_subject(sigla: String, data: Dictionary, details: VBoxContainer) -> void:
	for child in details.get_children():
		details.remove_child(child)
		child.queue_free()
	if bool(data.get("admission", false)):
		details.add_child(_label("INGRESO A LA FNI", 17, Color("#d0ae74")))
		details.add_child(_label(str(data.get("desc", "")), 12, _current_theme.get("sub", INK)))
		for admission_mode in data.get("admission_modes", []):
			details.add_child(_label("• " + str(admission_mode), 11, _current_theme.get("text", INK)))
		details.add_child(_label(str(data.get("notice", "")), 11, _current_theme.get("accent", GOLD)))
		return
	var prerequisites: Array = data.get("prereq", [])
	var topics: Array = data.get("topics", [])
	details.add_child(_label(str(data.get("name", "")) + " · " + sigla, 18, _current_theme.get("accent", GREEN)))
	var description := _label(str(data.get("desc", "")), 13, _current_theme.get("sub", INK))
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_child(description)
	details.add_child(_label("Semestre %s  ·  Requiere: %s" % [str(data.get("semester", "")), ", ".join(prerequisites) if not prerequisites.is_empty() else "Ingreso"], 12, _current_theme.get("sub", INK)))
	if not topics.is_empty():
		details.add_child(_label("Temas: " + ", ".join(topics), 12, _current_theme.get("sub", INK)))
