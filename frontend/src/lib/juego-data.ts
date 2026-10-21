export type RoleId = "estudiante" | "auxiliar" | "administrativo" | "decano";

export type Stats = {
  energia: number;
  enfoque: number;
  recursos: number;
  confianza: number;
};

export type Decision = {
  label: string;
  effects: Partial<Stats>;
  outcome: string;
  score?: number;
};

export type Challenge = {
  subject: string;
  topic: string;
  difficulty: 1 | 2 | 3;
  question: string;
  options: string[];
  answer: number;
  explanation: string;
};

export type Career = {
  id: string;
  name: string;
  faculty: string;
  summary: string;
  title: string;
  routes: { id: string; name: string; description: string }[];
  stages: Challenge[];
};

export type SimulationCase = {
  title: string;
  context: string;
  difficulty: 1 | 2 | 3;
  choices: Decision[];
  explanation: string;
};

export const careers: Career[] = [
  {
    id: "sistemas",
    name: "Ingeniería de Sistemas",
    faculty: "Facultad Nacional de Ingeniería",
    summary: "Diseña soluciones, organiza información y mejora procesos con tecnología.",
    title: "Diseñador de sistemas",
    routes: [
      { id: "gestion-empresarial", name: "Dirección y Gestión de Sistemas Empresariales", description: "Organizaciones, productos y decisiones de gestión." },
      { id: "optimizacion", name: "Modelamiento y Optimización de Recursos y Procesos", description: "Modelos, simulación y uso responsable de recursos." },
    ],
    stages: [
      { subject: "Metodología de la Programación I", topic: "Lógica condicional", difficulty: 1, question: "Un programa debe mostrar “aprobado” cuando la nota es al menos 51. ¿Qué condición expresa esa regla?", options: ["nota < 51", "nota >= 51", "nota = 0"], answer: 1, explanation: "La condición nota >= 51 incluye 51 y cualquier valor mayor." },
      { subject: "Álgebra I", topic: "Sistemas de ecuaciones", difficulty: 2, question: "Si x + y = 10 y x = 4, ¿cuánto vale y?", options: ["4", "6", "14"], answer: 1, explanation: "Al reemplazar x por 4, queda 4 + y = 10; por tanto y = 6." },
      { subject: "Estructura de Datos", topic: "Colecciones", difficulty: 2, question: "¿Qué estructura sigue el principio de “el último en entrar es el primero en salir”?", options: ["Pila", "Cola", "Tabla"], answer: 0, explanation: "Una pila usa LIFO: el elemento más reciente se retira primero." },
      { subject: "Simulación de Sistemas", topic: "Variables de un modelo", difficulty: 3, question: "Para estudiar filas de atención, ¿qué dato ayuda directamente a estimar el tiempo de espera?", options: ["La tasa de llegada y el tiempo de servicio", "El color del edificio", "El nombre del sistema operativo"], answer: 0, explanation: "Las llegadas y la duración de atención determinan cómo se forma y cuánto crece la fila." },
    ],
  },
  {
    id: "medicina",
    name: "Medicina",
    faculty: "Ciencias de la Salud",
    summary: "Aprende a observar, razonar y actuar con cuidado centrado en las personas.",
    title: "Cuidador del conocimiento",
    routes: [
      { id: "comunitaria", name: "Salud comunitaria", description: "Prevención, comunicación y trabajo con comunidades." },
      { id: "clinica", name: "Clínica y diagnóstico", description: "Observación, hipótesis y evaluación inicial." },
    ],
    stages: [
      { subject: "Anatomía Humana", topic: "Organización del cuerpo", difficulty: 1, question: "¿Qué sistema transporta oxígeno y nutrientes por el organismo?", options: ["Sistema circulatorio", "Sistema tegumentario", "Sistema urinario"], answer: 0, explanation: "La sangre circula por el sistema cardiovascular y distribuye oxígeno y nutrientes." },
      { subject: "Histología", topic: "Tejidos", difficulty: 2, question: "¿Cuál es una función principal del tejido epitelial?", options: ["Recubrir superficies y formar barreras", "Conducir impulsos eléctricos a larga distancia", "Almacenar minerales en los huesos"], answer: 0, explanation: "El tejido epitelial cubre superficies y participa en protección, absorción y secreción." },
      { subject: "Fisiología", topic: "Homeostasis", difficulty: 2, question: "¿Qué describe mejor la homeostasis?", options: ["Mantener condiciones internas dentro de rangos compatibles con la vida", "Evitar toda variación del ambiente externo", "Detener el metabolismo durante el sueño"], answer: 0, explanation: "La homeostasis regula variables internas, aunque estas fluctúen dentro de límites." },
      { subject: "Medicina Social", topic: "Prevención", difficulty: 3, question: "Una campaña local busca reducir una enfermedad antes de que aparezcan síntomas. ¿Qué nivel prioriza?", options: ["Prevención primaria", "Rehabilitación", "Cuidados paliativos"], answer: 0, explanation: "La prevención primaria actúa antes de que se desarrolle la enfermedad, por ejemplo mediante promoción y vacunación." },
    ],
  },
  {
    id: "derecho",
    name: "Derecho",
    faculty: "Derecho, Ciencias Políticas y Sociales",
    summary: "Interpreta normas, organiza argumentos y busca respuestas justas a conflictos.",
    title: "Defensor de derechos",
    routes: [
      { id: "publico", name: "Derecho público", description: "Instituciones, derechos y relaciones con el Estado." },
      { id: "social", name: "Derecho social", description: "Trabajo, comunidad y protección de las personas." },
    ],
    stages: [
      { subject: "Introducción al Derecho", topic: "Normas jurídicas", difficulty: 1, question: "¿Qué rasgo distingue a una norma jurídica dentro de un sistema legal?", options: ["Puede ser exigible mediante instituciones reconocidas", "Siempre depende de la opinión de una sola persona", "Solo se aplica si está escrita en un contrato privado"], answer: 0, explanation: "Las normas jurídicas forman parte de un ordenamiento institucional y su cumplimiento puede exigirse conforme al procedimiento aplicable." },
      { subject: "Derecho Constitucional", topic: "Garantías", difficulty: 2, question: "Una persona afirma que se vulneró un derecho fundamental. ¿Qué debe hacer primero quien analiza el caso?", options: ["Identificar el derecho, los hechos y la vía de protección aplicable", "Asumir que toda denuncia es falsa", "Publicar los datos personales del caso"], answer: 0, explanation: "El análisis empieza por precisar hechos y derechos y luego identificar la garantía o vía prevista por la normativa vigente." },
      { subject: "Derecho Civil", topic: "Obligaciones", difficulty: 2, question: "En una obligación, ¿qué papel tiene el acreedor?", options: ["Puede exigir la prestación debida conforme a la relación jurídica", "Es siempre la persona que presta el servicio", "No participa en la relación"], answer: 0, explanation: "El acreedor es quien puede exigir el cumplimiento de la prestación al deudor." },
      { subject: "Argumentación Jurídica", topic: "Prueba y razonamiento", difficulty: 3, question: "¿Qué fortalece más una conclusión jurídica?", options: ["Conectar hechos probados con normas pertinentes y explicar el razonamiento", "Repetir una conclusión sin analizar evidencias", "Usar únicamente una frase emotiva"], answer: 0, explanation: "Un argumento claro muestra las evidencias, la norma relevante y el vínculo lógico entre ambas." },
    ],
  },
  {
    id: "economia",
    name: "Economía",
    faculty: "Ciencias Económicas, Financieras y Administrativas",
    summary: "Analiza recursos escasos, incentivos y efectos de decisiones en la sociedad.",
    title: "Analista de decisiones",
    routes: [
      { id: "desarrollo", name: "Desarrollo regional", description: "Producción, empleo y bienestar en el territorio." },
      { id: "finanzas", name: "Economía financiera", description: "Ahorro, inversión y lectura de datos económicos." },
    ],
    stages: [
      { subject: "Introducción a la Economía", topic: "Costo de oportunidad", difficulty: 1, question: "Si una tarde se usa para trabajar en vez de estudiar, ¿qué representa el costo de oportunidad?", options: ["El valor de la mejor alternativa que se dejó de elegir", "La suma de todas las cosas que existen", "El dinero que ya se gastó el mes pasado"], answer: 0, explanation: "El costo de oportunidad es el valor de la mejor alternativa sacrificada al elegir." },
      { subject: "Microeconomía", topic: "Oferta y demanda", difficulty: 2, question: "Si aumenta la demanda de un bien y la oferta no cambia, ¿qué suele ocurrir inicialmente con su precio de equilibrio?", options: ["Aumenta", "Desaparece", "Siempre se reduce a cero"], answer: 0, explanation: "Con oferta constante, un aumento de demanda tiende a elevar el precio de equilibrio." },
      { subject: "Estadística Económica", topic: "Promedios", difficulty: 2, question: "¿Qué medida puede verse más afectada por un valor extremadamente alto?", options: ["La media aritmética", "La mediana", "La categoría más frecuente"], answer: 0, explanation: "La media incorpora el tamaño de cada valor; la mediana suele resistir mejor los extremos." },
      { subject: "Macroeconomía", topic: "Indicadores", difficulty: 3, question: "¿Qué mide principalmente el producto interno bruto real?", options: ["El valor de la producción final ajustado por cambios de precios", "La riqueza de cada hogar por separado", "Solo las ventas al exterior"], answer: 0, explanation: "El PIB real busca medir cambios en producción separándolos del efecto de los precios." },
    ],
  },
  {
    id: "administracion",
    name: "Administración de Empresas",
    faculty: "Ciencias Económicas, Financieras y Administrativas",
    summary: "Coordina equipos, recursos y procesos para que una organización cumpla sus objetivos.",
    title: "Guía de equipos",
    routes: [
      { id: "organizaciones", name: "Gestión organizacional", description: "Personas, estrategia y mejora interna." },
      { id: "emprendimiento", name: "Emprendimiento y proyectos", description: "Propuestas de valor y operaciones sostenibles." },
    ],
    stages: [
      { subject: "Administración General", topic: "Planificación", difficulty: 1, question: "¿Para qué sirve definir objetivos antes de organizar el trabajo?", options: ["Para orientar acciones y evaluar avances", "Para evitar revisar resultados", "Para que todos realicen tareas idénticas"], answer: 0, explanation: "Los objetivos dan dirección y permiten revisar si las acciones producen el resultado esperado." },
      { subject: "Contabilidad Básica", topic: "Ingresos y gastos", difficulty: 2, question: "Una tienda vende más de lo que gasta en un periodo. Antes de impuestos, ¿qué indica la diferencia?", options: ["Un resultado positivo del periodo", "Una deuda automáticamente", "El valor de sus inventarios únicamente"], answer: 0, explanation: "Ingresos menos gastos permite estimar el resultado del periodo antes de otros ajustes." },
      { subject: "Gestión de Personas", topic: "Trabajo en equipo", difficulty: 2, question: "Ante un desacuerdo entre dos integrantes, ¿qué facilita una solución de trabajo?", options: ["Aclarar el objetivo y escuchar las restricciones de ambas partes", "Asignar culpa sin revisar los hechos", "Ignorar el conflicto hasta el cierre"], answer: 0, explanation: "Escuchar y volver al objetivo común ayuda a acordar responsabilidades y próximos pasos." },
      { subject: "Gestión de Operaciones", topic: "Mejora de procesos", difficulty: 3, question: "Un proceso acumula demoras siempre en el mismo paso. ¿Qué conviene observar primero?", options: ["La capacidad y las causas del cuello de botella", "Cambiar el nombre de todo el proceso", "Aumentar inventario sin medir la demanda"], answer: 0, explanation: "Ubicar el cuello de botella permite enfocar cambios donde realmente se limita el flujo." },
    ],
  },
  {
    id: "contaduria",
    name: "Contaduría Pública",
    faculty: "Ciencias Económicas, Financieras y Administrativas",
    summary: "Registra operaciones y convierte información financiera en decisiones transparentes.",
    title: "Custodio de cuentas claras",
    routes: [
      { id: "auditoria", name: "Auditoría y control", description: "Evidencia, revisión y control interno." },
      { id: "tributaria", name: "Gestión tributaria", description: "Registros, cumplimiento y planificación financiera." },
    ],
    stages: [
      { subject: "Contabilidad General", topic: "Ecuación contable", difficulty: 1, question: "¿Cuál es la ecuación contable básica?", options: ["Activo = Pasivo + Patrimonio", "Ventas = Inventario + Efectivo", "Gasto = Activo + Impuesto"], answer: 0, explanation: "La ecuación refleja que los activos se financian con obligaciones y recursos propios." },
      { subject: "Costos", topic: "Costos directos", difficulty: 2, question: "En una panadería, la harina usada directamente en cada lote suele ser…", options: ["Un costo directo de producción", "Un gasto financiero", "Un ingreso diferido"], answer: 0, explanation: "La harina puede asociarse de forma directa al producto fabricado." },
      { subject: "Auditoría", topic: "Evidencia", difficulty: 2, question: "¿Qué aporta evidencia suficiente y pertinente en una revisión?", options: ["Documentos y comprobaciones vinculados al criterio revisado", "Una impresión sin respaldo", "Una cifra aislada sin origen"], answer: 0, explanation: "La evidencia debe relacionarse con el criterio y permitir sustentar las conclusiones." },
      { subject: "Análisis Financiero", topic: "Liquidez", difficulty: 3, question: "¿Qué pregunta ayuda a responder un indicador de liquidez?", options: ["Si la entidad puede cubrir obligaciones próximas con recursos de corto plazo", "Cuánto produce cada trabajador en una década", "Qué marca de equipo prefiere el personal"], answer: 0, explanation: "Los indicadores de liquidez comparan recursos corrientes con obligaciones cercanas." },
    ],
  },
];

export const campusEvents: SimulationCase[] = [
  { title: "Se cruzan dos entregas", context: "Un trabajo grupal coincide con la evaluación de la semana. El equipo no alcanza a preparar todo a la vez.", difficulty: 1, choices: [
    { label: "Dividir tareas y fijar una revisión breve", effects: { enfoque: 8, energia: -4, confianza: 5 }, outcome: "El equipo aclara responsabilidades y detecta a tiempo qué falta." },
    { label: "Hacer todo a última hora sin coordinar", effects: { enfoque: -8, confianza: -5 }, outcome: "El grupo avanza sin coordinación y debe corregir partes repetidas." },
    { label: "Pedir orientación y renegociar el plan", effects: { recursos: -5, enfoque: 6, confianza: 4 }, outcome: "Una consulta a tiempo ayuda a ordenar el esfuerzo disponible." },
  ], explanation: "Planificar en equipo ayuda a repartir esfuerzo, detectar bloqueos y pedir apoyo antes del límite." },
  { title: "Falta material para la práctica", context: "El laboratorio informa que parte del equipo no estará disponible durante la sesión.", difficulty: 2, choices: [
    { label: "Proponer una práctica por turnos y registrar resultados", effects: { enfoque: 8, energia: -6, confianza: 4 }, outcome: "El grupo aprovecha el equipo compartido y conserva datos comparables." },
    { label: "Cancelar sin avisar al equipo", effects: { confianza: -8, enfoque: -4 }, outcome: "Varias personas pierden la sesión y nadie sabe cómo recuperar el trabajo." },
    { label: "Consultar una alternativa equivalente con el docente", effects: { recursos: -4, enfoque: 6 }, outcome: "La consulta permite adaptar la actividad sin cambiar su objetivo." },
  ], explanation: "Un buen ajuste conserva el objetivo de aprendizaje y comunica los cambios con claridad." },
  { title: "Trabajo y estudio compiten por tiempo", context: "Un turno laboral adicional coincide con las horas que habías reservado para preparar una evaluación.", difficulty: 2, choices: [
    { label: "Reorganizar la semana y proteger un bloque corto de estudio", effects: { energia: -4, enfoque: 8, recursos: 3 }, outcome: "El plan se vuelve más realista y deja un espacio concreto para estudiar." },
    { label: "Eliminar todos los descansos", effects: { energia: -12, enfoque: -3 }, outcome: "Ganas tiempo hoy, pero el cansancio puede afectar los próximos días." },
    { label: "Pedir apoyo para ajustar el turno", effects: { recursos: -3, energia: 5, confianza: 4 }, outcome: "Hablar temprano abre opciones para cumplir con ambas responsabilidades." },
  ], explanation: "La planificación sostenible equilibra obligaciones, descanso y apoyo disponible." },
  { title: "La inscripción no coincide con tu avance", context: "El sistema muestra una materia sin registrar un prerrequisito que ya aprobaste.", difficulty: 3, choices: [
    { label: "Verificar el historial y presentar el antecedente por el canal formal", effects: { enfoque: 7, recursos: -2, confianza: 5 }, outcome: "La revisión encuentra el registro que faltaba y deja constancia del caso." },
    { label: "Inscribirte varias veces para forzar el sistema", effects: { confianza: -8, enfoque: -4 }, outcome: "Las solicitudes duplicadas dificultan rastrear el problema." },
    { label: "Consultar con registro académico antes de cerrar el plazo", effects: { energia: -2, confianza: 6, recursos: -2 }, outcome: "El equipo identifica el dato pendiente mientras aún hay tiempo para corregirlo." },
  ], explanation: "Los registros se resuelven mejor verificando evidencia y usando el procedimiento correspondiente." },
  { title: "El grupo entiende distinto la consigna", context: "Al comparar borradores, cada integrante interpretó una parte diferente de la instrucción.", difficulty: 1, choices: [
    { label: "Leer la consigna juntos y acordar criterios", effects: { enfoque: 7, confianza: 6 }, outcome: "El grupo alinea su trabajo y establece una referencia compartida." },
    { label: "Elegir el borrador más avanzado sin revisarlo", effects: { energia: 4, enfoque: -7 }, outcome: "El equipo ahorra tiempo ahora, pero conserva dudas importantes." },
    { label: "Preguntar al docente con una duda concreta", effects: { confianza: 4, recursos: -2, enfoque: 5 }, outcome: "Una pregunta precisa permite confirmar el alcance de la entrega." },
  ], explanation: "Aclarar expectativas antes de producir evita esfuerzo duplicado." },
];

export const roleNames: Record<RoleId, string> = {
  estudiante: "Estudiante",
  auxiliar: "Auxiliar docente",
  administrativo: "Personal administrativo",
  decano: "Decano",
};

export const roleUnlocks: Record<RoleId, string> = {
  estudiante: "Disponible desde el inicio",
  auxiliar: "Completa una carrera como estudiante",
  administrativo: "Completa la ruta de auxiliar docente",
  decano: "Completa la ruta administrativa",
};

export const roleTitles: Record<RoleId, string> = {
  estudiante: "Compañero de generación",
  auxiliar: "Mentor de aula",
  administrativo: "Guardián del registro",
  decano: "Decano de la comunidad",
};

export const roleCases: Record<Exclude<RoleId, "estudiante">, SimulationCase[]> = {
  auxiliar: [
    { title: "Una pregunta que nadie se anima a hacer", context: "En la práctica, varias personas se traban en el mismo paso y el grupo se queda en silencio.", difficulty: 1, choices: [
      { label: "Resolver el paso y explicar cómo comprobarlo", effects: { enfoque: 6, confianza: 5 }, outcome: "El grupo observa el procedimiento y una forma de verificarlo.", score: 88 },
      { label: "Preguntar qué parte genera la duda y dar una pista", effects: { confianza: 8, energia: -2 }, outcome: "La pista permite que el grupo complete el razonamiento.", score: 100 },
      { label: "Continuar como si todo estuviera claro", effects: { enfoque: -6, confianza: -8 }, outcome: "La duda sigue presente y se acumula para el siguiente tema.", score: 35 },
    ], explanation: "Acompañar el razonamiento y verificar comprensión favorece que el grupo aprenda con autonomía." },
    { title: "Dos respuestas distintas", context: "Dos estudiantes llegan a resultados diferentes y ambos muestran parte del procedimiento.", difficulty: 2, choices: [
      { label: "Comparar supuestos y revisar cada paso", effects: { enfoque: 8, confianza: 4 }, outcome: "La comparación detecta el punto donde los caminos divergen.", score: 100 },
      { label: "Elegir la respuesta que parece más rápida", effects: { confianza: -3 }, outcome: "El grupo obtiene una respuesta, pero no revisa si el método es válido.", score: 45 },
      { label: "Pedir que expliquen su razonamiento al grupo", effects: { confianza: 7, energia: -3 }, outcome: "La explicación permite que sus pares evalúen los procedimientos.", score: 88 },
    ], explanation: "Enseñar también significa hacer visible el razonamiento y los supuestos usados." },
    { title: "Una práctica se queda sin tiempo", context: "El primer ejercicio tomó más de lo previsto y quedan dos actividades por revisar.", difficulty: 2, choices: [
      { label: "Priorizar el objetivo central y dejar una guía para continuar", effects: { enfoque: 7, energia: 2 }, outcome: "La práctica conserva su propósito y el grupo sabe qué sigue.", score: 100 },
      { label: "Acelerar la explicación sin preguntar", effects: { energia: -4, confianza: -4 }, outcome: "Se cubre más contenido, aunque no se confirma qué entendió el grupo.", score: 50 },
      { label: "Extender la sesión sin consultar", effects: { energia: -8, confianza: -5 }, outcome: "Algunas personas deben retirarse y la actividad pierde continuidad.", score: 35 },
    ], explanation: "Priorizar el aprendizaje central y dejar una continuación clara ayuda a manejar el tiempo." },
    { title: "Una respuesta incorrecta en la pizarra", context: "Una estudiante resuelve un problema frente al grupo y comete un error intermedio.", difficulty: 3, choices: [
      { label: "Señalar el error con respeto y reconstruir el paso", effects: { confianza: 8, enfoque: 6 }, outcome: "El error se convierte en una oportunidad para revisar el método.", score: 100 },
      { label: "Reemplazarla de inmediato sin explicarlo", effects: { enfoque: 1, confianza: -8 }, outcome: "La pizarra queda corregida, pero el grupo no ve por qué.", score: 45 },
      { label: "Preguntar al grupo cómo comprobar el resultado", effects: { confianza: 7, enfoque: 5 }, outcome: "La revisión colectiva ayuda a ubicar el paso que requiere ajuste.", score: 88 },
    ], explanation: "La retroalimentación respetuosa ayuda a aprender del error sin desalentar la participación." },
  ],
  administrativo: [
    { title: "Una inscripción con datos duplicados", context: "Una estudiante aparece dos veces en la lista de una materia y el cupo está completo.", difficulty: 1, choices: [
      { label: "Verificar identidad, historial y fecha de solicitud antes de corregir", effects: { enfoque: 7, confianza: 5 }, outcome: "La revisión permite corregir el registro con trazabilidad.", score: 100 },
      { label: "Borrar una fila sin comprobar cuál es válida", effects: { confianza: -8 }, outcome: "La lista cambia, pero podría perderse información legítima.", score: 30 },
      { label: "Pedir a la estudiante que vuelva otro día", effects: { energia: 3, confianza: -6 }, outcome: "El problema queda abierto y la estudiante no conoce el siguiente paso.", score: 45 },
    ], explanation: "Verificar la fuente y dejar rastro de la corrección protege a la persona y la integridad del registro." },
    { title: "Prerrequisito aprobado que no aparece", context: "El historial físico indica una aprobación, pero la plataforma todavía no la refleja.", difficulty: 2, choices: [
      { label: "Contrastar acta y código de materia antes de actualizar", effects: { enfoque: 8, recursos: -2 }, outcome: "La comparación identifica el acta correcta y permite documentar el ajuste.", score: 100 },
      { label: "Habilitar la inscripción sin guardar evidencia", effects: { confianza: -5 }, outcome: "La estudiante avanza, pero el registro sigue sin sustento verificable.", score: 40 },
      { label: "Derivar el caso con los antecedentes completos", effects: { energia: -2, confianza: 5 }, outcome: "El caso llega al área competente con la información necesaria.", score: 88 },
    ], explanation: "Un ajuste académico debe apoyarse en el antecedente correcto y quedar trazable." },
    { title: "Dos grupos piden la misma aula", context: "Un cambio de horario generó una colisión entre una práctica y una evaluación.", difficulty: 2, choices: [
      { label: "Revisar capacidades, prioridades y alternativas con las áreas", effects: { enfoque: 6, confianza: 6 }, outcome: "El nuevo horario considera restricciones y comunica el cambio a ambos grupos.", score: 100 },
      { label: "Asignar el aula al grupo que llegó primero", effects: { confianza: -6 }, outcome: "Una parte del horario se resuelve, pero la otra queda sin espacio.", score: 40 },
      { label: "Cancelar ambas actividades", effects: { energia: 3, confianza: -8 }, outcome: "Se evita el choque, aunque se pierde tiempo académico innecesariamente.", score: 30 },
    ], explanation: "La coordinación de horarios debe equilibrar capacidad, propósito y comunicación oportuna." },
    { title: "Una constancia con un nombre distinto", context: "La solicitud de un certificado no coincide con el documento de identidad presentado.", difficulty: 3, choices: [
      { label: "Confirmar el dato con la persona y corregir la fuente autorizada", effects: { enfoque: 8, confianza: 5 }, outcome: "La corrección parte de un dato validado antes de emitir el documento.", score: 100 },
      { label: "Emitir el certificado con uno de los nombres al azar", effects: { confianza: -8 }, outcome: "El documento podría salir con un error difícil de subsanar.", score: 25 },
      { label: "Explicar qué antecedente falta y cómo presentarlo", effects: { confianza: 6, recursos: -2 }, outcome: "La persona conoce el requisito pendiente y puede completar el trámite.", score: 88 },
    ], explanation: "La precisión documental y una explicación clara evitan errores que afectan a la persona." },
  ],
  decano: [
    { title: "Cupos insuficientes en una materia clave", context: "La demanda supera la capacidad disponible y la materia es necesaria para avanzar en varias carreras.", difficulty: 2, choices: [
      { label: "Analizar demanda, docentes y aulas antes de ampliar paralelos", effects: { enfoque: 8, recursos: -3 }, outcome: "La decisión de capacidad se apoya en datos y recursos reales.", score: 100 },
      { label: "Abrir paralelos sin confirmar disponibilidad", effects: { recursos: -8, confianza: -3 }, outcome: "Aumenta la oferta, pero faltan condiciones para sostenerla.", score: 40 },
      { label: "Publicar criterios de prioridad y planificar una solución", effects: { confianza: 7, enfoque: 5 }, outcome: "La comunidad conoce los criterios mientras se trabaja en una alternativa.", score: 88 },
    ], explanation: "Una respuesta académica sostenible combina datos de demanda, capacidad y comunicación justa." },
    { title: "Presupuesto reducido para laboratorios", context: "El presupuesto no alcanza para reponer todos los equipos solicitados este periodo.", difficulty: 3, choices: [
      { label: "Priorizar seguridad, uso y continuidad formativa con criterios públicos", effects: { enfoque: 8, confianza: 6, recursos: -2 }, outcome: "La inversión se ordena por impacto y se explican las prioridades.", score: 100 },
      { label: "Repartir el dinero por igual sin revisar necesidades", effects: { recursos: -4, enfoque: -3 }, outcome: "La distribución parece pareja, pero podría dejar equipos críticos sin resolver.", score: 55 },
      { label: "Postergar todas las compras sin informar", effects: { confianza: -8, recursos: 3 }, outcome: "Se conserva presupuesto, pero los laboratorios no pueden planificar.", score: 30 },
    ], explanation: "Priorizar con criterios transparentes permite cuidar seguridad, aprendizaje y recursos." },
    { title: "Un conflicto interrumpe las clases", context: "Estudiantes y docentes discrepan sobre una evaluación y piden una decisión inmediata.", difficulty: 2, choices: [
      { label: "Escuchar a las partes, revisar las reglas y acordar un proceso", effects: { confianza: 8, enfoque: 6 }, outcome: "La comunidad conoce un procedimiento claro para resolver el desacuerdo.", score: 100 },
      { label: "Tomar partido antes de revisar los antecedentes", effects: { confianza: -8 }, outcome: "La decisión aumenta la tensión y puede ignorar información relevante.", score: 25 },
      { label: "Suspender indefinidamente la evaluación", effects: { energia: 2, confianza: -4 }, outcome: "El conflicto se aplaza, pero también la planificación del curso.", score: 45 },
    ], explanation: "La autoridad académica debe sostener reglas claras, escucha y un proceso imparcial." },
    { title: "La carrera necesita actualizar su plan", context: "Docentes, estudiantes y egresados proponen cambios distintos para responder a nuevas necesidades.", difficulty: 3, choices: [
      { label: "Convocar revisión con evidencia, objetivos y participación de la comunidad", effects: { enfoque: 8, confianza: 7 }, outcome: "Las propuestas se comparan con necesidades y resultados formativos.", score: 100 },
      { label: "Cambiar materias de inmediato por votación informal", effects: { confianza: -3, enfoque: -4 }, outcome: "Se toman decisiones rápido, pero sin revisar requisitos ni impactos.", score: 40 },
      { label: "Mantener todo igual para evitar discusión", effects: { recursos: 2, confianza: -6 }, outcome: "Se evita el debate, aunque quedan necesidades sin atender.", score: 35 },
    ], explanation: "Actualizar un plan requiere propósito, evidencia y participación de quienes lo viven." },
  ],
};

export const teacherProfiles = [
  { name: "Prof. Rojas", style: "guía clara", modifier: 5 },
  { name: "Lic. Salvatierra", style: "evaluación metódica", modifier: 0 },
  { name: "Ing. Quispe", style: "reto exigente", modifier: -5 },
  { name: "Dra. Flores", style: "aprendizaje aplicado", modifier: 3 },
];

export const roleOrder: RoleId[] = ["estudiante", "auxiliar", "administrativo", "decano"];
