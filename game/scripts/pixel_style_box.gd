extends StyleBox
const Fracture = preload("res://scripts/fracture_geometry.gd")
## Original stepped frame. Geometry stays crisp without a full-screen pixel filter.

var bg_color := Color("#07172e")
var border_color := Color("#39bcff")
var shadow_color := Color(0, 0, 0, 0.65)
var shadow_size := 4
var shadow_offset := Vector2(4, 4)
var draw_center := true
var border_width := 2
var raised := false
var pressed := false
var fractured := false
var chunk_size := 16
var fracture_depth := 0
var terminal_phase := -1.0
var terminal_output := true
var terminal_strength := 1.0


func set_border_width_all(value: int) -> void:
	border_width = value


func _get_minimum_size() -> Vector2:
	return Vector2.ONE * border_width * 2


func _get_draw_rect(rect: Rect2) -> Rect2:
	if fractured:
		return rect.grow(fracture_depth)
	return rect.merge(Rect2(rect.position + shadow_offset, rect.size)) if shadow_size > 0 else rect


func _draw(item: RID, rect: Rect2) -> void:
	var box := Rect2(rect.position.round(), rect.size.round())
	if fractured and draw_center:
		Fracture.draw(item, box, bg_color, border_color, chunk_size, fracture_depth, terminal_phase if terminal_output else -1, terminal_strength)
		return
	if shadow_size > 0 and draw_center:
		_fill(item, _outline(Rect2(box.position + shadow_offset, box.size)), shadow_color)
	if draw_center:
		_fill(item, _outline(box), border_color)
		_fill(item, _outline(box.grow(-border_width)), bg_color)
	else:
		# Focus brackets do not obscure the currently pressed/hovered background.
		for corner in [box.position, Vector2(box.end.x - 8, box.position.y), Vector2(box.position.x, box.end.y - 2), box.end - Vector2(8, 2)]:
			RenderingServer.canvas_item_add_rect(item, Rect2(corner, Vector2(8, 2)), border_color)
		return
	if raised:
		var light := Color(border_color.lerp(Color.WHITE, 0.5), 0.65)
		var dark := Color(0, 0, 0, 0.45)
		RenderingServer.canvas_item_add_rect(item, Rect2(box.position + Vector2(6, 3), Vector2(maxf(0, box.size.x - 12), 2)), dark if pressed else light)
		RenderingServer.canvas_item_add_rect(item, Rect2(box.position + Vector2(6, box.size.y - 5), Vector2(maxf(0, box.size.x - 12), 2)), light if pressed else dark)


func _outline(rect: Rect2) -> PackedVector2Array:
	var p := rect.position
	var e := rect.end
	var step := minf(2, minf(rect.size.x, rect.size.y) / 6)
	return PackedVector2Array([
		p + Vector2(step * 2, 0), Vector2(e.x - step * 2, p.y),
		Vector2(e.x - step * 2, p.y + step), Vector2(e.x - step, p.y + step),
		Vector2(e.x - step, p.y + step * 2), Vector2(e.x, p.y + step * 2),
		e - Vector2(0, step * 2), e - Vector2(step, step * 2),
		e - Vector2(step, step), e - Vector2(step * 2, step),
		e - Vector2(step * 2, 0), Vector2(p.x + step * 2, e.y),
		Vector2(p.x + step * 2, e.y - step), Vector2(p.x + step, e.y - step),
		Vector2(p.x + step, e.y - step * 2), Vector2(p.x, e.y - step * 2),
		p + Vector2(0, step * 2), p + Vector2(step, step * 2),
		p + Vector2(step, step), p + Vector2(step * 2, step)
	])


func _fill(item: RID, points: PackedVector2Array, color: Color) -> void:
	RenderingServer.canvas_item_add_polygon(item, points, PackedColorArray([color]))
