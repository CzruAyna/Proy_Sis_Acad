extends Control

const Neon = preload("res://scripts/neon_visuals.gd")

var mention_id := ""
var ink := Color("#78a9bc")


func setup(selected_id: String, accent: Color) -> void:
	mention_id = selected_id
	ink = accent
	custom_minimum_size = Vector2(148, 104)
	size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	queue_redraw()


func _draw() -> void:
	var bounds := Rect2(Vector2(2, 2), Vector2(maxf(size.x - 4, 120), maxf(size.y - 4, 88)))
	draw_style_box(Neon.panel({"panel": Color("#040a15"), "neon": ink}), bounds)
	var sprites = preload("res://scripts/pixel_mention_sprite.gd")
	var sprite: ImageTexture = sprites.texture(mention_id, ink)
	var scale := maxi(1, floori(minf(bounds.size.x / 32, bounds.size.y / 24)))
	var extent := Vector2(32, 24) * scale
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	draw_texture_rect(sprite, Rect2((bounds.get_center() - extent * 0.5).round(), extent), false)
