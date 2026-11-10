extends RefCounted

const Catalog = preload("res://scripts/catalog.gd")
const Procedures = preload("res://scripts/simulation_procedures.gd")
const Graph = preload("res://scripts/curriculum_graph.gd")
const SubjectPopup = preload("res://scripts/graph_subject_popup.gd")
const Glimpse = preload("res://scripts/course_glimpse.gd")
const Demo = preload("res://scripts/study_demo.gd")
const Choice = preload("res://scripts/choice_picker.gd")
const DOCUMENT_NAMES := {"ci": "Identidad", "matricula": "Matrícula vigente", "carnet": "Carnet universitario", "historial": "Historial académico", "formulario": "Formulario de solicitud", "conclusion": "Conclusión de estudios", "solvencia": "Solvencia", "perfil": "Perfil y propuesta de tutor", "borrador": "Borrador del trabajo", "plan_aux": "Plan de trabajo", "plan_firmado": "Plan firmado", "permiso_aula": "Permiso de aula", "informe_aux": "Informe docente", "acta_defensa": "Acta de defensa", "diploma": "Diploma académico", "titulo": "Título"}

var host: WeakRef
var section := "resumen"
var notice := ""
var notice_ok := true
var subject_search := ""
var subject_filter := 0
var selected_request := ""
var form_kind := "carta"
var form_program := ""
var form_mention := ""
var form_course := ""
var form_reason := ""
var graph_semester := 0
var graph_term_seen := 0
var _branches_by_plan: Dictionary = {}
var _recent_approvals: Dictionary = {}
var _office_back := Callable()
var show_request_form := false
var show_documents := false
var show_closed_requests := false


func _init(controller: Control) -> void:
	host = weakref(controller)


func _ui() -> Control:
	return host.get_ref()


func _model() -> RefCounted:
	return _ui().simulation


func _text(parent: Control, value: String, size: int = 16, muted: bool = false) -> Label:
	var ui := _ui()
	var label: Label = ui._label(value, size, ui._current_theme.get("sub" if muted else "text", Color.WHITE))
	parent.add_child(label)
	return label


func _actions(parent: Control) -> HFlowContainer:
	var row := HFlowContainer.new()
	row.add_theme_constant_override("h_separation", 8)
	row.add_theme_constant_override("v_separation", 8)
	parent.add_child(row)
	return row


func _button(parent: Control, label: String, callback: Callable, enabled: bool = true, primary: bool = false) -> Button:
	var button: Button = _ui()._add_button(parent, label, callback, primary, 44)
	button.disabled = not enabled
	button.add_theme_font_size_override("font_size", int(16 * float(_ui().settings["font_scale"])))
	return button


func _go(destination: String) -> void:
	_ui()._show_campus_section(destination)


func _friendly(message: String) -> String:
	if message.contains("/pagar"):
		return "Falta el comprobante. Registra el pago simulado en este expediente y presenta el paso otra vez."
	return message.replace("/tramites", "Trámites")


func perform(method: String, arguments: Array = [], destination: String = "", inspect_request: bool = false, back: Callable = Callable()) -> Dictionary:
	var model := _model()
	var previous: Array = _ui().current_profile.get("passed_subjects", []).duplicate() if method == "close_term" else []
	var result: Dictionary = model.callv(method, arguments)
	_ui()._save_profile()
	notice = _friendly(str(result.get("message", "Acción registrada.")))
	notice_ok = bool(result.get("ok", false))
	if _ui()._save_failed:
		notice += " · No se pudo guardar. Conserva abierta la partida y vuelve a intentarlo."
		notice_ok = false
	if result.get("ok", false) and method == "close_term":
		for sigla in _ui().current_profile.get("passed_subjects", []):
			if not previous.has(sigla):
				_recent_approvals[str(sigla)] = true
			_ui()._record_completed_subject(str(_ui().current_profile["program_id"]), str(_ui().current_profile["mention_id"]), str(sigla))
	if model.snapshot()["graduated"]:
		var program := Catalog.program_by_id(str(_ui().current_profile["program_id"]))
		_ui()._record_completed_career(str(program["id"]), str(program["title"]))
	if not destination.is_empty():
		section = destination
	if inspect_request and result.has("request_id"):
		selected_request = str(result["request_id"])
		show_request_form = false
		section = "tramites"
	if back.is_valid():
		back.call()
	else:
		_ui()._show_campus_section(section)
	return result


func render(destination: String) -> void:
	section = destination
	var ui := _ui()
	var profile: Dictionary = ui.current_profile
	ui._apply_career_theme(str(profile["program_id"]), str(profile["mention_id"]))
	ui.queue_redraw()
	var titles := {"resumen": "Tu campus", "materias": "Materias y planificación", "tramites": "Oficinas y trámites", "historial": "Tu historial académico", "auxiliatura": "Tu actividad de auxiliatura", "graduacion": "Del egreso al título"}
	var snapshot: Dictionary = _model().snapshot()
	if int(snapshot["term"]) == 1:
		titles["materias"] = "Materias del primer semestre"
	var subtitle := "Decisiones y progreso de tu partida" if section == "resumen" else str(profile.get("mention_name", ""))
	var contextual := section in ["tramites", "auxiliatura", "graduacion"] and _office_back.is_valid()
	var back: Callable = _leave_office if contextual else (ui._return_to_menu if section == "resumen" else _go.bind("resumen"))
	var page: VBoxContainer = ui._make_page(titles.get(section, "Tu campus"), subtitle, back, false, not contextual)
	if not notice.is_empty():
		var feedback: VBoxContainer = ui._card(page, true)
		feedback.name = "ActionFeedback"
		_text(feedback, ("✓ " if notice_ok else "Revisa: ") + notice)
		if not notice_ok:
			feedback.modulate = Color("#ffc7a3")
	match section:
		"resumen": _overview(page, snapshot)
		"materias": _subjects(page, snapshot)
		"tramites": _procedures(page, snapshot)
		"historial": _history(page, snapshot)
		"auxiliatura": _assistant(page, snapshot)
		"graduacion": _graduation(page, snapshot)


func _overview(page: VBoxContainer, snapshot: Dictionary) -> void:
	var ui := _ui()
	var model := _model()
	var stats: VBoxContainer = ui._card(page, true)
	var phase := {"INSCRIPCION": "Planifica tu semestre", "CURSANDO": "Tu semestre está en marcha", "TITULADO": "¡Tu título está emitido!"}
	if int(snapshot["term"]) == 1:
		phase["INSCRIPCION"] = "Prepara tu primer semestre"
	_text(stats, phase.get(snapshot["phase"], snapshot["phase"]), 23)
	var approved := 0
	var enrolled := 0
	var finished := 0
	for subject in snapshot["subjects"]:
		if subject["approved"]:
			approved += 1
		if not subject["enrollment"].is_empty():
			enrolled += 1
			if subject["enrollment"]["score"] != null:
				finished += 1
	_text(stats, "%d materias aprobadas · %d/%d inscritas · Promedio %s" % [approved, enrolled, int(snapshot["load_limit"]), "%.2f" % float(snapshot["average"]) if snapshot["average"] != null else "por construir"], 16)
	_text(stats, str(ui.current_profile.get("mention_name", "")), 15, true)
	if snapshot["unlocked_all"]:
		_text(stats, "Exploración activada · desbloquear no equivale a aprobar.", 14, true)
	if snapshot["graduated"]:
		return
	if snapshot["studies_complete"]:
		_text(stats, "Completaste el plan. Ya puedes consultar tus opciones de graduación.", 17)
		_button(stats, "Ver mi graduación", _go.bind("graduacion"), true, true)
	elif snapshot["phase"] == "INSCRIPCION":
		if not _document_present("matricula", "", snapshot):
			_text(stats, "Siguiente paso · Completa la matrícula desde la ventanilla simulada en Administración de Sistemas.", 16)
		elif enrolled > 0:
			_button(stats, "Iniciar semestre", perform.bind("start_term", [], "resumen"), true, true)
		else:
			_text(stats, "Elige tus materias para poder iniciar el semestre.", 15, true)
	else:
		_text(stats, "%d de %d materias con resultado final." % [finished, enrolled], 15, true)
		if finished == enrolled:
			_button(stats, "Cerrar semestre", _confirm_close, true, true)
		else:
			_button(stats, "Continuar estudiando", _go.bind("materias"), true, true)


func exploration_objective(back: Callable) -> Dictionary:
	var snapshot: Dictionary = _model().snapshot()
	if snapshot["graduated"]:
		return {"id": "graduated", "title": "Recorrido completo", "hint": "Tu título está emitido."}
	if snapshot["studies_complete"]:
		return {"id": "degree", "title": "Graduación disponible", "hint": "Consulta las modalidades en la ventanilla de Administración de Sistemas."}
	if snapshot["phase"] == "INSCRIPCION":
		if not _document_present("matricula", "", snapshot):
			return {"id": "matricula", "title": "Completa la matrícula", "hint": "Administración de Sistemas · entra y pulsa E al fondo de la oficina."}
		if snapshot["subjects"].any(func(subject: Dictionary) -> bool: return not subject["enrollment"].is_empty()):
			return {"id": "start", "title": "Inicia el semestre", "hint": "Matrícula vigente · abre los parciales de tus materias.", "label": "Iniciar", "action": perform.bind("start_term", [], "resumen", false, back)}
		return {"id": "plan", "title": "Elige tus materias", "hint": "Inscríbelas antes de iniciar el semestre.", "label": "Materias", "action": _go.bind("materias")}
	for subject in snapshot["subjects"]:
		var entry: Dictionary = subject["enrollment"]
		if not entry.is_empty() and entry["score"] == null:
			return {"id": "study", "title": str(subject["name"]), "hint": "Parcial %d de 3 · continúa desde aquí." % (entry["answers"].size() + 1), "label": "Rendir", "action": _ui()._start_subject.bind(str(subject["id"]), back)}
	return {"id": "close", "title": "Cierra el semestre", "hint": "Ya tienes un resultado en todas tus materias.", "label": "Cerrar", "action": _confirm_close.bind(back)}


func _confirm_close(back: Callable = Callable()) -> void:
	var snapshot: Dictionary = _model().snapshot()
	var lines: Array[String] = ["Se guardará cada resultado en el historial y comenzará la planificación del siguiente semestre."]
	for subject in snapshot["subjects"]:
		var entry: Dictionary = subject["enrollment"]
		if not entry.is_empty():
			lines.append("%s · %s" % [subject["sigla"], "%.2f" % float(entry["score"]) if entry["score"] != null else "sin resultado"])
	lines.append("Los permisos y actividades del periodo actual vencerán. Revisa tus trámites y trabajo de auxiliatura antes de cerrar.")
	_confirm("Cerrar el semestre", "\n".join(lines), perform.bind("close_term", [], "resumen", false, back))


func _confirm(title: String, body: String, callback: Callable) -> void:
	var dialog := ConfirmationDialog.new()
	dialog.title = title
	dialog.dialog_text = body
	dialog.ok_button_text = "Confirmar"
	dialog.cancel_button_text = "Volver"
	dialog.confirmed.connect(func() -> void:
		dialog.queue_free()
		callback.call())
	dialog.canceled.connect(dialog.queue_free)
	_ui().add_child(dialog)
	dialog.popup_centered(Vector2i(620, 360))


func subject_status(subject: Dictionary, snapshot: Dictionary) -> String:
	if subject.get("graduation_node", false):
		return "Graduación"
	if subject["approved"]:
		return "Aprobada"
	var entry: Dictionary = subject["enrollment"]
	if not entry.is_empty():
		if entry["score"] != null:
			return "%s provisional · %.2f" % ["Aprobada" if float(entry["score"]) >= 51.0 else "Reprobada", float(entry["score"])]
		if _pending_retaking(subject, snapshot):
			return "Recursando · %d/3 parciales" % entry["answers"].size() if snapshot["phase"] == "CURSANDO" else "Inscrita para recursar"
		return "Cursando · %d/3 parciales" % entry["answers"].size() if snapshot["phase"] == "CURSANDO" else "Inscrita"
	for record in snapshot["history"]:
		if record["course_id"] == subject["id"] and not record["passed"]:
			return "Pendiente de recursar"
	if not subject["eligibility"]["ok"]:
		return "Bloqueada"
	return "Correlativa habilitada" if not subject["eligibility"].get("regulars", []).is_empty() else "Habilitada"


func _pending_retaking(subject: Dictionary, snapshot: Dictionary) -> bool:
	if subject["approved"]:
		return false
	for record in snapshot["history"]:
		if record["course_id"] == subject["id"] and not record["passed"]:
			return true
	return false


func _subjects(page: VBoxContainer, snapshot: Dictionary) -> void:
	var message := "Planificación disponible" if snapshot["planning_available"] else "En curso"
	if int(snapshot["term"]) == 1 and snapshot["phase"] == "INSCRIPCION":
		message = "Inscripción inicial automática"
	_text(page, "Carga %d/%d · %s" % [_model().state["enrollments"].size(), int(snapshot["load_limit"]), message], 16)
	var toolbar := HBoxContainer.new()
	toolbar.add_theme_constant_override("separation", 10)
	page.add_child(toolbar)
	var search := LineEdit.new()
	search.name = "SubjectSearch"
	search.placeholder_text = "Buscar por nombre o sigla"
	search.text = subject_search
	_ui()._style_input(search)
	search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	search.custom_minimum_size.x = 190
	toolbar.add_child(search)
	var picker := Choice.new()
	picker.name = "SubjectFilter"
	for label in ["Mi semestre", "Todas las materias", "Habilitadas", "Pendientes", "Aprobadas"]:
		picker.add_item(label)
	picker.select(subject_filter)
	picker.custom_minimum_size.y = 44
	picker.add_theme_font_size_override("font_size", int(16 * float(_ui().settings["font_scale"])))
	_ui()._style_select(picker)
	picker.custom_minimum_size.x = 194
	picker.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	toolbar.add_child(picker)
	if not snapshot["history"].is_empty():
		_button(toolbar, "Historial", _go.bind("historial"))
	var list: GridContainer = _ui()._adaptive_grid(page, 300.0, 2)
	list.name = "SubjectResults"
	search.text_changed.connect(func(value: String) -> void:
		subject_search = value
		_subject_results(list, snapshot))
	picker.item_selected.connect(func(index: int) -> void:
		subject_filter = index
		_subject_results(list, snapshot))
	_subject_results(list, snapshot)


func _subject_results(list: GridContainer, snapshot: Dictionary) -> void:
	for child in list.get_children():
		list.remove_child(child)
		child.queue_free()
	var count := 0
	for subject in snapshot["subjects"]:
		if subject.get("graduation_node", false):
			continue
		var matches := subject_search.is_empty() or (str(subject["name"]) + " " + str(subject["sigla"])).to_lower().contains(subject_search.to_lower())
		var entry: Dictionary = subject["enrollment"]
		if not matches or (subject_filter == 0 and entry.is_empty()) or (subject_filter == 2 and (not subject["eligibility"]["ok"] or not entry.is_empty())) or (subject_filter == 3 and subject["approved"]) or (subject_filter == 4 and not subject["approved"]):
			continue
		count += 1
		var card: VBoxContainer = _ui()._card(list)
		var course := _button(card, "%s · %s" % [subject["sigla"], subject["name"]], Callable(), true, not entry.is_empty())
		course.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		course.custom_minimum_size.x = 0
		course.alignment = HORIZONTAL_ALIGNMENT_LEFT
		course.pressed.connect(_show_subject_sheet.bind(subject, course, snapshot))
		_text(card, "Semestre %d · %s" % [int(subject.get("semester", 0)), subject_status(subject, snapshot)], 14, true)
	if count == 0:
		_text(list, "No hay materias con este filtro. Prueba «Todas las materias» o cambia la búsqueda.", 16, true)


func _enroll(key: String) -> void:
	var check: Dictionary = _model().eligibility(key)
	var missing: Array[String] = []
	for regular in check.get("regulars", []):
		if not _model().state["enrollments"].has(regular):
			var course: Dictionary = _model().course_data(str(regular))
			missing.append(str(course["sigla"]) + " · " + str(course["name"]))
	if missing.is_empty():
		perform("enroll", [key], "materias")
	else:
		_confirm("Inscribir con sus regulares", "Esta elección incorpora también:\n" + "\n".join(missing) + "\n\nEl motor verificará la carga del paquete completo.", perform.bind("enroll", [key], "materias"))


func _history(page: VBoxContainer, snapshot: Dictionary) -> void:
	_text(page, "Cada intento se conserva. El semestre cursado puede incluir materias de distintos niveles del plan.", 16, true)
	if snapshot["history"].is_empty():
		_text(page, "Tu historial aparecerá al cerrar el primer semestre. Las notas actuales siguen siendo provisionales.", 18)
	var records: Array = snapshot["history"].duplicate()
	records.reverse()
	for record in records:
		var subject: Dictionary = _model().course_data(str(record["course_id"]))
		var card: VBoxContainer = _ui()._card(page)
		_text(card, "%s · %s" % [subject.get("sigla", record["course_id"]), subject.get("name", "Materia de un plan anterior")], 18)
		_text(card, "Semestre cursado %d · %s · Nota %s" % [int(record["term"]), "Aprobada" if record["passed"] else "Reprobada", "%.2f" % float(record["score"]) if record["score"] != null else "no conservada en partida antigua"], 15)
		var program := Catalog.program_by_id(str(record.get("program_id", "")))
		var mention := Catalog.mention_by_id(str(record.get("program_id", "")), str(record.get("mention_id", "")))
		_text(card, "Plan de origen: %s · %s" % [program.get("name", "Plan anterior"), mention.get("name", "")], 14, true)


func open_request(id: String) -> void:
	selected_request = id
	show_request_form = false
	_go("tramites")


func open_office(back: Callable) -> void:
	_office_back = back
	selected_request = ""
	show_request_form = false
	_go("tramites")


func _leave_office() -> void:
	var back := _office_back
	_office_back = Callable()
	if back.is_valid():
		back.call()


func _office_index() -> void:
	selected_request = ""
	show_request_form = false
	_go("tramites")


func _procedures(page: VBoxContainer, snapshot: Dictionary) -> void:
	var contextual := _office_back.is_valid()
	_text(page, "Ventanilla académica simulada. Consulta el expediente y la oficina indicada para su siguiente paso." if contextual else "Consulta de expedientes. Los documentos y pagos del juego son simulados.", 15, true)
	if show_request_form and contextual:
		_procedure_form(page)
		_button(page, "Volver a expedientes", _office_index)
		return
	if not selected_request.is_empty():
		var request: Dictionary = _model().procedure(selected_request).duplicate(true)
		if not request.is_empty():
			_request_detail(page, request, snapshot)
			_button(page, "Ver expedientes", _office_index)
			return
	var quick := _actions(page)
	if contextual:
		if not snapshot["graduated"]:
			_button(quick, "Nueva solicitud", _new_request_form, true, true)
			if not _document_present("matricula", "", snapshot) and not snapshot["procedures"].any(func(request: Dictionary) -> bool: return request["kind"] == "matricula" and request["status"] in ["PENDIENTE", "OBSERVADO"]):
				_button(quick, "Abrir matrícula", perform.bind("open_procedure", ["matricula"], "tramites", true))
		if snapshot["subjects"].any(func(subject: Dictionary) -> bool: return subject["approved"]):
			_button(quick, "Auxiliatura", _go.bind("auxiliatura"))
		if snapshot["studies_complete"] and not snapshot["graduated"]:
			_button(quick, "Graduación", _go.bind("graduacion"))
	_button(quick, "Documentos", _toggle_documents)
	_button(quick, "Ocultar cerrados" if show_closed_requests else "Expedientes cerrados", _toggle_closed_requests)
	_text(page, "Tus expedientes", 22)
	for request in snapshot["procedures"]:
		if not show_closed_requests and not ["PENDIENTE", "OBSERVADO"].has(request["status"]):
			continue
		var card: VBoxContainer = _ui()._card(page)
		var step := Procedures.current_step(request)
		_text(card, "%s · %s · %s" % [request["id"], request["name"], str(request["status"]).capitalize()], 18)
		if not step.is_empty():
			_text(card, "%s → %s" % [step["office"], step["label"]], 15, true)
		_button(card, "Abrir expediente", open_request.bind(str(request["id"])))
	if show_documents and not snapshot["documents"].is_empty():
		var documents: VBoxContainer = _ui()._card(page)
		_text(documents, "Tu carpeta de documentos", 21)
		for key in snapshot["documents"]:
			var document: Dictionary = snapshot["documents"][key]
			_text(documents, "%s · semestre %d%s" % [DOCUMENT_NAMES.get(document["kind"], document["kind"]), int(document["term"]), " · " + str(document["request_id"]) if not str(document["request_id"]).is_empty() else ""], 14, true)

		if contextual:
			_button(documents, "Registrar pago de historial", perform.bind("pay", ["historial"], "tramites"))
			_button(documents, "Emitir historial", perform.bind("issue_document", ["historial"], "tramites"))


func _new_request_form() -> void:
	selected_request = ""
	show_request_form = true
	_go("tramites")


func _toggle_documents() -> void:
	show_documents = not show_documents
	_go("tramites")


func _toggle_closed_requests() -> void:
	show_closed_requests = not show_closed_requests
	_go("tramites")


func _document_present(kind: String, id: String, snapshot: Dictionary) -> bool:
	var scoped := ["formulario", "plan_aux", "plan_firmado", "permiso_aula", "informe_aux", "perfil", "borrador", "acta_defensa", "diploma", "titulo"].has(kind)
	var key := "%s@%s" % [kind, id] if scoped else kind
	var document: Dictionary = snapshot["documents"].get(key, {})
	if document.is_empty():
		return false
	return (not document.get("term_specific", false) or int(document["term"]) == int(snapshot["term"])) and (kind != "historial" or document.get("history_size", -1) == snapshot["history"].size())


func _request_detail(page: VBoxContainer, request: Dictionary, snapshot: Dictionary) -> void:
	var card: VBoxContainer = _ui()._card(page, true)
	card.name = "ProcedureDetail"
	var id := str(request["id"])
	_text(card, "%s · %s" % [id, request["name"]], 23)
	_text(card, "Estado: %s · Semestre de apertura: %d" % [str(request["status"]).capitalize(), int(request["term"])], 16)
	if request.get("simulated", false):
		_text(card, "Recorrido de simulación: representa una experiencia introductoria del trámite.", 14, true)
	if request["payload"].has("reason"):
		_text(card, "Justificación: " + str(request["payload"]["reason"]), 15, true)
	for index in range(request["steps"].size()):
		var step: Dictionary = request["steps"][index]
		var marker := "✓" if index < int(request["step"]) else ("→" if index == int(request["step"]) else "○")
		_text(card, "%s %d. %s · %s" % [marker, index + 1, step["office"], step["label"]], 15, index != int(request["step"]))
	var current := Procedures.current_step(request)
	if not current.is_empty() and not _office_back.is_valid():
		_text(card, "Continúa en la ventanilla simulada de Administración de Sistemas.", 15, true)
	elif not current.is_empty():
		_text(card, "En esta oficina necesitas:", 17)
		for kind in current.get("documents", []):
			var present := _document_present(str(kind), id, snapshot)
			_text(card, ("✓ " if present else "Pendiente · ") + str(DOCUMENT_NAMES.get(kind, kind)), 15, present)
			if not present and ["historial", "solvencia", "perfil", "borrador", "plan_aux"].has(kind):
				if kind == "historial":
					_button(card, "Registrar pago de historial", perform.bind("pay", ["historial"], "tramites"))
				var scope := id if ["perfil", "borrador", "plan_aux"].has(kind) else ""
				_button(card, "Preparar " + str(DOCUMENT_NAMES[kind]), perform.bind("issue_document", [str(kind), scope], "tramites"))
		if current.has("receipt"):
			var scope := "" if current["receipt"] == "matricula" else id
			_button(card, "Registrar comprobante de pago simulado", perform.bind("pay", [str(current["receipt"]), scope], "tramites"))
		if current.get("requires_sessions", false):
			var sessions := int(request["payload"].get("sessions", 0))
			_text(card, "%d/3 actividades de apoyo completadas" % sessions, 16)
			_button(card, "Realizar actividad de apoyo", _ui()._show_simulation_activity.bind("apoyo", id), sessions < 3, true)
		if current.get("requires_defense", false):
			var passed := bool(request["payload"].get("defense_passed", false))
			_text(card, "Defensa aprobada" if passed else "El tribunal evaluará tres respuestas. Se conservan los intentos.", 16)
			_button(card, "Presentar defensa", _ui()._show_simulation_activity.bind("defensa", id), not passed, true)
		var actions := _actions(card)
		_button(actions, "Presentar en " + str(current["office"]), perform.bind("advance_procedure", [id, str(current["office"])], "tramites"), true, true)
		_button(actions, "Cancelar solicitud", _confirm.bind("Cancelar solicitud", "Se conservará el expediente cancelado en tu historial de trámites.", perform.bind("cancel_procedure", [id], "tramites")))
	for event in request.get("events", []).slice(-3):
		_text(card, "• " + _friendly(str(event.get("observation", event.get("action", "Paso registrado")))), 14, true)


func _picker(parent: Control, label: String, entries: Array, selected: String, changed: Callable) -> Button:
	_text(parent, label, 15)
	var picker := Choice.new()
	picker.custom_minimum_size.y = 44
	picker.add_theme_font_size_override("font_size", int(16 * float(_ui().settings["font_scale"])))
	picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	picker.clip_text = true
	for entry in entries:
		picker.add_item(str(entry[1]))
		picker.set_item_metadata(picker.item_count - 1, str(entry[0]))
		if str(entry[0]) == selected:
			picker.select(picker.item_count - 1)
	picker.item_selected.connect(func(index: int) -> void: changed.call(str(picker.get_item_metadata(index))))
	_ui()._style_select(picker)
	parent.add_child(picker)
	return picker


func _procedure_form(page: VBoxContainer) -> void:
	var model := _model()
	if model.snapshot()["graduated"]:
		return
	var card: VBoxContainer = _ui()._card(page)
	card.name = "ProcedureForm"
	_text(card, "Nueva solicitud académica", 22)
	_text(card, "Los cambios se tramitan durante la inscripción. Tu historial se conserva al cambiar de plan.", 15, true)
	_picker(card, "¿Qué necesitas?", [["carta", "Materia por carta"], ["otra_carrera", "Materia de otra carrera o mención"], ["mencion", "Cambio de mención · K-02"], ["carrera", "Cambio de carrera · K-03"]], form_kind, _change_form.bind("kind"))
	if form_program.is_empty():
		form_program = str(_ui().current_profile["program_id"])
	if ["otra_carrera", "carrera"].has(form_kind):
		var programs: Array = []
		for program in Catalog.PROGRAMS:
			programs.append([program["id"], program["name"]])
		_picker(card, "Carrera de destino", programs, form_program, _change_form.bind("program"))
	else:
		form_program = str(_ui().current_profile["program_id"])
	if form_kind != "carta":
		var mentions: Array = []
		for mention in Catalog.mentions_for_program(form_program):
			mentions.append([mention["id"], mention["name"]])
		if form_mention.is_empty() or Catalog.mention_by_id(form_program, form_mention).is_empty():
			form_mention = str(mentions[0][0])
		_picker(card, "Mención de destino", mentions, form_mention, _change_form.bind("mention"))
	else:
		form_mention = str(_ui().current_profile["mention_id"])
	var available := true
	if ["carta", "otra_carrera"].has(form_kind):
		var entries: Array = []
		var keys: Array[String] = []
		for key in model.courses:
			var course: Dictionary = model.course_data(str(key))
			if course["program_id"] != form_program or course["mention_id"] != form_mention or course.get("graduation_node", false) or model.is_approved(str(key)):
				continue
			if form_kind == "otra_carrera" and model.curriculum().has(key):
				continue
			keys.append(str(key))
			entries.append([key, "%s · %s" % [course["sigla"], course["name"]]])
		available = not entries.is_empty()
		if available:
			if not keys.has(form_course):
				form_course = keys[0]
			_picker(card, "Materia solicitada", entries, form_course, _change_form.bind("course"))
		else:
			_text(card, "No hay materias pendientes de ese plan para esta solicitud. Elige otro destino.", 15)
		_text(card, "Justificación (al menos diez caracteres)", 15)
		var reason := LineEdit.new()
		reason.name = "RequestReason"
		reason.max_length = 350
		reason.add_theme_font_size_override("font_size", int(16 * float(_ui().settings["font_scale"])))
		reason.custom_minimum_size.y = 44
		reason.text = form_reason
		reason.placeholder_text = "Explica por qué necesitas esta autorización."
		reason.text_changed.connect(func(value: String) -> void: form_reason = value)
		_ui()._style_input(reason)
		card.add_child(reason)
	_button(card, "Presentar solicitud", _submit_form, available and model.snapshot()["phase"] == "INSCRIPCION", true)


func _change_form(value: String, field: String) -> void:
	match field:
		"kind":
			form_kind = value
			form_program = str(_ui().current_profile["program_id"])
			form_mention = ""
			form_course = ""
			if ["otra_carrera", "carrera"].has(value):
				for program in Catalog.PROGRAMS:
					if program["id"] != form_program:
						form_program = str(program["id"])
						break
			elif value == "mencion":
				for mention in Catalog.mentions_for_program(form_program):
					if mention["id"] != _ui().current_profile["mention_id"]:
						form_mention = str(mention["id"])
						break
		"program":
			form_program = value
			form_mention = ""
		"mention": form_mention = value
		"course": form_course = value
	_go("tramites")


func _submit_form() -> void:
	var payload := {"program_id": form_program, "mention_id": form_mention}
	if ["carta", "otra_carrera"].has(form_kind):
		payload = {"course_id": form_course, "reason": form_reason}
	perform("open_procedure", [form_kind, payload], "tramites", true)


func _assistant(page: VBoxContainer, snapshot: Dictionary) -> void:
	_text(page, "La auxiliatura es parte de tu vida como estudiante. Ganar la competencia inicia el trabajo con un docente y un paralelo.", 16, true)
	for assignment in snapshot["assignments"]:
		var card: VBoxContainer = _ui()._card(page, true)
		var course: Dictionary = _model().course_data(str(assignment["course_id"]))
		_text(card, "%s · Paralelo %s" % [course["name"], assignment["parallel"]], 21)
		_text(card, "%s · Semestre %d · %s" % [assignment["teacher"], int(assignment["term"]), str(assignment["status"]).capitalize()], 16)
		_text(card, "Plan firmado → permiso de aula → tres actividades → informe docente → cierre.", 15, true)
		_button(card, "Ver trabajo y documentos", open_request.bind(str(assignment["request_id"])))
	for application in snapshot["applications"]:
		var course: Dictionary = _model().course_data(str(application["course_id"]))
		var card: VBoxContainer = _ui()._card(page)
		_text(card, "%s · %s" % [course["name"], str(application["status"]).capitalize()], 19)
		_text(card, "Postulación %s · %d/3 respuestas de competencia" % [application["id"], application["answers"].size()], 15, true)
		if application.has("score"):
			_text(card, "Resultado %.2f · Puesto %d" % [float(application["score"]), int(application["ranking"])], 16)
		var row := _actions(card)
		_button(row, "Ver expediente", open_request.bind(str(application["request_id"])))
		_button(row, "Rendir competencia", _ui()._show_simulation_activity.bind("examen", str(application["id"])), application["status"] == "HABILITADA" and int(application["term"]) == int(snapshot["term"]), true)
	_text(page, "Materias para postular", 22)
	var approved := 0
	for subject in snapshot["subjects"]:
		if not subject["approved"]:
			continue
		approved += 1
		var check: Dictionary = _model().assistant_eligibility(str(subject["id"]))
		var already := false
		for application in snapshot["applications"]:
			if application["course_id"] == subject["id"] and int(application["term"]) == int(snapshot["term"]):
				already = true
		var card: VBoxContainer = _ui()._card(page)
		_text(card, "%s · %s" % [subject["sigla"], subject["name"]], 18)
		_text(card, "Ya postulaste a esta convocatoria." if already else str(check["message"]), 15, true)
		_button(card, "Postular", perform.bind("apply_assistant", [str(subject["id"])], "auxiliatura", true), bool(check["ok"]) and not already, true)
	if approved == 0:
		_text(page, "Primero aprueba una materia y cierra el semestre. Después revisa la convocatoria con tu matrícula vigente.", 18)


func _graduation(page: VBoxContainer, snapshot: Dictionary) -> void:
	if not snapshot["studies_complete"] and not snapshot["graduated"]:
		_text(page, "La graduación se anunciará al completar los requisitos del plan.", 17)
		return
	var card: VBoxContainer = _ui()._card(page, true)
	_text(card, "Título emitido" if snapshot["graduated"] else ("Estudios concluidos" if snapshot["studies_complete"] else "Tu camino a la graduación"), 24)
	_text(card, "Concluir el plan, aprobar una modalidad, obtener el diploma y emitir el título son etapas diferentes.", 16)
	_text(card, str(snapshot["excellence"]["message"]), 16, true)
	if not _office_back.is_valid():
		if not snapshot["graduated"]:
			_text(card, "Consulta las modalidades en la ventanilla simulada de Administración de Sistemas.", 16)
		return
	for request in snapshot["procedures"]:
		if ["excelencia", "tesis", "proyecto"].has(request["kind"]):
			_button(card, "%s · %s" % [request["name"], str(request["status"]).capitalize()], open_request.bind(str(request["id"])))
	var grid: GridContainer = _ui()._adaptive_grid(page, 320.0, 3)
	for item in [["excelencia", "Excelencia", "Promedio mayor que 65 y ninguna materia reprobada. No requiere defensa."], ["tesis", "Tesis", "Perfil, tutor, borrador, habilitación y defensa ante tribunal."], ["proyecto", "Proyecto de grado", "Desarrolla una solución, presenta sus resultados y realiza la defensa."]]:
		var option: VBoxContainer = _ui()._card(grid)
		_text(option, item[1], 22)
		_text(option, item[2], 16, true)
		var enabled := bool(snapshot["studies_complete"]) and not bool(snapshot["graduated"])
		if item[0] == "excelencia":
			enabled = enabled and bool(snapshot["excellence"]["ok"])
		_button(option, "Iniciar " + str(item[1]).to_lower(), perform.bind("open_procedure", [item[0]], "graduacion", true), enabled, true)


func show_course_preview(key: String) -> void:
	var subject: Dictionary = _model().course_data(key)
	if subject.is_empty():
		return
	var course := Catalog.course_for_sigla(str(subject["program_id"]), str(subject["sigla"]), str(subject["mention_id"]))
	var page: VBoxContainer = _ui()._make_page(str(subject["name"]), "Exploración y repaso · no registra notas ni cambia tus intentos", _go.bind(section), false, false)
	_text(page, str(course.get("desc", subject.get("desc", ""))), 18)
	for topic in course.get("topics", []):
		_text(page, "• " + str(topic), 16)
	var demo := Demo.new()
	demo.setup(course, 0, float(_ui().settings["font_scale"]), _ui()._current_theme)
	page.add_child(demo)
	var prompts: Array = course.get("partials", [])
	for question in prompts:
		var card: VBoxContainer = _ui()._card(page)
		_text(card, str(question["q"]), 18)
		var answer := _text(card, "Piensa tu respuesta antes de consultar la explicación.", 16, true)
		_button(card, "Mostrar explicación", _reveal.bind(answer, str(question["why"])))


func _reveal(label: Label, explanation: String) -> void:
	label.text = explanation


func show_graph(program_id: String, personal: bool, mention_id: String) -> void:
	var ui := _ui()
	if personal:
		section = "malla"
		mention_id = str(ui.current_profile["mention_id"])
	ui._apply_career_theme(program_id, mention_id)
	var back: Callable = _go.bind("resumen") if personal else ui._show_mentions.bind(program_id)
	var page: VBoxContainer = ui._make_page("Tu malla y sus conexiones" if personal else "Explora el plan de estudios", "", back, false, false, false)
	var headline := _text(page, "", 15)
	var archive := _text(page, "", 13, true)
	archive.name = "GraphApprovedArchive"
	var graph := Graph.new()
	var plan_key := "%s/%s/%s" % [program_id, mention_id, personal]
	graph.branch_view = true
	graph.revealed = _branches_by_plan.get(plan_key, {}).duplicate()
	graph.name = "ExpandedCurriculumGraph"
	graph.font_scale = float(ui.settings["font_scale"])
	graph.animations_enabled = bool(ui.settings["animations"])
	graph.low_performance = bool(ui.settings.get("low_performance", false))
	graph.display_height = 220.0
	graph.retiring = _recent_approvals.duplicate()
	var snapshot: Dictionary = _model().snapshot() if personal else {}
	var approved: Array[Dictionary] = []
	if personal:
		for subject in snapshot["subjects"]:
			if subject.get("program_id", "") != program_id or subject.get("mention_id", "") != mention_id:
				continue
			graph.personal_states[str(subject["sigla"])] = subject_status(subject, snapshot)
			if subject["approved"]:
				approved.append(subject)
			elif _pending_retaking(subject, snapshot):
				graph.carry_subjects.append(subject.duplicate(true))
	graph.setup(program_id, mention_id, 760)
	if personal:
		graph.home_semester = _current_graph_semester(snapshot)
		if graph_term_seen != int(snapshot["term"]):
			graph_semester = graph.home_semester
			graph_term_seen = int(snapshot["term"])
		graph.semester_index = clampi(graph_semester, 0, graph.semesters.size() - 1)
		graph._build_semester()
	var frame := Control.new()
	frame.clip_contents = true
	frame.custom_minimum_size.y = 220
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(frame)
	frame.add_child(graph)
	graph.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_text(page, Graph.BRANCH_GUIDE, 13, true)
	var update := func(_index: int = 0, _count: int = 0) -> void:
		if personal:
			graph_semester = graph.semester_index
		headline.text = "%d materias abiertas%s" % [graph.revealed.size() - 1, " · Ámbar: en curso o por recursar" if personal else ""]
		var earlier := PackedStringArray()
		for subject in approved:
			if int(subject["semester"]) < graph.semester_index + 1:
				earlier.append(str(subject["sigla"]))
		archive.visible = not earlier.is_empty()
		archive.text = "Aprobadas de niveles previos · " + "  ".join(earlier.slice(-5))
		if earlier.size() > 5:
			archive.text += "  ·  %d más" % (earlier.size() - 5)
	graph.subject_selected.connect(func(_sigla: String, data: Dictionary) -> void: _show_subject_sheet(data, graph, snapshot))
	graph.semester_changed.connect(update)
	var save_branches := func() -> void:
		_branches_by_plan[plan_key] = graph.revealed.duplicate()
		update.call()
	graph.branches_changed.connect(save_branches)
	save_branches.call()
	update.call()
	ui._focus_control.call_deferred(weakref(graph))
	_recent_approvals.clear()


func _current_graph_semester(snapshot: Dictionary) -> int:
	var semester := 0
	var first_available := 0
	for subject in snapshot["subjects"]:
		if subject.get("program_id", "") != _ui().current_profile["program_id"] or subject.get("mention_id", "") != _ui().current_profile["mention_id"] or subject.get("graduation_node", false):
			continue
		var level := int(subject.get("semester", 1))
		if not subject["enrollment"].is_empty():
			semester = maxi(semester, level)
		elif not subject["approved"] and subject["eligibility"]["ok"]:
			first_available = level if first_available == 0 else mini(first_available, level)
	return maxi(0, (semester if semester > 0 else first_available) - 1)


func _show_subject_sheet(data: Dictionary, return_focus: Control, snapshot: Dictionary) -> void:
	var ui := _ui()
	if ui.find_child("GraphSubjectPopup", false, false) != null:
		return
	var popup := SubjectPopup.new()
	var details := popup.open(ui, return_focus)
	_text(details, str(data.get("sigla", "")), 14, true)
	_text(details, str(data.get("name", "Ingreso")), 22)
	var description := str(data.get("desc", ""))
	_text(details, description if data.get("admission", false) else description.get_slice(". ", 0).left(220).trim_suffix(".") + ".", 16)
	if data.get("admission", false):
		for mode in data.get("admission_modes", []):
			_text(details, "• " + str(mode), 14, true)
		return
	var glimpse := Glimpse.new()
	glimpse.configure(str(data["sigla"]), ui._current_theme, ui.settings["animations"] and not ui.settings["low_performance"])
	details.add_child(glimpse)
	var requirements: Array = data.get("prereq", [])
	_text(details, "Requisitos · " + (", ".join(requirements) if not requirements.is_empty() else "Sin correlativas"), 14, true)
	for subject in snapshot.get("subjects", []):
		if data.has("enrollment"):
			if subject["id"] != data["id"]:
				continue
		elif subject["sigla"] != data["sigla"] or subject["program_id"] != ui.current_profile["program_id"] or subject["mention_id"] != ui.current_profile["mention_id"]:
			continue
		_text(details, subject_status(subject, snapshot), 16)
		_text(details, str(subject["eligibility"]["message"]), 14, true)
		if not subject["eligibility"].get("regulars", []).is_empty():
			var regulars := PackedStringArray()
			for regular in subject["eligibility"]["regulars"]:
				regulars.append(str(_model().course_data(str(regular)).get("sigla", regular)))
			_text(details, "Regulares obligatorias · " + ", ".join(regulars), 14, true)
		if subject.get("graduation_node", false):
			if snapshot["studies_complete"]:
				_button(details, "Ver graduación", _go.bind("graduacion"), true, true)
			return
		var key := str(subject["id"])
		var entry: Dictionary = subject["enrollment"]
		if snapshot["phase"] == "CURSANDO" and not entry.is_empty() and entry["score"] == null:
			_button(details, "Estudiar y rendir", ui._start_subject.bind(key), true, true)
		elif snapshot["planning_available"] and entry.is_empty() and subject["eligibility"]["ok"] and not subject["approved"]:
			_button(details, "Inscribir", _enroll.bind(key), true, true)
		elif snapshot["planning_available"] and not entry.is_empty() and not subject["approved"]:
			_button(details, "Retirar del semestre", perform.bind("withdraw", [key], "materias"))
		return
