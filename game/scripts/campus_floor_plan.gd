extends RefCounted
const FONT = preload("res://assets/fonts/campus_pixel.fnt")
const Map = preload("res://scripts/campus_map.gd")


static func draw(canvas: CanvasItem, area: Rect2, id: String, level: int) -> void:
	var extent := Vector2(320, 230)
	var factor := minf(area.size.x / extent.x, area.size.y / extent.y)
	var origin := area.position + (area.size - extent * factor) * 0.5
	canvas.draw_set_transform(origin.round(), 0, Vector2.ONE * factor)
	canvas.draw_rect(Rect2(Vector2.ZERO, extent), Color("#12212b"))
	if id == "fis_mat":
		canvas.draw_rect(Rect2(12, 24, 296, 184), Color("#7c8680"))
		for index in range(3):
			var p := Vector2(22 + index * 86, 34)
			canvas.draw_rect(Rect2(p, Vector2(78, 88)), Color("#c4bda0"))
			canvas.draw_string(FONT, p + Vector2(6, 17), "AULA %d" % (index + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#294b58"))
			for desk in range(6):
				canvas.draw_rect(Rect2(p + Vector2(12 + desk % 2 * 34, 31 + desk / 2 * 16), Vector2(22, 8)), Color("#8c7053"))
		if level == 0:
			canvas.draw_rect(Rect2(24, 150, 156, 46), Color("#638b97"))
			canvas.draw_string(FONT, Vector2(31, 166), "FÍSICA VIRTUAL", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#e5efdc"))
			for x in range(35, 165, 24):
				canvas.draw_rect(Rect2(x, 176, 15, 10), Color("#263e4c"))
		_stairs(canvas, Vector2(231, 144))
	else:
		canvas.draw_rect(Rect2(113, 15, 94, 200), Color("#8c9890"))
		canvas.draw_rect(Rect2(15, 86, 290, 68), Color("#8c9890"))
		for rect in [Rect2(122, 25, 76, 57), Rect2(219, 94, 76, 53), Rect2(122, 158, 76, 49), Rect2(24, 94, 76, 53)]:
			canvas.draw_rect(rect, Color("#c5bda0"))
			for index in range(4):
				canvas.draw_rect(Rect2(rect.position + Vector2(8 + index % 2 * 32, 19 + index / 2 * 15), Vector2(22, 8)), Color("#92785b"))
		_stairs(canvas, Vector2(126, 98))
		if level in [0, 2, 4]:
			for index in range(2):
				var p := Vector2(14 + index * 227, 170)
				canvas.draw_rect(Rect2(p, Vector2(64, 40)), Color("#799b9e") if index == 0 else Color("#8e849f"))
				canvas.draw_string(FONT, p + Vector2(5, 14), "MUJERES" if index == 0 else "VARONES", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("#f0eddb"))
				for x in range(3):
					canvas.draw_rect(Rect2(p + Vector2(5 + x * 18, 21), Vector2(13, 14)), Color("#d1d7c5"))
	canvas.draw_string(FONT, Vector2(13, 224), "PB" if level == 0 else "PISO %d" % level, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#d9e9da"))
	canvas.draw_set_transform(Vector2.ZERO)


static func _stairs(canvas: CanvasItem, point: Vector2) -> void:
	canvas.draw_rect(Rect2(point, Vector2(62, 42)), Color("#455b64"))
	for index in range(7):
		canvas.draw_rect(Rect2(point + Vector2(3, 4 + index * 4), Vector2(23, 3)), Color("#b6bfae"))
		canvas.draw_rect(Rect2(point + Vector2(35, 28 - index * 4), Vector2(23, 3)), Color("#a0b0a8"))
	canvas.draw_rect(Rect2(point + Vector2(3, 33), Vector2(55, 6)), Color("#d2ceb6"))
	canvas.draw_line(point + Vector2(30, 2), point + Vector2(30, 32), Color("#263d4d"), 2)
