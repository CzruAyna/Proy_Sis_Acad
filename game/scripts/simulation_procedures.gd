extends RefCounted

const DEFINITIONS := {
	"matricula": {"name": "Matrícula del semestre", "steps": [
		{"office": "Caja", "label": "Presentar comprobante de matrícula", "receipt": "matricula"},
		{"office": "Kardex", "label": "Verificar identidad y registro", "documents": ["ci"]},
		{"office": "Cómputo", "label": "Habilitar matrícula y carnet", "output": "matricula"}
	]},
	"carta": {"name": "Materia por carta", "simulated": true, "steps": [
		{"office": "Dirección de Carrera", "label": "Presentar justificación", "documents": ["matricula", "historial", "formulario"]},
		{"office": "Vicedecanato", "label": "Revisar autorización excepcional"},
		{"office": "Cómputo", "label": "Registrar permiso para esta materia y semestre"}
	]},
	"otra_carrera": {"name": "Materia de otra carrera", "simulated": true, "steps": [
		{"office": "Dirección de origen", "label": "Presentar solicitud justificada", "documents": ["matricula", "historial", "formulario"]},
		{"office": "Dirección de destino", "label": "Aceptar el cursado de la materia"},
		{"office": "Vicedecanato", "label": "Autorizar el cursado excepcional"},
		{"office": "Cómputo", "label": "Registrar autorización temporal"}
	]},
	"mencion": {"name": "Cambio de mención · K-02", "form": "K-02", "steps": [
		{"office": "Dirección de Carrera", "label": "Revisar y firmar K-02", "documents": ["formulario", "matricula"]},
		{"office": "Vicedecanato", "label": "Revisar y firmar el cambio"},
		{"office": "Kardex", "label": "Recibir formulario y carnet", "documents": ["formulario", "carnet"]},
		{"office": "DTIC", "label": "Actualizar mención y reconocer materias comunes"}
	]},
	"carrera": {"name": "Cambio interno de carrera · K-03", "form": "K-03", "steps": [
		{"office": "Dirección de origen", "label": "Revisar y firmar K-03", "documents": ["formulario", "matricula"]},
		{"office": "Dirección de destino", "label": "Aceptar carrera de destino"},
		{"office": "Vicedecanato", "label": "Revisar y firmar el cambio"},
		{"office": "Kardex", "label": "Recibir formulario y carnet", "documents": ["formulario", "carnet"]},
		{"office": "DTIC", "label": "Actualizar carrera y reconocer materias comunes"}
	]},
	"auxiliatura": {"name": "Postulación a auxiliatura", "steps": [
		{"office": "Caja", "label": "Presentar derecho de postulación", "receipt": "auxiliatura"},
		{"office": "Dirección de Carrera", "label": "Revisar matrícula, historial y solicitud", "documents": ["ci", "matricula", "historial", "formulario"]}
	]},
	"trabajo_auxiliar": {"name": "Trabajo de auxiliatura", "simulated": true, "steps": [
		{"office": "Docente", "label": "Revisar y firmar plan de trabajo", "documents": ["plan_aux"], "output": "plan_firmado"},
		{"office": "Coordinación de aulas", "label": "Autorizar aula y horario", "documents": ["plan_firmado"], "output": "permiso_aula"},
		{"office": "Docente", "label": "Realizar actividades de apoyo", "documents": ["permiso_aula"], "requires_sessions": true},
		{"office": "Docente", "label": "Firmar informe de actividades", "output": "informe_aux"},
		{"office": "Dirección de Carrera", "label": "Cerrar actividades y registrar beneficio", "documents": ["informe_aux"]}
	]},
	"excelencia": {"name": "Graduación por excelencia", "steps": [
		{"office": "Dirección de Carrera", "label": "Verificar promedio mayor que 65 y ausencia de reprobaciones", "documents": ["historial", "conclusion"]},
		{"office": "Decanato", "label": "Aprobar graduación sin defensa", "documents": ["solvencia"]},
		{"office": "Caja", "label": "Presentar derecho de titulación", "receipt": "titulo"},
		{"office": "Kardex", "label": "Emitir diploma académico", "output": "diploma"},
		{"office": "Rectorado", "label": "Emitir título", "output": "titulo"}
	]},
	"tesis": {"name": "Graduación por tesis", "steps": [
		{"office": "Dirección de Carrera", "label": "Aprobar perfil de tesis y tutor", "documents": ["conclusion", "perfil"]},
		{"office": "Docente tutor", "label": "Revisar borrador de tesis", "documents": ["borrador"]},
		{"office": "Decanato", "label": "Habilitar defensa de tesis", "documents": ["historial", "solvencia"], "receipt": "defensa"},
		{"office": "Tribunal", "label": "Defender tesis", "requires_defense": true, "output": "acta_defensa"},
		{"office": "Caja", "label": "Presentar derecho de titulación", "receipt": "titulo"},
		{"office": "Kardex", "label": "Emitir diploma académico", "output": "diploma"},
		{"office": "Rectorado", "label": "Emitir título", "output": "titulo"}
	]},
	"proyecto": {"name": "Graduación por proyecto de grado", "steps": [
		{"office": "Dirección de Carrera", "label": "Aprobar perfil del proyecto y tutor", "documents": ["conclusion", "perfil"]},
		{"office": "Docente tutor", "label": "Revisar desarrollo y borrador del proyecto", "documents": ["borrador"]},
		{"office": "Decanato", "label": "Habilitar defensa del proyecto", "documents": ["historial", "solvencia"], "receipt": "defensa"},
		{"office": "Tribunal", "label": "Defender proyecto de grado", "requires_defense": true, "output": "acta_defensa"},
		{"office": "Caja", "label": "Presentar derecho de titulación", "receipt": "titulo"},
		{"office": "Kardex", "label": "Emitir diploma académico", "output": "diploma"},
		{"office": "Rectorado", "label": "Emitir título", "output": "titulo"}
	]}
}


static func definition(kind: String) -> Dictionary:
	return DEFINITIONS.get(kind, {}).duplicate(true)


static func current_step(procedure: Dictionary) -> Dictionary:
	var steps: Array = procedure.get("steps", [])
	var index := int(procedure.get("step", 0))
	if index < 0 or index >= steps.size() or not ["PENDIENTE", "OBSERVADO"].has(procedure.get("status", "")):
		return {}
	return steps[index].duplicate(true)
