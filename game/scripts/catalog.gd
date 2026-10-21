class_name UniCatalog
extends RefCounted

const FACULTIES := [
	{"id": "ingenieria", "name": "Facultad de Ingeniería", "description": "Planos, código, máquinas y trabajo de campo.", "programs": ["civil", "sistemas", "informatica", "mecatronica", "minas"]},
	{"id": "economia", "name": "Facultad de Economía", "description": "Números, organizaciones y decisiones con recursos limitados.", "programs": ["economia", "administracion", "contaduria"]},
	{"id": "medicina", "name": "Facultad de Medicina", "description": "Ciencia, cuidado y salud comunitaria.", "programs": ["medicina"]},
	{"id": "derecho", "name": "Facultad de Derecho", "description": "Normas, argumentos y resolución de conflictos.", "programs": ["derecho"]},
]

const PROGRAMS := [
	{"id": "civil", "faculty": "ingenieria", "name": "Ingeniería Civil", "title": "Ingeniero civil", "summary": "Estructuras, materiales y obras que conectan comunidades.", "subjects": ["Lectura de planos", "Materiales de construcción", "Agua y territorio"], "questions": [
		{"q": "En un plano a escala 1:100, ¿qué representa 1 cm en el papel?", "options": ["1 m en la obra", "10 m en la obra", "100 m en la obra"], "answer": 0, "why": "A escala 1:100, cada centímetro representa cien centímetros: un metro."},
		{"q": "¿Para qué sirve una probeta de hormigón en una práctica básica?", "options": ["Estimar su resistencia a compresión", "Medir el caudal de un río", "Comprobar el color de la arena"], "answer": 0, "why": "La probeta permite aplicar una carga controlada y observar la resistencia del material."},
		{"q": "Después de una lluvia, ¿qué dato ayuda a ubicar un punto de acumulación de agua?", "options": ["La pendiente y las cotas del terreno", "El número de ventanas de una vivienda", "La marca del equipo de dibujo"], "answer": 0, "why": "Las cotas y pendientes muestran hacia dónde escurre el agua."},
	]},
	{"id": "sistemas", "faculty": "ingenieria", "name": "Ingeniería de Sistemas", "title": "Ingeniero de sistemas", "summary": "Procesos, software y soluciones para problemas reales.", "subjects": ["Lógica de programación", "Datos y algoritmos", "Procesos y simulación"], "questions": [
		{"q": "Una nota aprueba desde 51 puntos. ¿Qué condición refleja esa regla?", "options": ["nota < 51", "nota >= 51", "nota == 0"], "answer": 1, "why": "El operador >= incluye el 51 y cualquier valor mayor."},
		{"q": "¿Qué estructura funciona como una fila de atención: primero en entrar, primero en salir?", "options": ["Cola", "Pila", "Árbol"], "answer": 0, "why": "Una cola conserva el orden de llegada, como una fila de personas."},
		{"q": "En una simulación de ventanilla, ¿qué datos sirven para estimar la espera?", "options": ["Llegadas y duración de atención", "Color del edificio y clima", "Nombre del sistema operativo"], "answer": 0, "why": "La tasa de llegada y el tiempo de servicio determinan cómo se forma la fila."},
	]},
	{"id": "informatica", "faculty": "ingenieria", "name": "Ingeniería Informática", "title": "Ingeniero informático", "summary": "Computadoras, redes y programas que hacen funcionar servicios.", "subjects": ["Representación de información", "Redes y comunicación", "Sistemas operativos"], "questions": [
		{"q": "¿Cuántos valores distintos puede representar un bit?", "options": ["Dos", "Ocho", "Diez"], "answer": 0, "why": "Un bit representa dos estados, normalmente escritos como 0 y 1."},
		{"q": "¿Qué equipo conecta redes distintas y dirige paquetes entre ellas?", "options": ["Router", "Teclado", "Monitor"], "answer": 0, "why": "El router reenvía paquetes entre redes según sus direcciones."},
		{"q": "¿Qué tarea cumple principalmente un sistema operativo?", "options": ["Gestionar recursos y ofrecer servicios a los programas", "Diseñar todas las páginas web automáticamente", "Reemplazar los componentes físicos"], "answer": 0, "why": "El sistema operativo coordina memoria, procesos, archivos y dispositivos."},
	]},
	{"id": "mecatronica", "faculty": "ingenieria", "name": "Ingeniería Mecatrónica", "title": "Ingeniero mecatrónico", "summary": "Sensores, mecanismos y control trabajando en conjunto.", "subjects": ["Sensores y medición", "Mecanismos básicos", "Control de movimiento"], "questions": [
		{"q": "¿Qué convierte un sensor en una señal que puede usar un controlador?", "options": ["Una magnitud física medida", "Una opinión del operador", "El color del gabinete"], "answer": 0, "why": "El sensor detecta una magnitud como temperatura, distancia o presión y la convierte en señal."},
		{"q": "¿Qué elemento transmite movimiento entre dos ejes mediante dientes?", "options": ["Engranaje", "Fusible", "Termómetro"], "answer": 0, "why": "Los engranajes transmiten movimiento y pueden cambiar velocidad o torque."},
		{"q": "Un robot se pasa del punto objetivo. ¿Qué ajuste conviene revisar primero?", "options": ["La realimentación y la respuesta del controlador", "El color de la carcasa", "La etiqueta del cable de alimentación"], "answer": 0, "why": "La realimentación permite comparar posición real y deseada para corregir el movimiento."},
	]},
	{"id": "minas", "faculty": "ingenieria", "name": "Ingeniería de Minas", "title": "Ingeniero de minas", "summary": "Geología, seguridad y planificación responsable de operaciones.", "subjects": ["Geología de campo", "Ventilación y seguridad", "Planificación minera"], "questions": [
		{"q": "En una salida de campo, ¿qué información ayuda a reconocer una unidad de roca?", "options": ["Minerales, textura y relaciones con otras capas", "El número de vehículos en el camino", "La hora en que se tomó la fotografía"], "answer": 0, "why": "La composición, textura y posición relativa ayudan a describir e interpretar rocas."},
		{"q": "¿Por qué se controla la ventilación en una labor subterránea?", "options": ["Para renovar el aire y reducir contaminantes", "Para aumentar el tamaño de las herramientas", "Para evitar registrar las labores"], "answer": 0, "why": "La ventilación ayuda a mantener condiciones respirables y controlar gases, polvo y calor."},
		{"q": "Antes de cambiar un plan de extracción, ¿qué conviene revisar?", "options": ["Seguridad, estabilidad y datos del yacimiento", "Solo el color del mineral", "El nombre del turno anterior"], "answer": 0, "why": "La decisión debe considerar riesgos de seguridad, estabilidad y evidencia geológica."},
	]},
	{"id": "economia", "faculty": "economia", "name": "Economía", "title": "Economista", "summary": "Incentivos, datos y efectos de decisiones en la sociedad.", "subjects": ["Economía cotidiana", "Oferta y demanda", "Indicadores económicos"], "questions": [
		{"q": "Si usas una tarde para trabajar en vez de estudiar, ¿qué es el costo de oportunidad?", "options": ["El valor de la mejor alternativa que dejaste", "El total de cosas que existen", "Un gasto del mes pasado"], "answer": 0, "why": "El costo de oportunidad es el valor de la mejor opción sacrificada."},
		{"q": "Si aumenta la demanda de un producto y la oferta no cambia, ¿qué suele pasar al precio de equilibrio?", "options": ["Tiende a subir", "Siempre cae a cero", "No puede cambiar"], "answer": 0, "why": "Con oferta fija, una demanda mayor suele presionar el precio hacia arriba."},
		{"q": "¿Qué mide el PIB real de forma aproximada?", "options": ["Producción final ajustada por cambios de precios", "El ingreso exacto de cada familia", "Solo las ventas al exterior"], "answer": 0, "why": "El PIB real separa el cambio en producción del efecto de los precios."},
	]},
	{"id": "administracion", "faculty": "economia", "name": "Administración de Empresas", "title": "Administrador de empresas", "summary": "Organización, personas y proyectos con objetivos claros.", "subjects": ["Planificación", "Personas y equipos", "Operaciones"], "questions": [
		{"q": "¿Para qué sirve definir objetivos antes de repartir tareas?", "options": ["Para orientar acciones y revisar avances", "Para evitar medir resultados", "Para que todo el mundo haga lo mismo"], "answer": 0, "why": "Los objetivos dan dirección y ayudan a evaluar el trabajo."},
		{"q": "Ante un desacuerdo en el equipo, ¿qué facilita una salida de trabajo?", "options": ["Aclarar el objetivo y escuchar a ambas partes", "Buscar culpables sin revisar hechos", "Ignorar el problema"], "answer": 0, "why": "Escuchar las restricciones permite repartir responsabilidades de manera realista."},
		{"q": "Un proceso siempre se demora en el mismo paso. ¿Qué conviene observar?", "options": ["La capacidad y las causas del cuello de botella", "Cambiar el nombre del proceso", "Comprar inventario sin revisar demanda"], "answer": 0, "why": "El cuello de botella limita el flujo y muestra dónde enfocar mejoras."},
	]},
	{"id": "contaduria", "faculty": "economia", "name": "Contaduría Pública", "title": "Contador público", "summary": "Registros, evidencia y lectura responsable de cuentas.", "subjects": ["Ecuación contable", "Costos y registros", "Control y auditoría"], "questions": [
		{"q": "¿Cuál es la ecuación contable básica?", "options": ["Activo = Pasivo + Patrimonio", "Ventas = Inventario + Efectivo", "Gasto = Activo + Impuesto"], "answer": 0, "why": "Los activos se financian con obligaciones y recursos propios."},
		{"q": "En una panadería, la harina usada en cada lote suele ser…", "options": ["Un costo directo de producción", "Un gasto financiero", "Un ingreso diferido"], "answer": 0, "why": "La harina puede asociarse directamente al producto fabricado."},
		{"q": "¿Qué fortalece una revisión contable?", "options": ["Evidencia vinculada al criterio revisado", "Una impresión sin respaldo", "Una cifra aislada sin origen"], "answer": 0, "why": "Las conclusiones deben apoyarse en evidencia pertinente y verificable."},
	]},
	{"id": "medicina", "faculty": "medicina", "name": "Medicina", "title": "Médico", "summary": "Observación, prevención y cuidado centrado en las personas.", "subjects": ["Cuerpo humano", "Salud y prevención", "Razonamiento clínico inicial"], "questions": [
		{"q": "¿Qué sistema transporta oxígeno y nutrientes por el organismo?", "options": ["Circulatorio", "Tegumentario", "Urinario"], "answer": 0, "why": "La sangre circula por el sistema cardiovascular y distribuye oxígeno y nutrientes."},
		{"q": "¿Qué describe mejor la homeostasis?", "options": ["Regular condiciones internas dentro de rangos compatibles con la vida", "Evitar cualquier cambio externo", "Detener el metabolismo al dormir"], "answer": 0, "why": "El cuerpo regula variables internas aunque fluctúen dentro de ciertos límites."},
		{"q": "Una campaña busca evitar una enfermedad antes de que aparezcan síntomas. ¿Qué prioriza?", "options": ["Prevención primaria", "Rehabilitación", "Cuidados paliativos"], "answer": 0, "why": "La prevención primaria actúa antes del inicio de la enfermedad."},
	]},
	{"id": "derecho", "faculty": "derecho", "name": "Derecho", "title": "Abogado", "summary": "Normas, argumentos y respuestas justas a conflictos.", "subjects": ["Normas jurídicas", "Derechos y garantías", "Argumentación"], "questions": [
		{"q": "¿Qué conviene identificar primero al analizar un conflicto jurídico?", "options": ["Hechos y derechos involucrados", "La opinión más popular", "Los datos personales para publicarlos"], "answer": 0, "why": "Un análisis responsable empieza por precisar hechos y derechos relevantes."},
		{"q": "¿Qué papel tiene el acreedor en una obligación?", "options": ["Puede exigir la prestación conforme a la relación jurídica", "Siempre presta el servicio", "No participa en la relación"], "answer": 0, "why": "El acreedor puede exigir al deudor la prestación debida."},
		{"q": "¿Qué fortalece una conclusión jurídica?", "options": ["Vincular hechos probados, normas y razonamiento", "Repetir una conclusión", "Usar solo una frase emotiva"], "answer": 0, "why": "Una conclusión sólida explica cómo se conectan evidencia y norma."},
	]},
]

static func faculty_by_id(faculty_id: String) -> Dictionary:
	for faculty in FACULTIES:
		if faculty["id"] == faculty_id:
			return faculty
	return {}

static func program_by_id(program_id: String) -> Dictionary:
	for program in PROGRAMS:
		if program["id"] == program_id:
			return program
	return {}

static func programs_for_faculty(faculty_id: String) -> Array:
	var result: Array = []
	for program in PROGRAMS:
		if program["faculty"] == faculty_id:
			result.append(program)
	return result

static func course(program_id: String, course_index: int) -> Dictionary:
	var program := program_by_id(program_id)
	if program.is_empty():
		return {}
	var questions: Array = program["questions"]
	var partials: Array = []
	for partial_index in range(3):
		var question: Dictionary = questions[(course_index + partial_index) % questions.size()].duplicate(true)
		question["difficulty"] = partial_index + 1
		partials.append(question)
	return {"name": program["subjects"][course_index], "partials": partials}
