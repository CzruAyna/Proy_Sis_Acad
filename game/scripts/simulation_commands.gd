extends RefCounted

const Procedures = preload("res://scripts/simulation_procedures.gd")
const HELP := "F10 abre o cierra la consola de exploración.\n/estado · /materias · /historial · /tramites · /catalogo\n/desbloquear todo\n/inscribir SIGLA · /retirar SIGLA · /iniciar · /cerrar\n/pagar matricula · /pagar historial · /documento historial\n/tramite matricula\n/tramite carta SIGLA | justificación\n/tramite otra_carrera carrera/mencion/SIGLA | justificación\n/tramite mencion MENCION\n/tramite carrera CARRERA | MENCION\n/paso TR-001 · /cancelar TR-001\n/auxiliar SIGLA · /pagar auxiliatura TR-001\n/examen AUX-001\n/documento plan_aux TR-001 · /apoyo TR-001\n/graduacion excelencia · /graduacion tesis · /graduacion proyecto\n/documento solvencia · /documento perfil TR-001 · /documento borrador TR-001\n/pagar defensa TR-001 · /defensa TR-001 · /pagar titulo TR-001\nLos pagos y documentos son simulados; no utilizan importes oficiales."


static func execute(simulation: RefCounted, input: String) -> Dictionary:
	var command := input.strip_edges()
	var parts := command.split(" ", false, 1)
	if parts.is_empty():
		return {"ok": false, "message": "Escribe /ayuda para consultar comandos."}
	var verb := str(parts[0]).to_lower()
	var argument := str(parts[1]).strip_edges() if parts.size() > 1 else ""
	var args := argument.split(" ", false, 1)
	var fields := argument.split("|", true)
	match verb:
		"/ayuda":
			return {"ok": true, "message": HELP}
		"/estado":
			return {"ok": true, "message": describe(simulation)}
		"/materias":
			return {"ok": true, "message": describe_courses(simulation)}
		"/historial":
			var lines: Array[String] = []
			for record in simulation.state["history"]:
				lines.append("Semestre %d · %s · %s · %s" % [int(record["term"]), record["course_id"], str(record["score"]) if record["score"] != null else "nota antigua no disponible", "APROBADA" if record["passed"] else "REPROBADA"])
			return {"ok": true, "message": "\n".join(lines) if not lines.is_empty() else "Todavía no hay semestres cerrados."}
		"/tramites":
			return {"ok": true, "message": describe_procedures(simulation)}
		"/catalogo":
			return {"ok": true, "message": "Planes: " + ", ".join(simulation.plans.keys()) + "\nPara materias externas usa carrera/mencion/SIGLA.\n" + "\n".join(simulation.courses.keys())}
		"/desbloquear":
			if argument.to_lower() == "todo":
				return simulation.unlock_all()
		"/inscribir":
			return simulation.enroll(argument)
		"/retirar":
			return simulation.withdraw(argument)
		"/iniciar":
			return simulation.start_term()
		"/cerrar":
			return simulation.close_term()
		"/pagar":
			if not args.is_empty():
				return simulation.pay(str(args[0]), str(args[1]) if args.size() > 1 else "")
		"/documento":
			if not args.is_empty():
				return simulation.issue_document(str(args[0]), str(args[1]) if args.size() > 1 else "")
		"/paso":
			var request: Dictionary = simulation.procedure(argument)
			var step := Procedures.current_step(request)
			if not step.is_empty():
				return simulation.advance_procedure(argument, str(step["office"]))
			return {"ok": false, "message": "Indica un trámite pendiente de /tramites."}
		"/cancelar":
			return simulation.cancel_procedure(argument)
		"/tramite":
			if args.is_empty():
				return {"ok": false, "message": "Indica el tipo de trámite. Consulta /ayuda."}
			var kind := str(args[0])
			var rest := str(args[1]) if args.size() > 1 else ""
			fields = rest.split("|", true)
			var payload := {}
			if ["carta", "otra_carrera"].has(kind) and fields.size() == 2:
				payload = {"course_id": str(fields[0]).strip_edges(), "reason": str(fields[1]).strip_edges()}
			elif kind == "mencion":
				payload = {"program_id": simulation.profile["program_id"], "mention_id": rest.strip_edges()}
			elif kind == "carrera" and fields.size() == 2:
				payload = {"program_id": str(fields[0]).strip_edges(), "mention_id": str(fields[1]).strip_edges()}
			return simulation.open_procedure(kind, payload)
		"/auxiliar":
			return simulation.apply_assistant(argument)
		"/graduacion":
			if ["excelencia", "tesis", "proyecto"].has(argument):
				return simulation.open_procedure(argument)
		"/examen", "/apoyo", "/defensa":
			return {"ok": true, "message": "Actividad solicitada.", "activity": verb.trim_prefix("/"), "id": argument}
	return {"ok": false, "message": "Comando no reconocido. Escribe /ayuda."}


static func describe(simulation: RefCounted) -> String:
	var state: Dictionary = simulation.state
	var mean: Variant = simulation.average()
	return "Semestre %d · %s\nPlan: %s\nMaterias: %d aprobadas / %d · Carga: %d/%d\nPromedio: %s · Reprobación histórica: %s\nEstudios concluidos: %s · Título emitido: %s\n%s\n%s" % [int(state["term"]), state["phase"], simulation.plan_id(), simulation.profile["passed_subjects"].size(), simulation.curriculum().size(), state["enrollments"].size(), simulation.load_limit(), "%.2f" % float(mean) if mean != null else "sin notas suficientes", "sí" if state["had_failure"] else "no", "sí" if state["studies_complete"] else "no", "sí" if state["graduated"] else "no", simulation.excellence()["message"], describe_procedures(simulation)]


static func describe_courses(simulation: RefCounted) -> String:
	var lines: Array[String] = []
	for subject in simulation.snapshot()["subjects"]:
		var label := "APROBADA" if subject["approved"] else str(subject["eligibility"]["message"])
		if not subject["enrollment"].is_empty():
			label = "INSCRITA · %d/3 parciales" % subject["enrollment"]["answers"].size()
		lines.append("%s · %s · %s" % [subject["sigla"], subject["name"], label])
	return "\n".join(lines)


static func describe_procedures(simulation: RefCounted) -> String:
	var lines: Array[String] = []
	for request in simulation.state["procedures"]:
		var step := Procedures.current_step(request)
		lines.append("%s · %s · %s%s" % [request["id"], request["name"], request["status"], " · %s: %s" % [step["office"], step["label"]] if not step.is_empty() else ""])
	for application in simulation.state["applications"]:
		lines.append("%s · %s · %s" % [application["id"], application["course_id"], application["status"]])
	return "\n".join(lines)
