extends RefCounted
const FONT = preload("res://assets/fonts/campus_pixel.fnt")
const Map = preload("res://scripts/campus_map.gd")


static func draw(canvas: CanvasItem, kind: String) -> void:
	if kind not in ["physics_lab", "chemistry_lab", "physics_virtual"]:
		return
	for desk in Map.room_obstacles(kind):
		var p: Vector2 = desk.position
		if kind == "physics_virtual":
			canvas.draw_rect(Rect2(p + Vector2(9, -9), Vector2(22, 14)), Color("#263e4e"))
			canvas.draw_rect(Rect2(p + Vector2(11, -7), Vector2(18, 9)), Color("#62a1b4"))
			canvas.draw_line(p + Vector2(12, 0), p + Vector2(27, -5), Color("#dbdc92"), 1)
			canvas.draw_rect(Rect2(p + Vector2(8, 8), Vector2(24, 4)), Color("#b9c4bc"))
		elif kind == "physics_lab":
			canvas.draw_rect(Rect2(p + Vector2(6, -5), Vector2(2, 20)), Color("#c0cbb8"))
			canvas.draw_rect(Rect2(p + Vector2(6, -5), Vector2(22, 2)), Color("#c0cbb8"))
			canvas.draw_line(p + Vector2(22, -3), p + Vector2(18, 9), Color("#dbe4cf"), 1)
			canvas.draw_rect(Rect2(p + Vector2(15, 8), Vector2(6, 6)), Color("#6c97a2"))
			canvas.draw_rect(Rect2(p + Vector2(28, 5), Vector2(9, 9)), Color("#304755"))
			canvas.draw_rect(Rect2(p + Vector2(30, 7), Vector2(5, 3)), Color("#b8ce88"))
		else:
			canvas.draw_rect(Rect2(p + Vector2(8, -4), Vector2(3, 13)), Color("#a6ccc8"))
			canvas.draw_rect(Rect2(p + Vector2(5, 7), Vector2(10, 6)), Color("#79a88c"))
			canvas.draw_rect(Rect2(p + Vector2(24, 1), Vector2(10, 12)), Color("#afd0cb"))
			canvas.draw_rect(Rect2(p + Vector2(26, 8), Vector2(6, 4)), Color("#a77ca4"))
	canvas.draw_rect(Rect2(152, 28, 176, 32), Color("#244f50"))
	var formula := "F = ma · V = IR" if kind == "physics_lab" else ("SIMULACIÓN · FÍSICA" if kind == "physics_virtual" else "pH = -log[H+] · H2O")
	canvas.draw_string(FONT, Vector2(162, 47), formula, HORIZONTAL_ALIGNMENT_LEFT, 162, 9, Color("#b4e8c9"))
