extends "res://tests/test_compact_navigation.gd"

const Presentation = preload("res://scripts/career_presentation.gd")
const Icon = preload("res://scripts/pixel_app_icon.gd")


func _run() -> void:
	var model := Presentation.new()
	_check(not model.execute("tree; exit") and model.phase == "IDLE", "La terminal acepta sólo su comando virtual")
	_check(model.execute(Presentation.COMMAND), "El comando inicia el recorrido")
	var ids := {}
	var mentions := {}
	var subjects := {}
	for cue in model.chapters:
		_check(not ids.has(cue["id"]), "ID estable y único: " + str(cue["id"]))
		ids[cue["id"]] = true
		_check(str(cue["text"]).length() <= 190, "Explicaciones acotadas sin historial creciente")
		_check(Presentation.SCENES.values().has(cue["scene"]) or cue["scene"] in ["overview", "curriculum", "procedure", "graduation"], "Señal visual conocida")
		if not str(cue["mention_id"]).is_empty():
			mentions[cue["mention_id"]] = true
		if cue.has("subject"):
			subjects[str(cue["mention_id"]) + "/" + str(cue["subject"])] = true
	_check(mentions.size() == 5, "Incluye las cinco menciones")
	for program in Presentation.Catalog.PROGRAMS:
		for mention in Presentation.Catalog.mentions_for_program(program["id"]):
			for subject in Presentation.Catalog.all_subjects(program["id"], mention["id"]):
				_check(subjects.has(str(mention["id"]) + "/" + str(subject["sigla"])), "Recorre cada materia de cada mención")
	model.advance(0.25)
	_check(model.visible_command() > 0 and model.visible_text() == 0, "Escribe comando antes de explicación")
	model.set_paused(true)
	var actor_id := str(model.pause_actor["id"])
	var sequence := model.pause_sequence
	model.set_paused(true)
	_check(model.pause_sequence == sequence and model.pause_actor["id"] == actor_id, "Notificaciones repetidas conservan el personaje de esa pausa")
	var pause_payload := model.pause_cue()
	pause_payload["actor"]["id"] = "no modificar"
	_check(model.pause_actor["id"] != "no modificar", "Contrato de pausa devuelve una copia aislada")
	_check(pause_payload["facing"] == "viewer" and pause_payload["action"] == "idle_wait", "Pausa pide personaje mirando al espectador y esperando")
	var time := model.elapsed
	model.advance(0.25)
	_check(model.elapsed == time, "Pausa detiene escritura y avance")
	model.set_paused(false)
	model.set_paused(true)
	_check(model.pause_actor["id"] != actor_id, "Nueva pausa elige otro arquetipo sin repetir el anterior")
	model.set_paused(false)
	while model.cycle < 2:
		model.advance(0.25)
	_check(model.index == 0, "Resumen repite carreras, menciones y procesos automáticamente")
	model.toggle_detail()
	model.execute(Presentation.COMMAND)
	var total := model.chapters.size()
	var steps := 0
	while model.cycle < 3 and steps < 200000:
		model.advance(0.25)
		steps += 1
	_check(model.cycle == 3 and model.index == 0 and model.chapters.size() == total, "Dos vueltas automáticas sin ampliar memoria")
	model.previous()
	_check(model.index == total - 1, "Anterior desde inicio va al cierre")
	var detached := model.current()
	detached["text"] = "alteración externa"
	_check(model.current()["text"] != detached["text"], "El contrato visual no modifica el guion")
	model.toggle_detail()
	_check(model.overview.has(model.index), "Volver a resumen usa un capítulo válido")
	var icon := Icon.image_at(32)
	_check(icon.get_pixel(0, 0).a == 0 and icon.get_pixel(10, 10).a == 1, "Icono pixel transparente con emblema visible")
	viewport = SubViewport.new()
	root.add_child(viewport)
	game = TestGame.new()
	viewport.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game.active_slot = 1
	game.draft_player_name = "Prueba compacta"
	game._create_solo_save("sistemas", "gestion_sistemas")
	var academic := JSON.stringify(game.current_profile)
	for dimensions in [Vector2i(900, 640), Vector2i(1152, 720)]:
		viewport.size = dimensions
		game.settings["font_scale"] = 1.2
		game._show_main()
		await _inspect("inicio")
		_check(game.find_child("CareerPresentationEntry", true, false) != null, "Acceso directo desde inicio")
		game._show_career_presentation()
		var view = game.find_child("CareerPresentation", true, false)
		view.model.paused = true
		for mid in Presentation.SCENES:
			for i in range(view.model.chapters.size()):
				if view.model.chapters[i]["mention_id"] == mid:
					view.model.index = i
					view.model._select()
					break
			view.model.elapsed = 100
			view._sync()
			await _inspect("demo " + str(mid))
			var pager = game.find_child("PageNavigator", true, false)
			_check(pager.page_offsets.size() == 1, "Terminal y controles juntos a 120%")
		view.toggle_speed()
		_check(view.model.speed == 2, "Velocidad por botón")
		view.model.set_paused(false)
		var pause_events: Array = []
		view.pause_scene_requested.connect(func(cue: Dictionary) -> void: pause_events.append(cue))
		view.toggle_pause()
		var frozen: float = view.model.elapsed
		view._process(0.1)
		_check(pause_events.size() == 1 and pause_events[0]["paused"] and pause_events[0]["actor"].has("id"), "Vista envía contrato del personaje a frontend al pausar")
		_check(view.model.elapsed == frozen, "Personaje en espera no avanza demostración")
		view.toggle_pause()
		_check(pause_events.size() == 2 and not pause_events[1]["paused"], "Continuar pide retirar personaje y ruptura")
		view.restart()
		_check(view.model.index == 0 and view.model.cycle == 1 and not view.model.paused, "Reinicio controlado")
		_check(JSON.stringify(game.current_profile) == academic, "Demo no modifica perfil, notas o logros")
	game.queue_free()
	viewport.queue_free()
	await process_frame
	for failure in failures:
		push_error(failure)
	print("CAREER_PRESENTATION: %d chapters, %d assertions, %d failures" % [total, assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)
