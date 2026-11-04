extends RefCounted
const Land = preload("res://scripts/campus_landscape.gd")
const ROWS := 8
const COLUMNS := 8
const CELL_SIZE := Land.SIZE / Vector2(COLUMNS, ROWS)


static func code(row: int, column: int) -> String:
	return "ABCDEFGH".substr(clampi(row, 0, ROWS - 1), 1) + str(clampi(column, 0, COLUMNS - 1) + 1)


static func bounds(row: int, column: int) -> Rect2:
	return Rect2(Vector2(column, row) * CELL_SIZE, CELL_SIZE)


static func at(point: Vector2) -> String:
	return code(floori(point.y / CELL_SIZE.y), floori(point.x / CELL_SIZE.x))
