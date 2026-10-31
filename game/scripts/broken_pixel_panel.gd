extends StyleBox
## An opaque black opening with chipped pixels, separate from ordinary UI frames.
var edge_color := Color("#42eaff")


func _init() -> void:
	content_margin_left = 28
	content_margin_right = 28
	content_margin_top = 24
	content_margin_bottom = 24


func _get_draw_rect(rect: Rect2) -> Rect2:
	return rect.grow(24)


func _draw(item: RID, rect: Rect2) -> void:
	var box := Rect2(rect.position.round(), rect.size.round())
	var black := Color("#020305")
	for row in range(ceili(box.size.y / 8.0)):
		var y := row * 8.0
		var left := float(posmod(row * 13 + 7, 4) * 4)
		var right := float(posmod(row * 7 + 3, 4) * 4)
		if row < 3 or y > box.size.y - 24:
			left += 16
			right += 16
		var height := minf(8, box.size.y - y)
		RenderingServer.canvas_item_add_rect(item, Rect2(box.position + Vector2(left, y), Vector2(box.size.x - left - right, height)), black)
		if row % 3 == 0:
			RenderingServer.canvas_item_add_rect(item, Rect2(box.position + Vector2(left, y), Vector2(4, 4)), Color(edge_color, 0.28))
		if row % 4 == 1:
			RenderingServer.canvas_item_add_rect(item, Rect2(box.position + Vector2(box.size.x - right - 4, y), Vector2(4, 4)), Color(edge_color, 0.22))
	# Detached dark fragments leave actual gaps through which the cosmos is visible.
	for index in range(12):
		var y := 16 + fposmod(index * 43.0, maxf(16, box.size.y - 32))
		var side := -1.0 if index % 2 == 0 else 1.0
		var x := -12.0 if side < 0 else box.size.x + 8.0
		var chip := Rect2(box.position + Vector2(x, y), Vector2(8, 8))
		RenderingServer.canvas_item_add_rect(item, chip, black)
		RenderingServer.canvas_item_add_rect(item, Rect2(chip.position, Vector2(4, 4)), Color(edge_color, 0.16))
	for index in range(8):
		var x := 36.0 + fposmod(index * 59.0, maxf(16, box.size.x - 72))
		var y := -12.0 if index % 2 == 0 else box.size.y + 8
		RenderingServer.canvas_item_add_rect(item, Rect2(box.position + Vector2(x, y), Vector2(8, 4)), black)
