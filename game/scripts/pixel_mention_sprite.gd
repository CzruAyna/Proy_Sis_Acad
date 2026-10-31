extends RefCounted
## Original 32×24 sprites. Cache once per mention and career color.
static var cache: Dictionary = {}


static func texture(mention: String, tint: Color) -> ImageTexture:
	var key := mention + tint.to_html()
	if cache.has(key):
		return cache[key]
	var image := Image.create(32, 24, false, Image.FORMAT_RGBA8)
	var dark := tint.darkened(0.80)
	var mid := tint.darkened(0.4)
	var light := tint.lerp(Color.WHITE, 0.7)
	match mention:
		"desarrollo_sw":
			image.fill_rect(Rect2i(2, 2, 28, 17), tint)
			image.fill_rect(Rect2i(3, 3, 26, 15), dark)
			for index in range(4):
				var x := 6 + (index % 2) * 3
				image.fill_rect(Rect2i(x, 5 + index * 3, 3, 1), light)
				image.fill_rect(Rect2i(x + 5, 5 + index * 3, 9 - index, 1), tint)
			image.fill_rect(Rect2i(14, 19, 4, 2), mid)
			image.fill_rect(Rect2i(9, 21, 14, 2), light)
		"telematica":
			image.fill_rect(Rect2i(2, 10, 28, 10), mid)
			image.fill_rect(Rect2i(3, 10, 26, 2), tint)
			image.fill_rect(Rect2i(5, 3, 2, 7), light)
			image.fill_rect(Rect2i(25, 3, 2, 7), light)
			for port in range(6):
				image.fill_rect(Rect2i(5 + port * 4, 14, 3, 3), dark)
				image.fill_rect(Rect2i(5 + port * 4, 14, 2, 1), light)
			image.fill_rect(Rect2i(4, 20, 4, 2), dark)
			image.fill_rect(Rect2i(24, 20, 4, 2), dark)
		"gestion_informacion":
			for tier in range(3):
				var y := 3 + tier * 6
				image.fill_rect(Rect2i(6, y + 1, 20, 6), mid)
				image.fill_rect(Rect2i(8, y, 16, 2), light)
				image.fill_rect(Rect2i(7, y + 2, 18, 1), tint)
				image.fill_rect(Rect2i(8, y + 6, 16, 1), dark)
				image.fill_rect(Rect2i(22, y + 4, 2, 1), light)
		"modelamiento_optimizacion":
			image.fill_rect(Rect2i(3, 3, 1, 18), light)
			image.fill_rect(Rect2i(3, 20, 27, 1), light)
			for x in range(5, 29):
				var y := 7 + int(pow(float(x - 17) / 7.0, 2))
				image.fill_rect(Rect2i(x, mini(y, 18), 1, 2), tint)
			image.fill_rect(Rect2i(16, 6, 3, 3), light)
		_:
			image.fill_rect(Rect2i(15, 4, 2, 16), tint)
			image.fill_rect(Rect2i(6, 15, 20, 2), tint)
			for point in [Vector2i(11, 2), Vector2i(2, 16), Vector2i(21, 16)]:
				image.fill_rect(Rect2i(point, Vector2i(9, 6)), tint)
				image.fill_rect(Rect2i(point + Vector2i(1, 1), Vector2i(7, 4)), dark)
				image.fill_rect(Rect2i(point + Vector2i(2, 2), Vector2i(4, 1)), light)
	var result := ImageTexture.create_from_image(image)
	cache[key] = result
	return result
