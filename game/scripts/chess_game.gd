extends "res://scripts/recreation_game.gd"

const PAWN := 1
const KNIGHT := 2
const BISHOP := 3
const ROOK := 4
const QUEEN := 5
const KING := 6
const VALUES := [0, 100, 320, 330, 500, 900, 0]
const KNIGHTS := [Vector2i(1, 2), Vector2i(2, 1), Vector2i(2, -1), Vector2i(1, -2), Vector2i(-1, -2), Vector2i(-2, -1), Vector2i(-2, 1), Vector2i(-1, 2)]
const DIRECTIONS := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]
const NODE_LIMIT := 2400
var board := PackedInt32Array()
var rights := 15
var ep := -1
var halfmoves := 0
var ply := 0
var repetitions: Dictionary = {}
var notation: Array[String] = []
var nodes := 0
var cache_hits := 0
var _legal_cache: Dictionary = {}
var _ai_moves: Array[Dictionary] = []
var _ai_choices: Array[Dictionary] = []
var _ai_cursor := 0
var _ai_best := -40000


func _init(seed_value: int = 1) -> void:
	super(seed_value)
	game_id = "ajedrez"
	board.resize(64)
	var back := [ROOK, KNIGHT, BISHOP, QUEEN, KING, BISHOP, KNIGHT, ROOK]
	for file in range(8):
		board[file] = -int(back[file])
		board[8 + file] = -PAWN
		board[48 + file] = PAWN
		board[56 + file] = int(back[file])
	repetitions[position_key()] = 1
	message = "Juegas con blancas. Elige una pieza y una casilla marcada."


static func square(name: String) -> int:
	if name.length() != 2:
		return -1
	var file := name.unicode_at(0) - 97
	var rank := int(name.substr(1))
	return (8 - rank) * 8 + file if file >= 0 and file < 8 and rank >= 1 and rank <= 8 else -1


static func coordinate(index: int) -> String:
	return String.chr(97 + index % 8) + str(8 - index / 8)


func attacked(index: int, side: int) -> bool:
	var file := index % 8
	var rank := index / 8
	var pawn_rank := rank + side
	for dx in [-1, 1]:
		if _inside(file + dx, pawn_rank) and board[pawn_rank * 8 + file + dx] == side * PAWN:
			return true
	for offset in KNIGHTS:
		var x: int = file + offset.x
		var y: int = rank + offset.y
		if _inside(x, y) and board[y * 8 + x] == side * KNIGHT:
			return true
	for direction in DIRECTIONS:
		var x: int = file + direction.x
		var y: int = rank + direction.y
		var distance := 1
		while _inside(x, y):
			var piece := board[y * 8 + x]
			if piece != 0:
				if signi(piece) == side:
					var type := absi(piece)
					if type == QUEEN or (distance == 1 and type == KING) or (type == BISHOP and direction.x != 0 and direction.y != 0) or (type == ROOK and (direction.x == 0 or direction.y == 0)):
						return true
				break
			x += direction.x
			y += direction.y
			distance += 1
	return false


static func _inside(x: int, y: int) -> bool:
	return x >= 0 and x < 8 and y >= 0 and y < 8


func in_check(side: int) -> bool:
	var king := board.find(side * KING)
	return king < 0 or attacked(king, -side)


func _append_move(list: Array[Dictionary], from: int, to: int, en_passant: bool = false) -> void:
	if absi(board[from]) == PAWN and to / 8 in [0, 7]:
		for promote in [QUEEN, ROOK, BISHOP, KNIGHT]:
			list.append({"from": from, "to": to, "promotion": promote, "ep": false})
	else:
		list.append({"from": from, "to": to, "promotion": 0, "ep": en_passant})


func _pseudo_moves() -> Array[Dictionary]:
	var moves: Array[Dictionary] = []
	for from in range(64):
		var piece := board[from]
		if signi(piece) != turn:
			continue
		var file := from % 8
		var rank := from / 8
		var type := absi(piece)
		if type == PAWN:
			var next := from - turn * 8
			if next >= 0 and next < 64 and board[next] == 0:
				_append_move(moves, from, next)
				if rank == (6 if turn == 1 else 1) and board[from - turn * 16] == 0:
					_append_move(moves, from, from - turn * 16)
			for dx in [-1, 1]:
				var target: int = next + dx
				if not _inside(file + dx, rank - turn):
					continue
				if board[target] != 0 and signi(board[target]) == -turn and absi(board[target]) != KING:
					_append_move(moves, from, target)
				elif target == ep and board[target] == 0 and board[target + turn * 8] == -turn * PAWN:
					_append_move(moves, from, target, true)
		elif type == KNIGHT:
			for offset in KNIGHTS:
				var x: int = file + offset.x
				var y: int = rank + offset.y
				if _inside(x, y) and signi(board[y * 8 + x]) != turn and absi(board[y * 8 + x]) != KING:
					_append_move(moves, from, y * 8 + x)
		else:
			for direction in DIRECTIONS:
				if type == BISHOP and (direction.x == 0 or direction.y == 0):
					continue
				if type == ROOK and direction.x != 0 and direction.y != 0:
					continue
				var x: int = file + direction.x
				var y: int = rank + direction.y
				while _inside(x, y):
					var target := y * 8 + x
					if signi(board[target]) == turn or absi(board[target]) == KING:
						break
					_append_move(moves, from, target)
					if board[target] != 0 or type == KING:
						break
					x += direction.x
					y += direction.y
			if type == KING:
				_castles(moves, from)
	return moves


func _castles(moves: Array[Dictionary], from: int) -> void:
	var home := 60 if turn == 1 else 4
	if from != home or in_check(turn):
		return
	var king_bit := 1 if turn == 1 else 4
	var queen_bit := 2 if turn == 1 else 8
	if rights & king_bit and board[home + 3] == turn * ROOK and board[home + 1] == 0 and board[home + 2] == 0 and not attacked(home + 1, -turn) and not attacked(home + 2, -turn):
		_append_move(moves, home, home + 2)
	if rights & queen_bit and board[home - 4] == turn * ROOK and board[home - 1] == 0 and board[home - 2] == 0 and board[home - 3] == 0 and not attacked(home - 1, -turn) and not attacked(home - 2, -turn):
		_append_move(moves, home, home - 2)


func _push(move: Dictionary) -> Array:
	var undo := [board.duplicate(), turn, rights, ep, halfmoves]
	var from := int(move["from"])
	var to := int(move["to"])
	var piece := board[from]
	var captured := board[to]
	board[to] = piece
	board[from] = 0
	if move.get("ep", false):
		board[to + turn * 8] = 0
		captured = -turn * PAWN
	if int(move.get("promotion", 0)) != 0:
		board[to] = turn * int(move["promotion"])
	if absi(piece) == KING:
		rights &= ~(3 if turn == 1 else 12)
		if absi(to - from) == 2:
			var rook_from := from + 3 if to > from else from - 4
			var rook_to := from + 1 if to > from else from - 1
			board[rook_to] = board[rook_from]
			board[rook_from] = 0
	for entry in [[63, 1], [56, 2], [7, 4], [0, 8]]:
		if from == entry[0] or to == entry[0]:
			rights &= ~int(entry[1])
	ep = (from + to) / 2 if absi(piece) == PAWN and absi(to - from) == 16 else -1
	halfmoves = 0 if absi(piece) == PAWN or captured != 0 else halfmoves + 1
	turn *= -1
	return undo


func _pop(undo: Array) -> void:
	board = undo[0]
	turn = undo[1]
	rights = undo[2]
	ep = undo[3]
	halfmoves = undo[4]


func legal_moves() -> Array[Dictionary]:
	var key := position_key()
	if _legal_cache.has(key):
		cache_hits += 1
		return _legal_cache[key].duplicate(true)
	var result: Array[Dictionary] = []
	for move in _pseudo_moves():
		var side := turn
		var undo := _push(move)
		var legal := not in_check(side)
		_pop(undo)
		if legal:
			result.append(move)
	if _legal_cache.size() < 128:
		_legal_cache[key] = result.duplicate(true)
	return result


func _action(action: Dictionary) -> bool:
	if action.get("type") == "claim_draw":
		if halfmoves >= 100 or int(repetitions.get(position_key(), 0)) >= 3:
			finish(0, "Tablas reclamadas por repetición o 50 movimientos.")
			return true
		return false
	if action.get("type") != "move":
		return false
	for move in legal_moves():
		if int(action.get("from", -1)) == move["from"] and int(action.get("to", -1)) == move["to"] and int(action.get("promotion", QUEEN)) == (int(move["promotion"]) if int(move["promotion"]) != 0 else QUEEN):
			play(move)
			return true
	return false


func play(move: Dictionary) -> void:
	_legal_cache.clear()
	_ai_moves.clear()
	_ai_choices.clear()
	var label := coordinate(int(move["from"])) + "–" + coordinate(int(move["to"]))
	if int(move.get("promotion", 0)) != 0:
		label += "=" + " PNBRQK"[int(move["promotion"])]
	_push(move)
	ply += 1
	notation.append(label)
	if notation.size() > 300:
		notation.pop_front()
	var key := position_key()
	if halfmoves == 0:
		repetitions.clear()
	repetitions[key] = int(repetitions.get(key, 0)) + 1
	var moves := legal_moves()
	if moves.is_empty():
		finish(-turn if in_check(turn) else 0, ("Jaque mate. " + ("Ganaste." if turn == -1 else "Gana el rival.")) if in_check(turn) else "Tablas por ahogado.")
	elif halfmoves >= 150 or int(repetitions[key]) >= 5 or insufficient_material():
		finish(0, "Tablas por repetición, material insuficiente o 75 movimientos.")
	else:
		message = ("Tu turno." if turn == 1 else "El rival está pensando…") + (" Jaque." if in_check(turn) else "")
	revision += 1


func insufficient_material() -> bool:
	var minor := []
	for index in range(64):
		var type := absi(board[index])
		if type in [PAWN, ROOK, QUEEN]:
			return false
		if type in [KNIGHT, BISHOP]:
			minor.append([type, (index % 8 + index / 8) % 2])
	if minor.size() <= 1:
		return true
	for item in minor:
		if item[0] != BISHOP or item[1] != minor[0][1]:
			return false
	return true


func position_key() -> String:
	var effective_ep := -1
	if ep >= 0:
		for dx in [-1, 1]:
			var from: int = ep + turn * 8 + dx
			if from >= 0 and from < 64 and absi(from % 8 - ep % 8) == 1 and board[from] == turn * PAWN:
				var side := turn
				var undo := _push({"from": from, "to": ep, "promotion": 0, "ep": true})
				var legal := not in_check(side)
				_pop(undo)
				if legal:
					effective_ep = ep
	return board.to_byte_array().hex_encode() + "/%d/%d/%d" % [turn, rights, effective_ep]


func _evaluate() -> int:
	var score := 0
	for index in range(64):
		var piece := board[index]
		if piece == 0:
			continue
		var center := int(14 - absf(index % 8 - 3.5) * 2 - absf(index / 8 - 3.5) * 2)
		score += signi(piece) * (int(VALUES[absi(piece)]) + (center * 3 if absi(piece) in [KNIGHT, BISHOP] else center))
	return score * turn


func _ordered(moves: Array[Dictionary]) -> void:
	moves.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return VALUES[absi(board[a["to"]])] * 10 - VALUES[absi(board[a["from"]])] + int(a["promotion"]) * 100 > VALUES[absi(board[b["to"]])] * 10 - VALUES[absi(board[b["from"]])] + int(b["promotion"]) * 100)


func _search(depth: int, alpha_value: int, beta: int) -> int:
	if nodes >= NODE_LIMIT:
		return _evaluate()
	nodes += 1
	if depth == 0:
		if in_check(turn) and legal_moves().is_empty():
			return -30000
		return _evaluate()
	var moves := legal_moves()
	if moves.is_empty():
		return -30000 - depth if in_check(turn) else 0
	_ordered(moves)
	var alpha := alpha_value
	var best := -40000
	for move in moves:
		var undo := _push(move)
		var value := -_search(depth - 1, -beta, -alpha)
		_pop(undo)
		best = maxi(best, value)
		alpha = maxi(alpha, best)
		if alpha >= beta or nodes >= NODE_LIMIT:
			break
	return best


func _start_search() -> void:
	nodes = 0
	cache_hits = 0
	_ai_moves = legal_moves()
	_ordered(_ai_moves)
	_ai_choices.clear()
	_ai_cursor = 0
	_ai_best = -40000


func _search_root_step() -> void:
	var move := _ai_moves[_ai_cursor]
	_ai_cursor += 1
	var undo := _push(move)
	var score := -_search(1, -40000, mini(40000, -_ai_best + 46))
	_pop(undo)
	_ai_best = maxi(_ai_best, score)
	_ai_choices.append({"move": move, "score": score})


func _finish_search() -> Dictionary:
	_ai_choices.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["score"] > b["score"])
	if _ai_choices.is_empty():
		return {}
	var candidates := [_ai_choices[0]]
	for index in range(1, mini(_ai_choices.size(), 4)):
		if _ai_choices[index]["score"] >= _ai_choices[0]["score"] - 45:
			candidates.append(_ai_choices[index])
	return candidates[random.randi_range(0, candidates.size() - 1)]["move"].duplicate(true)


func choose_move() -> Dictionary:
	_start_search()
	while _ai_cursor < _ai_moves.size() and nodes < NODE_LIMIT:
		_search_root_step()
	return _finish_search()


func advance(delta: float) -> void:
	if paused or phase == "FINISHED" or turn != -1 or not is_finite(delta) or delta <= 0:
		return
	ai_wait += minf(delta, 0.1)
	if ai_wait < 0.45:
		return
	if halfmoves >= 100 or int(repetitions.get(position_key(), 0)) >= 3:
		finish(0, "El rival reclama tablas.")
		return
	if _ai_moves.is_empty():
		_start_search()
	if _ai_cursor < _ai_moves.size() and nodes < NODE_LIMIT:
		_search_root_step()
	if _ai_cursor >= _ai_moves.size() or nodes >= NODE_LIMIT:
		var move := _finish_search()
		ai_wait = 0
		if not move.is_empty():
			play(move)


func _data() -> Dictionary:
	return {"board": Array(board), "rights": rights, "ep": ep, "halfmoves": halfmoves, "ply": ply, "repetitions": repetitions.duplicate(), "notation": notation.duplicate()}


func _load_data(data: Dictionary) -> bool:
	if not numbers(data.get("board"), 64, 6) or not data.get("repetitions", {}) is Dictionary or not data.get("notation", []) is Array:
		return false
	var proposed := PackedInt32Array(data["board"])
	if proposed.count(KING) != 1 or proposed.count(-KING) != 1:
		return false
	var candidate_ep := int(data.get("ep", -1))
	if candidate_ep != -1 and (candidate_ep < 0 or candidate_ep >= 64 or candidate_ep / 8 not in [2, 5] or proposed[candidate_ep] != 0):
		return false
	board = proposed
	rights = clampi(int(data.get("rights", 0)), 0, 15)
	ep = clampi(int(data.get("ep", -1)), -1, 63)
	_legal_cache.clear()
	halfmoves = clampi(int(data.get("halfmoves", 0)), 0, 150)
	ply = maxi(0, int(data.get("ply", 0)))
	repetitions = data.get("repetitions", {}).duplicate()
	notation.clear()
	for item in data.get("notation", []).slice(-300):
		notation.append(str(item))
	return true
