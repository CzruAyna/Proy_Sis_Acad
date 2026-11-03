extends RefCounted
## Compact geometric interpretation of the supplied SIS/INF emblem.
## Original code: GPL-3.0-or-later. Emblem provenance remains documented separately.


static func image_at(side: int = 256) -> Image:
	var image := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var blue := Color("#28b4d7")
	var red := Color("#ef435b")
	var pale := Color("#e9fbff")
	for y in range(32):
		for x in range(32):
			var distance := Vector2(x - 15.5, y - 15.5).length_squared()
			if distance <= 225:
				image.set_pixel(x, y, (blue if x < 16 else red) if distance >= 169 else Color("#102431"))
	# The two symbols remain distinguishable at taskbar size: S, i, network, keyboard.
	var letter_s := ["11111", "10000", "10000", "11111", "00001", "00001", "11111"]
	for y in range(7):
		for x in range(5):
			if letter_s[y][x] == "1":
				image.fill_rect(Rect2i(6 + x * 2, 8 + y * 2, 2, 2), blue)
	image.fill_rect(Rect2i(20, 12, 3, 3), red)
	image.fill_rect(Rect2i(20, 17, 3, 7), red)
	image.fill_rect(Rect2i(18, 23, 7, 2), red)
	for point in [Vector2i(19, 6), Vector2i(25, 9), Vector2i(25, 15)]:
		image.fill_rect(Rect2i(point, Vector2i(2, 2)), pale)
	for y in [25, 27]:
		for x in range(9, 18, 3):
			image.set_pixel(x, y, pale)
	image.resize(maxi(16, side), maxi(16, side), Image.INTERPOLATE_NEAREST)
	return image
