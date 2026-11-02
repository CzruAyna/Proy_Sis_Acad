extends Control

signal cell_selected(index: int)
signal state_changed
signal pause_requested

const FONT = preload("res://assets/fonts/campus_pixel.fnt")
var model: RefCounted
var selected := -1
var destinations: Array[int] = []
var keyboard_square := 52
var _revision := -1
var _keys: Dictionary = {}
var _origin := Vector2.ZERO
var _scale := 1.0


func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	clip_contents = true
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_process(true)


func _process(delta: float) -> void:
	if model == null:
		return
	if model.game_id == "ping_pong" and not model.paused:
		var vertical := int(_keys.get(KEY_S, false) or _keys.get(KEY_DOWN, false)) - int(_keys.get(KEY_W, false) or _keys.get(KEY_UP, false))
		if vertical != 0:
			model.set_target(float(model.paddles[0]) + vertical * 350 * delta)
	model.advance(delta)
	if model.revision != _revision:
		_revision = model.revision
		state_changed.emit()
		queue_redraw()
	elif not model.paused and ((model.game_id == "ping_pong" and model.phase != "FINISHED") or (model.game_id == "billar" and model.phase == "MOVING")):
		queue_redraw()


func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_WM_WINDOW_FOCUS_OUT]:
		_keys.clear()
		if model != null:
			model.paused = true
			state_changed.emit()
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if model == null:
		return
	if event is InputEventKey:
		var key: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
		_keys[key] = event.pressed
		if event.pressed and not event.echo:
			if key == KEY_P:
				pause_requested.emit()
			elif model.game_id == "ajedrez":
				if key in [KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN]:
					var x := keyboard_square % 8
					var y := keyboard_square / 8
					x = clampi(x + int(key == KEY_RIGHT) - int(key == KEY_LEFT), 0, 7)
					y = clampi(y + int(key == KEY_DOWN) - int(key == KEY_UP), 0, 7)
					keyboard_square = y * 8 + x
					queue_redraw()
				elif key in [KEY_ENTER, KEY_SPACE]:
					cell_selected.emit(keyboard_square)
			elif key == KEY_SPACE:
				var action := "serve" if model.game_id == "ping_pong" else ("shoot" if model.game_id == "billar" else "roll")
				model.command({"type": action}, model.revision)
				state_changed.emit()
		accept_event()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		grab_focus()
		var point: Vector2 = (event.position - _origin) / _scale
		if model.game_id == "ajedrez" and Rect2(140, 0, 320, 320).has_point(point):
			var file := clampi(int((point.x - 140) / 40), 0, 7)
			var rank := clampi(int(point.y / 40), 0, 7)
			keyboard_square = rank * 8 + file
			cell_selected.emit(keyboard_square)
		elif model.game_id == "billar":
			model.command({"type": "aim", "angle": (point - model.positions[0]).angle(), "power": model.power}, model.revision)
			state_changed.emit()
		accept_event()
	elif event is InputEventMouseMotion and model.game_id == "ping_pong":
		model.set_target(((event.position - _origin) / _scale).y)


func _draw() -> void:
	if model == null:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color("#06100d"))
	_scale = maxf(0.1, minf((size.x - 12) / 600, (size.y - 12) / 340))
	_origin = ((size - Vector2(600, 340) * _scale) * 0.5).floor()
	draw_set_transform(_origin, 0, Vector2.ONE * _scale)
	match model.game_id:
		"ajedrez": _chess()
		"billar": _pool()
		"ping_pong": _pong()
		"monopolio": _property()
	draw_set_transform(Vector2.ZERO)
	if model.paused:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.72))
		draw_string(FONT, size * 0.5 + Vector2(-56, 6), "EN PAUSA", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#fff1b0"))


func _text(point: Vector2, value: String, font_size: int = 16, color: Color = Color("#ece5c7")) -> void:
	draw_string(FONT, point, value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


func _chess() -> void:
	for index in range(64):
		var point := Vector2(140 + index % 8 * 40, index / 8 * 40)
		var square := Rect2(point, Vector2.ONE * 40)
		draw_rect(square, Color("#b5c2a4") if (index / 8 + index % 8) % 2 == 0 else Color("#4e6c65"))
		if index == selected:
			draw_rect(square.grow(-2), Color("#ffe684"), false, 3)
		if destinations.has(index):
			draw_rect(Rect2(point + Vector2(16, 16), Vector2(8, 8)), Color("#64ecbe"))
		if index == keyboard_square and has_focus():
			draw_rect(square.grow(-1), Color("#61c9ff"), false, 2)
		var piece := int(model.board[index])
		if piece != 0:
			var color := Color("#f8f1cf") if piece > 0 else Color("#102b34")
			var outline := Color("#142b31") if piece > 0 else Color("#e1dec1")
			draw_rect(Rect2(point + Vector2(8, 28), Vector2(24, 7)), outline)
			draw_rect(Rect2(point + Vector2(9, 29), Vector2(22, 5)), color)
			draw_rect(Rect2(point + Vector2(14, 23), Vector2(12, 7)), color)
			draw_string_outline(FONT, point + Vector2(13, 23), " PNBRQK"[absi(piece)], HORIZONTAL_ALIGNMENT_LEFT, -1, 22, 2, outline)
			_text(point + Vector2(13, 23), " PNBRQK"[absi(piece)], 22, color)
	_text(Vector2(14, 25), "BLANCAS", 14)
	_text(Vector2(14, 47), "TÚ", 16)
	_text(Vector2(478, 25), "NEGRAS", 14)
	_text(Vector2(478, 47), "RIVAL", 16)
	for rank in range(8):
		_text(Vector2(124, rank * 40 + 25), str(8 - rank), 12)
	for file in range(8):
		_text(Vector2(156 + file * 40, 336), String.chr(97 + file), 10)


func _pool() -> void:
	draw_rect(Rect2(0, 0, 600, 300), Color("#896142"))
	draw_rect(Rect2(14, 14, 572, 272), Color("#286753"))
	for point in model.POCKETS:
		draw_rect(Rect2(point - Vector2(13, 13), Vector2(26, 26)), Color("#07150e"))
	for index in range(7):
		if not model.active[index]:
			continue
		var point: Vector2 = model.positions[index]
		var color: Color = [Color("#eee9cd"), Color("#e7c550"), Color("#c65e58"), Color("#658ec0"), Color("#bb7bba"), Color("#d38b4c"), Color("#76ad72")][index]
		draw_rect(Rect2(point - Vector2(7, 6), Vector2(14, 12)), color)
		draw_rect(Rect2(point - Vector2(5, 8), Vector2(10, 16)), color)
		draw_rect(Rect2(point - Vector2(4, 5), Vector2(4, 3)), color.lightened(0.4))
	if model.phase == "READY" and model.turn == 1:
		var direction := Vector2.from_angle(float(model.angle))
		draw_line(model.positions[0] + direction * 12, model.positions[0] + direction * 105, Color("#e6e7b1"), 1)
		draw_line(model.positions[0] - direction * 15, model.positions[0] - direction * 85, Color("#d4ae76"), 4)
	_text(Vector2(15, 318), "TÚ %d · RIVAL %d · TIRO %d/40" % [model.scores[0], model.scores[1], model.shots], 14)


func _pong() -> void:
	draw_rect(Rect2(0, 0, 600, 300), Color("#245368"))
	draw_rect(Rect2(8, 6, 584, 288), Color("#d5dfcd"), false, 2)
	for y in range(8, 290, 12):
		draw_rect(Rect2(298, y, 4, 7), Color("#bfd8cc"))
	for index in range(2):
		draw_rect(Rect2(30 if index == 0 else 558, float(model.paddles[index]) - 34, 12, 68), Color("#79b9e1") if index == 0 else Color("#df997b"))
	draw_rect(Rect2(model.ball - Vector2.ONE * 5, Vector2.ONE * 10), Color("#fff0c0"))
	_text(Vector2(220, 25), "%d : %d" % [model.scores[0], model.scores[1]], 28)
	_text(Vector2(16, 318), "TÚ: W/S, ↑/↓ O RATÓN · 7 PUNTOS, MÁXIMO 11", 14)


func _property() -> void:
	for index in range(20):
		var point := _tile_position(index)
		draw_rect(Rect2(point, Vector2(88, 52)), Color("#9aab87"))
		var owner := int(model.owners[index])
		var color := Color("#619cc1") if owner == 1 else (Color("#ce7c69") if owner == -1 else Color("#c9bf95"))
		draw_rect(Rect2(point + Vector2(2, 2), Vector2(84, 8)), color)
		_text(point + Vector2(5, 25), str(model.TILES[index]).to_upper(), 10, Color("#142d2b"))
		if model.PRICES.has(index):
			_text(point + Vector2(5, 41), "%d · +%d" % [model.PRICES[index], model.levels[index]], 10, Color("#142d2b"))
	for index in range(2):
		var point := _tile_position(int(model.positions[index])) + Vector2(20 + index * 28, 34)
		draw_rect(Rect2(point, Vector2(12, 14)), Color("#57c8ff") if index == 0 else Color("#ff8c76"))
	_text(Vector2(140, 120), "RUTA DEL CAMPUS", 20)
	_text(Vector2(140, 151), "TÚ %d · RIVAL %d" % [model.cash[0], model.cash[1]], 16)
	_text(Vector2(140, 181), "DADOS %d + %d" % [model.dice[0], model.dice[1]], 16)
	_text(Vector2(140, 211), "TURNO %d / 40" % [model.turns + 1], 16)


func _tile_position(index: int) -> Vector2:
	if index < 6:
		return Vector2(index * 100, 0)
	if index < 10:
		return Vector2(500, (index - 5) * 52)
	if index < 16:
		return Vector2((15 - index) * 100, 260)
	return Vector2(0, (20 - index) * 52)
