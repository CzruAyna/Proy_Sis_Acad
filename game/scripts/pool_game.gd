extends "res://scripts/recreation_game.gd"

const STEP := 1.0 / 120.0
const RADIUS := 8.0
const POCKETS := [Vector2(18, 18), Vector2(300, 14), Vector2(582, 18), Vector2(18, 282), Vector2(300, 286), Vector2(582, 282)]
var positions: Array[Vector2] = [Vector2(140, 150), Vector2(410, 150), Vector2(428, 140), Vector2(428, 160), Vector2(446, 130), Vector2(446, 150), Vector2(446, 170)]
var velocities: Array[Vector2] = []
var active: Array[bool] = [true, true, true, true, true, true, true]
var scores := [0, 0]
var angle := 0.0
var power := 60.0
var shots := 0
var accumulator := 0.0
var _potted: Array[int] = []
var _hit := false
var _scratch := false


func _init(seed_value: int = 1) -> void:
	super(seed_value)
	game_id = "billar"
	velocities.resize(7)
	velocities.fill(Vector2.ZERO)
	message = "Duelo de seis bolas: apunta, ajusta fuerza y tira."


func _action(action: Dictionary) -> bool:
	if phase != "READY":
		return false
	if action.get("type") == "aim":
		var value: Variant = action.get("angle", angle)
		var force: Variant = action.get("power", power)
		if not (value is int or value is float) or not (force is int or force is float) or not is_finite(float(value)) or not is_finite(float(force)):
			return false
		angle = wrapf(float(value), -PI, PI)
		power = clampf(float(force), 20, 100)
		return true
	if action.get("type") == "shoot":
		shoot(angle, power)
		return true
	return false


func shoot(direction: float, force: float) -> void:
	velocities[0] = Vector2.from_angle(direction) * clampf(force, 20, 100) * 5
	_potted.clear()
	_hit = false
	_scratch = false
	shots += 1
	phase = "MOVING"
	message = "Bolas en movimiento…"
	revision += 1


func advance(delta: float) -> void:
	if paused or phase == "FINISHED" or not is_finite(delta) or delta <= 0:
		return
	if phase == "READY":
		if turn == -1:
			ai_wait += minf(delta, 0.1)
			if ai_wait > 0.65:
				ai_wait = 0
				var choice := choose_shot()
				shoot(choice.x, choice.y)
		return
	accumulator += minf(delta, 0.1)
	while accumulator >= STEP and phase == "MOVING":
		accumulator -= STEP
		_tick()


func _tick() -> void:
	var moving := false
	for index in range(7):
		if not active[index]:
			continue
		positions[index] += velocities[index] * STEP
		for pocket in POCKETS:
			if positions[index].distance_squared_to(pocket) < 18 * 18:
				active[index] = false
				velocities[index] = Vector2.ZERO
				if index == 0:
					_scratch = true
				else:
					_potted.append(index)
				break
		if not active[index]:
			continue
		if positions[index].x < 22 or positions[index].x > 578:
			positions[index].x = clampf(positions[index].x, 22, 578)
			velocities[index].x *= -0.88
		if positions[index].y < 22 or positions[index].y > 278:
			positions[index].y = clampf(positions[index].y, 22, 278)
			velocities[index].y *= -0.88
		velocities[index] *= exp(-0.8 * STEP)
		if velocities[index].length_squared() < 4:
			velocities[index] = Vector2.ZERO
		moving = moving or velocities[index] != Vector2.ZERO
	for a in range(7):
		for b in range(a + 1, 7):
			if not active[a] or not active[b]:
				continue
			var offset := positions[b] - positions[a]
			if offset.length_squared() >= 4 * RADIUS * RADIUS:
				continue
			var normal := offset.normalized() if offset.length_squared() > 0.001 else Vector2.RIGHT
			var separation := (RADIUS * 2 - offset.length() + 0.01) * 0.5
			positions[a] -= normal * separation
			positions[b] += normal * separation
			var closing := (velocities[a] - velocities[b]).dot(normal)
			if closing > 0:
				velocities[a] -= normal * closing * 0.97
				velocities[b] += normal * closing * 0.97
				if a == 0:
					_hit = true
				moving = true
	if not moving:
		_end_shot()


func _place_cue() -> void:
	for x in range(100, 540, 24):
		for y in range(150, 270, 24):
			var point := Vector2(x, y)
			var clear := true
			for index in range(1, 7):
				clear = clear and (not active[index] or point.distance_squared_to(positions[index]) > 20 * 20)
			if clear:
				positions[0] = point
				active[0] = true
				return


func _end_shot() -> void:
	var index := 0 if turn == 1 else 1
	var foul := _scratch or not _hit
	scores[1 - index if foul else index] += _potted.size()
	if _scratch:
		_place_cue()
	message = ("Falta: blanca embocada o sin contacto; las bolas embocadas cuentan para el rival." if foul else "Tiro resuelto: %d bola(s)." % _potted.size())
	if _potted.is_empty() or foul:
		turn *= -1
	phase = "READY"
	if shots >= 40 or active.count(true) == 1:
		var result := signi(int(scores[0]) - int(scores[1]))
		finish(result, "Fin: tú %d · rival %d. %s" % [scores[0], scores[1], "Empate." if result == 0 else ("Ganaste." if result == 1 else "Gana el rival.")])
	else:
		message += " Tu turno." if turn == 1 else " Tira el rival."
	revision += 1


func _clear_segment(start: Vector2, finish: Vector2, excluded: int) -> bool:
	for index in range(1, 7):
		if index != excluded and active[index] and positions[index].distance_squared_to(Geometry2D.get_closest_point_to_segment(positions[index], start, finish)) < 17 * 17:
			return false
	return true


func choose_shot() -> Vector2:
	var best := INF
	var direction := 0.0
	var force := 60.0
	for index in range(1, 7):
		if not active[index]:
			continue
		for pocket in POCKETS:
			var path: Vector2 = (pocket - positions[index]).normalized()
			var ghost := positions[index] - path * RADIUS * 2
			var to_ghost := ghost - positions[0]
			var alignment := to_ghost.normalized().dot(path)
			if alignment < 0.15 or not Rect2(22, 22, 556, 256).has_point(ghost):
				continue
			if not _clear_segment(positions[0], ghost, index) or not _clear_segment(positions[index], pocket, index):
				continue
			var distance := to_ghost.length() + positions[index].distance_to(pocket)
			var cost := distance + (1 - alignment) * 350
			if cost < best:
				best = cost
				direction = to_ghost.angle()
				force = clampf((0.8 * (to_ghost.length() + positions[index].distance_to(pocket) / maxf(alignment, 0.3)) + 35) / 5, 35, 100)
	if best == INF:
		for index in range(1, 7):
			if active[index]:
				direction = (positions[index] - positions[0]).angle()
				break
	return Vector2(direction + random.randf_range(-0.045, 0.045), force)


func _data() -> Dictionary:
	var points := []
	var speeds := []
	for index in range(7):
		points.append([positions[index].x, positions[index].y])
		speeds.append([velocities[index].x, velocities[index].y])
	return {"positions": points, "velocities": speeds, "active": active.duplicate(), "scores": scores.duplicate(), "angle": angle, "power": power, "shots": shots, "potted": _potted.duplicate(), "hit": _hit, "scratch": _scratch}


func allowed_phases() -> Array:
	return ["READY", "MOVING", "FINISHED"]


func _load_data(data: Dictionary) -> bool:
	for key in ["positions", "velocities", "active"]:
		if not data.get(key) is Array or data[key].size() != 7:
			return false
	for index in range(7):
		if not numbers(data["positions"][index], 2, 1000) or not numbers(data["velocities"][index], 2, 600) or not data["active"][index] is bool:
			return false
	if not numbers(data.get("scores"), 2, 6) or not numbers([data.get("angle"), data.get("power")], 2, 100):
		return false
	var potted: Variant = data.get("potted", [])
	if not potted is Array or potted.size() > 6:
		return false
	for index in potted:
		if not (index is int or index is float) or int(index) < 1 or int(index) > 6:
			return false
	for index in range(7):
		positions[index] = Vector2(data["positions"][index][0], data["positions"][index][1])
		velocities[index] = Vector2(data["velocities"][index][0], data["velocities"][index][1])
		active[index] = data["active"][index]
	scores = [int(data["scores"][0]), int(data["scores"][1])]
	angle = float(data["angle"])
	power = clampf(float(data["power"]), 20, 100)
	shots = clampi(int(data.get("shots", 0)), 0, 40)
	_potted.assign(potted.map(func(value: Variant) -> int: return int(value)))
	_hit = bool(data.get("hit", false))
	_scratch = bool(data.get("scratch", false))
	return true
