extends Control
## An unframed continuation of the same black opening, behind the menu.
var style: StyleBox


func _draw() -> void:
	if style != null:
		draw_style_box(style, Rect2(Vector2.ZERO, size))
