extends RefCounted
## Code-authored pixel primitives. No downloaded image or external font.
var image: Image


func _init(width: int = 160, height: int = 192) -> void:
	image = Image.create(width, height, false, Image.FORMAT_RGBA8)


func rect(x: int, y: int, width: int, height: int, color: Color) -> void:
	var area := Rect2i(x, y, width, height).intersection(Rect2i(0, 0, image.get_width(), image.get_height()))
	if area.has_area():
		image.fill_rect(area, color)


func dot(x: int, y: int, color: Color) -> void:
	if x >= 0 and y >= 0 and x < image.get_width() and y < image.get_height():
		image.set_pixel(x, y, color)


func polygon(vertices: Array, color: Color) -> void:
	var points := PackedVector2Array()
	for vertex in vertices:
		points.append(Vector2(vertex[0], vertex[1]))
	var bounds := Rect2(points[0], Vector2.ZERO)
	for point in points:
		bounds = bounds.expand(point)
	for y in range(maxi(0, floori(bounds.position.y)), mini(image.get_height(), ceili(bounds.end.y) + 1)):
		for x in range(maxi(0, floori(bounds.position.x)), mini(image.get_width(), ceili(bounds.end.x) + 1)):
			if Geometry2D.is_point_in_polygon(Vector2(x + 0.5, y + 0.5), points):
				dot(x, y, color)


func ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	for y in range(maxi(0, floori(center.y - radius.y)), mini(image.get_height(), ceili(center.y + radius.y))):
		for x in range(maxi(0, floori(center.x - radius.x)), mini(image.get_width(), ceili(center.x + radius.x))):
			if ((Vector2(x, y) - center) / radius).length_squared() <= 1:
				dot(x, y, color)


func line(a: Vector2, b: Vector2, color: Color, width: int = 1) -> void:
	var steps := maxi(1, ceili(a.distance_to(b)))
	for index in range(steps + 1):
		var p := a.lerp(b, float(index) / steps).round()
		rect(int(p.x) - width / 2, int(p.y) - width / 2, width, width, color)


func texture() -> ImageTexture:
	return ImageTexture.create_from_image(image)
