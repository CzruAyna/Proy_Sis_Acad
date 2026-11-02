extends Control
## Shared table art; gameplay belongs to the recreation engines.
const FONT = preload("res://assets/fonts/campus_pixel.fnt")
const CATALOG := {
	"billar": {"title": "Billar", "description": "Duelo de seis bolas contra un rival que calcula ángulos y deja margen de error."},
	"ping_pong": {"title": "Ping-pong", "description": "Duelo arcade con paletas, servicio y rival de reacción limitada."},
	"ajedrez": {"title": "Ajedrez", "description": "Blancas contra un rival que estudia dos medias jugadas. Sin reloj."},
	"monopolio": {"title": "Monopolio", "description": "Ruta del campus: variante propia breve con compras, rentas, mejoras y un rival prudente."}
}
var game_id := "billar"


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#0c1418"))
	var factor := minf((size.x - 24) / 320, (size.y - 24) / 180)
	var extent := Vector2(320, 180) * factor
	draw_set_transform(((size - extent) * 0.5).floor(), 0, Vector2.ONE * factor)
	draw_table(self, Rect2(0, 0, 320, 180), game_id)
	draw_set_transform(Vector2.ZERO)


static func draw_table(canvas: CanvasItem, rect: Rect2, id: String) -> void:
	# Normalize the art to 160 × 90; all marks use square pixels / stepped edges.
	var unit := rect.size / Vector2(160, 90)
	var offset := rect.position
	_box(canvas, offset, unit, Rect2(2, 5, 158, 85), Color("#141e23"))
	_box(canvas, offset, unit, Rect2(0, 0, 158, 84), Color("#825f43"))
	_box(canvas, offset, unit, Rect2(4, 4, 150, 76), Color("#c49b65"))
	match id:
		"billar":
			_box(canvas, offset, unit, Rect2(8, 8, 142, 68), Color("#326a55"))
			for point in [Vector2(10, 10), Vector2(79, 8), Vector2(148, 10), Vector2(10, 74), Vector2(79, 76), Vector2(148, 74)]:
				_box(canvas, offset, unit, Rect2(point - Vector2(3, 3), Vector2(6, 6)), Color("#101f23"))
			for index in range(10):
				var point := Vector2(100 + floorf(index / 4.0) * 6, 30 + (index % 4) * 6)
				_box(canvas, offset, unit, Rect2(point, Vector2(4, 4)), [Color("#e8c364"), Color("#ba5655"), Color("#97a6c4")][index % 3])
			_box(canvas, offset, unit, Rect2(38, 40, 4, 4), Color("#ece9cc"))
			_box(canvas, offset, unit, Rect2(16, 60, 68, 2), Color("#d4b98a"))
		"ping_pong":
			_box(canvas, offset, unit, Rect2(8, 8, 142, 68), Color("#38647d"))
			for line in [Rect2(10, 10, 138, 2), Rect2(10, 72, 138, 2), Rect2(10, 10, 2, 64), Rect2(146, 10, 2, 64), Rect2(12, 42, 134, 1)]:
				_box(canvas, offset, unit, line, Color("#e2e7cb"))
			_box(canvas, offset, unit, Rect2(77, 6, 4, 72), Color("#172c38"))
			for y in range(8, 76, 4):
				_box(canvas, offset, unit, Rect2(78, y, 2, 2), Color("#b9c9c4"))
			for point in [Vector2(28, 22), Vector2(124, 56)]:
				_box(canvas, offset, unit, Rect2(point, Vector2(9, 12)), Color("#bb575b"))
				_box(canvas, offset, unit, Rect2(point + Vector2(3, 12), Vector2(3, 7)), Color("#d3ad76"))
			_box(canvas, offset, unit, Rect2(56, 44, 3, 3), Color("#fff0ce"))
		"ajedrez":
			for row in range(8):
				for column in range(8):
					var p := Vector2(43 + column * 9, 6 + row * 9)
					_box(canvas, offset, unit, Rect2(p, Vector2(9, 9)), Color("#d9ceac") if (column + row) % 2 == 0 else Color("#596960"))
					if row in [0, 1, 6, 7]:
						var ink := Color("#223039") if row < 2 else Color("#f2e8c8")
						_box(canvas, offset, unit, Rect2(p + Vector2(2, 6), Vector2(5, 2)), ink)
						_box(canvas, offset, unit, Rect2(p + Vector2(3, 3), Vector2(3, 3)), ink)
						var height := 2 if row in [1, 6] else 3 + column % 2
						_box(canvas, offset, unit, Rect2(p + Vector2(3, 4 - height), Vector2(3, height)), ink)
		"monopolio":
			_box(canvas, offset, unit, Rect2(22, 5, 114, 74), Color("#9daf8e"))
			for index in range(11):
				for side in range(4):
					var p := Vector2(24 + index * 10, 7) if side == 0 else (Vector2(24 + index * 10, 67) if side == 1 else (Vector2(24, 7 + index * 6) if side == 2 else Vector2(124, 7 + index * 6)))
					_box(canvas, offset, unit, Rect2(p, Vector2(10, 10)), Color("#dfd7b5"))
					_box(canvas, offset, unit, Rect2(p, Vector2(9, 2)), [Color("#ba7770"), Color("#71a2b0"), Color("#c5a35d"), Color("#8e79a0")][index % 4])
			_box(canvas, offset, unit, Rect2(52, 26, 22, 14), Color("#b47c5b"))
			_box(canvas, offset, unit, Rect2(84, 42, 22, 14), Color("#7e9db1"))
			for point in [Vector2(72, 48), Vector2(82, 48)]:
				_box(canvas, offset, unit, Rect2(point, Vector2(7, 7)), Color("#ede4c7"))
				_box(canvas, offset, unit, Rect2(point + Vector2(3, 3), Vector2(1, 1)), Color("#253943"))
			_box(canvas, offset, unit, Rect2(26, 69, 4, 5), Color("#d65e59"))
			_box(canvas, offset, unit, Rect2(126, 9, 4, 5), Color("#4c87b8"))


static func _box(canvas: CanvasItem, offset: Vector2, unit: Vector2, area: Rect2, color: Color) -> void:
	canvas.draw_rect(Rect2((offset + area.position * unit).round(), (area.size * unit).ceil()), color)
