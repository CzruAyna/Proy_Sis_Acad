class_name UtoCurricula
extends RefCounted

const SYSTEMS_COMMON := [
	["FIS 1100|FÍSICA I|INGRESO", "MAT 1100|ÁLGEBRA I|INGRESO", "MAT 1101|CÁLCULO I|INGRESO", "QMC 1100|QUÍMICA GENERAL|INGRESO", "SIS 1110|METODOLOGÍA DE LA PROGRAMACIÓN I|INGRESO"],
	["FIS 1102|FÍSICA II|FIS 1100", "INF 1210|ANÁLISIS DISCRETO|SIS 1110", "MAT 1102|CÁLCULO II|MAT 1101", "MAT 1103|ÁLGEBRA II|MAT 1100", "SIS 2210|METODOLOGÍA DE LA PROGRAMACIÓN II|SIS 1110", "SIS 2220|ANÁLISIS DE BALANCE|QMC 1100"],
	["FIS 1200|FÍSICA III|FIS 1102", "MAT 1135|ESTADÍSTICA I|MAT 1103", "MAT 1207|ECUACIONES DIFERENCIALES I|MAT 1102", "SIS 2310|ESTRUCTURA DE DATOS|INF 1210", "SIS 2320|MODELOS ADMINISTRATIVOS|SIS 2220", "SIS 2330|METODOLOGÍA DE LA PROGRAMACIÓN III|SIS 2210"],
	["INF 2410|ESTRUCTURA DE COMPUTADORES I|FIS 1200", "INF 2430|BASE DE DATOS I|SIS 2320", "MAT 1105|MÉTODOS NUMÉRICOS I|MAT 1207", "MAT 1437|ESTADÍSTICA APLICADA|MAT 1135", "SIS 2420|ACTUALIZACIÓN TECNOLÓGICA|SIS 2310", "SIS 2430|PROGRAMACIÓN GRÁFICA|SIS 2330"]
]

const INFORMATICS_COMMON := [
	["FIS 1100|FÍSICA I|INGRESO", "MAT 1100|ÁLGEBRA I|INGRESO", "MAT 1101|CÁLCULO I|INGRESO", "QMC 1100|QUÍMICA GENERAL|INGRESO", "SIS 1110|METODOLOGÍA DE LA PROGRAMACIÓN I|INGRESO"],
	["FIS 1102|FÍSICA II|FIS 1100", "INF 1210|ANÁLISIS DISCRETO|MAT 1100", "MAT 1102|CÁLCULO II|MAT 1101", "MAT 1103|ÁLGEBRA II|MAT 1100", "MAT 1135|ESTADÍSTICA I|MAT 1101", "SIS 2210|METODOLOGÍA DE LA PROGRAMACIÓN II|SIS 1110"],
	["FIS 1200|FÍSICA III|FIS 1102", "INF 2310|SISTEMAS OPERATIVOS I|INF 1210", "MAT 1207|ECUACIONES DIFERENCIALES I|MAT 1102", "MAT 1437|ESTADÍSTICA APLICADA|MAT 1135", "SIS 2310|ESTRUCTURA DE DATOS|INF 1210", "SIS 2330|METODOLOGÍA DE LA PROGRAMACIÓN III|SIS 2210"],
	["INF 2410|ESTRUCTURA DE COMPUTADORES I|FIS 1200", "INF 2430|BASE DE DATOS I|SIS 2310", "INF 3420|SISTEMAS OPERATIVOS II|INF 2310", "MAT 1105|MÉTODOS NUMÉRICOS I|MAT 1207", "SIS 2420|ACTUALIZACIÓN TECNOLÓGICA|SIS 2330", "SIS 2430|PROGRAMACIÓN GRÁFICA|SIS 2330"],
	["INF 3510|REDES INFORMÁTICAS I|INF 3420", "INF 3520|BASE DE DATOS II|INF 2430", "INF 3530|ESTRUCTURA DE COMPUTADORES II|INF 2410", "MAT 2106|MÉTODOS NUMÉRICOS II|SIS 2420", "SIS 2510|INVESTIGACIÓN OPERATIVA I|MAT 1105", "SIS 2530|ANÁLISIS DE SISTEMAS|INF 2430"]
]

const SYSTEMS_TAIL := {
	"gestion_sistemas": [
		["INF 3510|REDES INFORMÁTICAS I|INF 2410", "MAT 2106|MÉTODOS NUMÉRICOS II|MAT 1105", "SIS 2510|INVESTIGACIÓN OPERATIVA I|MAT 1105", "SIS 2520|SIMULACIÓN DE SISTEMAS|MAT 1437", "SIS 2530|ANÁLISIS DE SISTEMAS|SIS 2420", "SIS 3540|MODELOS ECONOMÉTRICOS|INF 2430"],
		["SIS 2610|INVESTIGACIÓN OPERATIVA II|SIS 2510", "SIS 3620|INGENIERÍA DE SISTEMAS I|SIS 2530", "SIS 3630|DINÁMICA DE SISTEMAS I|SIS 2520", "SIS 3640|PLANIFICACIÓN Y CONTROL DE LA PRODUCCIÓN I|SIS 3540", "SIS 3652|DISEÑO ORGANIZACIONAL|SIS 3540", "SIS 3662|COMERCIO ELECTRÓNICO|INF 3510"],
		["SIS 2740|PROYECTOS DE INGENIERÍA DE SISTEMAS|SIS 3640", "SIS 3720|INGENIERÍA DE SISTEMAS II|SIS 3620", "SIS 3730|EVALUACIÓN DE SISTEMAS|SIS 3630", "SIS 4710|METODOLOGÍA DE LA INVESTIGACIÓN|SIS 2610", "ELEC 1|ELECTIVA 1|"],
		["IND 2212|MARKETING INDUSTRIAL|SIS 3730", "SIS 2820|GESTIÓN DE PROYECTOS|SIS 2740", "SIS 2830|GESTIÓN DE CALIDAD|SIS 3720", "SIS 3810|TALLER DE GRADUACIÓN I|SIS 4710", "SIS 3842|GESTIÓN DE RECURSOS HUMANOS|SIS 3720", "ELEC 2|ELECTIVA 2|"],
		["SIS 3910|TALLER DE GRADUACIÓN II|SIS 3810", "SIS 3930|AUDITORÍA DE SISTEMAS|SIS 2830", "SIS 3952|COMPETITIVIDAD Y PRODUCTIVIDAD|SIS 3842", "SIS 4920|PRÁCTICAS EN LA INDUSTRIA|SIS 2820", "SIS 4940|REALIDAD NACIONAL|SIS 2830"],
		["SIS 5100|GRADUACIÓN|SIS 3910"]
	],
	"gestion_informacion": [
		["INF 3510|REDES INFORMÁTICAS I|INF 2410", "MAT 2106|MÉTODOS NUMÉRICOS II|MAT 1105", "SIS 2510|INVESTIGACIÓN OPERATIVA I|MAT 1105", "SIS 2520|SIMULACIÓN DE SISTEMAS|MAT 1437", "SIS 2530|ANÁLISIS DE SISTEMAS|SIS 2420", "SIS 3540|MODELOS ECONOMÉTRICOS|INF 2430"],
		["INF 3520|BASE DE DATOS II|INF 3510", "SIS 2610|INVESTIGACIÓN OPERATIVA II|SIS 2510", "SIS 3620|INGENIERÍA DE SISTEMAS I|SIS 2530", "SIS 3630|DINÁMICA DE SISTEMAS I|SIS 2520", "SIS 3640|PLANIFICACIÓN Y CONTROL DE LA PRODUCCIÓN I|SIS 3540", "SIS 3651|DISEÑO DE SISTEMAS I|SIS 2530"],
		["INF 3620|REDES INFORMÁTICAS II|SIS 3651", "SIS 2740|PROYECTOS DE INGENIERÍA DE SISTEMAS|SIS 3640", "SIS 3720|INGENIERÍA DE SISTEMAS II|SIS 3620", "SIS 3730|EVALUACIÓN DE SISTEMAS|SIS 3630", "SIS 4710|METODOLOGÍA DE LA INVESTIGACIÓN|SIS 2610", "ELEC 1|ELECTIVA 1|"],
		["SIS 2820|GESTIÓN DE PROYECTOS|SIS 2740", "SIS 2830|GESTIÓN DE CALIDAD|SIS 3720", "SIS 3810|TALLER DE GRADUACIÓN I|SIS 4710", "SIS 3841|DISEÑO DE SISTEMAS II|SIS 3651", "ELEC 2|ELECTIVA 2|"],
		["INF 2720|INGENIERÍA DE SOFTWARE I|SIS 3841", "SIS 3910|TALLER DE GRADUACIÓN II|SIS 3810", "SIS 3930|AUDITORÍA DE SISTEMAS|SIS 2830", "SIS 4920|PRÁCTICAS EN LA INDUSTRIA|SIS 3810", "SIS 4940|REALIDAD NACIONAL|SIS 2830"],
		["SIS 5100|GRADUACIÓN|SIS 3910"]
	],
	"modelamiento_optimizacion": [
		["INF 3510|REDES INFORMÁTICAS I|INF 2410", "MAT 2208|ECUACIONES DIFERENCIALES II|MAT 1207", "SIS 2510|INVESTIGACIÓN OPERATIVA I|MAT 1105", "SIS 2520|SIMULACIÓN DE SISTEMAS|MAT 1437", "SIS 2530|ANÁLISIS DE SISTEMAS|SIS 2420", "SIS 3540|MODELOS ECONOMÉTRICOS|INF 2430"],
		["IND 2202|INGENIERÍA DE MÉTODOS|SIS 2510", "SIS 2610|INVESTIGACIÓN OPERATIVA II|SIS 2510", "SIS 3620|INGENIERÍA DE SISTEMAS I|SIS 2530", "SIS 3630|DINÁMICA DE SISTEMAS I|SIS 2520", "SIS 3640|PLANIFICACIÓN Y CONTROL DE LA PRODUCCIÓN I|SIS 3540", "ELEC 1|ELECTIVA 1|"],
		["SIS 2740|PROYECTOS DE INGENIERÍA DE SISTEMAS|SIS 3640", "SIS 3720|INGENIERÍA DE SISTEMAS II|SIS 3620", "SIS 3730|EVALUACIÓN DE SISTEMAS|SIS 3630", "SIS 3753|INVESTIGACIÓN OPERATIVA III|SIS 2610", "SIS 3763|PLANIFICACIÓN Y CONTROL DE LA PRODUCCIÓN II|SIS 3640", "SIS 4710|METODOLOGÍA DE LA INVESTIGACIÓN|SIS 2610"],
		["SIS 2820|GESTIÓN DE PROYECTOS|SIS 2740", "SIS 2830|GESTIÓN DE CALIDAD|SIS 3720", "SIS 3810|TALLER DE GRADUACIÓN I|SIS 4710", "SIS 3843|INVESTIGACIÓN OPERATIVA IV|SIS 3753", "ELEC 2|ELECTIVA 2|"],
		["ELT 3890|AUTOMÁTICA I|SIS 3843", "SIS 3910|TALLER DE GRADUACIÓN II|SIS 3810", "SIS 3930|AUDITORÍA DE SISTEMAS|SIS 2830", "SIS 4920|PRÁCTICAS EN LA INDUSTRIA|SIS 2820", "SIS 4940|REALIDAD NACIONAL|SIS 2830"],
		["SIS 5100|GRADUACIÓN|SIS 3910"]
	]
}

const INFORMATICS_TAIL := {
	"desarrollo_sw": [
		["INF 2610|TEORÍA DE LA INFORMACIÓN|SIS 2510", "INF 3620|REDES INFORMÁTICAS II|INF 3510", "INF 3631|DISEÑO DE COMPILADORES|INF 3530", "INF 3641|ALGORÍTMICA GENERAL|SIS 2530", "SIS 2520|SIMULACIÓN DE SISTEMAS|SIS 2510", "SIS 3651|DISEÑO DE SISTEMAS I|SIS 2530"],
		["INF 2710|SEGURIDAD DE SISTEMAS INFORMÁTICOS|INF 3620", "INF 2720|INGENIERÍA DE SOFTWARE I|SIS 3651", "INF 3731|INTELIGENCIA ARTIFICIAL I|INF 3631", "INF 3741|TALLER DE DESARROLLO DE SOFTWARE|INF 3641", "SIS 4710|METODOLOGÍA DE LA INVESTIGACIÓN|SIS 2520", "ELEC 1|ELECTIVA 1|"],
		["INF 3811|INGENIERÍA DE SOFTWARE II|INF 2720", "SIS 2740|PROYECTOS DE INGENIERÍA DE SISTEMAS|SIS 4710", "SIS 3810|TALLER DE GRADUACIÓN I|INF 2710", "SIS 3930|AUDITORÍA DE SISTEMAS|INF 3741", "ELEC 2|ELECTIVA 2|"],
		["INF 3911|DESARROLLO DE APLICACIONES WEB|INF 3811", "INF 3920|SISTEMAS DE INFORMACIÓN GEOGRÁFICA|SIS 2740", "SIS 3910|TALLER DE GRADUACIÓN II|SIS 3810", "SIS 4920|PRÁCTICAS EN LA INDUSTRIA|SIS 3810", "SIS 4940|REALIDAD NACIONAL|SIS 2740"],
		["SIS 5100|GRADUACIÓN|SIS 3910"]
	],
	"telematica": [
		["INF 2610|TEORÍA DE LA INFORMACIÓN|SIS 2510", "INF 3620|REDES INFORMÁTICAS II|INF 3510", "INF 3632|SISTEMAS DE TRANSMISIÓN ÓPTICOS|INF 3530", "INF 3642|DISEÑO DE REDES|INF 3510", "SIS 2520|SIMULACIÓN DE SISTEMAS|SIS 2510", "SIS 3651|DISEÑO DE SISTEMAS I|SIS 2530"],
		["INF 2710|SEGURIDAD DE SISTEMAS INFORMÁTICOS|INF 3620", "INF 2720|INGENIERÍA DE SOFTWARE I|SIS 3651", "INF 3732|TALLER DE TELEMÁTICA I|INF 3642", "INF 3742|REDES DE BANDA ANCHA|INF 3632", "SIS 4710|METODOLOGÍA DE LA INVESTIGACIÓN|SIS 2520", "ELEC 1|ELECTIVA 1|"],
		["INF 3812|REDES INFORMÁTICAS III|INF 3732", "INF 3822|COMUNICACIÓN INALÁMBRICA|INF 3742", "SIS 2740|PROYECTOS DE INGENIERÍA DE SISTEMAS|SIS 4710", "SIS 3810|TALLER DE GRADUACIÓN I|INF 2710", "ELEC 2|ELECTIVA 2|"],
		["INF 3912|TALLER DE TELEMÁTICA II|INF 3812", "INF 3920|SISTEMAS DE INFORMACIÓN GEOGRÁFICA|SIS 2740", "SIS 3910|TALLER DE GRADUACIÓN II|SIS 3810", "SIS 4920|PRÁCTICAS EN LA INDUSTRIA|SIS 3810", "SIS 4940|REALIDAD NACIONAL|SIS 2740"],
		["SIS 5100|GRADUACIÓN|SIS 3910"]
	]
}

const TOPIC_DATA := {
	"SIS 1110": ["Algoritmos", "Estructuras de control", "Arreglos"],
	"INF 1210": ["Lógica proposicional", "Relaciones y funciones", "Inducción"],
	"SIS 2210": ["Funciones", "Estructuras", "Archivos"],
	"SIS 2310": ["Listas, pilas y colas", "Árboles", "Grafos y complejidad"],
	"INF 2410": ["Lógica digital", "Unidad central", "Memoria y buses"],
	"INF 2430": ["Modelo entidad-relación", "Modelo relacional y SQL", "Normalización"],
	"INF 3510": ["Capas TCP/IP", "Direccionamiento y subredes", "Enrutamiento"],
	"INF 3520": ["Transacciones", "Concurrencia", "Índices y optimización"],
	"INF 3530": ["Pipeline", "Jerarquía de memoria", "Paralelismo"],
	"INF 3620": ["Protocolos de red", "Enrutamiento", "Servicios de red"],
	"INF 3631": ["Análisis léxico y sintáctico", "Gramáticas", "Generación de código"],
	"INF 3641": ["Diseño de algoritmos", "Complejidad", "Estrategias de resolución"],
	"INF 3632": ["Fibra óptica", "Atenuación y dispersión", "Presupuesto de enlace"],
	"INF 3642": ["Requisitos de red", "Topologías", "Dimensionamiento y validación"],
	"INF 3731": ["Agentes inteligentes", "Búsqueda y resolución de problemas", "Representación del conocimiento"],
	"INF 3741": ["Análisis de requisitos", "Implementación", "Pruebas de software"],
	"INF 3732": ["Servicios telemáticos", "Integración de redes", "Pruebas de comunicación"],
	"INF 3742": ["Acceso de banda ancha", "Capacidad y calidad de servicio", "Redes de acceso"],
	"INF 3811": ["Calidad de software", "Pruebas", "Mantenimiento"],
	"INF 3812": ["Enrutamiento avanzado", "Servicios de red", "Gestión de redes"],
	"INF 3822": ["Medios inalámbricos", "Modulación y propagación", "Planificación de cobertura"],
	"INF 3911": ["Aplicaciones web", "Integración con servicios", "Despliegue"],
	"INF 3912": ["Integración telemática", "Diagnóstico de comunicaciones", "Validación de servicios"],
	"SIS 2520": ["Modelos de simulación", "Variables y eventos", "Validación de escenarios"],
	"SIS 3630": ["Diagramas causales", "Bucles de realimentación", "Comportamiento dinámico"],
	"SIS 3640": ["Planificación de producción", "Control de operaciones", "Indicadores de desempeño"],
	"SIS 3753": ["Modelos de optimización", "Asignación de recursos", "Análisis de sensibilidad"],
	"SIS 3763": ["Programación de producción", "Capacidad y restricciones", "Control de operaciones"],
	"SIS 3843": ["Optimización de sistemas", "Modelos de decisión", "Análisis de escenarios"],
	"ELT 3890": ["Sistemas de control", "Sensores y actuadores", "Respuesta automática"],
	"SIS 3841": ["Arquitectura de sistemas", "Diseño detallado", "Integración y validación"],
	"SIS 3720": ["Enfoque sistémico", "Diseño de soluciones", "Evaluación de alternativas"],
	"SIS 3730": ["Criterios de evaluación", "Indicadores", "Análisis de resultados"],
	"SIS 2740": ["Alcance del proyecto", "Planificación", "Evaluación de riesgos"],
	"SIS 2820": ["Plan de proyecto", "Cronograma", "Seguimiento de entregables"],
	"SIS 2830": ["Gestión de calidad", "Medición de procesos", "Mejora continua"],
	"SIS 3930": ["Controles de sistemas", "Evidencia", "Hallazgos y recomendaciones"],
	"SIS 3651": ["Requisitos del sistema", "Arquitectura", "Prototipos y validación"],
	"INF 2720": ["Ciclo de vida de software", "Diseño", "Calidad y pruebas"],
	"INF 2710": ["Amenazas", "Controles de acceso", "Seguridad de sistemas"],
	"INF 2610": ["Medida de información", "Codificación", "Transmisión"],
	"SIS 2530": ["Levantamiento de requisitos", "Modelado de procesos", "Análisis de sistemas"],
	"SIS 2510": ["Programación lineal", "Método simplex", "Transporte y asignación"],
	"SIS 3620": ["Análisis sistémico", "Diseño de soluciones", "Integración de sistemas"],
	"SIS 2610": ["Modelos de decisión", "Optimización", "Análisis de sensibilidad"],
	"SIS 3540": ["Modelos económicos", "Estimación", "Análisis de relaciones entre variables"],
	"SIS 3652": ["Diseño organizacional", "Estructuras", "Coordinación"],
	"IND 2202": ["Métodos de trabajo", "Estudio de tiempos", "Mejora de operaciones"],
	"IND 2212": ["Mercados industriales", "Segmentación", "Estrategias comerciales"],
	"SIS 3952": ["Competitividad", "Productividad", "Indicadores de desempeño"],
	"SIS 3842": ["Gestión de personas", "Organización del trabajo", "Desarrollo de equipos"],
	"SIS 3662": ["Comercio electrónico", "Procesamiento de pedidos", "Transacciones digitales"],
	"MAT 1100": ["Conjuntos", "Ecuaciones", "Matrices"],
	"MAT 1101": ["Límites", "Derivadas", "Optimización"],
	"MAT 1102": ["Integrales", "Técnicas de integración", "Aplicaciones"],
	"MAT 1103": ["Espacios vectoriales", "Matrices", "Transformaciones lineales"],
	"MAT 1135": ["Estadística descriptiva", "Probabilidad", "Variables aleatorias"],
	"MAT 1207": ["Ecuaciones diferenciales", "Soluciones", "Aplicaciones"],
	"MAT 1105": ["Errores numéricos", "Métodos iterativos", "Interpolación"],
	"MAT 1437": ["Muestreo", "Estimación", "Pruebas de hipótesis"],
	"MAT 2106": ["Métodos numéricos", "Solución aproximada", "Análisis del error"],
	"MAT 2208": ["Ecuaciones diferenciales", "Sistemas de ecuaciones", "Aplicaciones"],
	"FIS 1100": ["Cinemática", "Dinámica", "Trabajo y energía"],
	"FIS 1102": ["Electricidad", "Magnetismo", "Circuitos"],
	"FIS 1200": ["Ondas", "Óptica", "Termodinámica"],
	"QMC 1100": ["Estructura atómica", "Enlace químico", "Estequiometría"],
	"SIS 2220": ["Balances de materia", "Balances con reacción", "Balances de energía"],
	"SIS 2320": ["Organización", "Planificación", "Control administrativo"],
	"SIS 2330": ["Modularidad", "Estructuras de datos", "Programación aplicada"],
	"SIS 2420": ["Evaluación tecnológica", "Herramientas", "Aplicación de tecnología"],
	"SIS 2430": ["Transformaciones gráficas", "Representación", "Interacción"],
	"SIS 4710": ["Problema de investigación", "Metodología", "Diseño del estudio"],
	"SIS 3810": ["Propuesta de grado", "Metodología", "Plan de trabajo"],
	"SIS 3910": ["Desarrollo del proyecto", "Validación", "Presentación de resultados"],
	"SIS 5100": ["Proyecto de grado", "Verificación de resultados", "Defensa"],
	"INF 3920": ["Datos geográficos", "Capas y coordenadas", "Análisis espacial"]
}

const DESCRIPTION_DATA := {
	"SIS 1110": "Descompone un problema en instrucciones finitas. Practica con pseudocódigo, diagramas de flujo, condiciones y ciclos antes de programarlos.",
	"INF 1210": "Usa lógica, conjuntos, relaciones e inducción para expresar reglas y demostrar propiedades de algoritmos y estructuras discretas.",
	"SIS 2210": "Construye programas modulares con funciones, arreglos y archivos. Separa la lógica del problema de la entrada y salida de datos.",
	"SIS 2310": "Organiza datos con listas, pilas, colas, árboles y grafos. Compara su costo para escoger una estructura apropiada.",
	"INF 2410": "Relaciona lógica digital con procesadores, memoria y buses. Sigue cómo se representan y ejecutan instrucciones en una computadora.",
	"INF 2430": "Modela entidades y relaciones, convierte el diseño en tablas y consulta con SQL. La normalización ayuda a evitar inconsistencias.",
	"INF 3510": "Divide redes en capas, calcula subredes IPv4 y configura rutas. Comprueba conectividad con tablas de encaminamiento y diagnóstico.",
	"INF 3520": "Practica transacciones, concurrencia, índices y planes de consulta para mantener consistentes bases de datos con más carga.",
	"INF 3530": "Analiza procesadores, jerarquías de memoria y paralelismo. Compara cómo el pipeline y las cachés cambian la ejecución.",
	"INF 3620": "Estudia protocolos y servicios que conectan equipos y aplicaciones. Examina paquetes y diagnostica problemas de comunicación.",
	"INF 3631": "Construye etapas de un compilador: análisis léxico, gramática, árbol sintáctico y generación de código.",
	"INF 3641": "Diseña algoritmos y compara su complejidad. Contrasta estrategias como dividir y conquistar, programación dinámica y algoritmos voraces.",
	"INF 3632": "Estudia transmisión por fibra óptica, pérdidas y dispersión. Resuelve presupuestos de enlace para estimar su viabilidad.",
	"INF 3642": "Diseña redes desde sus requisitos: elige topología y equipos, estima capacidad y propone pruebas de cobertura y conectividad.",
	"INF 3731": "Representa problemas para resolverlos mediante búsqueda, reglas o conocimiento. Compara soluciones por costo, límites y evidencia.",
	"INF 3741": "Convierte requisitos en software mediante diseño, implementación y pruebas. Usa prototipos y revisiones antes de integrar componentes.",
	"INF 3732": "Integra servicios y redes en una solución telemática. Define cómo se comunican sus partes y prueba el servicio de extremo a extremo.",
	"INF 3742": "Compara tecnologías de banda ancha por capacidad, alcance y calidad de servicio. Estima demanda y localiza cuellos de botella.",
	"INF 3811": "Planifica pruebas y mantenimiento de software. Relaciona criterios de calidad con casos de prueba, incidencias y cambios controlados.",
	"INF 3812": "Administra redes con rutas, servicios y monitoreo. Diagnostica fallos desde la configuración, el tráfico y los registros.",
	"INF 3822": "Analiza propagación, modulación e interferencia en enlaces inalámbricos. Estima cobertura y compara parámetros de transmisión.",
	"INF 3911": "Desarrolla aplicaciones web conectando interfaz, lógica del servidor y almacenamiento. Integra servicios y prueba el despliegue.",
	"INF 3912": "Integra redes telemáticas y verifica protocolos y servicios. Usa mediciones y registros para localizar errores de comunicación.",
	"SIS 2510": "Formula decisiones como modelos lineales con variables, objetivos y restricciones. Resuelve casos con simplex, transporte y asignación.",
	"SIS 2520": "Representa procesos con entidades, eventos y reglas. Ejecuta escenarios y valida los supuestos antes de recomendar cambios.",
	"SIS 2530": "Levanta requisitos y modela procesos para entender un problema organizacional. Produce especificaciones revisables por usuarios y equipo técnico.",
	"SIS 3630": "Modela cambios de sistemas con variables y bucles causales. Simula escenarios para observar efectos, realimentación y retrasos.",
	"SIS 3640": "Planifica producción y controla operaciones con capacidad, inventarios e indicadores. Compara el plan con resultados para detectar desvíos.",
	"SIS 3651": "Define requisitos, arquitectura y prototipos de un sistema. Verifica con usuarios que la solución responda a tareas reales.",
	"SIS 3753": "Plantea modelos de optimización con variables y restricciones. Compara asignaciones y analiza cambios en los supuestos.",
	"SIS 3763": "Programa operaciones según tiempos, capacidad y restricciones. Compara secuencias de producción y ajusta el plan a la demanda.",
	"SIS 3843": "Resuelve decisiones mediante modelos y escenarios. Interpreta resultados y límites antes de recomendar una alternativa.",
	"MAT 1101": "Usa límites y derivadas para describir cambios, calcular tasas y optimizar funciones con interpretación del resultado.",
	"MAT 1102": "Aplica integrales a áreas, volúmenes y movimiento. Comprueba unidades y condiciones al acumular cantidades.",
	"MAT 1207": "Resuelve ecuaciones diferenciales que modelan cambios como crecimiento y movimiento. Formula condiciones iniciales e interpreta soluciones.",
	"MAT 2208": "Modela procesos acoplados con sistemas de ecuaciones diferenciales. Estudia soluciones y estabilidad a lo largo del tiempo.",
	"FIS 1100": "Describe movimiento y fuerzas con vectores, leyes de Newton y energía. Resuelve casos con diagramas y unidades coherentes.",
	"FIS 1102": "Analiza campos eléctricos y magnéticos, potencial y circuitos. Relaciona magnitudes con leyes físicas y verifica unidades.",
	"FIS 1200": "Estudia ondas, óptica y termodinámica con modelos y mediciones. Interpreta gráficas y contrasta predicciones.",
	"QMC 1100": "Relaciona estructura atómica, enlaces y reacciones. Usa proporciones estequiométricas y comprueba la conservación de materia."
}


static func semesters(program_id: String, mention_id: String) -> Array:
	var common: Array = SYSTEMS_COMMON if program_id == "sistemas" else INFORMATICS_COMMON
	var tail_map: Dictionary = SYSTEMS_TAIL if program_id == "sistemas" else INFORMATICS_TAIL
	if not tail_map.has(mention_id):
		return []
	var semester_rows: Array = common.duplicate(true)
	semester_rows.append_array(tail_map[mention_id].duplicate(true))
	var result: Array = []
	for semester_index in range(semester_rows.size()):
		var subjects: Array = []
		for row in semester_rows[semester_index]:
			subjects.append(_subject_from_row(str(row)))
		result.append({"order": semester_index + 1, "name": _semester_name(semester_index + 1), "subjects": subjects})
	return result


static func _subject_from_row(row: String) -> Dictionary:
	var columns := row.split("|", true, 2)
	var sigla := str(columns[0])
	var name := str(columns[1])
	var prerequisite_text := str(columns[2]) if columns.size() > 2 else ""
	var prerequisites: Array = []
	if not prerequisite_text.is_empty():
		prerequisites = prerequisite_text.split(",", false)
	var topics: Array = TOPIC_DATA.get(sigla, [name + " · fundamentos", name + " · aplicación", name + " · integración"])
	var description := str(DESCRIPTION_DATA.get(sigla, "Estudia %s mediante %s. En ejercicios, plantea el problema, elige un procedimiento y revisa el resultado con datos, condiciones o unidades." % [name.to_lower(), ", ".join(topics).to_lower()]))
	return {"sigla": sigla, "name": name, "prereq": prerequisites, "desc": description, "topics": topics.duplicate(true)}


static func _semester_name(order: int) -> String:
	var names := ["PRIMER", "SEGUNDO", "TERCER", "CUARTO", "QUINTO", "SEXTO", "SÉPTIMO", "OCTAVO", "NOVENO", "DÉCIMO"]
	return "%s SEMESTRE" % names[order - 1]
