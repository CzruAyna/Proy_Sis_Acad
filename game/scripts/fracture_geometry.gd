extends RefCounted
## Chunky, layered cave edges shared by all menu surfaces.
const FONT = preload("res://assets/fonts/campus_pixel.fnt")
const MESSAGES := ["0101 1100 // SIS", "<render campus />", "route :: ready", "const idea = build()", "SELECT recorrido", "[ SIS-INF :: OK ]"]


static func draw(item: RID, box: Rect2, fill: Color, edge: Color, chunk: int, depth: int, phase: float) -> void:
	var coarse := chunk >= 28
	if depth > 0:
		_layer(item, box.grow(depth), Color("#07111a"), chunk, coarse)
		_layer(item, box.grow(depth * 0.5), Color("#0b1820"), chunk, coarse)
	_layer(item, box, fill, chunk, coarse)
	for row in range(1, ceili(box.size.y / chunk) - 1):
		if row % 3 == 1:
			var x := box.end.x - chunk * 0.5 if row % 2 == 0 else box.position.x
			RenderingServer.canvas_item_add_rect(item, Rect2(Vector2(x, box.position.y + row * chunk), Vector2(chunk * 0.5, chunk)), Color(edge.darkened(0.4), 0.12))
	if phase >= 0:
		_terminal(item, box, phase)


static func _layer(item: RID, box: Rect2, color: Color, chunk: int, coarse: bool) -> void:
	for row in range(ceili(box.size.y / chunk)):
		var y := float(row * chunk)
		var corner := minf(y, box.size.y - y - chunk)
		var taper := maxf(0, 2 - corner / chunk) * (chunk * 0.5 if coarse else 3.0)
		var step := float(chunk / 2 if coarse else 4)
		var left := taper + posmod(row * 7 + 1, 3) * step
		var right := taper + posmod(row * 11 + 2, 3) * step
		RenderingServer.canvas_item_add_rect(item, Rect2(box.position + Vector2(left, y), Vector2(maxf(1, box.size.x - left - right), minf(chunk, box.size.y - y))), color)


static func _terminal(item: RID, box: Rect2, phase: float) -> void:
	var seed := int(box.size.x + box.size.y) % MESSAGES.size()
	var cycle := fposmod(phase + seed * 1.7, 10.0)
	if cycle < 4.0 or cycle > 8.0:
		return
	var fade := minf(minf(cycle - 4, 8 - cycle), 1.0)
	var message: String = MESSAGES[posmod(seed + int(phase / 10), MESSAGES.size())]
	message = message.left(maxi(0, int((cycle - 4) * 16)))
	var width := minf(180, box.size.x - 48)
	var font_size := 12 if box.size.y > 300 else 10
	FONT.draw_string(item, Vector2(box.end.x - width - 24, box.end.y - 5), message, HORIZONTAL_ALIGNMENT_LEFT, width, font_size, Color(0.22, 1.0, 0.48, fade * 0.72))
