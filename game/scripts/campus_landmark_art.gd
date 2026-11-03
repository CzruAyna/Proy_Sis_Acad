extends RefCounted
## Original pixel interpretations of the two photographs supplied by the user.
const Painter = preload("res://scripts/pixel_painter.gd")
static var _textures: Dictionary = {}


static func texture(id: String) -> Texture2D:
	if _textures.has(id):
		return _textures[id]
	var p := Painter.new()
	if id == "chivato":
		_goat(p)
	else:
		_piedritas(p)
	_textures[id] = p.texture()
	return _textures[id]


static func _goat(p: RefCounted) -> void:
	var stone := Color("#d7d6c0")
	var light := Color("#f0edda")
	var shade := Color("#a4aca1")
	p.ellipse(Vector2(80, 180), Vector2(62, 10), Color("#182d36", 0.5))
	p.polygon([[18, 177], [30, 153], [55, 139], [72, 145], [102, 137], [127, 156], [141, 178], [112, 186], [43, 185]], Color("#5b6768"))
	p.polygon([[24, 172], [42, 151], [65, 151], [75, 175], [53, 184]], Color("#90988a"))
	p.polygon([[69, 154], [98, 140], [121, 154], [113, 179], [81, 182]], Color("#78847b"))
	p.polygon([[102, 151], [119, 158], [134, 175], [112, 179]], Color("#b8b7a0"))
	p.polygon([[69, 101], [75, 108], [69, 148], [63, 156], [57, 155], [62, 139]], shade)
	p.polygon([[100, 109], [110, 112], [118, 146], [123, 152], [113, 155], [106, 141]], shade)
	p.ellipse(Vector2(89, 100), Vector2(28, 33), shade)
	p.ellipse(Vector2(86, 97), Vector2(25, 31), stone)
	p.polygon([[67, 110], [74, 115], [72, 154], [65, 157], [65, 146]], light)
	p.polygon([[97, 113], [105, 114], [110, 151], [104, 155], [99, 142]], stone)
	p.rect(63, 152, 12, 5, Color("#6f7b77"))
	p.rect(102, 151, 11, 5, Color("#6f7b77"))
	p.polygon([[70, 103], [65, 79], [48, 61], [51, 42], [65, 35], [77, 44], [80, 68], [103, 91], [94, 113]], stone)
	p.polygon([[72, 101], [63, 77], [52, 62], [57, 44], [67, 41], [68, 67], [87, 96]], light)
	p.polygon([[48, 43], [37, 40], [40, 32], [56, 35], [65, 44], [58, 61], [45, 63], [39, 56]], stone)
	p.polygon([[53, 38], [47, 26], [46, 15], [54, 7], [66, 8], [79, 16], [86, 29], [76, 21], [64, 15], [56, 16], [54, 25], [59, 37]], shade)
	p.line(Vector2(54, 35), Vector2(51, 22), light, 4)
	p.line(Vector2(51, 22), Vector2(55, 12), light, 4)
	p.line(Vector2(55, 12), Vector2(67, 12), light, 3)
	p.polygon([[47, 37], [38, 29], [25, 31], [18, 41], [18, 51], [24, 43], [32, 38], [41, 40]], Color("#bdc3b4"))
	p.line(Vector2(46, 37), Vector2(36, 33), light, 3)
	p.line(Vector2(36, 33), Vector2(26, 36), light, 3)
	p.polygon([[44, 58], [53, 61], [50, 76], [45, 83], [43, 70]], light)
	p.rect(45, 46, 3, 2, Color("#465c60"))
	p.rect(39, 55, 5, 3, shade)
	p.line(Vector2(113, 94), Vector2(123, 101), stone, 4)
	var rng := RandomNumberGenerator.new()
	rng.seed = 11303
	for index in range(170):
		var x := rng.randi_range(54, 110)
		var y := rng.randi_range(52, 126)
		if p.image.get_pixel(x, y) in [stone, light]:
			p.line(Vector2(x, y), Vector2(x + 1, y + 3), Color("#b9c0b1"), 1)


static func _piedritas(p: RefCounted) -> void:
	var bronze := Color("#6e452b")
	var light := Color("#be9250")
	var dark := Color("#2d2c27")
	p.ellipse(Vector2(80, 183), Vector2(56, 7), Color("#162b35", 0.5))
	p.rect(24, 172, 112, 9, Color("#b8c6bf"))
	p.rect(31, 162, 98, 10, Color("#e0e0ce"))
	p.ellipse(Vector2(80, 157), Vector2(44, 10), Color("#7e5535"))
	p.polygon([[55, 86], [91, 82], [107, 109], [110, 144], [97, 158], [49, 158], [45, 143], [50, 111]], dark)
	p.ellipse(Vector2(78, 118), Vector2(27, 39), bronze)
	p.polygon([[56, 91], [66, 88], [69, 130], [65, 152], [55, 152]], light.darkened(0.25))
	p.polygon([[81, 91], [90, 95], [96, 145], [90, 156], [81, 155]], light.darkened(0.12))
	p.ellipse(Vector2(60, 155), Vector2(12, 5), light)
	p.ellipse(Vector2(89, 156), Vector2(12, 5), light)
	p.ellipse(Vector2(80, 68), Vector2(23, 26), dark)
	p.polygon([[58, 55], [52, 27], [57, 11], [69, 37], [81, 44], [97, 29], [109, 13], [109, 41], [100, 61]], bronze)
	p.polygon([[57, 25], [62, 35], [62, 48], [58, 41]], light)
	p.polygon([[100, 37], [106, 24], [104, 43], [98, 51]], light)
	p.ellipse(Vector2(82, 58), Vector2(22, 19), bronze)
	p.polygon([[87, 57], [109, 62], [115, 71], [103, 80], [82, 73]], light.darkened(0.25))
	p.rect(106, 66, 10, 6, dark)
	p.rect(73, 52, 4, 3, Color("#dfb75c"))
	p.rect(94, 51, 4, 3, Color("#dfb75c"))
	p.rect(74, 52, 2, 2, dark)
	p.rect(95, 51, 2, 2, dark)
	p.line(Vector2(67, 81), Vector2(89, 85), light, 2)
	p.line(Vector2(103, 141), Vector2(122, 150), bronze, 7)
	p.line(Vector2(122, 150), Vector2(112, 159), light.darkened(0.2), 5)
	var rng := RandomNumberGenerator.new()
	rng.seed = 30113
	for index in range(200):
		var x := rng.randi_range(49, 108)
		var y := rng.randi_range(40, 151)
		if p.image.get_pixel(x, y) == bronze:
			p.rect(x, y, 1, 3, light.darkened(rng.randf_range(0.1, 0.5)))
