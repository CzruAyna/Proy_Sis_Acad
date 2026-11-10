extends RefCounted

const Story = preload("res://scripts/career_story.gd")
const Catalog = preload("res://scripts/catalog.gd")
const Graph = preload("res://scripts/curriculum_graph.gd")
const SubjectPopup = preload("res://scripts/graph_subject_popup.gd")
const Demo = preload("res://scripts/study_demo.gd")
const DOCUMENT_NAMES := {"ci": "identidad", "matricula": "matrícula vigente", "historial": "historial académico", "formulario": "formulario de solicitud", "conclusion": "conclusión de estudios", "solvencia": "solvencia", "perfil": "perfil y tutor", "borrador": "borrador del trabajo", "plan_aux": "plan de trabajo", "plan_firmado": "plan firmado", "permiso_aula": "permiso de aula", "informe_aux": "informe de actividades"}

var host: WeakRef
var player_name := ""
var program_id := "sistemas"
var mention_id := "gestion_sistemas"
var approach := "constancia"
var report: Dictionary = {}
var chapter := 0
var graph_semester := 0
var graph_layouts: Dictionary = {}


func _init(controller: Control) -> void:
	host = weakref(controller)


func _ui() -> Control:
	return host.get_ref()


func _text(parent: Control, value: String, size: int = 16) -> Label:
	var label: Label = _ui()._label(value, size, _ui()._current_theme.get("text", Color.WHITE))
	parent.add_child(label)
	return label


func _actions(parent: Control) -> HFlowContainer:
	var row := HFlowContainer.new()
	row.add_theme_constant_override("h_separation", 8)
	row.add_theme_constant_override("v_separation", 8)
	parent.add_child(row)
	return row


func show_setup(message: String = "") -> void:
	_ui()._apply_career_theme(program_id, mention_id)
	var page: VBoxContainer = _ui()._make_page("Una posible historia", "Demostración independiente · nombre, decisiones de estudio y sucesos aleatorios", _ui()._show_simulate)
	_text(page, "Crea una historia ficticia por toda la carrera. El nombre personaliza el relato; no determina capacidad ni predice tu futuro. Cada nueva historia puede cambiar.", 16)
	var card: VBoxContainer = _ui()._card(page)
	_text(card, "¿Quién protagoniza la historia?", 19)
	var field := LineEdit.new()
	field.name = "StoryPlayerName"
	field.placeholder_text = "Nombre o apodo obligatorio"
	field.max_length = 60
	_ui()._style_input(field)
	field.text = player_name
	field.custom_minimum_size = Vector2(0, 42)
	card.add_child(field)
	field.text_changed.connect(func(value: String) -> void: player_name = value)
	if not message.is_empty():
		_text(card, message, 15).name = "StoryValidation"
	var choices := _actions(card)
	for program in Catalog.PROGRAMS:
		var id := str(program["id"])
		_ui()._add_button(choices, str(program["name"]), _select_program.bind(id), id == program_id, 40)
	var mentions := _actions(card)
	for mention in Catalog.mentions_for_program(program_id):
		var id := str(mention["id"])
		_ui()._add_button(mentions, str(mention["name"]), _select_mention.bind(id), id == mention_id, 40)
	var styles: GridContainer = _ui()._adaptive_grid(page, 240, 3)
	for id in Story.APPROACHES:
		var choice: Dictionary = Story.APPROACHES[id]
		var style: VBoxContainer = _ui()._card(styles)
		_text(style, str(choice["name"]), 19)
		_text(style, str(choice["description"]), 14)
		_ui()._add_button(style, "Elegido" if id == approach else "Elegir enfoque", _select_approach.bind(str(id)), id == approach, 38)
	var row := _actions(page)
	var generate: Button = _ui()._add_button(row, "Crear historia", create_story, true, 44)
	generate.name = "GenerateCareerStory"
	generate.disabled = player_name.strip_edges().is_empty()
	field.text_changed.connect(func(value: String) -> void: generate.disabled = value.strip_edges().is_empty())
	field.text_submitted.connect(func(_value: String) -> void: create_story())
	if not report.is_empty():
		_ui()._add_button(row, "Volver a la historia", show_chapter, false, 44)
	_text(page, "La demostración usa las reglas del juego y temarios orientativos del catálogo. No consume espacios de guardado ni concede logros. Los trámites y pagos son simulados; la normativa y los programas requieren verificación institucional.", 13)


func _select_program(id: String) -> void:
	program_id = id
	mention_id = str(Catalog.mentions_for_program(id)[0]["id"])
	show_setup()


func _select_mention(id: String) -> void:
	mention_id = id
	show_setup()


func _select_approach(id: String) -> void:
	approach = id
	show_setup()


func create_story(seed_value: int = -1) -> void:
	var runner := Story.new()
	var generated: Dictionary = runner.generate(player_name, program_id, mention_id, approach, seed_value)
	if not generated["ok"]:
		show_setup(str(generated["message"]))
		return
	report = generated
	chapter = 0
	graph_semester = 0
	graph_layouts.clear()
	show_chapter()


func _page(title: String, subtitle: String, back: Callable = Callable()) -> VBoxContainer:
	_ui()._apply_career_theme(str(report["program_id"]), str(report["mention_id"]))
	var page: VBoxContainer = _ui()._make_page(title, subtitle, back if back.is_valid() else show_setup)
	_text(page, "%s · %s · %s" % [report["player_name"], Catalog.program_by_id(str(report["program_id"]))["name"], Catalog.mention_by_id(str(report["program_id"]), str(report["mention_id"]))["name"]], 15).name = "StoryIdentity"
	return page


func _navigation(page: Control) -> void:
	var row := _actions(page)
	var previous: Button = _ui()._add_button(row, "← Capítulo anterior", _move.bind(-1), false, 38)
	previous.disabled = chapter == 0
	_text(row, "Capítulo %d / %d" % [chapter + 1, report["chapters"].size()], 15)
	var next: Button = _ui()._add_button(row, "Capítulo siguiente →", _move.bind(1), false, 38)
	next.disabled = chapter == report["chapters"].size() - 1
	_ui()._add_button(row, "Desenlace", show_summary, false, 38)


func _move(step: int) -> void:
	chapter = clampi(chapter + step, 0, report["chapters"].size() - 1)
	show_chapter()


func show_chapter() -> void:
	if report.is_empty() or report["chapters"].is_empty():
		show_setup(str(report.get("message", "No se generaron capítulos. Revisa el catálogo.")))
		return
	var item: Dictionary = report["chapters"][chapter]
	var page := _page(str(item["title"]), "Historia simulada · periodo %d · sucesos y resultados del motor académico" % int(item["term"]))
	_navigation(page)
	_text(page, str(item["story"]), 19).name = "CareerStoryNarrative"
	var row := _actions(page)
	_ui()._add_button(row, "Grafo de este capítulo", show_graph, true, 40).name = "StoryGraphButton"
	_ui()._add_button(row, "Qué se exploró", show_learning, false, 40)
	if not item["results"].is_empty():
		var results: VBoxContainer = _ui()._card(page)
		_text(results, "Resultados del periodo", 20)
		for result in item["results"]:
			_text(results, "%s · %s · %.2f · %s%s" % [result["sigla"], result["name"], float(result["score"]), "Aprobada" if result["passed"] else "Reprobada", " · nuevo intento" if result["retake"] else ""], 15)
		if not item["unlocked"].is_empty():
			_text(page, "Habilitadas para próximos periodos: " + ", ".join(item["unlocked"]), 15)
	for event in item["events"]:
		var card: VBoxContainer = _ui()._card(page)
		_text(card, str(event.get("title", {"tramite": "Ruta del trámite", "competencia": "Competencia de auxiliatura", "designacion": "Trabajo con el docente", "defensa": "Evaluación de defensa"}.get(event["kind"], "En el campus"))), 17)
		_text(card, str(event["text"]), 15)
		if not str(event.get("receipt", "")).is_empty():
			_text(card, "Comprobante simulado: " + str(event["receipt"]), 13)
		if not event.get("documents", []).is_empty():
			var names: Array[String] = []
			for document in event["documents"]:
				names.append(str(DOCUMENT_NAMES.get(document, document)))
			_text(card, "Documentos requeridos: " + ", ".join(names), 13)
		for candidate in event.get("candidates", []):
			_text(card, "%s: %.2f" % [candidate["name"], float(candidate["score"])], 13)


func show_summary() -> void:
	var page := _page("El desenlace de tu historia", "Una posibilidad simulada, no un pronóstico personal")
	_text(page, "%d periodos cursados · promedio %.2f · %s" % [int(report["terms"]), float(report["average"]) if report["average"] != null else 0.0, "Con reprobaciones históricas" if report["had_failure"] else "Sin materias reprobadas"], 19)
	_text(page, "Titulación por " + str(report["graduation_mode"]) if report["complete"] else "Historia incompleta: " + str(report["message"]), 20)
	_text(page, "La suerte cambia las circunstancias y resultados; el enfoque influye en las decisiones y las probabilidades. Aprobar una materia no demuestra dominio real de sus temas. Puedes revisar cada periodo, sus documentos y las conexiones de la malla.", 16)
	var row := _actions(page)
	_ui()._add_button(row, "Continuar lectura", show_chapter, true, 42)
	_ui()._add_button(row, "Otra historia", create_story, false, 42)
	_ui()._add_button(row, "Cambiar protagonista", show_setup, false, 42)
	_text(page, "Identificador reproducible de historia: %d · modelo 1" % int(report["seed"]), 13)


func show_graph() -> void:
	var item: Dictionary = report["chapters"][chapter]
	var ui := _ui()
	ui._apply_career_theme(str(report["program_id"]), str(report["mention_id"]))
	var page: VBoxContainer = ui._make_page("Grafo de la historia", "", show_chapter, false, false, false)
	_text(page, "%s · %s" % [report["player_name"], Catalog.mention_by_id(str(report["program_id"]), str(report["mention_id"]))["name"]], 14).name = "StoryIdentity"
	var counter := _text(page, "", 15)
	var graph := Graph.new()
	graph.name = "StoryCurriculumGraph"
	graph.font_scale = float(ui.settings["font_scale"])
	graph.animations_enabled = bool(ui.settings["animations"])
	graph.low_performance = bool(ui.settings.get("low_performance", false))
	graph.display_height = 220
	graph.personal_states = item["states"].duplicate(true)
	graph.manual_positions = graph_layouts.duplicate(true)
	graph.setup(str(report["program_id"]), str(report["mention_id"]), 800)
	graph.semester_index = clampi(graph_semester, 0, graph.semesters.size() - 1)
	for subject in Catalog.all_subjects(str(report["program_id"]), str(report["mention_id"])):
		if str(item["states"].get(subject["sigla"], "")).contains("Reprobada"):
			graph.carry_subjects.append(subject)
	graph._build_semester()
	var frame := Control.new()
	frame.clip_contents = true
	frame.custom_minimum_size.y = 220
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(frame)
	frame.add_child(graph)
	graph.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_text(page, Graph.KEY_GUIDE, 13)
	var update := func(_index: int = 0, _count: int = 0) -> void:
		graph_semester = graph.semester_index
		counter.text = "Semestre curricular %d de %d · Historia hasta el periodo %d" % [graph_semester + 1, graph.semesters.size(), int(item["term"])]
	graph.semester_changed.connect(update)
	graph.layout_changed.connect(func() -> void: graph_layouts = graph.manual_positions.duplicate(true))
	graph.subject_selected.connect(func(code: String, data: Dictionary) -> void:
		if ui.find_child("GraphSubjectPopup", false, false) != null:
			return
		var popup := SubjectPopup.new()
		var detail := popup.open(ui, graph)
		_text(detail, str(data["name"]), 22)
		_text(detail, str(data.get("desc", "")), 16)
		if not data.get("admission", false):
			_text(detail, str(graph.personal_states.get(code, "Materia del plan")), 15)
			ui._add_button(detail, "Explorar modelo", show_subject.bind(data), true, 40))
	update.call()
	ui._focus_control.call_deferred(weakref(graph))


func show_learning() -> void:
	var page := _page("Temas de este capítulo", "Contenido orientativo · la historia no acredita aprendizaje real", show_chapter)
	_ui()._add_button(page, "Volver al relato", show_chapter, false, 38)
	var results: Array = report["chapters"][chapter]["results"]
	if results.is_empty():
		_text(page, "En la titulación se integran los temas recorridos: metodología, argumentación, documentación y comunicación de resultados.")
	for item in results:
		var card: VBoxContainer = _ui()._card(page)
		_text(card, str(item["name"]), 19)
		_text(card, "Temas explorados: " + ", ".join(item["topics"]), 15)
		_text(card, "Nuevo intento necesario: conviene reforzar estos temas." if not item["passed"] else "Materia aprobada en la historia: puedes explorar su modelo.", 14)
		_ui()._add_button(card, "Explorar modelo", show_subject.bind(item), false, 38)


func show_subject(subject: Dictionary) -> void:
	var course := Catalog.course_for_sigla(str(report["program_id"]), str(subject["sigla"]), str(report["mention_id"]))
	var page := _page(str(course.get("name", subject["name"])), "Exploración didáctica de la historia", show_graph)
	_ui()._add_button(page, "Volver al grafo", show_graph, false, 38)
	_ui()._add_button(page, "Volver al relato", show_chapter, false, 38)
	_text(page, str(course.get("desc", "")), 17)
	_text(page, "Temas orientativos: " + ", ".join(course.get("topics", [])), 15)
	var demo := Demo.new()
	demo.setup(course, 0, float(_ui().settings["font_scale"]), _ui()._current_theme)
	page.add_child(demo)
