extends "res://scripts/recreation_game.gd"
## Local eight-ball variant; original fixed-step physics, no external game assets.

const RULES := "campus-eight-ball-v1"
const STEP := 1.0 / 120.0
const RADIUS := 8.0
const FRICTION := 0.9933555063
const TABLE := Rect2(22, 22, 556, 256)
const POCKETS := [Vector2(18, 18), Vector2(300, 14), Vector2(582, 18), Vector2(18, 282), Vector2(300, 286), Vector2(582, 282)]
var positions: Array[Vector2] = []
var velocities: Array[Vector2] = []
var active: Array[bool] = []
var groups := [0, 0] # 0 open, 1 solids, 2 stripes.
var scores := [0, 0]
var angle := 0.0
var power := 75.0
var spin := Vector2.ZERO
var shots := 0
var accumulator := 0.0
var break_shot := true
var can_place := true
var called_pocket := -1
var first_hit := -1
var _potted: Array[int] = []
var _pockets: Array[int] = []
var _scratch := false
var _rail_after_contact := false
var _break_rails: Array[int] = []
var _on_eight := false
var _spin_used := false
var _shot_direction := Vector2.RIGHT
var _shot_speed := 0.0


func _init(seed_value: int = 1) -> void:
	super(seed_value)
	game_id = "billar"
	positions.resize(16)
	velocities.resize(16)
	velocities.fill(Vector2.ZERO)
	active.resize(16)
	active.fill(true)
	positions[0] = Vector2(140, 150)
	# The eight sits in the centre; opposite back corners have different groups.
	var order := [1, 9, 2, 10, 8, 3, 11, 4, 12, 5, 6, 13, 7, 14, 15]
	var cursor := 0
	for row in range(5):
		for column in range(row + 1):
			positions[order[cursor]] = Vector2(390 + row * 14.05, 150 + (column - row * 0.5) * 16.2)
			cursor += 1
	message = "Abre el triángulo. Apunta, retira el taco y suelta para tirar."


static func ball_group(number: int) -> int:
	return 1 if number >= 1 and number <= 7 else (2 if number >= 9 and number <= 15 else 0)


func side_index() -> int:
	return 0 if turn == 1 else 1


func remaining(group: int) -> int:
	var count := 0
	for number in range(1, 16):
		if active[number] and ball_group(number) == group:
			count += 1
	return count


func on_eight() -> bool:
	return groups[side_index()] != 0 and remaining(groups[side_index()]) == 0


func legal_target(number: int) -> bool:
	if number <= 0 or number >= 16 or not active[number]:
		return false
	if on_eight():
		return number == 8
	return number != 8 and (groups[side_index()] == 0 or ball_group(number) == groups[side_index()])


func valid_placement(point: Vector2) -> bool:
	if not point.is_finite() or not TABLE.has_point(point) or (break_shot and point.x > 150):
		return false
	for pocket in POCKETS:
		if point.distance_squared_to(pocket) < 23 * 23:
			return false
	for number in range(1, 16):
		if active[number] and point.distance_squared_to(positions[number]) < 17 * 17:
			return false
	return true


func _action(action: Dictionary) -> bool:
	var kind := str(action.get("type", ""))
	if kind == "place" and can_place and phase in ["READY", "PLACEMENT"]:
		if not numbers([action.get("x"), action.get("y")], 2, 1000):
			return false
		var point := Vector2(float(action["x"]), float(action["y"]))
		if not valid_placement(point):
			return false
		positions[0] = point
		active[0] = true
		phase = "READY"
		message = "Blanca colocada. Apunta y tira; puedes recolocarla antes del tiro."
		return true
	if phase != "READY":
		return false
	match kind:
		"aim":
			if not numbers([action.get("angle", angle), action.get("power", power)], 2, 100000):
				return false
			angle = wrapf(float(action.get("angle", angle)), -PI, PI)
			power = clampf(float(action.get("power", power)), 5, 100)
			return true
		"spin":
			if not numbers([action.get("x"), action.get("y")], 2, 1):
				return false
			spin = Vector2(float(action["x"]), float(action["y"])).limit_length()
			return true
		"call":
			var value: Variant = action.get("pocket", -1)
			if not (value is int or value is float) or value != int(value) or int(value) < 0 or int(value) >= 6:
				return false
			called_pocket = int(value)
			return true
		"shoot":
			if on_eight() and called_pocket < 0:
				message = "Elige primero una de las seis troneras para la negra."
				return false
			shoot(angle, power)
			return true
	return false


func shoot(direction: float, force: float) -> void:
	_shot_direction = Vector2.from_angle(direction)
	_shot_speed = clampf(force, 5, 100) * 5.8
	velocities[0] = _shot_direction * _shot_speed
	_potted.clear()
	_pockets.clear()
	_break_rails.clear()
	first_hit = -1
	_rail_after_contact = false
	_scratch = false
	_spin_used = false
	_on_eight = on_eight()
	can_place = false
	shots += 1
	accumulator = 0
	phase = "MOVING"
	message = "Tiro en movimiento…"
	revision += 1


func advance(delta: float) -> void:
	if paused or phase == "FINISHED" or not is_finite(delta) or delta <= 0:
		return
	if phase in ["READY", "PLACEMENT"]:
		if turn == -1:
			ai_wait += minf(delta, 0.1)
			if ai_wait >= 0.7:
				ai_wait = 0
				if phase == "PLACEMENT":
					_ai_place()
				var choice := choose_shot()
				spin = Vector2.ZERO
				shoot(choice.x, choice.y)
		return
	accumulator += minf(delta, 0.1)
	while accumulator >= STEP and phase == "MOVING":
		accumulator -= STEP
		_tick()


func _tick() -> void:
	var moving := false
	for number in range(16):
		if not active[number]:
			continue
		positions[number] += velocities[number] * STEP
		for pocket in range(6):
			if positions[number].distance_squared_to(POCKETS[pocket]) < 17 * 17:
				active[number] = false
				velocities[number] = Vector2.ZERO
				if number == 0:
					_scratch = true
				else:
					_potted.append(number)
					_pockets.append(pocket)
				break
		if not active[number]:
			continue
		var cushion := false
		if positions[number].x < 22 or positions[number].x > 578:
			positions[number].x = clampf(positions[number].x, 22, 578)
			velocities[number].x *= -0.88
			cushion = true
		if positions[number].y < 22 or positions[number].y > 278:
			positions[number].y = clampf(positions[number].y, 22, 278)
			velocities[number].y *= -0.88
			cushion = true
		if cushion:
			if first_hit >= 0:
				_rail_after_contact = true
			if number > 0 and not _break_rails.has(number):
				_break_rails.append(number)
			if number == 0:
				velocities[0] += velocities[0].orthogonal() * spin.x * 0.08
		velocities[number] *= FRICTION
		if velocities[number].length_squared() < 4:
			velocities[number] = Vector2.ZERO
		moving = moving or velocities[number] != Vector2.ZERO
	for a in range(16):
		if not active[a]:
			continue
		for b in range(a + 1, 16):
			if not active[b] or (velocities[a] == Vector2.ZERO and velocities[b] == Vector2.ZERO):
				continue
			var offset := positions[b] - positions[a]
			var distance_squared := offset.length_squared()
			if distance_squared >= 4 * RADIUS * RADIUS:
				continue
			var distance := sqrt(distance_squared)
			var normal := offset / distance if distance > 0.001 else Vector2.RIGHT
			var separation := (RADIUS * 2 - distance + 0.01) * 0.5
			positions[a] -= normal * separation
			positions[b] += normal * separation
			var closing := (velocities[a] - velocities[b]).dot(normal)
			if closing > 0:
				velocities[a] -= normal * closing * 0.97
				velocities[b] += normal * closing * 0.97
				if a == 0 and first_hit < 0:
					first_hit = b
				if a == 0 and not _spin_used:
					velocities[0] += _shot_direction * spin.y * _shot_speed * 0.18 + _shot_direction.orthogonal() * spin.x * _shot_speed * 0.1
					_spin_used = true
				moving = true
	if not moving:
		_end_shot()


func _place_cue() -> void:
	for x in range(70, 550, 20):
		for y in range(50, 270, 20):
			var point := Vector2(x, y)
			if valid_placement(point):
				positions[0] = point
				active[0] = true
				velocities[0] = Vector2.ZERO
				return


func _respot_eight() -> void:
	for x in range(390, 550, 18):
		var point := Vector2(x, 150)
		var free := true
		for number in range(16):
			if number != 8 and active[number] and point.distance_squared_to(positions[number]) < 17 * 17:
				free = false
		if free:
			positions[8] = point
			active[8] = true
			velocities[8] = Vector2.ZERO
			return
	# This row cannot be filled by fifteen non-overlapping balls.
	for x in range(40, 560, 18):
		for y in range(40, 260, 18):
			var point := Vector2(x, y)
			var free := true
			for number in range(16):
				if number != 8 and active[number] and point.distance_squared_to(positions[number]) < 17 * 17:
					free = false
			if free:
				positions[8] = point
				active[8] = true
				return


func _end_shot() -> void:
	var side := side_index()
	var group := int(groups[side])
	var valid_first := first_hit > 0 and (first_hit == 8 if _on_eight else first_hit != 8 and (group == 0 or ball_group(first_hit) == group))
	var foul := _scratch or not valid_first or (_potted.is_empty() and not _rail_after_contact)
	if break_shot and _potted.is_empty() and _break_rails.size() < 4:
		foul = true
	if _potted.has(8) and not break_shot:
		var pocket := _pockets[_potted.find(8)]
		var won := _on_eight and not foul and pocket == called_pocket
		finish(turn if won else -turn, "Negra legal en la tronera elegida. " + ("Ganaste." if turn == 1 else "Gana el rival.") if won else "Negra prematura, falta o tronera equivocada. " + ("Gana el rival." if turn == 1 else "Ganaste."))
		return
	if break_shot and _potted.has(8):
		_respot_eight()
	if not break_shot and group == 0 and not foul:
		for number in _potted:
			if number != 8:
				groups[side] = ball_group(number)
				groups[1 - side] = 3 - int(groups[side])
				group = int(groups[side])
				break
	var keep := false
	for number in _potted:
		if number != 8 and (break_shot or ball_group(number) == group):
			keep = true
	break_shot = false
	called_pocket = -1
	spin = Vector2.ZERO
	for index in range(2):
		scores[index] = 7 - remaining(groups[index]) if groups[index] != 0 else 0
	if foul or not keep:
		turn *= -1
	can_place = foul
	phase = "PLACEMENT" if foul else "READY"
	if foul:
		_place_cue()
	message = "Falta: blanca en mano para " + ("ti." if turn == 1 else "el rival.") if foul else ("Sigues tirando." if keep else "Cambio de turno.")
	message += " Mesa abierta: lisas/rayadas se asignan tras una embocada legal." if groups[0] == 0 else " Tú: " + ("lisas." if groups[0] == 1 else "rayadas.")
	revision += 1


func _clear_segment(start: Vector2, finish: Vector2, excluded: int) -> bool:
	for number in range(1, 16):
		if number != excluded and active[number] and positions[number].distance_squared_to(Geometry2D.get_closest_point_to_segment(positions[number], start, finish)) < 16.5 * 16.5:
			return false
	return true


func _ai_place() -> void:
	# Small bounded placement grid, then the same physical shot evaluation.
	var best := INF
	var target := positions[0]
	for x in range(80, 560, 60):
		for y in range(50, 280, 55):
			var point := Vector2(x, y)
			if not valid_placement(point):
				continue
			for number in range(1, 16):
				if legal_target(number) and _clear_segment(point, positions[number], number):
					var cost := point.distance_squared_to(positions[number])
					if cost < best:
						best = cost
						target = point
	positions[0] = target
	active[0] = true
	phase = "READY"


func choose_shot() -> Vector2:
	if break_shot:
		return Vector2((positions[1] - positions[0]).angle(), 100)
	var best := INF
	var direction := 0.0
	var force := 60.0
	for number in range(1, 16):
		if not legal_target(number):
			continue
		for pocket in range(6):
			var path: Vector2 = (POCKETS[pocket] - positions[number]).normalized()
			var ghost := positions[number] - path * RADIUS * 2
			var to_ghost := ghost - positions[0]
			var alignment := to_ghost.normalized().dot(path)
			if alignment < 0.18 or not TABLE.has_point(ghost) or not _clear_segment(positions[0], ghost, number) or not _clear_segment(positions[number], POCKETS[pocket], number):
				continue
			var distance := to_ghost.length() + positions[number].distance_to(POCKETS[pocket])
			var cost := distance + (1 - alignment) * 350
			if cost < best:
				best = cost
				direction = to_ghost.angle()
				force = clampf((0.8 * (to_ghost.length() + positions[number].distance_to(POCKETS[pocket]) / maxf(alignment, 0.3)) + 35) / 5.8, 30, 100)
				called_pocket = pocket
	if best == INF:
		var closest := INF
		for number in range(1, 16):
			if legal_target(number) and positions[number].distance_squared_to(positions[0]) < closest:
				closest = positions[number].distance_squared_to(positions[0])
				direction = (positions[number] - positions[0]).angle()
		called_pocket = 0
	return Vector2(direction + random.randf_range(-0.025, 0.025), force)


func _data() -> Dictionary:
	var points := []
	var speeds := []
	for number in range(16):
		points.append([positions[number].x, positions[number].y])
		speeds.append([velocities[number].x, velocities[number].y])
	return {"rules": RULES, "positions": points, "velocities": speeds, "active": active.duplicate(), "groups": groups.duplicate(), "scores": scores.duplicate(), "angle": angle, "power": power, "spin": [spin.x, spin.y], "shots": shots, "break": break_shot, "can_place": can_place, "called": called_pocket, "first_hit": first_hit, "potted": _potted.duplicate(), "pockets": _pockets.duplicate(), "scratch": _scratch, "rail": _rail_after_contact, "break_rails": _break_rails.duplicate(), "on_eight": _on_eight, "spin_used": _spin_used, "shot_direction": [_shot_direction.x, _shot_direction.y], "shot_speed": _shot_speed, "accumulator": accumulator}


func allowed_phases() -> Array:
	return ["READY", "PLACEMENT", "MOVING", "FINISHED"]


func _load_data(data: Dictionary) -> bool:
	if data.get("rules", "") != RULES:
		return false
	for key in ["positions", "velocities", "active"]:
		if not data.get(key) is Array or data[key].size() != 16:
			return false
	for number in range(16):
		if not numbers(data["positions"][number], 2, 1000) or not numbers(data["velocities"][number], 2, 800) or not data["active"][number] is bool:
			return false
	if not numbers(data.get("groups"), 2, 2) or not numbers(data.get("scores"), 2, 7):
		return false
	for key in ["groups", "scores"]:
		for value in data[key]:
			if value < 0 or value != int(value):
				return false
	if [int(data["groups"][0]), int(data["groups"][1])] not in [[0, 0], [1, 2], [2, 1]]:
		return false
	if not numbers([data.get("angle"), data.get("power"), data.get("shot_speed"), data.get("accumulator")], 4, 1000) or not numbers(data.get("spin"), 2, 1) or not numbers(data.get("shot_direction"), 2, 1):
		return false
	for item in [["called", -1, 5], ["first_hit", -1, 15], ["shots", 0, 100000]]:
		var value: Variant = data.get(item[0])
		if not (value is int or value is float) or not is_finite(float(value)) or value != int(value) or int(value) < item[1] or int(value) > item[2]:
			return false
	for key in ["break", "can_place", "scratch", "rail", "on_eight", "spin_used"]:
		if not data.get(key) is bool:
			return false
	for key in ["potted", "pockets", "break_rails"]:
		if not data.get(key) is Array or data[key].size() > 15:
			return false
		var seen := {}
		for value in data[key]:
			if not (value is int or value is float) or not is_finite(float(value)) or value != int(value) or value < (0 if key == "pockets" else 1) or value > (5 if key == "pockets" else 15) or (key != "pockets" and seen.has(int(value))):
				return false
			seen[int(value)] = true
	if data["potted"].size() != data["pockets"].size():
		return false
	for number in data["potted"]:
		if data["active"][int(number)] and not (number == 8 and data["break"] == false):
			return false
	for number in range(16):
		positions[number] = Vector2(data["positions"][number][0], data["positions"][number][1])
		velocities[number] = Vector2(data["velocities"][number][0], data["velocities"][number][1])
		active[number] = data["active"][number]
	groups = [int(data["groups"][0]), int(data["groups"][1])]
	scores = [int(data["scores"][0]), int(data["scores"][1])]
	angle = wrapf(float(data["angle"]), -PI, PI)
	power = clampf(float(data["power"]), 5, 100)
	spin = Vector2(data["spin"][0], data["spin"][1]).limit_length()
	shots = int(data["shots"])
	break_shot = data["break"]
	can_place = data["can_place"]
	called_pocket = int(data["called"])
	first_hit = int(data["first_hit"])
	_potted.assign(data["potted"])
	_pockets.assign(data["pockets"])
	_break_rails.assign(data["break_rails"])
	_scratch = data["scratch"]
	_rail_after_contact = data["rail"]
	_on_eight = data["on_eight"]
	_spin_used = data["spin_used"]
	_shot_direction = Vector2(data["shot_direction"][0], data["shot_direction"][1])
	_shot_speed = clampf(float(data["shot_speed"]), 0, 580)
	accumulator = clampf(float(data["accumulator"]), 0, STEP)
	return true
