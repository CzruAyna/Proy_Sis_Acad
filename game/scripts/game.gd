extends Control

const Catalog = preload("res://scripts/catalog.gd")
const NeonVisuals = preload("res://scripts/neon_visuals.gd")
const Achievements = preload("res://scripts/achievement_catalog.gd")
const Simulation = preload("res://scripts/student_simulation.gd")
const SimulationCommands = preload("res://scripts/simulation_commands.gd")
const SimulationProcedures = preload("res://scripts/simulation_procedures.gd")
const SimulationSaveStore = preload("res://scripts/simulation_save_store.gd")
const CareerStoryUI = preload("res://scripts/career_story_ui.gd")
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
var _visual_program_id := ""
var _visual_mention_id := ""

const ASSISTANT_CASES := [
	{"question": "En la tutoría, alguien memoriza una fórmula pero no entiende cuándo usarla. ¿Qué haces?", "options": ["Resolver todo por esa persona", "Proponer un ejemplo sencillo y pedirle que explique el paso", "Decir que vuelva cuando ya sepa"], "best": 1, "good": "La persona practica el razonamiento y puede detectar qué parte le cuesta.", "bad": "La tutoría sirve más cuando ayuda a entender el proceso, no solo a copiar el resultado."},
	{"question": "Dos estudiantes piden ayuda al mismo tiempo y queda poco de la hora. ¿Cómo organizas el apoyo?", "options": ["Acordar una prioridad y dejar un siguiente paso claro para ambas personas", "Atender solo a quien habla más fuerte", "Cerrar la tutoría sin avisar"], "best": 0, "good": "La prioridad queda clara y nadie se va sin saber qué hacer después.", "bad": "Coordinar tiempos y expectativas evita que el apoyo dependa de quién insiste más."},
	{"question": "Una respuesta de la guía parece tener un error. ¿Qué haces antes de difundirla?", "options": ["Verificar el procedimiento y consultar al docente si sigue la duda", "Cambiarla en silencio y repartir otra versión", "Decir al grupo que la guía no sirve"], "best": 0, "good": "Revisar la evidencia y avisar del cambio evita que el error se replique.", "bad": "Una duda se resuelve mejor comprobando el procedimiento y comunicando el resultado."},
]

var current_profile: Dictionary = {}
const CampusUI = preload("res://scripts/student_campus.gd")
const PagedView = preload("res://scripts/paged_view.gd")
const Ambient = preload("res://scripts/mention_ambient.gd")
var _ambient: TextureRect
var _options_page := 0
var campus_ui: RefCounted
var career_story_ui: RefCounted
var _campus_section := "resumen"
var _save_feedback := ""
var _save_failed := false
var simulation: RefCounted
var simulation_console: Control
var save_store := SimulationSaveStore.new()
var global_profile: Dictionary = {"achievements": [], "completed_programs": [], "completed_subjects": []}
var active_slot := 0
var selected_faculty := ""
var draft_player_name := ""
var current_question: Dictionary = {}
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
	_load_global_profile()
	_setup_theme()
	_use_menu_theme()
	get_window().min_size = Vector2i(900, 640)
	_apply_image_settings()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if settings["fullscreen"] else DisplayServer.WINDOW_MODE_WINDOWED)
	_show_main()
	queue_redraw()


func _draw() -> void:
	if _current_theme.is_empty():
		_current_theme = NEUTRAL_THEME
	var bg: Color = _current_theme.get("bg", PAPER)
	draw_rect(Rect2(Vector2.ZERO, size), bg)
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
	if _home_cosmic_event == "sun" and burn > 0.08:
		_draw_home_flames(body, burn)
	var economical := bool(settings.get("low_performance", false))
	var kind := str(body.get("kind", "text"))
	if kind in ["integral", "definite_integral"]:
		var symbol_size := int(round(font_size * 1.58))
		var limit_size := maxi(10, int(round(font_size * 0.58)))
		var symbol_width := formula_font.get_string_size("∫", HORIZONTAL_ALIGNMENT_LEFT, -1, symbol_size).x
		NeonVisuals.text(self, formula_font, position + Vector2(0.0, font_size * 1.72), "∫", symbol_size, color, economical)
		if kind == "definite_integral":
			NeonVisuals.text(self, formula_font, position + Vector2(symbol_width * 0.72, font_size * 0.67), str(body["upper"]), limit_size, color, economical)
			NeonVisuals.text(self, formula_font, position + Vector2(symbol_width * 0.78, font_size * 2.05), str(body["lower"]), limit_size, color, economical)
		NeonVisuals.text(self, formula_font, position + Vector2(symbol_width + 7.0, font_size * 1.35), str(body["integrand"]) + " " + str(body["result"]), font_size, color, economical)
	else:
		NeonVisuals.text(self, formula_font, position + Vector2(0.0, font_size), str(body["text"]), font_size, color, economical)


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
	for segment in segments:
		if segment.size() < 2:
			continue
		var visible_points := PackedVector2Array()
		for point in segment:
			visible_points.append(_home_curve_visual_point(point))
		if str(HOME_CURVES[_home_curve_index]) != "tan":
			NeonVisuals.path(self, visible_points, color, 2.8, bool(settings.get("low_performance", false)))
			continue
		for i in range(1, visible_points.size()):
			if absf(visible_points[i].y - visible_points[i - 1].y) < minf(size.y * 0.15, 120.0):
				NeonVisuals.line(self, visible_points[i - 1], visible_points[i], color, 2.8, 1.0, bool(settings.get("low_performance", false)))


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
	_visual_program_id = ""
	_visual_mention_id = ""
	_current_theme = NEUTRAL_THEME.duplicate()
	_sync_ambient()
	RenderingServer.set_default_clear_color(NEUTRAL_THEME["bg"])
	queue_redraw()


func _use_menu_theme() -> void:
	_visual_program_id = ""
	_visual_mention_id = ""
	_current_theme = NEON_THEME.duplicate()
	match _home_cosmic_event:
		"sun": _current_theme["accent"] = Color("#ffae48")
		"black_hole": _current_theme["accent"] = Color("#b78aff")
		"eclipse": _current_theme["accent"] = Color("#43eaff")
		"pulsar": _current_theme["accent"] = Color("#91a9ff")
		_: _current_theme["accent"] = Color("#ff67d8")
	_sync_ambient()
	RenderingServer.set_default_clear_color(NEON_THEME["bg"])
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F10 and not current_profile.is_empty():
		_show_simulation_console()
		get_viewport().set_input_as_handled()
		return
	if is_instance_valid(simulation_console) and simulation_console.visible and event.is_action_pressed("ui_cancel"):
		_close_simulation_console()
		get_viewport().set_input_as_handled()
		return
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
	game_theme.default_font = ThemeDB.fallback_font
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
	var changed := Achievements.ensure_profile(global_profile)
	for slot in range(1, SAVE_COUNT + 1):
		var saved := _read_save(slot, "solo")
		if not saved.is_empty():
			changed = Achievements.evaluate(global_profile, saved) or changed
	if changed:
		_save_global_profile()


func _append_global_achievement(title: String) -> bool:
	return Achievements.record_title(global_profile, title)


func _award_title_once(title: String) -> void:
	if _append_global_achievement(title):
		_save_global_profile()


func _record_completed_subject(program_id: String, mention_id: String, sigla: String, persist: bool = true) -> bool:
	var changed := Achievements.ensure_profile(global_profile)
	var key := "%s:%s:%s" % [program_id, mention_id, sigla]
	if not global_profile["completed_subjects"].has(key):
		global_profile["completed_subjects"].append(key)
		changed = true
	changed = Achievements.evaluate(global_profile) or changed
	if persist and changed:
		_save_global_profile()
	return changed


func _record_completed_career(program_id: String, career_title: String, persist: bool = true) -> bool:
	var changed := Achievements.ensure_profile(global_profile)
	if not global_profile["completed_programs"].has(program_id):
		global_profile["completed_programs"].append(program_id)
		changed = true
	changed = _append_global_achievement("Título: " + career_title) or changed
	changed = Achievements.evaluate(global_profile) or changed
	if persist and changed:
		_save_global_profile()
	return changed


func _save_global_profile() -> void:
	var file := FileAccess.open(GLOBAL_PROFILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(global_profile, "\t"))
		file.close()


func _show_global_achievements(back: Callable = Callable(), _menu_backdrop: bool = true) -> void:
	_refresh_global_achievements()
	if not back.is_valid():
		back = Callable(self, "_show_main")
	_use_neutral_theme()
	var content := _make_page("Logros globales", "Consulta todos los logros públicos. Los ocultos se revelan cuando los consigues.", back, false)
	var catalog := Achievements.presentation(global_profile)
	content.add_child(_label("%d / %d logros públicos desbloqueados" % [int(catalog["public_unlocked"]), catalog["public"].size()], 17, _current_theme.get("accent", GREEN)))
	content.add_child(_label("Los logros se conservan entre partidas y al borrar un recorrido.", 14, _current_theme.get("sub", INK)))
	for item in catalog["public"]:
		_achievement_card(content, item)
	content.add_child(_label("Logros ocultos · %d / %d descubiertos" % [catalog["secrets"].size(), int(catalog["hidden_total"])], 21, _current_theme.get("accent", GREEN)))
	if catalog["secrets"].size() < int(catalog["hidden_total"]):
		content.add_child(_label("Todavía quedan secretos por descubrir durante tus recorridos.", 15, _current_theme.get("sub", INK)))
	for item in catalog["secrets"]:
		_achievement_card(content, item)
	if not catalog["legacy"].is_empty():
		content.add_child(_label("Logros de recorridos anteriores", 21, _current_theme.get("accent", GREEN)))
		for title in catalog["legacy"]:
			var card := _card(content)
			card.add_child(_label("✦ " + str(title), 16, _current_theme.get("text", INK)))


func _make_page(title: String, subtitle: String, back: Callable = Callable(), menu_backdrop: bool = false) -> VBoxContainer:
	if not current_profile.is_empty() and simulation != null and not menu_backdrop:
		_apply_career_theme(str(current_profile["program_id"]), str(current_profile["mention_id"]))
	if menu_backdrop:
		_activate_menu_backdrop()
	else:
		_menu_backdrop_active = false
		_home_art = false
		set_process(false)
	_active_back = back
	_sync_ambient()
	for child in get_children():
		if child == _transition_overlay or child == _ambient:
			continue
		remove_child(child)
		child.queue_free()
	var margin := MarginContainer.new()
	margin.name = "PageMargin"
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(margin)
	var graph_workspace := title in ["Tu malla y sus conexiones", "Explora el plan de estudios", "Grafo de la historia"]
	var maximum_width := 1100.0 if graph_workspace else 880.0
	var resize_page := func() -> void:
		var side := maxi(24, int((size.x - maximum_width) * 0.5))
		margin.add_theme_constant_override("margin_left", side)
		margin.add_theme_constant_override("margin_right", side)
	resized.connect(resize_page)
	margin.tree_exiting.connect(func() -> void:
		if resized.is_connected(resize_page):
			resized.disconnect(resize_page))
	resize_page.call()
	for edge in ["top", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 16)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 8)
	margin.add_child(layout)
	if not current_profile.is_empty() and simulation != null and not menu_backdrop:
		var program_name := "Sistemas" if current_profile["program_id"] == "sistemas" else "Informática"
		var identity := _label("PARTIDA %d · %s · %s · Periodo %d" % [active_slot, str(current_profile.get("player_name", "Estudiante")).left(40), program_name, int(simulation.state["term"])], 13, _current_theme.get("neon", Color.WHITE))
		identity.name = "PlayerIdentity"
		identity.tooltip_text = str(current_profile.get("player_name", "")) + " · " + str(current_profile.get("mention_name", ""))
		layout.add_child(identity)
	if not title.is_empty():
		layout.add_child(_label(title, 24, _current_theme.get("text", INK)))
	if not subtitle.is_empty() and not graph_workspace:
		layout.add_child(_label(subtitle, 13, _current_theme.get("sub", INK)))
	if not current_profile.is_empty() and simulation != null and not menu_backdrop and not graph_workspace:
		_add_campus_navigation(layout)
	var pager := PagedView.new()
	layout.add_child(pager)
	pager.configure(self)
	var content: VBoxContainer = pager.content
	if back.is_valid():
		var footer := HBoxContainer.new()
		layout.add_child(footer)
		var action := Callable(self, "_transition_to").bind(back) if menu_backdrop else back
		var back_label := "Guardar y salir" if back == Callable(self, "_return_to_menu") else "← Atrás"
		var button := _add_button(footer, back_label, action, false, 42)
		button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		if not current_profile.is_empty() and simulation != null:
			footer.add_child(_label("Simulación educativa", 12, _current_theme.get("sub", INK)))
		if not _save_feedback.is_empty() and not current_profile.is_empty():
			footer.add_child(_label(_save_feedback, 13, _current_theme.get("sub", INK)))
	if bool(settings["animations"]):
		margin.modulate.a = 0.0
		margin.create_tween().tween_property(margin, "modulate:a", 1.0, 0.14)
	return content


func _campus() -> RefCounted:
	if campus_ui == null:
		campus_ui = CampusUI.new(self)
	return campus_ui


func _show_campus_section(section: String) -> void:
	if simulation == null:
		_show_solo_slots()
		return
	_campus_section = section
	if section == "malla":
		_show_curriculum_graph(str(current_profile["program_id"]), true)
	else:
		_campus().render(section)


func _add_campus_navigation(parent: Control) -> void:
	var navigation := HFlowContainer.new()
	navigation.name = "CampusNavigation"
	navigation.add_theme_constant_override("h_separation", 6)
	navigation.add_theme_constant_override("v_separation", 6)
	parent.add_child(navigation)
	var sections := [["resumen", "Mi campus"], ["materias", "Materias"], ["malla", "Malla"], ["tramites", "Trámites"], ["historial", "Historial"], ["auxiliatura", "Auxiliatura"], ["graduacion", "Graduación"]]
	for section in sections:
		var button := _add_button(navigation, section[1], _show_campus_section.bind(section[0]), _campus_section == section[0], 38)
		button.custom_minimum_size.x = maxf(100, ThemeDB.fallback_font.get_string_size(section[1], HORIZONTAL_ALIGNMENT_LEFT, -1, int(14 * float(settings["font_scale"]))).x + 42)
		button.autowrap_mode = TextServer.AUTOWRAP_OFF
		button.add_theme_font_size_override("font_size", int(14 * float(settings["font_scale"])))
		if _campus_section == section[0]:
			_focus_control.call_deferred(weakref(button))


func _adaptive_grid(parent: Control, minimum_width: float = 360.0, maximum_columns: int = 3) -> GridContainer:
	var grid := GridContainer.new()
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	parent.add_child(grid)
	var update := func() -> void:
		grid.columns = clampi(floori((grid.size.x + 14.0) / (minimum_width * float(settings["font_scale"]) + 14.0)), 1, maximum_columns)
	grid.resized.connect(update)
	update.call_deferred()
	return grid


func _focus_control(reference: WeakRef) -> void:
	var control = reference.get_ref()
	if is_instance_valid(control) and control.is_inside_tree() and control.is_visible_in_tree():
		control.grab_focus()


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
	if _current_theme.has("neon") and font_size >= 20:
		label.add_theme_color_override("font_shadow_color", Color(_current_theme["neon"], 0.5))
		label.add_theme_constant_override("shadow_outline_size", 3)
		label.add_theme_constant_override("shadow_offset_x", 0)
		label.add_theme_constant_override("shadow_offset_y", 0)
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
	button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.custom_minimum_size.x = clampf(ThemeDB.fallback_font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, int(18 * float(settings["font_scale"]))).x + 36, 112, 300)
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
	if _current_theme.has("neon"):
		button.add_theme_color_override("font_shadow_color", Color(_current_theme["neon"], 0.4))
		button.add_theme_constant_override("shadow_outline_size", 2)
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
	if _current_theme.has("neon"):
		return NeonVisuals.button(_current_theme, accent, state, bool(settings.get("low_performance", false)))
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
	style.shadow_color = Color(_current_theme.get("neon", _current_theme.get("accent", Color("#39bcff"))), 0.45)
	style.shadow_size = 9
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
	if _current_theme.has("neon"):
		return NeonVisuals.panel(_current_theme, tinted, bool(settings.get("low_performance", false)))
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
	var theme_data := _current_theme if _current_theme.has("neon") else NeonVisuals.career("sistemas")
	var style := NeonVisuals.panel(theme_data, focused, bool(settings.get("low_performance", false)))
	style.bg_color = theme_data["bg"]
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	style.set_corner_radius_all(8)
	return style


func _style_input(field: LineEdit) -> void:
	field.add_theme_stylebox_override("normal", _input_style(false))
	field.add_theme_stylebox_override("focus", _input_style(true))
	field.add_theme_color_override("font_color", _current_theme.get("text", Color("#edf8ff")))
	field.add_theme_color_override("font_placeholder_color", _current_theme.get("sub", Color("#b3cde6")))
	field.add_theme_color_override("caret_color", _current_theme.get("neon", Color("#39bcff")))
	field.add_theme_color_override("selection_color", Color(_current_theme.get("accent", Color("#338aff")), 0.5))
	field.add_theme_font_size_override("font_size", int(round(18 * float(settings["font_scale"]))))


func _style_select(field: Control) -> void:
	field.add_theme_stylebox_override("normal", _input_style(false))
	field.add_theme_stylebox_override("focus", _input_style(true))
	field.add_theme_color_override("font_color", _current_theme.get("text", Color("#edf8ff")))
	field.add_theme_color_override("font_hover_color", _current_theme.get("core", Color.WHITE))
	if field.has_method("configure"):
		field.add_theme_stylebox_override("hover", _button_style(false, "hover"))
		field.add_theme_stylebox_override("pressed", _button_style(false, "pressed"))
		field.configure(self)
		field.tooltip_text = "Elegir mediante botones o buscar una opción"


func _apply_career_theme(program_id: String, mention_id: String = "") -> void:
	_visual_program_id = program_id
	_visual_mention_id = mention_id
	_current_theme = NeonVisuals.career(program_id, mention_id)
	_sync_ambient()
	RenderingServer.set_default_clear_color(_current_theme["bg"])
	queue_redraw()


func _animate_button(button: Button, hovering: bool) -> void:
	if not _menu_backdrop_active:
		return
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
		if child == _transition_overlay or child == _ambient:
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
	menu_panel.size = Vector2(minf(420.0, size.x - 48.0), size.y - 48.0)
	menu_panel.add_theme_stylebox_override("panel", _home_panel_style())
	stage.add_child(menu_panel)
	stage.resized.connect(func() -> void: menu_panel.size = Vector2(minf(420.0, stage.size.x - 48.0), stage.size.y - 48.0))
	var menu_pages := PagedView.new()
	menu_panel.add_child(menu_pages)
	menu_pages.configure(self)
	var menu: VBoxContainer = menu_pages.content
	var eyebrow := _label("SISTEMAS · INFORMÁTICA · TU RECORRIDO", 12, Color("#8ff5ff"))
	menu.add_child(eyebrow)
	var title := _label(HOME_NAME, 32, Color("#f4fdff"))
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	menu.add_child(title)
	menu.add_child(_label("Explora tu carrera, elige tus materias y vive las decisiones del campus.", 15, Color("#c6d0d4")))
	var menu_gap := Control.new()
	menu_gap.custom_minimum_size.y = 5
	menu.add_child(menu_gap)
	var recent := _recent_slot()
	if recent > 0:
		var saved := _read_save(recent, "solo")
		menu.add_child(_label("Última partida · " + str(saved.get("player_name", "Estudiante")), 14, Color("#c6d0d4")))
		_add_menu_button(menu, "Continuar mi recorrido", _open_slot.bind(recent, "solo"), true, 48)
	var play_button := _add_menu_button(menu, "Nueva carrera", _new_available_game, recent == 0, 46)
	_add_menu_button(menu, "Mis partidas", _show_solo_slots, false, 42)
	_add_menu_button(menu, "Historia de una carrera", _show_career_story, false, 43).name = "CareerStoryEntry"
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
	# Keep the approved home composition: one consistent vertical menu.
	for action in menu.get_children():
		if action is Button:
			action.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			action.custom_minimum_size.x = 0
	_home_quote_label = _label("", 14, Color("#d1d4d2"), true)
	_home_quote_label.custom_minimum_size = Vector2(0, 58)
	_home_quote_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	var quote_panel := PanelContainer.new()
	quote_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	quote_panel.offset_left = -370
	quote_panel.offset_top = -180
	quote_panel.offset_right = -24
	quote_panel.offset_bottom = -22
	quote_panel.custom_minimum_size = Vector2(346, 90)
	quote_panel.add_theme_stylebox_override("panel", _home_panel_style())
	quote_panel.add_child(_home_quote_label)
	stage.add_child(quote_panel)
	_update_home_quote()


func _home_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#07101b", 0.94)
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


func _show_career_story() -> void:
	if career_story_ui == null:
		career_story_ui = CareerStoryUI.new(self)
	career_story_ui.show_setup()


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
	tween.tween_property(effect, "progress", 1.0, 0.16)
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
	reveal.tween_property(effect, "progress", 0.0, 0.2)
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
	var content := _make_page("Opciones del juego", "Elige cómo ver y recorrer el juego. Los cambios se guardan en este equipo.", Callable(self, "_show_main"), true)
	_menu_backdrop_active = false
	_home_art = false
	set_process(false)
	_apply_career_theme("sistemas")
	var grid := _adaptive_grid(content, 330.0, 2)
	var choices := [
		["DisplayOption", "Pantalla", "Pantalla completa aprovecha el monitor. Ventana permite trabajar junto a otras aplicaciones.", "Usar ventana" if settings["fullscreen"] else "Usar pantalla completa", _toggle_fullscreen, "Pantalla completa" if settings["fullscreen"] else "En ventana"],
		["MotionOption", "Movimiento y efectos", "Reduce las animaciones si prefieres una experiencia tranquila. Las acciones y resultados siguen disponibles.", "Reducir movimiento" if settings["animations"] else "Activar animaciones", _toggle_animations, "Animaciones activas" if settings["animations"] else "Movimiento reducido"],
		["SmoothingOption", "Bordes y líneas", "El suavizado reduce los bordes dentados en grafos y dibujos. Puede exigir más trabajo a la tarjeta gráfica.", "Desactivar suavizado" if settings["antialiasing"] else "Activar suavizado", _toggle_antialiasing, "Suavizado activado" if settings["antialiasing"] else "Suavizado desactivado"],
		["PerformanceOption", "Rendimiento", "Bajo consumo reduce partículas y halos y limita la animación a 30 FPS. Útil en equipos con menos recursos.", "Usar calidad normal" if settings["low_performance"] else "Activar bajo consumo", _toggle_low_performance, "Bajo consumo" if settings["low_performance"] else "Calidad normal"]
	]
	for item in choices:
		var card := _card(grid)
		card.name = item[0]
		card.add_child(_label(item[1], 21))
		card.add_child(_label(item[2], 14, _current_theme["sub"]))
		card.add_child(_label("Actual: " + item[5], 14, _current_theme.get("neon", _current_theme["accent"])))
		_add_button(card, item[3], item[4], true, 40)
	var text_card := _card(content, true)
	text_card.name = "TextScaleChoices"
	text_card.get_parent().size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	text_card.get_parent().custom_minimum_size.x = 620
	text_card.add_child(_label("Tamaño de las letras", 21))
	text_card.add_child(_label("Ajusta todo el texto de la interfaz. Las páginas se reorganizan para conservar los controles accesibles.", 14, _current_theme["sub"]))
	var sample := _label("Así leerás los textos · %d%%" % int(float(settings["font_scale"]) * 100), 18)
	sample.name = "TextScalePreview"
	text_card.add_child(sample)
	var sizes := HFlowContainer.new()
	sizes.add_theme_constant_override("h_separation", 10)
	text_card.add_child(sizes)
	for value in [0.8, 1.0, 1.2]:
		var button := _add_button(sizes, "%d%%" % int(value * 100), _set_font_scale.bind(value), is_equal_approx(float(settings["font_scale"]), value), 40)
		button.name = "TextScale%d" % int(value * 100)
	var pager = find_child("PageNavigator", true, false)
	pager.page_index = _options_page
	pager.page_changed.connect(func(index: int, _count: int) -> void: _options_page = index)


func _set_font_scale(value: float) -> void:
	settings["font_scale"] = clampf(value, 0.8, 1.2)
	_save_settings()
	_show_options()


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


func _show_modes() -> void:
	_show_solo_slots()


func _show_solo_slots() -> void:
	_show_slots("solo")


func _show_slots(mode: String) -> void:
	if mode != "solo":
		return
	_use_neutral_theme()
	var content := _make_page("Partidas de estudiante", "Tres espacios guardados en este equipo.", Callable(self, "_show_main"), true)
	var rows := _add_compact_list(content)
	for slot in range(1, SAVE_COUNT + 1):
		var save := _read_save(slot, "solo")
		var card := _card(rows)
		var row := HBoxContainer.new()
		card.add_child(row)
		var description := "Espacio %d · vacío" % slot
		if not save.is_empty():
			var program := Catalog.program_by_id(str(save.get("program_id", "")))
			description = "Espacio %d · %s · %s" % [slot, save.get("player_name", "Estudiante"), program.get("name", "Carrera")]
		var label := _label(description, 16)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)
		if save.is_empty():
			_add_menu_button(row, "Nueva", _begin_new_game.bind(slot), true, 42)
		else:
			_add_menu_button(row, "Continuar", _open_slot.bind(slot, "solo"), true, 42)
			_add_button(row, "Borrar", _delete_slot.bind(slot, "solo"), false, 42)


func _begin_new_game(slot: int) -> void:
	_save_profile()
	if _save_failed:
		_show_result("No se pudo guardar", _save_feedback, false, _show_solo_hub)
		return
	current_profile = {}
	simulation = null
	active_slot = slot
	draft_player_name = ""
	campus_ui = null
	_show_new_solo()


func _open_slot(slot: int, mode: String) -> void:
	if mode != "solo":
		return
	_save_profile()
	if _save_failed:
		_show_result("No se pudo guardar", _save_feedback, false, _show_solo_hub)
		return
	var loaded := _read_save(slot, mode)
	if loaded.is_empty():
		_show_slots(mode)
		return
	var validation := Simulation.validate_profile(loaded)
	if not validation["ok"]:
		var page := _make_page("No se pudo cargar la partida", str(validation["message"]), _show_solo_slots)
		_add_button(page, "Volver a partidas", _show_solo_slots, true, 46)
		return
	current_profile = loaded
	current_profile["slot"] = slot
	active_slot = slot
	simulation = Simulation.new(current_profile)
	campus_ui = null
	_save_profile()
	_show_solo_hub()


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
	if mode != "solo":
		return
	var result := save_store.remove_slot(slot)
	if result != OK:
		push_error("No se pudo borrar la partida: %s." % error_string(result))
		return
	if active_slot == slot:
		current_profile = {}
		simulation = null
		active_slot = 0
	_show_slots("solo")


func _find_free_slot(mode: String) -> int:
	for slot in range(1, SAVE_COUNT + 1):
		if _read_save(slot, mode).is_empty():
			return slot
	return 0


func _show_new_solo(name_error: String = "") -> void:
	_use_neutral_theme()
	selected_faculty = "ingenieria"
	var content := _make_page("Crea tu recorrido", "Facultad de Ingeniería · Sistemas e Informática", _show_solo_slots)
	content.add_child(_label("¿Cómo te llamas?", 18))
	var field := LineEdit.new()
	field.name = "StudentName"
	field.placeholder_text = "Tu nombre o apodo"
	field.text = draft_player_name
	field.max_length = 48
	field.custom_minimum_size.y = 48
	_style_input(field)
	content.add_child(field)
	var error_label := _label(name_error, 14, Color("#ffc7a3"))
	error_label.name = "StudentNameError"
	error_label.visible = not name_error.is_empty()
	content.add_child(error_label)
	var career_buttons: Array[Button] = []
	field.text_changed.connect(func(value: String) -> void:
		draft_player_name = value
		var valid := not value.strip_edges().is_empty()
		for button in career_buttons:
			button.disabled = not valid
		error_label.visible = not valid and not error_label.text.is_empty())
	field.text_submitted.connect(func(_value: String) -> void: _choose_faculty_from_field(field))
	content.add_child(_label("Elige una carrera y después explora sus menciones. Puedes consultar el plan antes de comenzar.", 15))
	var grid := _adaptive_grid(content, 380.0, 2)
	for program in Catalog.PROGRAMS:
		var card := _card(grid)
		var preview_theme := NeonVisuals.career(str(program["id"]))
		card.get_parent().add_theme_stylebox_override("panel", NeonVisuals.panel(preview_theme, true))
		card.add_child(_label(str(program["name"]), 22, preview_theme["neon"]))
		card.add_child(_label(str(program["summary"]), 16))
		var button := _add_button(card, "Explorar menciones", _choose_new_program.bind(str(program["id"])), true, 46)
		for state in ["normal", "hover", "pressed", "disabled"]:
			button.add_theme_stylebox_override(state, NeonVisuals.button(preview_theme, true, state))
		button.disabled = draft_player_name.strip_edges().is_empty()
		button.tooltip_text = "Escribe tu nombre para elegir una carrera."
		career_buttons.append(button)
	_focus_control.call_deferred(weakref(field))


func _choose_new_program(program_id: String) -> void:
	selected_faculty = "ingenieria"
	_show_mentions(program_id)


func _choose_faculty_from_field(name_field: LineEdit) -> void:
	draft_player_name = name_field.text.strip_edges()
	_show_mentions("sistemas")


func _require_player_name() -> bool:
	draft_player_name = draft_player_name.strip_edges()
	if not draft_player_name.is_empty():
		return true
	_show_new_solo("Escribe tu nombre o apodo antes de elegir una carrera.")
	return false


func _show_faculties() -> void:
	_show_new_solo()


func _select_faculty(faculty_id: String) -> void:
	selected_faculty = faculty_id
	_show_programs()


func _show_programs() -> void:
	_show_new_solo()


func _show_mentions(program_id: String) -> void:
	if not _require_player_name():
		return
	_use_neutral_theme()
	var program := Catalog.program_by_id(program_id)
	if program.is_empty():
		_show_programs()
		return
	_apply_career_theme(program_id)
	var theme := _current_theme
	var accent: Color = theme.get("accent", GREEN)
	var content := _make_page("Menciones y enfoques", str(program["name"]) + " · planes FNI publicados en 2011; los temarios detallados requieren revisión", _show_programs)
	var info_card := _card(content)
	info_card.add_child(_label(str(program["name"]), 21, accent))
	info_card.add_child(_label(str(program.get("description", "")), 15, theme.get("sub", Color("#5f6257"))))
	var rows := _adaptive_grid(content, 440.0, 2)
	for mention in Catalog.mentions_for_program(program_id):
		var card := _card(rows)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 14)
		card.add_child(row)
		var color: Color = theme["neon"]
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


func _create_solo_save(program_id: String, mention_id: String) -> void:
	if not _require_player_name():
		return
	var mention := Catalog.mention_by_id(program_id, mention_id)
	if Catalog.program_by_id(program_id).is_empty() or mention.is_empty():
		_show_solo_slots()
		return
	current_profile = {"slot": active_slot, "mode": "solo", "player_name": draft_player_name,
		"program_id": program_id, "mention_id": mention_id, "mention_name": mention.get("name", ""),
		"role_id": "estudiante", "confidence": 60, "chanchullo_used": [],
		"created_at": Time.get_datetime_string_from_system()}
	simulation = Simulation.new(current_profile)
	campus_ui = null
	_save_profile()
	_show_solo_hub()


func _show_solo_hub() -> void:
	if current_profile.is_empty():
		_show_solo_slots()
		return
	if simulation == null:
		simulation = Simulation.new(current_profile)
	_show_campus_section("resumen")


func _start_subject(key: String) -> void:
	if simulation == null or simulation.state["phase"] != "CURSANDO" or not simulation.state["enrollments"].has(key):
		_show_solo_hub()
		return
	var entry: Dictionary = simulation.state["enrollments"][key]
	if entry["score"] != null:
		_show_solo_hub()
		return
	current_profile["current_subject"] = key
	_campus_section = "materias"
	_campus().section = "materias"
	current_profile["partial_index"] = entry["answers"].size()
	_save_profile()
	_show_exam()


func _show_exam() -> void:
	if simulation == null:
		_show_solo_hub()
		return
	var key := str(current_profile.get("current_subject", ""))
	var subject: Dictionary = simulation.course_data(key)
	var entry: Dictionary = simulation.state["enrollments"].get(key, {})
	if subject.is_empty() or entry.is_empty() or entry["score"] != null or simulation.state["phase"] != "CURSANDO":
		_show_solo_hub()
		return
	var course := Catalog.course_for_sigla(str(subject["program_id"]), str(subject["sigla"]), str(subject["mention_id"]))
	var partial_index: int = entry["answers"].size()
	current_profile["partial_index"] = partial_index
	current_question = course["partials"][partial_index].duplicate(true)
	var theme := NeonVisuals.career(str(current_profile["program_id"]), str(current_profile["mention_id"]))
	var accent: Color = theme.get("accent", GREEN)
	_current_theme = theme
	var content := _make_page("Parcial %d / 3 · %s (%s)" % [partial_index + 1, course["name"], subject["sigla"]], "Semestre cursado %d · Tres parciales determinan la nota final" % int(simulation.state["term"]), Callable(self, "_show_solo_hub"))
	var columns := _adaptive_grid(content, 470.0, 2)
	var lesson := _card(columns, true)
	lesson.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lesson.add_child(_label("APUNTE RÁPIDO", 13, accent))
	lesson.add_child(_label(str(course.get("desc", "")), 13, theme.get("sub", INK)))
	var demo := StudyDemo.new()
	demo.setup(course, partial_index, float(settings["font_scale"]), _current_theme)
	lesson.add_child(demo)
	var exam := VBoxContainer.new()
	exam.set_meta("page_atomic", true)
	exam.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(exam)
	exam.add_child(_label(str(current_question["q"]), 19, accent, true))
	for option in range(current_question["options"].size()):
		_add_button(exam, str(current_question["options"][option]), _answer_subject.bind(option), false, 48)
	var cheat_key := "%d:%s:%d" % [int(simulation.state["term"]), key, partial_index]
	var cheat := _add_button(exam, "Chanchullo · usar apunte", _try_chanchullo.bind(cheat_key), true, 42)
	cheat.disabled = current_profile.get("chanchullo_used", []).has(cheat_key)


func _answer_subject(option_index: int) -> void:
	if not current_question.has("answer"):
		return
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
	if simulation == null or not current_question.has("answer"):
		return
	var key := str(current_profile.get("current_subject", ""))
	var partial := int(current_profile.get("partial_index", 0))
	var explanation := str(current_question.get("why", ""))
	var result: Dictionary = simulation.answer(key, partial, correct)
	if not result["ok"]:
		_show_result("Resultado pendiente", str(result["message"]), false, _show_solo_hub)
		return
	current_question = {}
	current_profile["confidence"] = clampi(int(current_profile.get("confidence", 60)) + (4 if correct and not cheated else -3), 0, 100)
	current_profile["partial_index"] = partial + 1
	if result["finished"]:
		var subject: Dictionary = simulation.course_data(key)
		explanation += " Nota final %.2f. El resultado se consolida al cerrar el semestre." % float(result["score"])
		_save_profile()
		_show_result("Materia aprobada" if result["passed"] else "Materia reprobada", explanation, bool(result["passed"]), _show_solo_hub)
	else:
		_save_profile()
		_show_result("Parcial registrado", explanation + " La nota final se calcula con los tres parciales.", correct, _show_exam)


func _show_titles() -> void:
	_show_global_achievements(Callable(self, "_show_solo_hub"), false)


func _return_to_menu() -> void:
	_save_profile()
	if _save_failed:
		_show_result("No se pudo guardar", _save_feedback + ". La partida sigue abierta; vuelve a intentar guardar.", false, _show_solo_hub)
		return
	current_profile = {}
	simulation = null
	campus_ui = null
	active_slot = 0
	_show_main()


func _exit_game() -> void:
	_save_profile()
	if _save_failed:
		_show_result("No se pudo guardar", _save_feedback + ". La partida sigue abierta; vuelve a intentar guardar.", false, _show_solo_hub)
		return
	get_tree().quit()


func _show_result(title: String, body: String, positive: bool, next: Callable) -> void:
	var content := _make_page(title, "", Callable(self, "_show_solo_hub"))
	var card := _card(content)
	card.add_child(_label(body, 20, GREEN if positive else INK, true))
	_add_button(content, "Continuar", next, true, 62)


func _save_path(slot: int, mode: String) -> String:
	return "%s/%s_partida_%d.json" % [SAVE_DIR, mode, slot]


func _legacy_save_path(slot: int) -> String:
	return "%s/partida_%d.json" % [SAVE_DIR, slot]


func _read_save(slot: int, mode: String) -> Dictionary:
	return save_store.read_slot(slot) if mode == "solo" else {}


func _save_profile() -> void:
	_save_failed = false
	if current_profile.is_empty() or active_slot < 1 or active_slot > SAVE_COUNT:
		return
	current_profile["updated_at"] = Time.get_datetime_string_from_system()
	var result := save_store.save_slot(active_slot, current_profile)
	if result != OK:
		_save_failed = true
		_save_feedback = "Error de guardado: " + error_string(result)
		push_error("No se pudo guardar la partida: %s." % error_string(result))
	else:
		_save_feedback = "Guardado · " + Time.get_time_string_from_system()
		_refresh_global_achievements()


const GraphScene := preload("res://scripts/curriculum_graph.gd")
const StudyDemo := preload("res://scripts/study_demo.gd")
const MentionArt := preload("res://scripts/mention_art.gd")

func _show_curriculum_graph(program_id: String, return_to_hub: bool = false, selected_mention_id: String = "") -> void:
	if return_to_hub:
		_campus_section = "malla"
	_campus().show_graph(program_id, return_to_hub, selected_mention_id)


func _show_curriculum(program_id: String, mention_id: String) -> void:
	_show_curriculum_graph(program_id, false, mention_id)


func _show_course_preview(key: String) -> void:
	_campus().show_course_preview(key)


func _run_simulation_action(command: String) -> void:
	var result: Dictionary = SimulationCommands.execute(simulation, command)
	_save_profile()
	if result["ok"] and command == "/cerrar":
		for sigla in current_profile.get("passed_subjects", []):
			_record_completed_subject(str(current_profile["program_id"]), str(current_profile["mention_id"]), str(sigla))
	_show_result("Gestión registrada" if result["ok"] else "Revisa los requisitos", str(result["message"]), bool(result["ok"]), _show_solo_hub)


func _show_simulation_console() -> void:
	if current_profile.is_empty() or simulation == null:
		return
	if is_instance_valid(simulation_console):
		_close_simulation_console()
		return
	var page := _make_page("Consola de exploración · F10", "Gestión opcional por comandos. La navegación habitual está en los botones del campus.", _close_simulation_console)
	simulation_console = page
	var field := LineEdit.new()
	field.placeholder_text = "Comando de gestión o /ayuda"
	_style_input(field)
	page.add_child(field)
	var output := VBoxContainer.new()
	output.name = "ConsoleOutput"
	page.add_child(output)
	_fill_console_output(output, SimulationCommands.describe(simulation))
	field.text_submitted.connect(_submit_simulation_command.bind(field, output))
	_add_button(page, "Ejecutar comando", func() -> void: _submit_simulation_command(field.text, field, output), true, 40)
	field.grab_focus()


func _fill_console_output(output: VBoxContainer, text: String) -> void:
	for child in output.get_children():
		output.remove_child(child)
		child.queue_free()
	for line in text.split("\n", false):
		output.add_child(_label(line, 14))


func _close_simulation_console() -> void:
	simulation_console = null
	_show_solo_hub()


func _submit_simulation_command(text: String, field: LineEdit, output: VBoxContainer) -> void:
	var result: Dictionary = SimulationCommands.execute(simulation, text)
	_save_profile()
	field.clear()
	if result.has("activity"):
		_close_simulation_console()
		_show_simulation_activity(str(result["activity"]), str(result["id"]))
		return
	if simulation.state["graduated"]:
		var program := Catalog.program_by_id(str(current_profile["program_id"]))
		_record_completed_career(str(current_profile["program_id"]), str(program.get("title", "Carrera")))
	_fill_console_output(output, str(result["message"]) + "\n\n" + SimulationCommands.describe(simulation))


func _show_simulation_activity(kind: String, id: String) -> void:
	var question := {}
	var index := 0
	if kind == "examen":
		var application: Dictionary = simulation._application(id)
		if application.is_empty() or application["status"] != "HABILITADA":
			_show_result("Postulación pendiente", "Completa primero el expediente de postulación desde Auxiliatura.", false, _show_solo_hub)
			return
		index = application["answers"].size()
		var subject: Dictionary = simulation.course_data(str(application["course_id"]))
		var course := Catalog.course_for_sigla(str(subject["program_id"]), str(subject["sigla"]), str(subject["mention_id"]))
		question = course["partials"][index].duplicate(true)
	elif kind == "apoyo":
		var request: Dictionary = simulation.procedure(id)
		if request.is_empty() or request["kind"] != "trabajo_auxiliar" or not ["PENDIENTE", "OBSERVADO"].has(request["status"]) or int(request["step"]) != 2:
			_show_result("Actividad pendiente", "Primero consigue la firma del plan y el permiso de aula.", false, _show_solo_hub)
			return
		index = int(request["payload"].get("sessions", 0))
		if index >= 3:
			_show_result("Actividades completas", "Puedes continuar el expediente desde Trámites.", true, _show_solo_hub)
			return
		var item: Dictionary = ASSISTANT_CASES[index]
		question = {"q": item["question"], "options": item["options"], "answer": item["best"], "why": item["good"] + " " + item["bad"]}
	elif kind == "defensa":
		var request: Dictionary = simulation.procedure(id)
		var step := SimulationProcedures.current_step(request)
		if step.is_empty() or not step.get("requires_defense", false) or request["payload"].get("defense_passed", false):
			_show_result("Defensa pendiente", "Completa la habilitación del tribunal o continúa el trámite si ya aprobaste.", false, _show_solo_hub)
			return
		index = request["payload"].get("defense_answers", []).size()
		var questions := [
			{"q": "¿Cómo justificas el problema de tu trabajo?", "options": ["Con evidencia, objetivos y alcance", "Solo con una opinión", "Sin revisar antecedentes"], "answer": 0, "why": "El trabajo necesita un problema y objetivos sustentados."},
			{"q": "¿Cómo sostienes que la solución funciona?", "options": ["Omitiendo los resultados negativos", "Con pruebas y resultados contrastables", "Por la cantidad de páginas"], "answer": 1, "why": "La validación relaciona resultados con objetivos y evidencia."},
			{"q": "¿Cómo presentas las limitaciones?", "options": ["Las ocultas", "Prometes que no existen", "Explicas sus efectos y mejoras posibles"], "answer": 2, "why": "Reconocer límites permite evaluar con honestidad el alcance."}
		]
		question = questions[index].duplicate(true)
	else:
		return
	current_question = question
	current_question["activity"] = kind
	current_question["activity_id"] = id
	current_question["activity_index"] = index
	var activity_titles := {"examen": "Competencia de auxiliatura", "apoyo": "Trabajo con el docente", "defensa": "Defensa ante tribunal"}
	var content := _make_page("%s · actividad %d/3" % [activity_titles.get(kind, kind.capitalize()), index + 1], id, _show_campus_section.bind("auxiliatura" if kind != "defensa" else "graduacion"))
	content.add_child(_label(str(question["q"]), 22, _current_theme.get("accent", GREEN), true))
	for option in range(question["options"].size()):
		_add_button(content, str(question["options"][option]), _answer_simulation_activity.bind(option), false, 56)


func _answer_simulation_activity(option: int) -> void:
	if not current_question.has("activity"):
		return
	var kind := str(current_question["activity"])
	var id := str(current_question["activity_id"])
	var index := int(current_question["activity_index"])
	var correct := option == int(current_question["answer"])
	var explanation := str(current_question.get("why", ""))
	current_question = {}
	var result := {}
	if kind == "examen":
		result = simulation.assistant_answer(id, index, correct)
	elif kind == "apoyo":
		result = simulation.support_session(id, index, correct)
	else:
		result = simulation.defense_answer(id, index, correct)
	_save_profile()
	var next := _show_simulation_activity.bind(kind, id)
	if result.get("finished", false) or (kind == "apoyo" and index == 2 and result["ok"]):
		if kind == "examen":
			next = _campus().open_request.bind(str(result["request_id"])) if result.has("request_id") else _show_campus_section.bind("auxiliatura")
		else:
			next = _campus().open_request.bind(id)
	var positive := bool(result.get("selected", result.get("passed", result["ok"])))
	_show_result("Actividad registrada" if result["ok"] else "Repasa la actividad", str(result["message"]) + "\n" + explanation, positive, next)


func _recent_slot() -> int:
	var found := 0
	var updated := ""
	for slot in range(1, SAVE_COUNT + 1):
		var saved := _read_save(slot, "solo")
		if not saved.is_empty() and (found == 0 or str(saved.get("updated_at", "")) > updated):
			found = slot
			updated = str(saved.get("updated_at", ""))
	return found


func _new_available_game() -> void:
	var slot := _find_free_slot("solo")
	if slot > 0:
		_begin_new_game(slot)
	else:
		_show_solo_slots()


func _refresh_global_achievements() -> void:
	if Achievements.evaluate(global_profile, current_profile):
		_save_global_profile()


func _achievement_card(parent: Control, item: Dictionary) -> void:
	var card := _card(parent, bool(item["unlocked"]))
	card.name = "Achievement_" + str(item["id"])
	card.set_meta("achievement_id", item["id"])
	card.set_meta("unlocked", item["unlocked"])
	card.add_child(_label(("✦ " if item["unlocked"] else "◇ ") + str(item["title"]), 18, _current_theme.get("accent", GREEN) if item["unlocked"] else _current_theme.get("text", INK)))
	card.add_child(_label(str(item["description"]), 15, _current_theme.get("sub", INK)))
	card.add_child(_label("Desbloqueado" if item["unlocked"] else "Pendiente", 14, _current_theme.get("sub", INK)))


func _sync_ambient() -> void:
	var enabled := not _home_art and not _visual_program_id.is_empty()
	if not is_instance_valid(_ambient):
		if not enabled:
			return
		_ambient = Ambient.new()
		add_child(_ambient)
		move_child(_ambient, 0)
	_ambient.visible = enabled
	if enabled:
		_ambient.configure(_current_theme, bool(settings["animations"]), bool(settings.get("low_performance", false)))
	else:
		_ambient.set_process(false)
