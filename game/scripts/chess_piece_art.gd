extends RefCounted
## Original 32x40 silhouettes; cached textures, no letter labels or font dependency.
static var _textures: Dictionary = {}


static func texture(piece: int) -> ImageTexture:
	if _textures.has(piece):
		return _textures[piece]
	var mask := Image.create(32, 40, false, Image.FORMAT_RGBA8)
	_rect(mask, Rect2i(5, 34, 22, 4))
	_rect(mask, Rect2i(8, 31, 16, 3))
	_rect(mask, Rect2i(10, 28, 12, 3))
	match absi(piece):
		1: # Pawn: round head, narrow stem.
			_disc(mask, Vector2i(16, 13), 6)
			_rect(mask, Rect2i(13, 18, 6, 11))
			_rect(mask, Rect2i(10, 24, 12, 4))
		2: # Knight: horse profile, pointed ear, muzzle and a stepped mane.
			_polygon(mask, [Vector2(9, 29), Vector2(9, 19), Vector2(12, 12), Vector2(12, 5), Vector2(17, 9), Vector2(21, 8), Vector2(26, 16), Vector2(25, 21), Vector2(19, 20), Vector2(20, 29)])
			_rect(mask, Rect2i(8, 14, 4, 12))
			mask.fill_rect(Rect2i(20, 13, 2, 2), Color.TRANSPARENT)
		3: # Bishop: mitre with a visible diagonal cut.
			_polygon(mask, [Vector2(16, 3), Vector2(23, 13), Vector2(21, 20), Vector2(18, 22), Vector2(21, 29), Vector2(11, 29), Vector2(14, 22), Vector2(10, 18), Vector2(9, 13)])
			for i in range(7):
				mask.fill_rect(Rect2i(14 + i, 14 - i, 2, 2), Color.TRANSPARENT)
		4: # Rook: three battlements, broad tower.
			_rect(mask, Rect2i(8, 6, 16, 9))
			for x in [7, 14, 21]:
				_rect(mask, Rect2i(x, 3, 4, 5))
			mask.fill_rect(Rect2i(11, 5, 3, 4), Color.TRANSPARENT)
			mask.fill_rect(Rect2i(18, 5, 3, 4), Color.TRANSPARENT)
			_rect(mask, Rect2i(11, 15, 10, 14))
		5: # Queen: three points with jewels, wide crown.
			_polygon(mask, [Vector2(7, 10), Vector2(12, 15), Vector2(16, 6), Vector2(20, 15), Vector2(25, 10), Vector2(22, 23), Vector2(10, 23)])
			for point in [Vector2i(7, 8), Vector2i(16, 5), Vector2i(25, 8)]:
				_disc(mask, point, 2)
			_rect(mask, Rect2i(12, 23, 8, 6))
		6: # King: clear cross above the crown.
			_rect(mask, Rect2i(15, 2, 3, 10))
			_rect(mask, Rect2i(11, 5, 11, 3))
			_rect(mask, Rect2i(9, 13, 15, 5))
			_polygon(mask, [Vector2(10, 18), Vector2(23, 18), Vector2(19, 25), Vector2(21, 29), Vector2(11, 29), Vector2(13, 25)])
	var image := Image.create(32, 40, false, Image.FORMAT_RGBA8)
	var ink := Color("#0c1728") if piece > 0 else Color("#b3d9df")
	var fill := Color("#f8efd4") if piece > 0 else Color("#26384e")
	for y in range(40):
		for x in range(32):
			if mask.get_pixel(x, y).a > 0:
				image.set_pixel(x, y, fill.lightened(0.16) if x < 15 else fill.darkened(0.2))
			else:
				for offset in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
					var p: Vector2i = Vector2i(x, y) + offset
					if p.x >= 0 and p.y >= 0 and p.x < 32 and p.y < 40 and mask.get_pixelv(p).a > 0:
						image.set_pixel(x, y, ink)
						break
	_textures[piece] = ImageTexture.create_from_image(image)
	return _textures[piece]


static func _rect(image: Image, rect: Rect2i) -> void:
	image.fill_rect(rect, Color.WHITE)


static func _disc(image: Image, centre: Vector2i, radius: int) -> void:
	for y in range(centre.y - radius, centre.y + radius + 1):
		for x in range(centre.x - radius, centre.x + radius + 1):
			if Vector2i(x, y).distance_squared_to(centre) <= radius * radius:
				image.set_pixel(x, y, Color.WHITE)


static func _polygon(image: Image, points: PackedVector2Array) -> void:
	for y in range(40):
		for x in range(32):
			if Geometry2D.is_point_in_polygon(Vector2(x, y) + Vector2.ONE * 0.5, points):
				image.set_pixel(x, y, Color.WHITE)
