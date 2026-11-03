extends "res://scripts/recreation_game.gd"

const STEP := 1.0 / 120.0
var ball := Vector2(300, 150)
var velocity := Vector2.ZERO
var paddles := [150.0, 150.0]
var scores := [0, 0]
var target := 150.0
var ai_target := 150.0
var reaction := 0.0
var accumulator := 0.0
var rallies := 0
var aim_error := 0.0
var boost_left := 0.0
var boost_cooldown := 0.0
var paddle_speed := 0.0


func _init(seed_value: int = 1) -> void:
	super(seed_value)
	game_id = "ping_pong"
	phase = "SERVE"
	message = "Saca con Espacio o Sacar. Mueve tu paleta con W/S, flechas o el ratón."


func _action(action: Dictionary) -> bool:
	if action.get("type") == "boost" and phase == "PLAY" and boost_cooldown <= 0:
		boost_left = 0.28
		boost_cooldown = 3.0
		return true
	if action.get("type") == "serve" and phase == "SERVE":
		serve()
		return true
	return false


func _human_turn(action: Dictionary) -> bool:
	return turn == 1 or (action.get("type") == "boost" and phase == "PLAY")


func serve() -> void:
	ball = Vector2(300, 150)
	velocity = Vector2(-1 if turn == -1 else 1, random.randf_range(-0.5, 0.5)).normalized() * 240
	phase = "PLAY"
	rallies = 0
	aim_error = random.randf_range(-44, 44)
	message = "Juega: tu paleta está a la izquierda."
	revision += 1


func set_target(value: float) -> void:
	if is_finite(value):
		target = clampf(value, 34, 266)


func advance(delta: float) -> void:
	if paused or phase == "FINISHED" or not is_finite(delta) or delta <= 0:
		return
	accumulator += minf(delta, 0.1)
	while accumulator >= STEP:
		accumulator -= STEP
		_tick(STEP)


func _tick(dt: float) -> void:
	boost_left = maxf(0, boost_left - dt)
	boost_cooldown = maxf(0, boost_cooldown - dt)
	var previous_paddle := float(paddles[0])
	paddles[0] = move_toward(previous_paddle, target, (390 if boost_left > 0 else 250) * dt)
	paddle_speed = (float(paddles[0]) - previous_paddle) / dt
	reaction -= dt
	if reaction <= 0:
		reaction = 0.18
		var predicted := ball.y
		if velocity.x > 0:
			var future := ball.y + velocity.y * (558 - ball.x) / velocity.x
			predicted = 5 + absf(fposmod(future - 5 + 290, 580) - 290)
		ai_target = clampf(predicted + aim_error, 34, 266)
	paddles[1] = move_toward(float(paddles[1]), ai_target, 174 * dt)
	if phase == "SERVE":
		if turn == -1:
			ai_wait += dt
			if ai_wait >= 0.7:
				ai_wait = 0
				serve()
		return
	var previous := ball
	ball += velocity * dt
	if ball.y < 5 or ball.y > 295:
		ball.y = clampf(ball.y, 5, 295)
		velocity.y *= -1
	for index in range(2):
		var x := 42.0 if index == 0 else 558.0
		var toward := velocity.x < 0 if index == 0 else velocity.x > 0
		var crosses := ball.x <= x and previous.x >= x if index == 0 else ball.x >= x and previous.x <= x
		if toward and crosses and absf(ball.y - float(paddles[index])) <= 39:
			var offset := clampf((ball.y - float(paddles[index])) / 34, -1, 1)
			rallies += 1
			if index == 0:
				aim_error = random.randf_range(-44, 44)
			var motion := clampf(paddle_speed / 390, -1, 1) * 0.3 if index == 0 else 0.0
			velocity = Vector2(1 if index == 0 else -1, clampf(offset * 1.15 + motion, -1.4, 1.4)).normalized() * minf(400, 240 + rallies * 12)
			ball.x = x
	if ball.x < -8 or ball.x > 608:
		point(0 if ball.x > 608 else 1)


func point(index: int) -> void:
	scores[index] += 1
	velocity = Vector2.ZERO
	ball = Vector2(300, 150)
	if (scores[index] >= 7 and absi(int(scores[0]) - int(scores[1])) >= 2) or scores[index] >= 11:
		finish(1 if index == 0 else -1, "Ganaste el partido." if index == 0 else "El rival ganó el partido. Puedes pedir revancha.")
	else:
		turn = 1 if (int(scores[0]) + int(scores[1])) / 2 % 2 == 0 else -1
		phase = "SERVE"
		message = "Punto. %d – %d. %s" % [scores[0], scores[1], "Te toca sacar." if turn == 1 else "Saca el rival."]
		revision += 1


func _data() -> Dictionary:
	return {"ball": [ball.x, ball.y], "velocity": [velocity.x, velocity.y], "paddles": paddles.duplicate(), "scores": scores.duplicate(), "rallies": rallies, "target": target, "aim_error": aim_error, "ai_target": ai_target, "reaction": reaction, "ai_wait": ai_wait, "boost_left": boost_left, "boost_cooldown": boost_cooldown, "paddle_speed": paddle_speed}


func allowed_phases() -> Array:
	return ["SERVE", "PLAY", "FINISHED"]


func _load_data(data: Dictionary) -> bool:
	if not numbers(data.get("ball"), 2, 1000) or not numbers(data.get("velocity"), 2, 500) or not numbers(data.get("paddles"), 2, 300) or not numbers(data.get("scores"), 2, 11):
		return false
	ball = Vector2(data["ball"][0], data["ball"][1])
	velocity = Vector2(data["velocity"][0], data["velocity"][1])
	paddles = data["paddles"].duplicate()
	scores = [int(data["scores"][0]), int(data["scores"][1])]
	rallies = clampi(int(data.get("rallies", 0)), 0, 1000)
	if not numbers([data.get("aim_error", 0), data.get("ai_target", 150), data.get("reaction", 0), data.get("ai_wait", 0)], 4, 300):
		return false
	aim_error = clampf(float(data.get("aim_error", 0)), -44, 44)
	ai_target = clampf(float(data.get("ai_target", 150)), 34, 266)
	reaction = clampf(float(data.get("reaction", 0)), 0, 0.18)
	ai_wait = clampf(float(data.get("ai_wait", 0)), 0, 0.7)
	if not numbers([data.get("boost_left", 0), data.get("boost_cooldown", 0), data.get("paddle_speed", 0), data.get("target", paddles[0])], 4, 400):
		return false
	target = clampf(float(data.get("target", paddles[0])), 34, 266)
	boost_left = clampf(float(data.get("boost_left", 0)), 0, 0.28)
	boost_cooldown = clampf(float(data.get("boost_cooldown", 0)), 0, 3)
	paddle_speed = clampf(float(data.get("paddle_speed", 0)), -390, 390)
	return scores[0] >= 0 and scores[1] >= 0
