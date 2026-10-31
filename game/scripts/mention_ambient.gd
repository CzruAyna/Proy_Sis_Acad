extends TextureRect

const BLUR := """shader_type canvas_item;
render_mode unshaded;
uniform float softness = 2.1;
void fragment() {
    // Quantized sampling gives the atmospheric blur a chunky pixel rhythm.
    vec2 pixel_uv = (floor(UV * vec2(300.0, 170.0)) + 0.5) / vec2(300.0, 170.0);
    vec2 d = TEXTURE_PIXEL_SIZE * softness;
    vec4 c = texture(TEXTURE, pixel_uv) * 0.20;
    c += texture(TEXTURE, pixel_uv + vec2(d.x, 0.0)) * 0.12;
    c += texture(TEXTURE, pixel_uv - vec2(d.x, 0.0)) * 0.12;
    c += texture(TEXTURE, pixel_uv + vec2(0.0, d.y)) * 0.12;
    c += texture(TEXTURE, pixel_uv - vec2(0.0, d.y)) * 0.12;
    c += texture(TEXTURE, pixel_uv + d) * 0.08;
    c += texture(TEXTURE, pixel_uv - d) * 0.08;
    c += texture(TEXTURE, pixel_uv + vec2(d.x, -d.y)) * 0.08;
    c += texture(TEXTURE, pixel_uv + vec2(-d.x, d.y)) * 0.08;
    float edge = smoothstep(0.0, 0.16, UV.x) * smoothstep(0.0, 0.16, 1.0 - UV.x);
    // Viewport textures contain premultiplied color. Convert before the
    // standard canvas blend so the atmospheric layer does not fade twice.
    COLOR = vec4(c.rgb / max(c.a, 0.0001), c.a * edge * 0.55);
}
"""

class MotifCanvas extends Node2D:
	var kind := "software"
	var tint := Color("#ff393d")
	var phase := 0.0
	var animated := false
	const SAMPLES := {
		"software": ["<main class=\"campus\">", "  <section id=\"proyectos\">", "    <h1>Construir una idea</h1>", "    <article data-state=\"ready\">", "      <button>Explorar</button>", "    </article>", "  </section>", "</main>", "const render = state => view(state);"],
		"network": ["router> enable", "router# configure terminal", "router(config)# interface gigabitEthernet 0/1", "router(config-if)# description enlace-campus", "router(config-if)# no shutdown", "switch# show interfaces status", "Gi0/1    connected    trunk    full", "Gi0/2    connected    20       full", "switch(config)# vlan 20"],
		"data": ["SELECT materia, periodo, estado", "FROM recorrido", "JOIN plan USING (materia_id)", "WHERE estado = 'pendiente';", "CREATE INDEX idx_plan ON materias(plan_id);", "datos → limpieza → modelo → análisis", "{ id: 24, relaciones: [8, 12, 16] }"],
		"management": ["def evaluar_proceso(entrada):", "    alternativas = analizar(entrada)", "    plan = priorizar(alternativas)", "    return ejecutar(plan)", "estrategia → recursos → operación", "objetivos · seguimiento · resultados", "indicador = resultado / objetivo"],
		"optimization": ["minimizar Z = c₁x₁ + c₂x₂", "sujeto a Ax ≤ b", "x ≥ 0", "for candidato in soluciones:", "    costo = evaluar(candidato)", "    actualizar_mejor(costo)", "modelo → simulación → solución"]
	}

	func _draw() -> void:
		var lines: Array = SAMPLES.get(kind, SAMPLES["software"])
		var drift := sin(phase * 0.16) * 5.0
		var font := preload("res://assets/fonts/campus_pixel.fnt")
		var progress := int(phase * 10.0)
		for column in range(2):
			var origin := Vector2(18 + column * 285, 35 + column * 70) + Vector2(drift, -drift)
			for index in range(lines.size()):
				var text := str(lines[(index + column * 3) % lines.size()])
				if animated and index == 2:
					text = text.left(progress % (text.length() + 15))
				var alpha := 0.42 + 0.17 * sin(float(index) * 0.7 + phase * 0.22)
				draw_string(font, origin + Vector2(0, index * 22), text, HORIZONTAL_ALIGNMENT_LEFT, 280, 11, Color(tint, alpha))
		if kind == "network":
			for rack in range(3):
				var point := Vector2(370, 214 + rack * 24)
				for port in range(10):
					var lit := (port + rack + int(phase * 1.7)) % 4 != 0
					draw_rect(Rect2(point + Vector2(port * 15, 0), Vector2(9, 6)), Color(tint, 0.55 if lit else 0.1))
		elif kind == "optimization":
			var path := PackedVector2Array()
			for step in range(65):
				var x := float(step) / 64.0
				path.append(Vector2(320 + x * 225, 260 - (0.12 + pow(x - 0.6, 2)) * 120))
			draw_polyline(path, Color(tint, 0.5), 1.3, true)
		elif kind in ["data", "management"]:
			for index in range(8):
				var height := 12 + fposmod(float(index * 19) + phase * 2, 58)
				draw_rect(Rect2(Vector2(350 + index * 23, 278 - height), Vector2(12, height)), Color(tint, 0.22))

var surface: SubViewport
var motif: MotifCanvas
var elapsed := 0.0
var tick := 0.0
var running := false


func _init() -> void:
	name = "MentionAmbient"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 0
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	stretch_mode = TextureRect.STRETCH_SCALE
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	surface = SubViewport.new()
	surface.size = Vector2i(600, 340)
	surface.transparent_bg = true
	surface.disable_3d = true
	surface.gui_disable_input = true
	surface.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(surface)
	motif = MotifCanvas.new()
	surface.add_child(motif)
	texture = surface.get_texture()
	var shader := Shader.new()
	shader.code = BLUR
	var blur := ShaderMaterial.new()
	blur.shader = shader
	material = blur


func configure(palette: Dictionary, animations: bool, economical: bool) -> void:
	motif.kind = str(palette.get("motif", {}).get("kind", "software"))
	motif.tint = palette.get("neon", Color("#39bcff"))
	running = animations and not economical
	motif.animated = running
	set_process(running and visible)
	_refresh()


func _process(delta: float) -> void:
	elapsed += delta
	tick += delta
	if tick >= 0.10:
		tick = 0
		motif.phase = elapsed
		_refresh()


func _refresh() -> void:
	motif.queue_redraw()
	surface.render_target_update_mode = SubViewport.UPDATE_ONCE
