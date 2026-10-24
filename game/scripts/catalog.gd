class_name UniCatalog
extends RefCounted

const THEME := {
	"sistemas": {"bg": Color("#0f1628"), "panel": Color("#16213e"), "accent": Color("#4d9bff"), "text": Color("#e6edf3"), "sub": Color("#9fb3c8"), "grid": Color("#1f2d4a")},
	"informatica": {"bg": Color("#1a0f14"), "panel": Color("#2a161c"), "accent": Color("#ff4d6d"), "text": Color("#f5e6ea"), "sub": Color("#d9b3bd"), "grid": Color("#3a2028")},
}

const FACULTIES := [
	{"id": "ingenieria", "name": "Facultad de Ingeniería", "description": "Software, sistemas, redes y tecnología.", "programs": ["sistemas", "informatica"]},
]

const PROGRAMS := [
	{
		"id": "sistemas",
		"faculty": "ingenieria",
		"name": "Ingeniería de Sistemas",
		"title": "Ingeniero de Sistemas",
		"summary": "Procesos, información, organización y desarrollo de soluciones basadas en sistemas computacionales.",
		"focus_color": Color("#4d9bff"),
		"description": "Forma profesionales para analizar, modelar, diseñar e implementar soluciones informáticas que apoyan la toma de decisiones y la automatización de procesos en organizaciones.",
		"mentions": [
			{"id": "gestion_sistemas", "name": "Dirección y Gestión de Sistemas Empresariales", "focus": "Gestión, organización y sistemas para empresas.", "activity": "Analizar un proceso organizativo y proponer una solución basada en sistemas."}
		],
		"semesters": [
			{"order": 1, "name": "PRIMER SEMESTRE", "subjects": [
				{"sigla": "FIS 1100", "name": "FÍSICA I", "prereq": ["INGRESO"], "desc": "Cinemática, dinámica, leyes de Newton, trabajo y energía. Base para entender el comportamiento físico aplicable a la ingeniería.", "topics": ["Cinemática", "Dinámica", "Trabajo y energía", "Cantidad de movimiento"]},
				{"sigla": "MAT 1100", "name": "ÁLGEBRA I", "prereq": ["INGRESO"], "desc": "Álgebra elemental, ecuaciones, matrices y fundamentos para el razonamiento matemático.", "topics": ["Conjuntos", "Ecuaciones e inecuaciones", "Matrices", "Sistemas lineales"]},
				{"sigla": "MAT 1101", "name": "CÁLCULO I", "prereq": ["INGRESO"], "desc": "Límites, derivadas y sus aplicaciones al análisis de funciones.", "topics": ["Límites", "Derivadas", "Aplicaciones de la derivada", "Optimización"]},
				{"sigla": "QMC 1100", "name": "QUÍMICA GENERAL", "prereq": ["INGRESO"], "desc": "Estructura atómica, enlace químico, estequiometría y fundamentos de química general.", "topics": ["Átomos y moléculas", "Enlace químico", "Estequiometría", "Soluciones"]},
				{"sigla": "SIS 1110", "name": "METODOLOGÍA DE LA PROGRAMACIÓN I", "prereq": ["INGRESO"], "desc": "Introducción a la lógica, algoritmos y programación estructurada con enfoque a resolución de problemas.", "topics": ["Algoritmos", "Tipos de datos", "Estructuras secuenciales/condicionales/repetitivas", "Arreglos"]}
			]},
			{"order": 2, "name": "SEGUNDO SEMESTRE", "subjects": [
				{"sigla": "FIS 1102", "name": "FÍSICA II", "prereq": ["FIS 1100"], "desc": "Electricidad, magnetismo y fundamentos electromagnéticos.", "topics": ["Electrostática", "Corriente eléctrica", "Magnetismo", "Campos electromagnéticos"]},
				{"sigla": "INF 1210", "name": "ANÁLISIS DISCRETO", "prereq": ["SIS 1110"], "desc": "Lógica matemática, conjuntos, relaciones, funciones y fundamentos discretos para computación.", "topics": ["Lógica proposicional", "Conjuntos", "Relaciones y funciones", "Inducción y recursión"]},
				{"sigla": "MAT 1102", "name": "CÁLCULO II", "prereq": ["MAT 1101"], "desc": "Integrales, técnicas de integración y aplicaciones.", "topics": ["Integral definida/indefinida", "Técnicas de integración", "Aplicaciones", "Integrales impropias"]},
				{"sigla": "MAT 1103", "name": "ÁLGEBRA II", "prereq": ["MAT 1100"], "desc": "Espacios vectoriales, transformaciones lineales y diagonalización.", "topics": ["Espacios vectoriales", "Bases y dimensión", "Transformaciones lineales", "Autovalores y autovectores"]},
				{"sigla": "SIS 2210", "name": "METODOLOGÍA DE LA PROGRAMACIÓN II", "prereq": ["SIS 1110"], "desc": "Programación modular, estructuras de datos básicas y buenas prácticas.", "topics": ["Funciones", "Estructuras", "Archivos", "Manejo de errores"]},
				{"sigla": "SIS 2220", "name": "ANÁLISIS DE BALANCE", "prereq": ["QMC 1100"], "desc": "Balances de materia y energía con enfoque a procesos.", "topics": ["Balances de materia", "Balances con reacción", "Balances de energía", "Sistemas con recirculación"]}
			]},
			{"order": 3, "name": "TERCER SEMESTRE", "subjects": [
				{"sigla": "FIS 1200", "name": "FÍSICA III", "prereq": ["FIS 1102"], "desc": "Óptica, ondas, termodinámica aplicada.", "topics": ["Ondas", "Óptica geométrica/física", "Termodinámica", "Fluidos"]},
				{"sigla": "MAT 1135", "name": "ESTADÍSTICA I", "prereq": ["MAT 1101"], "desc": "Estadística descriptiva, probabilidad y variables aleatorias.", "topics": ["Estadística descriptiva", "Probabilidad", "Distribuciones discretas/continuas", "Teorema central del límite"]},
				{"sigla": "MAT 1207", "name": "ECUACIONES DIFERENCIALES I", "prereq": ["MAT 1102"], "desc": "EDO de primer y segundo orden y aplicaciones.", "topics": ["EDO primer orden", "EDO lineales", "Sistemas", "Aplicaciones a ingeniería"]},
				{"sigla": "SIS 2310", "name": "ESTRUCTURA DE DATOS", "prereq": ["INF 1210"], "desc": "Estructuras lineales y no lineales, algoritmos de búsqueda/ordenamiento.", "topics": ["Listas, pilas, colas", "Árboles", "Grafos", "Complejidad algorítmica"]},
				{"sigla": "SIS 2320", "name": "MODELOS ADMINISTRATIVOS", "prereq": ["SIS 2220"], "desc": "Teoría organizativa, funciones gerenciales y enfoque sistémico.", "topics": ["Organización", "Planificación", "Control", "Enfoque sistémico"]}
			]},
			{"order": 4, "name": "CUARTO SEMESTRE", "subjects": [
				{"sigla": "INF 2410", "name": "ESTRUCTURA DE COMPUTADORES I", "prereq": ["FIS 1200"], "desc": "Arquitectura de computadores, lógica digital y organización.", "topics": ["Sistemas numéricos", "Álgebra booleana", "Circuitos combinacionales/secuenciales", "CPU y memoria"]},
				{"sigla": "INF 2430", "name": "BASE DE DATOS I", "prereq": ["SIS 2320"], "desc": "Modelo relacional, SQL, normalización y diseño de BD.", "topics": ["Modelo entidad-relación", "Álgebra relacional", "SQL", "Normalización"]}
			]},
			{"order": 5, "name": "QUINTO SEMESTRE", "subjects": [
				{"sigla": "INF 2510", "name": "ARQUITECTURA DE COMPUTADORES", "prereq": ["INF 2410"], "desc": "Arquitectura, pipeline, jerarquía de memoria y rendimiento.", "topics": ["ISA", "Pipeline", "Memoria caché", "I/O y rendimiento"]},
				{"sigla": "INF 2520", "name": "BASE DE DATOS II", "prereq": ["INF 2430"], "desc": "Transacciones, concurrencia, optimización y BD avanzadas.", "topics": ["Transacciones", "Bloqueos", "Índices y optimización", "Procedimientos almacenados"]},
				{"sigla": "SIS 2530", "name": "INVESTIGACIÓN OPERATIVA I", "prereq": ["MAT 1135", "SIS 2310"], "desc": "Programación lineal, modelos y métodos cuantitativos.", "topics": ["PL", "Método simplex", "Transporte", "Asignación"]},
				{"sigla": "SIS 2540", "name": "ANÁLISIS Y DISEÑO DE SISTEMAS", "prereq": ["SIS 2310", "SIS 2320"], "desc": "Metodologías, levantamiento, análisis y diseño de sistemas.", "topics": ["Ciclo de vida", "Levantamiento de requisitos", "Casos de uso", "Diagramas UML"]}
			]},
			{"order": 6, "name": "SEXTO SEMESTRE", "subjects": [
				{"sigla": "INF 3610", "name": "SISTEMAS OPERATIVOS", "prereq": ["INF 2510"], "desc": "Procesos, memoria, archivos, sincronización y seguridad.", "topics": ["Procesos e hilos", "Planificación", "Memoria virtual", "Sistemas de archivos"]},
				{"sigla": "INF 3620", "name": "REDES DE COMPUTADORAS I", "prereq": ["INF 2510"], "desc": "Modelos OSI/TCP-IP, direccionamiento, enrutamiento básico.", "topics": ["Capas", "Ethernet/IP", "Subnetting", "Routing básico"]},
				{"sigla": "SIS 3630", "name": "INVESTIGACIÓN OPERATIVA II", "prereq": ["SIS 2530"], "desc": "Modelos probabilísticos, simulación y toma de decisiones.", "topics": ["Teoría de colas", "Simulación", "Árboles de decisión", "Inventarios"]},
				{"sigla": "SIS 3640", "name": "INGENIERÍA DE SOFTWARE I", "prereq": ["SIS 2540"], "desc": "Requisitos, diseño, pruebas y gestión de proyectos SW.", "topics": ["Requisitos", "Arquitectura", "Calidad", "Metodologías ágiles"]},
				{"sigla": "SIS 3650", "name": "DISEÑO DE SISTEMAS I", "prereq": ["SIS 2540"], "desc": "Diseño detallado, arquitectura de aplicaciones y prototipado.", "topics": ["Diseño lógico/físico", "Patrones", "Prototipado", "Documentación"]}
			]},
			{"order": 7, "name": "SEPTIMO SEMESTRE", "subjects": [
				{"sigla": "INF 3710", "name": "REDES DE COMPUTADORAS II", "prereq": ["INF 3620"], "desc": "Enrutamiento avanzado, VLANs, servicios de red.", "topics": ["VLANs", "OSPF/RIP", "ACLs", "Servicios de red"]},
				{"sigla": "INF 3720", "name": "SEGURIDAD INFORMÁTICA", "prereq": ["INF 3620"], "desc": "Criptografía, amenazas, vulnerabilidades y protección.", "topics": ["Amenazas", "Criptografía", "Autenticación", "Seguridad perimetral"]},
				{"sigla": "SIS 3730", "name": "INGENIERÍA DE SOFTWARE II", "prereq": ["SIS 3640"], "desc": "Pruebas, despliegue, mantenimiento y calidad.", "topics": ["Pruebas", "CI/CD", "Mantenimiento", "Gestión de configuración"]},
				{"sigla": "SIS 3740", "name": "SISTEMAS DE INFORMACIÓN", "prereq": ["SIS 3640"], "desc": "SI empresariales, ERP, CRM y alineación estratégica.", "topics": ["SI estratégico", "ERP/CRM", "Gobierno TI", "Arquitectura empresarial"]},
				{"sigla": "SIS 3750", "name": "DISEÑO DE SISTEMAS II", "prereq": ["SIS 3650"], "desc": "Implementación, integración y validación de sistemas.", "topics": ["Integración", "Pruebas de sistema", "Despliegue", "Capacitación"]}
			]},
			{"order": 8, "name": "OCTAVO SEMESTRE", "subjects": [
				{"sigla": "INF 4810", "name": "ADMINISTRACIÓN DE REDES", "prereq": ["INF 3710"], "desc": "Monitoreo, administración, troubleshooting y gestión de red.", "topics": ["SNMP", "Monitoreo", "Resolución de incidencias", "Políticas de red"]},
				{"sigla": "SIS 4820", "name": "AUDITORÍA DE SISTEMAS", "prereq": ["SIS 3740", "INF 3720"], "desc": "Auditoría informática, controles, normativas y riesgos.", "topics": ["Normativas", "Riesgo y control", "Evidencia", "Informe de auditoría"]},
				{"sigla": "SIS 4830", "name": "GESTIÓN DE PROYECTOS INFORMÁTICOS", "prereq": ["SIS 3730"], "desc": "Planificación, alcance, cronograma, costos y seguimiento.", "topics": ["PMI/Ágil", "Alcance", "Cronograma", "Riesgos"]},
				{"sigla": "SIS 4840", "name": "INTELIGENCIA DE NEGOCIOS", "prereq": ["INF 2520", "SIS 3740"], "desc": "Data warehouse, BI, dashboards y toma de decisiones.", "topics": ["ETL", "Modelado dimensional", "KPI", "Visualización"]},
				{"sigla": "SIS 4850", "name": "TALLER DE GRADO I", "prereq": ["SIS 3750"], "desc": "Propuesta de proyecto de grado, anteproyecto y metodología.", "topics": ["Planteamiento", "Marco teórico", "Metodología", "Cronograma"]}
			]},
			{"order": 9, "name": "NOVENO SEMESTRE", "subjects": [
				{"sigla": "SIS 4910", "name": "GESTIÓN EMPRESARIAL", "prereq": ["SIS 4830"], "desc": "Dirección estratégica, liderazgo y gestión organizativa.", "topics": ["Estrategia", "Liderazgo", "Cambio organizativo", "Ética profesional"]},
				{"sigla": "SIS 4920", "name": "SISTEMAS EMPRESARIALES", "prereq": ["SIS 4840"], "desc": "Integración empresarial, procesos y soluciones corporativas.", "topics": ["Procesos empresariales", "Integración", "BPM", "Transformación digital"]},
				{"sigla": "SIS 4930", "name": "ÉTICA PROFESIONAL", "prereq": ["SIS 4820"], "desc": "Ética, responsabilidad profesional, legislación y ejercicio profesional.", "topics": ["Ética", "Responsabilidad", "Propiedad intelectual", "Marco legal"]},
				{"sigla": "SIS 4940", "name": "TALLER DE GRADO II", "prereq": ["SIS 4850"], "desc": "Desarrollo, implementación, pruebas y defensa del proyecto.", "topics": ["Desarrollo", "Pruebas", "Documentación", "Defensa"]}
			]},
		]
	},
	{
		"id": "informatica",
		"faculty": "ingenieria",
		"name": "Ingeniería Informática",
		"title": "Ingeniero Informático",
		"summary": "Computación, redes, sistemas operativos, software y servicios digitales.",
		"focus_color": Color("#ff4d6d"),
		"description": "Forma profesionales para diseñar, desarrollar, implementar y administrar sistemas informáticos, redes, bases de datos y soluciones de software con enfoque a servicios y plataformas digitales.",
		"mentions": [
			{"id": "desarrollo_sw", "name": "Desarrollo de Software", "focus": "Programación, aplicaciones y plataformas digitales.", "activity": "Analizar un problema y proponer una solución aplicativa funcional."}
		],
		"semesters": [
			{"order": 1, "name": "PRIMER SEMESTRE", "subjects": [
				{"sigla": "FIS 1100", "name": "FÍSICA I", "prereq": ["INGRESO"], "desc": "Fundamentos de mecánica aplicados a la computación y sistemas.", "topics": ["Cinemática", "Dinámica", "Trabajo y energía", "Cantidad de movimiento"]},
				{"sigla": "MAT 1100", "name": "ÁLGEBRA I", "prereq": ["INGRESO"], "desc": "Álgebra y fundamentos matemáticos para informática.", "topics": ["Conjuntos", "Ecuaciones", "Matrices", "Sistemas"]},
				{"sigla": "MAT 1101", "name": "CÁLCULO I", "prereq": ["INGRESO"], "desc": "Funciones, límites, derivadas.", "topics": ["Límites", "Derivadas", "Aplicaciones"]},
				{"sigla": "QMC 1100", "name": "QUÍMICA GENERAL", "prereq": ["INGRESO"], "desc": "Fundamentos de química general.", "topics": ["Materia", "Enlace", "Estequiometría"]},
				{"sigla": "SIS 1110", "name": "METODOLOGÍA DE LA PROGRAMACIÓN I", "prereq": ["INGRESO"], "desc": "Lógica, algoritmos y programación estructurada.", "topics": ["Algoritmos", "Secuencial/condicional/repetitivo", "Arreglos"]}
			]},
			{"order": 2, "name": "SEGUNDO SEMESTRE", "subjects": [
				{"sigla": "FIS 1102", "name": "FÍSICA II", "prereq": ["FIS 1100"], "desc": "Electricidad y magnetismo con aplicación a circuitos.", "topics": ["Electrostática", "Corriente", "Magnetismo", "Circuitos básicos"]},
				{"sigla": "INF 1210", "name": "ANÁLISIS DISCRETO", "prereq": ["MAT 1100", "SIS 1110"], "desc": "Lógica, conjuntos, combinatoria y grafos.", "topics": ["Lógica", "Conjuntos", "Combinatoria", "Grafos"]},
				{"sigla": "MAT 1102", "name": "CÁLCULO II", "prereq": ["MAT 1101"], "desc": "Integrales y aplicaciones.", "topics": ["Integrales", "Técnicas", "Aplicaciones"]},
				{"sigla": "MAT 1103", "name": "ÁLGEBRA II", "prereq": ["MAT 1100"], "desc": "Álgebra lineal aplicada a computación.", "topics": ["Espacios vectoriales", "Matrices", "Transformaciones lineales"]},
				{"sigla": "SIS 2210", "name": "METODOLOGÍA DE LA PROGRAMACIÓN II", "prereq": ["SIS 1110"], "desc": "Programación modular y estructuras.", "topics": ["Funciones", "Estructuras", "Punteros básicos", "Archivos"]}
			]},
			{"order": 3, "name": "TERCER SEMESTRE", "subjects": [
				{"sigla": "INF 2310", "name": "SISTEMAS OPERATIVOS I", "prereq": ["INF 1210"], "desc": "Fundamentos de sistemas operativos y gestión de procesos.", "topics": ["Historia/SO", "Procesos", "Planificación", "Recursos"]},
				{"sigla": "MAT 1207", "name": "ECUACIONES DIFERENCIALES I", "prereq": ["MAT 1102"], "desc": "EDO y aplicaciones.", "topics": ["EDO primer/segundo orden", "Aplicaciones"]},
				{"sigla": "SIS 2310", "name": "ESTRUCTURA DE DATOS", "prereq": ["INF 1210"], "desc": "Estructuras de datos y análisis de algoritmos.", "topics": ["Listas", "Pilas/colas", "Árboles", "Grafos", "Ordenamiento/búsqueda"]}
			]},
			{"order": 4, "name": "CUARTO SEMESTRE", "subjects": [
				{"sigla": "INF 2410", "name": "ESTRUCTURA DE COMPUTADORES I", "prereq": ["FIS 1102"], "desc": "Organización y arquitectura de computadores.", "topics": ["Lógica digital", "Unidad central", "Memoria", "Buses"]},
				{"sigla": "INF 2430", "name": "BASE DE DATOS I", "prereq": ["SIS 2310"], "desc": "Diseño relacional, SQL.", "topics": ["MER", "Modelo relacional", "SQL", "Normalización"]},
				{"sigla": "INF 3420", "name": "SISTEMAS OPERATIVOS II", "prereq": ["INF 2310"], "desc": "Memoria virtual, sincronización, archivos y seguridad.", "topics": ["Memoria", "Sincronización", "Sistemas de archivos", "Seguridad SO"]},
				{"sigla": "INF 3520", "name": "BASE DE DATOS II", "prereq": ["INF 2430"], "desc": "Transacciones, PL/SQL, optimización.", "topics": ["Transacciones", "Concurrencia", "Triggers", "Optimización"]},
				{"sigla": "INF 3530", "name": "ESTRUCTURA DE COMPUTADORES II", "prereq": ["INF 2410"], "desc": "Arquitectura avanzada, pipeline, multiprocesamiento.", "topics": ["Pipeline", "Jerarquía de memoria", "Paralelismo", "RISC/CISC"]}
			]},
			{"order": 5, "name": "QUINTO SEMESTRE", "subjects": [
				{"sigla": "INF 3510", "name": "PROGRAMACIÓN ORIENTADA A OBJETOS", "prereq": ["SIS 2310"], "desc": "POO, herencia, polimorfismo, patrones básicos.", "topics": ["Clases/objetos", "Herencia", "Polimorfismo", "Excepciones"]},
				{"sigla": "INF 3540", "name": "REDES DE COMPUTADORAS I", "prereq": ["INF 3530"], "desc": "Fundamentos de redes, TCP/IP.", "topics": ["OSI/TCP-IP", "Direccionamiento", "Subredes", "Aplicaciones"]},
				{"sigla": "INF 3550", "name": "ANÁLISIS Y DISEÑO DE SISTEMAS", "prereq": ["INF 3510"], "desc": "Levantamiento, análisis, UML.", "topics": ["Requisitos", "Casos de uso", "Diagramas", "Prototipo"]},
				{"sigla": "INF 3560", "name": "LENGUAJES DE PROGRAMACIÓN", "prereq": ["INF 3510"], "desc": "Paradigmas, compiladores, intérpretes.", "topics": ["Paradigmas", "Sintaxis/semántica", "Compilación", "Máquinas virtuales"]}
			]},
			{"order": 6, "name": "SEXTO SEMESTRE", "subjects": [
				{"sigla": "INF 3610", "name": "REDES DE COMPUTADORAS II", "prereq": ["INF 3540"], "desc": "Enrutamiento, VLANs, servicios.", "topics": ["Ruteo", "VLAN", "NAT", "Servicios"]},
				{"sigla": "INF 3620", "name": "INGENIERÍA DE SOFTWARE I", "prereq": ["INF 3550"], "desc": "Proceso de software, requisitos, diseño.", "topics": ["Ciclo de vida", "Requisitos", "Arquitectura", "Gestión"]},
				{"sigla": "INF 3630", "name": "PROGRAMACIÓN WEB I", "prereq": ["INF 3510", "INF 3520"], "desc": "HTML, CSS, JS, fundamentos web.", "topics": ["Frontend", "HTTP", "Formularios", "Datos"]},
				{"sigla": "INF 3640", "name": "SISTEMAS DISTRIBUIDOS", "prereq": ["INF 3610"], "desc": "Computación distribuida, RPC, comunicación.", "topics": ["Arquitecturas distribuidas", "Comunicación", "Sincronización", "Tolerancia a fallos"]}
			]},
			{"order": 7, "name": "SEPTIMO SEMESTRE", "subjects": [
				{"sigla": "INF 4710", "name": "SEGURIDAD INFORMÁTICA", "prereq": ["INF 3610"], "desc": "Seguridad, criptografía, ataques y contramedidas.", "topics": ["Criptografía", "Amenazas", "Firewalls", "Auditoría"]},
				{"sigla": "INF 4720", "name": "INGENIERÍA DE SOFTWARE II", "prereq": ["INF 3620"], "desc": "Pruebas, calidad, despliegue.", "topics": ["Pruebas", "QA", "CI/CD", "Mantenimiento"]},
				{"sigla": "INF 4730", "name": "PROGRAMACIÓN WEB II", "prereq": ["INF 3630"], "desc": "Backend, APIs, autenticación, BD web.", "topics": ["Backend", "REST", "Autenticación", "Despliegue"]},
				{"sigla": "INF 4740", "name": "INTELIGENCIA ARTIFICIAL", "prereq": ["INF 3510", "MAT 1207"], "desc": "Búsqueda, heurísticas, fundamentos de IA.", "topics": ["Búsqueda", "Heurísticas", "Conocimiento", "Aprendizaje básico"]}
			]},
			{"order": 8, "name": "OCTAVO SEMESTRE", "subjects": [
				{"sigla": "INF 4810", "name": "ADMINISTRACIÓN DE REDES", "prereq": ["INF 3610"], "desc": "Gestión, monitoreo, configuración avanzada.", "topics": ["Administración", "Monitoreo", "Seguridad de red", "Troubleshooting"]},
				{"sigla": "INF 4820", "name": "DESARROLLO MÓVIL", "prereq": ["INF 4730"], "desc": "Aplicaciones móviles, APIs, UI/UX.", "topics": ["Android/Multiplataforma", "UI", "Datos móviles", "Publicación"]},
				{"sigla": "INF 4830", "name": "GESTIÓN DE PROYECTOS INFORMÁTICOS", "prereq": ["INF 4720"], "desc": "Planificación, seguimiento, SCRUM.", "topics": ["Alcance", "Cronograma", "Riesgos", "Agile"]},
				{"sigla": "INF 4840", "name": "TALLER DE GRADO I", "prereq": ["INF 4720"], "desc": "Anteproyecto de grado.", "topics": ["Propuesta", "Marco teórico", "Metodología"]}
			]},
			{"order": 9, "name": "NOVENO SEMESTRE", "subjects": [
				{"sigla": "INF 4910", "name": "COMPUTACIÓN EN LA NUBE", "prereq": ["INF 4730"], "desc": "Cloud, servicios, despliegue, escalabilidad.", "topics": ["IaaS/PaaS/SaaS", "Contenedores", "Despliegue", "Monitoreo"]},
				{"sigla": "INF 4920", "name": "ÉTICA PROFESIONAL", "prereq": ["INF 4830"], "desc": "Ética, responsabilidad y marco legal.", "topics": ["Ética", "Propiedad intelectual", "Responsabilidad", "Legislación"]},
				{"sigla": "INF 4930", "name": "PRÁCTICAS PROFESIONALES", "prereq": ["INF 4830"], "desc": "Práctica supervisada en entorno real.", "topics": ["Aplicación práctica", "Informe", "Supervisión"]},
				{"sigla": "INF 4940", "name": "TALLER DE GRADO II", "prereq": ["INF 4840"], "desc": "Desarrollo, defensa de proyecto de grado.", "topics": ["Implementación", "Pruebas", "Documentación", "Defensa"]}
			]},
		]
	},
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

static func mentions_for_program(program_id: String) -> Array:
	var program := program_by_id(program_id)
	if program.is_empty(): return []
	var mentions: Array = program.get("mentions", [])
	return mentions.duplicate(true)

static func mention_by_id(program_id: String, mention_id: String) -> Dictionary:
	for mention in mentions_for_program(program_id):
		if mention["id"] == mention_id:
			return mention
	return {}

static func get_theme(program_id: String) -> Dictionary:
	return THEME.get(program_id, THEME["sistemas"])

static func all_subjects(program_id: String) -> Array:
	var program := program_by_id(program_id)
	if program.is_empty(): return []
	var result: Array = []
	for sem in program.get("semesters", []):
		for sub in sem.get("subjects", []):
			var copy: Dictionary = sub.duplicate(true)
			copy["semester"] = sem.get("order", 0)
			copy["semester_name"] = sem.get("name", "")
			result.append(copy)
	return result

static func subject_by_sigla(program_id: String, sigla: String) -> Dictionary:
	for sub in all_subjects(program_id):
		if sub.get("sigla", "") == sigla:
			return sub
	return {}

static func course(program_id: String, course_index: int) -> Dictionary:
	var subjects := all_subjects(program_id)
	if subjects.is_empty() or course_index < 0 or course_index >= subjects.size():
		return {}
	var sub: Dictionary = subjects[course_index].duplicate(true)
	var questions := [
		{"q": "Según el temario de %s, ¿qué concepto es fundamental para iniciar esta unidad?" % sub["name"], "options": ["Identificar definiciones y reglas básicas", "Memorizar nombres sin contexto", "Saltar directamente a resultados"], "answer": 0, "why": "Todo tema parte de sus conceptos fundamentales para luego aplicarlos."},
		{"q": "En %s, ¿qué enfoque es más acertado para resolver un ejercicio tipo?" % sub["name"], "options": ["Leer el enunciado, identificar datos y aplicar el procedimiento", "Adivinar la respuesta sin análisis", "Copiar sin entender los pasos"], "answer": 0, "why": "El método paso a paso permite detectar errores y comprender la solución."},
		{"q": "Para dominar %s, ¿qué actividad refuerza mejor el aprendizaje?" % sub["name"], "options": ["Practicar con ejercicios y verificar resultados", "Solo leer el título de cada tema", "Repasar una sola vez la noche antes"], "answer": 0, "why": "La práctica deliberada con verificación consolida el conocimiento."},
	]
	var partials: Array = []
	for partial_index in range(3):
		var q: Dictionary = questions[partial_index].duplicate(true)
		q["difficulty"] = partial_index + 1
		partials.append(q)
	return {"name": sub["name"], "sigla": sub["sigla"], "semester": sub.get("semester", 0), "desc": sub.get("desc", ""), "topics": sub.get("topics", []), "prereq": sub.get("prereq", []), "partials": partials}
