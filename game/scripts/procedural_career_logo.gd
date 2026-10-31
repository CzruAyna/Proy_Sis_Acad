extends Control
## Geometric pixel interpretation of the user-supplied emblem. No source texture.
const SIDE := 160
const GLYPHS := {
	"A":"0E11111F111111", "B":"1E11111E11111E", "C":"0E11101010110E",
	"D":"1E11111111111E", "E":"1F10101E10101F", "F":"1F10101E101010",
	"G":"0E11101711110F", "H":"1111111F111111", "I":"0E04040404040E",
	"J":"0702020212120C", "K":"11121418141211", "L":"1010101010101F",
	"M":"111B1515111111", "N":"11191513111111", "O":"0E11111111110E",
	"P":"1E11111E101010", "Q":"0E11111115120D", "R":"1E11111E141211",
	"S":"0F10100E01011E", "T":"1F040404040404", "U":"1111111111110E",
	"V":"11111111110A04", "W":"11111115151B11", "X":"11110A040A1111",
	"Y":"11110A04040404", "Z":"1F01020408101F", "-":"0000001F000000",
	"0":"0E11131519110E", "1":"040C040404040E", " ":"00000000000000",
	"i":"04000C0404040E", "n":"00001619111111", "f":"0609081C080808"
}
static var _meshes: Dictionary = {}
var night := true

class Painter:
	var cells: Dictionary = {}

	func dot(point: Vector2, color: Color) -> void:
		var p := Vector2i(point.round())
		if p.x >= 0 and p.y >= 0 and p.x < SIDE and p.y < SIDE:
			cells[p] = color

	func disc(center: Vector2, radius: float, color: Color) -> void:
		for y in range(maxi(0, floori(center.y - radius)), mini(SIDE, ceili(center.y + radius + 1))):
			for x in range(maxi(0, floori(center.x - radius)), mini(SIDE, ceili(center.x + radius + 1))):
				if Vector2(x, y).distance_squared_to(center) <= radius * radius:
					dot(Vector2(x, y), color)

	func ellipse(center: Vector2, extent: Vector2, color: Color, outline: bool = false) -> void:
		for y in range(floori(center.y - extent.y), ceili(center.y + extent.y + 1)):
			for x in range(floori(center.x - extent.x), ceili(center.x + extent.x + 1)):
				var d := ((Vector2(x, y) - center) / extent).length_squared()
				if d <= 1 and (not outline or d >= 0.82):
					dot(Vector2(x, y), color)

	func rect(box: Rect2i, color: Color) -> void:
		for y in range(box.position.y, box.end.y):
			for x in range(box.position.x, box.end.x):
				dot(Vector2(x, y), color)

	func line(a: Vector2, b: Vector2, color: Color, width: float = 1.0) -> void:
		var steps := maxi(1, ceili(a.distance_to(b) * 1.5))
		for step in range(steps + 1):
			disc(a.lerp(b, float(step) / steps), width * 0.5, color)

	func letter(character: String, origin: Vector2, color: Color, scale: int = 1, rotation: float = 0.0) -> void:
		var rows: String = GLYPHS.get(character, GLYPHS[" "])
		for y in range(7):
			var mask := rows.substr(y * 2, 2).hex_to_int()
			for x in range(5):
				if mask & (1 << (4 - x)):
					for dy in range(scale):
						for dx in range(scale):
							dot(origin + Vector2(x * scale + dx, y * scale + dy).rotated(rotation), color)

	func arc_text(text: String, center: Vector2, radius: float, top: bool, color: Color) -> void:
		for index in range(text.length()):
			var fraction := float(index) / maxf(1, text.length() - 1)
			var angle := lerpf(-PI * 0.94, -PI * 0.06, fraction) if top else lerpf(PI * 0.78, PI * 0.22, fraction)
			var rotation := angle + PI * 0.5 if top else angle - PI * 0.5
			var origin := center + Vector2(cos(angle), sin(angle)) * radius - Vector2(2, 3).rotated(rotation)
			letter(text[index], origin, color, 1, rotation)

	func mesh() -> ArrayMesh:
		# Merge horizontal runs: one cached mesh rather than thousands of draw calls.
		var vertices := PackedVector3Array()
		var colors := PackedColorArray()
		for y in range(SIDE):
			var x := 0
			while x < SIDE:
				var key := Vector2i(x, y)
				if not cells.has(key):
					x += 1
					continue
				var color: Color = cells[key]
				var end := x + 1
				while end < SIDE and cells.get(Vector2i(end, y), Color.TRANSPARENT) == color:
					end += 1
				for p in [Vector2(x, y), Vector2(end, y), Vector2(end, y + 1), Vector2(x, y), Vector2(end, y + 1), Vector2(x, y + 1)]:
					vertices.append(Vector3(p.x, p.y, 0))
					colors.append(color)
				x = end
		var arrays := []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = vertices
		arrays[Mesh.ARRAY_COLOR] = colors
		var result := ArrayMesh.new()
		result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		return result


func _init() -> void:
	name = "ProceduralCareerLogo"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


static func emblem(dark: bool = true) -> ArrayMesh:
	if _meshes.has(dark):
		return _meshes[dark]
	var p := Painter.new()
	var navy := Color("#315b79") if dark else Color("#062739")
	var paper := Color("#152f40") if dark else Color("#f2f3ef")
	var gray := Color("#627c85") if dark else Color("#b7b9b5")
	var ink := Color("#bad2d3") if dark else navy
	var red := Color("#d83848")
	var cyan := Color("#28b4d7")
	var center := Vector2(80, 80)
	p.disc(center, 76, navy)
	p.disc(center, 71, paper)
	p.disc(center, 64, red)
	p.disc(center, 59, paper)
	p.arc_text("ING SISTEMAS - INFORMATICA", center, 67.5, true, ink)
	p.arc_text("FNI - UTO", center, 67, false, red)
	# Network triangle and round ports from the upper-right of the reference.
	for pair in [[Vector2(108, 35), Vector2(138, 84)], [Vector2(108, 35), Vector2(108, 68)], [Vector2(108, 68), Vector2(138, 84)], [Vector2(108, 35), Vector2(91, 67)], [Vector2(91, 67), Vector2(138, 84)]]:
		p.line(pair[0], pair[1], gray, 1.4)
	for point in [Vector2(108, 35), Vector2(138, 84), Vector2(108, 68)]:
		p.disc(point, 3, gray)
		p.disc(point, 1, paper)
	p.ellipse(Vector2(65, 72), Vector2(38, 23), gray)
	p.rect(Rect2i(51, 55, 29, 22), navy)
	for pair in [[Vector2(65, 58), Vector2(59, 72)], [Vector2(59, 72), Vector2(74, 72)], [Vector2(65, 58), Vector2(74, 72)], [Vector2(65, 58), Vector2(65, 68)], [Vector2(65, 68), Vector2(59, 72)], [Vector2(65, 68), Vector2(74, 72)]]:
		p.line(pair[0], pair[1], ink)
	for point in [Vector2(65, 58), Vector2(59, 72), Vector2(74, 72)]:
		p.disc(point, 1, ink)
	for pair in [[Vector2(43, 66), Vector2(43, 87)], [Vector2(43, 87), Vector2(52, 87)], [Vector2(82, 66), Vector2(82, 87)], [Vector2(82, 66), Vector2(91, 66)], [Vector2(36, 66), Vector2(51, 66)], [Vector2(56, 89), Vector2(66, 80)], [Vector2(56, 80), Vector2(66, 89)]]:
		p.line(pair[0], pair[1], navy, 1.4)
	# Cyan sweeps of the Systems symbol.
	var previous := Vector2(24, 69)
	for step in range(49):
		var t := float(step) / 48
		var point := Vector2(24 + 75 * t, 69 - sin(t * PI * 0.5) * 29)
		p.line(previous, point, cyan, 3 * (1 - t) + 0.5)
		previous = point
	p.line(Vector2(34, 104), Vector2(85, 96), cyan, 2)
	# Stylized keyboard, behind the Informatics roundel.
	for row in range(4):
		for column in range(8):
			p.rect(Rect2i(35 + column * 5 + row * 2, 113 + row * 4, 4, 3), gray)
	var globe := Vector2(101, 109)
	p.disc(globe, 31, red)
	p.disc(globe, 28, paper)
	for radius in [Vector2(24, 24), Vector2(12, 24), Vector2(24, 9)]:
		p.ellipse(globe, radius, gray, true)
	p.line(globe - Vector2(23, 0), globe + Vector2(23, 0), gray)
	p.line(globe - Vector2(0, 23), globe + Vector2(0, 23), gray)
	for index in range(36):
		var angle := TAU * index / 36.0
		p.disc(globe + Vector2(cos(angle), sin(angle)) * 29, 0.8, ink)
	p.letter("i", Vector2(79, 90), red, 3)
	p.letter("n", Vector2(97, 90), red, 3)
	p.letter("f", Vector2(115, 90), red, 3)
	for row in range(3):
		p.ellipse(Vector2(98, 123 + row * 3), Vector2(14, 3), navy, true)
	_meshes[dark] = p.mesh()
	return _meshes[dark]


func _draw() -> void:
	var scale := maxf(1, floorf(minf(size.x, size.y) / SIDE))
	var origin := ((size - Vector2.ONE * SIDE * scale) * 0.5).round()
	draw_set_transform(origin, 0, Vector2.ONE * scale)
	draw_mesh(emblem(night), null)
