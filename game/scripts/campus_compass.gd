extends RefCounted
## Orientation explicitly provided by the user, not inferred from image metadata.
const FONT = preload("res://assets/fonts/campus_pixel.fnt")
const DIRECTIONS := {"N": Vector2.RIGHT, "E": Vector2.DOWN, "S": Vector2.LEFT, "O": Vector2.UP}


static func draw(canvas: CanvasItem, center: Vector2, font_size: int = 12) -> void:
	canvas.draw_rect(Rect2(center - Vector2(43, 43), Vector2(86, 86)), Color("#10191f"))
	for label in DIRECTIONS:
		var direction: Vector2 = DIRECTIONS[label]
		var side := direction.orthogonal()
		var tip := center + direction * 24
		var base := center - direction * 3
		var color := Color("#f1d18c") if label == "N" else Color("#c0cbc0")
		canvas.draw_colored_polygon(PackedVector2Array([tip, base + side * 7, center, base - side * 7]), color)
		var text_point := center + direction * 33 + Vector2(-font_size * 0.3, font_size * 0.35)
		canvas.draw_string(FONT, text_point, label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
	canvas.draw_rect(Rect2(center - Vector2(2, 2), Vector2(4, 4)), Color("#6b898c"))
