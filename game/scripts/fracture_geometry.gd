extends RefCounted
## Pure black openings. Terminal output is decorative, never an OS command.
const FONT = preload("res://assets/fonts/campus_pixel.fnt")
const LINUX_TREE := ["sis-inf@campus:~$ tree -L 3", ".", "├── sistemas", "│   ├── modelos", "│   └── informacion", "├── informatica", "│   ├── software", "│   └── telematica", "└── campus", "    ├── aulas", "    └── sala_de_juegos", "9 directories, 0 files"]
const WINDOWS_TREE := ["C:\\SIS-INF> tree /A", "Listado de rutas de carpetas", "C:.", "+---Sistemas", "|   +---Modelos", "|   \\---Informacion", "+---Informatica", "|   +---Software", "|   \\---Telematica", "\\---Campus", "    +---Aulas", "    \\---Sala_de_juegos"]


static func draw(item: RID, box: Rect2, _fill: Color, _edge: Color, chunk: int, depth: int, phase: float, terminal_strength: float = 1.0) -> void:
	var coarse := chunk >= 28
	if depth > 0:
		_layer(item, box.grow(depth), Color.BLACK, chunk, coarse)
		_layer(item, box.grow(depth * 0.5), Color.BLACK, chunk, coarse)
	_layer(item, box, Color.BLACK, chunk, coarse)
	if phase >= 0:
		_terminal(item, box, phase, terminal_strength)


static func _layer(item: RID, box: Rect2, color: Color, chunk: int, coarse: bool) -> void:
	for row in range(ceili(box.size.y / chunk)):
		var y := float(row * chunk)
		var corner := minf(y, box.size.y - y - chunk)
		var taper := maxf(0, 2 - corner / chunk) * (chunk * 0.5 if coarse else 3.0)
		var step := float(chunk / 2 if coarse else 4)
		var left := taper + posmod(row * 7 + 1, 3) * step
		var right := taper + posmod(row * 11 + 2, 3) * step
		RenderingServer.canvas_item_add_rect(item, Rect2(box.position + Vector2(left, y), Vector2(maxf(1, box.size.x - left - right), minf(chunk, box.size.y - y))), color)


static func _terminal(item: RID, box: Rect2, phase: float, strength: float) -> void:
	# Two real tree syntaxes, typed line by line behind the menu controls.
	# No framed window, external process, filesystem access or input capture.
	var cycle := fposmod(phase, 24.0)
	var local := fposmod(cycle, 12.0)
	if local > 11.0:
		return
	var lines: Array = LINUX_TREE if cycle < 12 else WINDOWS_TREE
	var font_size := 12 if box.size.y >= 300 else 10
	var spacing := float(font_size + 6)
	var count := mini(lines.size(), floori((box.size.y - 40) / spacing))
	var inset := 64.0 if strength > 1 else 32.0
	var width := box.size.x - inset - 32
	if count <= 0 or width < 60:
		return
	var budget := int(local * 60)
	var fade := clampf(minf(local * 2, 11 - local), 0, 1)
	var alpha := (0.16 if box.size.y >= 300 else 0.08) * strength
	var start := box.position + Vector2(inset, maxf(28, box.size.y - count * spacing - 16))
	for index in range(count):
		var value: String = lines[index]
		var visible_text := value.left(maxi(0, budget))
		budget -= value.length() + 8
		FONT.draw_string(item, start + Vector2(0, index * spacing), visible_text, HORIZONTAL_ALIGNMENT_LEFT, width, font_size, Color(0.16, 1, 0.36, fade * alpha))
