extends "res://scripts/pixel_style_box.gd"
## Large blocks and deep terraces form the opening around a compact menu.


func _init() -> void:
	fractured = true
	chunk_size = 32
	fracture_depth = 24
	bg_color = Color("#020405")
	border_color = Color("#338aff")
	content_margin_left = 40
	content_margin_right = 40
	content_margin_top = 24
	content_margin_bottom = 24
