extends Control
## Game surface, input and bounded presentation effects; rules live in models.
signal cell_selected(index: int)
signal promotion_selected(piece: int)
signal action_requested(action: Dictionary)
signal state_changed
signal pause_requested

const FONT = preload("res://assets/fonts/campus_pixel.fnt")
const Pieces = preload("res://scripts/chess_piece_art.gd")
const Cave = preload("res://scripts/menu_cave.gd")
const BASE := Vector2(1000, 600)
const CHESS := Rect2(244, 28, 512, 512)
const COURT_ORIGIN := Vector2(65, 70)
const COURT_SCALE := 1.45
const BALL_COLORS := [Color("#f9f1d5"), Color("#f2c432"), Color("#467de3"), Color("#df4e5a"), Color("#9e60be"), Color("#ef8f38"), Color("#45996c"), Color("#9f3f39"), Color("#142031")]
var model: RefCounted
var selected := -1
var promotion := 5
var destinations: Array[int] = []
var keyboard_square := 52
var animations := true
var text_scale := 1.0
var selected_tile := -1
var _revision := -1
var _keys: Dictionary = {}
var _origin := Vector2.ZERO
var _scale := 1.0
var _drag := ""
var _anchor := Vector2.ZERO
var _drag_direction := Vector2.RIGHT
var _pull := 0.0
var _cue_preview := Vector2.ZERO
var _trail: Array[Vector2] = []
var _visual_time := 0.0
var _display_positions := [0, 0]
var _last_positions := [0, 0]
var _travel := [0, 0]
var _travel_clock := 0.0
var _dice_time := 0.0
var _hotspots: Array[Dictionary] = []
var _background_size := Vector2.ZERO
var _background: Dictionary = {}


func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	clip_contents = true
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if model.game_id == "monopolio":
		_display_positions = model.positions.duplicate()
		_last_positions = model.positions.duplicate()
	set_process(true)


func _process(delta: float) -> void:
	if model == null:
		return
	var dt := minf(delta, 0.1)
	if not model.paused:
		_visual_time += dt
		if model.game_id == "ping_pong":
			var vertical := int(_keys.get(KEY_S, false) or _keys.get(KEY_DOWN, false)) - int(_keys.get(KEY_W, false) or _keys.get(KEY_UP, false))
			if vertical != 0:
				model.set_target(float(model.paddles[0]) + vertical * 440 * dt)
			if animations and model.phase == "PLAY":
				_trail.append(model.ball)
				if _trail.size() > 12:
					_trail.pop_front()
			else:
				_trail.clear()
		if model.game_id == "monopolio":
			_animate_property(dt)
	if not _property_busy():
		model.advance(dt)
	if model.game_id == "monopolio":
		for side in range(2):
			if model.positions[side] != _last_positions[side]:
				_travel[side] = posmod(int(model.positions[side]) - int(_display_positions[side]), 20) if animations else 0
				_display_positions[side] = _display_positions[side] if animations else model.positions[side]
				_last_positions[side] = model.positions[side]
				selected_tile = int(model.positions[side])
				_dice_time = 0.45 if animations else 0
	if model.revision != _revision:
		_revision = model.revision
		state_changed.emit()
		queue_redraw()
	elif not model.paused and ((model.game_id == "ping_pong" and model.phase != "FINISHED") or (model.game_id == "billar" and model.phase == "MOVING") or _property_busy()):
		queue_redraw()


func _animate_property(delta: float) -> void:
	_dice_time = maxf(0, _dice_time - delta)
	_travel_clock += delta
	if _travel_clock < 0.065 or _dice_time > 0:
		return
	_travel_clock = 0
	for side in range(2):
		if _travel[side] > 0:
			_display_positions[side] = (int(_display_positions[side]) + 1) % 20
			_travel[side] -= 1


func _property_busy() -> bool:
	return model.game_id == "monopolio" and (_dice_time > 0 or _travel[0] > 0 or _travel[1] > 0)


func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_WM_WINDOW_FOCUS_OUT]:
		_keys.clear()
		_drag = ""
		if model != null and not model.paused:
			model.command({"type": "pause"})
			state_changed.emit()
	elif what == NOTIFICATION_RESIZED:
		queue_redraw()


func _dispatch(action: Dictionary) -> void:
	if action_requested.get_connections().is_empty():
		model.command(action, model.revision)
		state_changed.emit()
	else:
		action_requested.emit(action)
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if model == null:
		return
	if event is InputEventKey:
		var key: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
		_keys[key] = event.pressed
		if event.pressed and not event.echo:
			if key == KEY_P:
				_drag = ""
				pause_requested.emit()
			elif key == KEY_ESCAPE:
				_drag = ""
			elif not model.paused:
				_key_action(key)
		accept_event()
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_drag = ""
			if event.pressed and model.game_id == "ping_pong":
				_dispatch({"type": "boost"})
			queue_redraw()
			accept_event()
			return
		if event.button_index != MOUSE_BUTTON_LEFT:
			return
		grab_focus()
		var point: Vector2 = (event.position - _origin) / _scale
		if not model.paused:
			if event.pressed:
				_mouse_down(point)
			else:
				_mouse_up(point)
		accept_event()
	elif event is InputEventMouseMotion and not model.paused:
		var point: Vector2 = (event.position - _origin) / _scale
		if model.game_id == "ping_pong":
			model.set_target(_court_point(point).y)
		elif model.game_id == "billar":
			_pool_motion(_court_point(point))


func _key_action(key: int) -> void:
	match model.game_id:
		"ajedrez":
			if key in [KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN]:
				var x := keyboard_square % 8
				var y := keyboard_square / 8
				x = clampi(x + int(key == KEY_RIGHT) - int(key == KEY_LEFT), 0, 7)
				y = clampi(y + int(key == KEY_DOWN) - int(key == KEY_UP), 0, 7)
				keyboard_square = y * 8 + x
				queue_redraw()
			elif key in [KEY_ENTER, KEY_SPACE]:
				cell_selected.emit(keyboard_square)
		"billar":
			if key in [KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN]:
				_dispatch({"type": "aim", "angle": model.angle + (int(key == KEY_RIGHT) - int(key == KEY_LEFT)) * deg_to_rad(0.5), "power": model.power + (int(key == KEY_UP) - int(key == KEY_DOWN)) * 5})
			elif key == KEY_SPACE:
				_dispatch({"type": "shoot"})
		"ping_pong":
			if key == KEY_SPACE:
				_dispatch({"type": "serve"})
			elif key == KEY_SHIFT:
				_dispatch({"type": "boost"})
		"monopolio":
			if key in [KEY_SPACE, KEY_ENTER] and not _property_busy():
				_dispatch({"type": "roll" if model.phase == "READY" else "end"})


func _mouse_down(point: Vector2) -> void:
	if model.game_id == "billar" and model.positions.size() == 16 and point.distance_to(Vector2(962, 170)) < 28:
		var offset := (point - Vector2(962, 170)) / 26
		_dispatch({"type": "spin", "x": clampf(offset.x, -1, 1), "y": clampf(-offset.y, -1, 1)})
		return
	for hotspot in _hotspots:
		if Rect2(hotspot["rect"]).has_point(point):
			if hotspot["enabled"]:
				if hotspot["action"].get("type") == "promotion":
					promotion_selected.emit(hotspot["action"]["piece"])
				else:
					_dispatch(hotspot["action"])
			return
	match model.game_id:
		"ajedrez":
			if CHESS.has_point(point):
				var cell := Vector2i((point - CHESS.position) / 64)
				keyboard_square = cell.y * 8 + cell.x
				cell_selected.emit(keyboard_square)
		"billar":
			_pool_down(_court_point(point))
		"ping_pong":
			if model.phase == "SERVE" and _court_point(point).x >= 0:
				_dispatch({"type": "serve"})
		"monopolio":
			for tile in range(20):
				if tile_rect(tile).has_point(point):
					selected_tile = tile
					queue_redraw()
					return


func _court_point(point: Vector2) -> Vector2:
	return (point - COURT_ORIGIN) / COURT_SCALE


func _pool_down(point: Vector2) -> void:
	if model.turn != 1 or model.phase not in ["READY", "PLACEMENT"]:
		return
	if model.positions.size() == 16:
		for pocket in range(6):
			if point.distance_to(model.POCKETS[pocket]) <= 18:
				_dispatch({"type": "call", "pocket": pocket})
				return
		if model.can_place and (model.phase == "PLACEMENT" or point.distance_to(model.positions[0]) < 14):
			_drag = "place"
			_cue_preview = point
			queue_redraw()
			return
	if not Rect2(0, 0, 600, 300).has_point(point):
		return
	_anchor = point
	_drag_direction = (point - model.positions[0]).normalized()
	if _drag_direction.length_squared() < 0.1:
		_drag_direction = Vector2.from_angle(model.angle)
	_dispatch({"type": "aim", "angle": _drag_direction.angle(), "power": model.power})
	_drag = "cue"
	_pull = 0


func _pool_motion(point: Vector2) -> void:
	if model.turn != 1 or model.phase not in ["READY", "PLACEMENT"]:
		return
	if _drag == "cue":
		_pull = clampf((_anchor - point).dot(_drag_direction), 0, 100)
		queue_redraw()
	elif _drag == "place":
		_cue_preview = point
		queue_redraw()


func _mouse_up(point: Vector2) -> void:
	if model.game_id != "billar":
		return
	var mode := _drag
	_drag = ""
	if mode == "place":
		var p := _court_point(point)
		_dispatch({"type": "place", "x": p.x, "y": p.y})
	elif mode == "cue" and _pull >= 5:
		_dispatch({"type": "aim", "angle": _drag_direction.angle(), "power": _pull})
		_dispatch({"type": "shoot"})
	queue_redraw()


func _draw() -> void:
	if model == null:
		return
	if _background_size != size:
		_background_size = size
		_background = Cave.frame(Rect2(Vector2.ONE * 12, size - Vector2.ONE * 24), 32, 0, -1)
	var bounds: Rect2 = _background["bounds"]
	for row in range(_background["spans"].size()):
		for span in _background["spans"][row]:
			draw_rect(Rect2(span.x, bounds.position.y + row * float(_background["step"]), span.y - span.x, _background["step"]), Color.BLACK)
	_scale = maxf(0.1, minf((size.x - 16) / BASE.x, (size.y - 16) / BASE.y))
	_origin = ((size - BASE * _scale) * 0.5).floor()
	_hotspots.clear()
	draw_set_transform(_origin, 0, Vector2.ONE * _scale)
	match model.game_id:
		"ajedrez": _chess()
		"billar": _pool()
		"ping_pong": _pong()
		"monopolio": _property()
	if model.paused:
		draw_rect(Rect2(Vector2(300, 245), Vector2(400, 90)), Color("#050911"))
		_text(Vector2(398, 294), "EN PAUSA", 28, Color("#ffe7a0"))
	draw_set_transform(Vector2.ZERO)


func _text(point: Vector2, value: String, font_size: int = 18, color: Color = Color("#e9f1e0"), adaptive: bool = true) -> void:
	draw_string(FONT, point, value, HORIZONTAL_ALIGNMENT_LEFT, -1, roundi(font_size * text_scale) if adaptive else font_size, color)


func _target(rect: Rect2, text: String, action: Dictionary, enabled: bool = true) -> void:
	var can_play: bool = enabled and model.turn == 1 and not model.paused and model.phase != "FINISHED" and not _property_busy()
	if model.game_id == "ping_pong" and action.get("type") == "boost":
		can_play = enabled and not model.paused and model.phase == "PLAY"
	_hotspots.append({"rect": rect, "action": action, "enabled": can_play})
	draw_rect(rect, Color("#15394a") if can_play else Color("#15232b"))
	draw_rect(rect, Color("#65d4e7") if can_play else Color("#526368"), false, 2)
	_text(rect.position + Vector2(12, rect.size.y * 0.5 + 6), text, 16, Color("#effbdc") if can_play else Color("#7e9295"))


static func chess_cell_centre(square: int) -> Vector2:
	return CHESS.position + Vector2(square % 8 * 64 + 32, square / 8 * 64 + 32)


func _chess() -> void:
	draw_rect(CHESS.grow(8), Color("#816549"))
	for square in range(64):
		var point := CHESS.position + Vector2(square % 8 * 64, square / 8 * 64)
		var rect := Rect2(point, Vector2.ONE * 64)
		draw_rect(rect, Color("#c5ccb0") if (square / 8 + square % 8) % 2 == 0 else Color("#496a63"))
		if square == selected:
			draw_rect(rect.grow(-3), Color("#ffe684"), false, 4)
		if destinations.has(square):
			draw_circle(point + Vector2.ONE * 32, 7, Color("#45e9b7"))
		if square == keyboard_square and has_focus():
			draw_rect(rect.grow(-1), Color("#55c8ff"), false, 2)
		var piece := int(model.board[square])
		if piece != 0:
			draw_texture_rect(Pieces.texture(piece), Rect2(point + Vector2(12, 5), Vector2(40, 50)), false)
	_text(Vector2(28, 53), "TÚ · BLANCAS", 21)
	_text(Vector2(790, 53), "RIVAL", 21)
	_text(Vector2(28, 100), "Elige una pieza", 16)
	_text(Vector2(28, 128), "y su destino.", 16)
	for type in range(1, 7):
		var point := Vector2(30, 145 + (type - 1) * 54)
		draw_texture_rect(Pieces.texture(type), Rect2(point, Vector2(32, 40)), false)
		_text(point + Vector2(44, 28), ["", "Peón", "Caballo", "Alfil", "Torre", "Dama", "Rey"][type], 16)
	_text(Vector2(787, 105), "Promoción", 17)
	for index in range(4):
		var type: int = [5, 4, 3, 2][index]
		var rect := Rect2(790, 120 + index * 67, 150, 58)
		_target(rect, "", {"type": "promotion", "piece": type})
		draw_texture_rect(Pieces.texture(type), Rect2(rect.position + Vector2(12, 6), Vector2(36, 45)), false)
		_text(rect.position + Vector2(60, 35), ["Dama", "Torre", "Alfil", "Caballo"][index], 15)
		if promotion == type:
			draw_rect(rect.grow(-3), Color("#eacb64"), false, 2)
	_target(Rect2(790, 414, 180, 42), "Tablas", {"type": "claim_draw"}, model.halfmoves >= 100 or int(model.repetitions.get(model.position_key(), 0)) >= 3)
	_target(Rect2(790, 470, 180, 42), "Abandonar", {"type": "resign"})
	for rank in range(8):
		_text(Vector2(224, CHESS.position.y + rank * 64 + 40), str(8 - rank), 14)
	for file in range(8):
		_text(Vector2(CHESS.position.x + file * 64 + 26, 568), String.chr(97 + file), 14)


func _pixel_ball(point: Vector2, number: int, radius: int = 8) -> void:
	var color: Color = BALL_COLORS[number if number <= 8 else number - 8]
	for y in range(-radius, radius + 1):
		var half := floori(sqrt(maxi(0, radius * radius - y * y)))
		var row_color := Color("#eceddc") if number > 8 and absi(y) > radius / 2 else color
		if y > radius / 2:
			row_color = row_color.darkened(0.25)
		draw_rect(Rect2(point + Vector2(-half, y), Vector2(half * 2, 1)), row_color)
	draw_rect(Rect2(point + Vector2(-radius * 0.5, -radius * 0.6), Vector2(3, 2)), Color(1, 1, 1, 0.6))
	if number > 0:
		draw_circle(point, 4.5, Color("#f2f2e3"))
		_text(point + Vector2(-3.5 if number < 10 else -6, 3), str(number), 8, Color("#10202b"), false)


func _pool() -> void:
	var modern: bool = model.positions.size() == 16
	_text(Vector2(65, 31), "BILLAR · OCHO BOLAS" if modern else "BILLAR · PARTIDA CLÁSICA", 25)
	if modern:
		if model.groups[0] == 0:
			_text(Vector2(594, 31), "MESA ABIERTA", 22, Color("#edce6e"))
		else:
			_text(Vector2(530, 31), "TÚ %s: %d" % ["LISAS" if model.groups[0] == 1 else "RAYADAS", model.remaining(model.groups[0])], 16, Color("#edce6e"))
			_text(Vector2(760, 31), "RIVAL %s: %d" % ["LISAS" if model.groups[1] == 1 else "RAYADAS", model.remaining(model.groups[1])], 16, Color("#edce6e"))
	draw_set_transform(_origin + COURT_ORIGIN * _scale, 0, Vector2.ONE * _scale * COURT_SCALE)
	draw_rect(Rect2(-6, -6, 612, 312), Color("#302b2c"))
	draw_rect(Rect2(0, 0, 600, 300), Color("#916648"))
	draw_rect(Rect2(12, 12, 576, 276), Color("#155a4c"))
	draw_rect(Rect2(21, 21, 558, 258), Color("#247961"), false, 2)
	for x in range(90, 600, 80):
		for y in [6, 294]:
			draw_rect(Rect2(x, y - 1, 3, 3), Color("#d6c8a6"))
	for pocket in range(6):
		var point: Vector2 = model.POCKETS[pocket]
		draw_circle(point, 18, Color("#b6a27b"))
		draw_circle(point, 15, Color("#02090c"))
		if modern and model.called_pocket == pocket:
			draw_arc(point, 19, 0, TAU, 24, Color("#ffe878"), 2)
	if modern and model.break_shot:
		draw_line(Vector2(150, 30), Vector2(150, 270), Color(0.8, 0.9, 0.7, 0.25))
	for number in range(model.positions.size()):
		if model.active[number]:
			_pixel_ball(model.positions[number], number)
	if _drag == "place":
		draw_circle(_cue_preview, 11, Color("#70f2ac") if model.valid_placement(_cue_preview) else Color("#ef6c71"))
		_pixel_ball(_cue_preview, 0)
	if model.phase == "READY" and model.turn == 1:
		var direction := Vector2.from_angle(float(model.angle))
		var end: Vector2 = model.positions[0] + direction * 170
		var ghost := Vector2.ZERO
		var nearest := 170.0
		for number in range(1, model.positions.size()):
			if not model.active[number]:
				continue
			var along: float = (model.positions[number] - model.positions[0]).dot(direction)
			var lateral: float = absf((model.positions[number] - model.positions[0]).cross(direction))
			if along > 0 and lateral < 16 and along < nearest:
				nearest = maxf(0, along - sqrt(256 - lateral * lateral))
				end = model.positions[0] + direction * nearest
				ghost = end
		draw_line(model.positions[0] + direction * 10, end, Color("#deedbd"), 1)
		if ghost != Vector2.ZERO:
			draw_arc(ghost, 8, 0, TAU, 18, Color("#dbf2cf"), 1)
		var pull := _pull * 0.45 if _drag == "cue" else 0.0
		draw_line(model.positions[0] - direction * (14 + pull), model.positions[0] - direction * (94 + pull), Color("#edd2a0"), 3)
	draw_set_transform(_origin, 0, Vector2.ONE * _scale)
	_text(Vector2(65, 551), "FUERZA %d%% · RETIRA EL TACO Y SUELTA · CLIC DERECHO CANCELA" % int(_pull if _drag == "cue" else model.power), 17)
	if modern:
		_text(Vector2(65, 581), "BLANCA EN MANO: COLOCAR" if model.phase == "PLACEMENT" else "FLECHAS: AJUSTE FINO · ESPACIO: TIRO · NEGRA: ELIGE TRONERA", 15, Color("#aad9cb"))
		# Direct contact point on the cue-ball diagram; not a slider.
		_text(Vector2(938, 121), "EFECTO", 12)
		_pixel_ball(Vector2(962, 170), 0, 26)
		var contact: Vector2 = Vector2(962, 170) + Vector2(model.spin.x, -model.spin.y) * 20
		draw_rect(Rect2(contact - Vector2.ONE * 3, Vector2.ONE * 6), Color("#de465d"))
		_text(Vector2(944, 221), "CLIC", 12)


func _pong() -> void:
	_text(Vector2(65, 32), "PING-PONG", 25)
	_text(Vector2(420, 38), "%02d : %02d" % [model.scores[0], model.scores[1]], 36)
	_target(Rect2(700, 5, 235, 44), "Impulso [Shift]", {"type": "boost"}, model.boost_cooldown <= 0 and model.phase == "PLAY")
	draw_set_transform(_origin + COURT_ORIGIN * _scale, 0, Vector2.ONE * _scale * COURT_SCALE)
	draw_rect(Rect2(-5, -5, 610, 310), Color("#253a52"))
	draw_rect(Rect2(0, 0, 600, 300), Color("#215a7a"))
	draw_rect(Rect2(8, 6, 584, 288), Color("#d5dfcd"), false, 2)
	draw_line(Vector2(12, 150), Vector2(588, 150), Color("#417b99"), 1)
	for y in range(8, 290, 12):
		draw_rect(Rect2(298, y, 4, 7), Color("#bfd8cc"))
	for index in range(_trail.size()):
		draw_rect(Rect2(_trail[index] - Vector2.ONE * 3, Vector2.ONE * 6), Color(0.6, 0.9, 1, float(index) / 24))
	for index in range(2):
		var point := Vector2(30 if index == 0 else 558, float(model.paddles[index]))
		draw_rect(Rect2(point + Vector2(-3, -37), Vector2(17, 74)), Color("#0c283a"))
		draw_rect(Rect2(point + Vector2(0, -34), Vector2(12, 68)), Color("#71dbf2") if index == 0 else Color("#e98e78"))
		if index == 0 and model.boost_left > 0:
			draw_rect(Rect2(point + Vector2(-6, -36), Vector2(3, 72)), Color("#ffe783"))
	_pixel_ball(model.ball, 0, 5)
	if model.phase == "SERVE":
		_text(Vector2(185, 145), "CLIC / ESPACIO: SACAR" if model.turn == 1 else "PREPARA LA DEVOLUCIÓN", 16)
	draw_set_transform(_origin, 0, Vector2.ONE * _scale)
	_text(Vector2(65, 551), "W/S · FLECHAS · RATÓN · SHIFT: IMPULSO · MOVER LA PALETA CAMBIA EL REBOTE", 15)
	_text(Vector2(65, 581), "INTERCAMBIO %d · IMPULSO %s · PRIMERO A 7, DOS DE VENTAJA; MÁXIMO 11" % [model.rallies, "LISTO" if model.boost_cooldown <= 0 else "%.1fs" % model.boost_cooldown], 15, Color("#aad9cb"))


static func tile_rect(index: int) -> Rect2:
	var point := Vector2.ZERO
	if index < 6:
		point = Vector2(62 + index * 146, 12)
	elif index < 10:
		point = Vector2(792, 12 + (index - 5) * 96)
	elif index < 16:
		point = Vector2(62 + (15 - index) * 146, 492)
	else:
		point = Vector2(62, 12 + (20 - index) * 96)
	return Rect2(point, Vector2(140, 90))


func _die(point: Vector2, value: int) -> void:
	draw_rect(Rect2(point, Vector2(56, 56)), Color("#eee9cc"))
	draw_rect(Rect2(point, Vector2(56, 56)), Color("#8a9b9f"), false, 3)
	var dots := [[Vector2(28, 28)], [Vector2(14, 14), Vector2(42, 42)], [Vector2(14, 14), Vector2(28, 28), Vector2(42, 42)], [Vector2(14, 14), Vector2(42, 14), Vector2(14, 42), Vector2(42, 42)], [Vector2(14, 14), Vector2(42, 14), Vector2(28, 28), Vector2(14, 42), Vector2(42, 42)], [Vector2(14, 14), Vector2(42, 14), Vector2(14, 28), Vector2(42, 28), Vector2(14, 42), Vector2(42, 42)]]
	for dot in dots[clampi(value, 1, 6) - 1]:
		draw_rect(Rect2(point + dot - Vector2.ONE * 4, Vector2.ONE * 8), Color("#18303d"))


func _property() -> void:
	for tile in range(20):
		var rect := tile_rect(tile)
		var point := rect.position
		draw_rect(rect, Color("#d0d4b8"))
		var owner := int(model.owners[tile])
		var color := Color("#568fbb") if owner == 1 else (Color("#cc746e") if owner == -1 else Color("#6c8d74"))
		draw_rect(Rect2(point, Vector2(140, 13)), color)
		_text(point + Vector2(7, 33), str(model.TILES[tile]).to_upper(), 14, Color("#152c35"))
		if model.PRICES.has(tile):
			_text(point + Vector2(7, 54), "%d C · RENTA %d" % [model.PRICES[tile], int(model.PRICES[tile]) / 5 * (1 + int(model.levels[tile]))], 11, Color("#324947"))
			for house in range(model.levels[tile]):
				var h := point + Vector2(102 + house * 15, 67)
				draw_rect(Rect2(h, Vector2(11, 10)), Color("#3a8268"))
				draw_colored_polygon(PackedVector2Array([h + Vector2(-2, 0), h + Vector2(5, -7), h + Vector2(13, 0)]), Color("#786043"))
		else:
			_text(point + Vector2(7, 55), "+100 AL PASAR" if tile == 0 else ("SUERTE" if tile in [3, 9, 17] else "PAUSA" if tile in [5, 15] else "45 CRÉDITOS"), 11, Color("#324947"))
		if tile == selected_tile:
			draw_rect(rect.grow(-2), Color("#f5b845"), false, 4)
	for side in range(2):
		var point := tile_rect(int(_display_positions[side])).position + Vector2(25 + side * 30, 70)
		var color := Color("#2489ce") if side == 0 else Color("#dc6263")
		draw_circle(point - Vector2(0, 7), 6, color)
		draw_rect(Rect2(point + Vector2(-7, -1), Vector2(14, 14)), color)
		draw_rect(Rect2(point + Vector2(-9, 12), Vector2(18, 4)), Color("#153349"))
	_text(Vector2(247, 141), "RUTA DEL CAMPUS", 28)
	_text(Vector2(247, 179), "TÚ %d C · PATRIMONIO %d" % [model.cash[0], model.wealth(0)], 18, Color("#8dd6ff"))
	_text(Vector2(247, 210), "RIVAL %d C · PATRIMONIO %d" % [model.cash[1], model.wealth(1)], 18, Color("#f7b29e"))
	var die_a := int(_visual_time * 29) % 6 + 1 if _dice_time > 0 else int(model.dice[0])
	var die_b := int(_visual_time * 37) % 6 + 1 if _dice_time > 0 else int(model.dice[1])
	_die(Vector2(434, 232), die_a)
	_die(Vector2(507, 232), die_b)
	if model.phase == "READY":
		_target(Rect2(412, 224, 170, 72), "", {"type": "roll"})
		_die(Vector2(424, 232), die_a)
		_die(Vector2(507, 232), die_b)
	_text(Vector2(247, 327), "TURNO %d/40 · %s" % [mini(model.turns + 1, 40), "LANZA LOS DADOS" if model.phase == "READY" else "MIRA LA CASILLA"], 16)
	var tile := selected_tile if selected_tile >= 0 else int(model.positions[0 if model.turn == 1 else 1])
	_text(Vector2(247, 358), str(model.TILES[tile]).to_upper(), 20, Color("#e8cc7d"))
	if model.PRICES.has(tile):
		_text(Vector2(247, 385), "PRECIO %d · NIVEL %d · %s" % [model.PRICES[tile], model.levels[tile], "LIBRE" if model.owners[tile] == 0 else "TUYA" if model.owners[tile] == 1 else "DEL RIVAL"], 15)
	else:
		_text(Vector2(247, 385), "CLIC EN CUALQUIER CASILLA PARA CONSULTARLA", 14)
	var current := int(model.positions[0])
	if model.phase == "BUY":
		_target(Rect2(247, 414, 235, 46), "Comprar %d C" % int(model.PRICES[current]), {"type": "buy"}, tile == current and model.cash[0] >= int(model.PRICES[current]))
	elif model.phase == "UPGRADE":
		_target(Rect2(247, 414, 235, 46), "Construir 70 C", {"type": "upgrade"}, tile == current and model.cash[0] >= 70)
	if model.phase in ["BUY", "UPGRADE", "END"]:
		_target(Rect2(507, 414, 245, 46), "Finalizar turno", {"type": "end"})
