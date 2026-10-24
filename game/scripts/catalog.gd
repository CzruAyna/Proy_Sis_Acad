class_name UniCatalog
extends RefCounted

const Curricula = preload("res://scripts/uto_curricula.gd")

const THEME := {
	"sistemas": {"bg": Color("#0f1628"), "panel": Color("#16213e"), "accent": Color("#4d9bff"), "text": Color("#e6edf3"), "sub": Color("#9fb3c8"), "grid": Color("#1f2d4a")},
	"informatica": {"bg": Color("#1a0f14"), "panel": Color("#2a161c"), "accent": Color("#ff4d6d"), "text": Color("#f5e6ea"), "sub": Color("#d9b3bd"), "grid": Color("#3a2028")},
}

const QUIZ_BANK := {
	"SIS 1110": [
		{"q": "Un algoritmo es una secuencia de pasos para resolver un problema. ¿Qué condición ayuda a que sea ejecutable?", "options": ["Definir entradas, operaciones y una salida para cada caso previsto", "Usar nombres de variables largos", "Repetir pasos sin una condición de término"], "answer": 0, "why": "Los pasos deben ser claros, finitos y producir un resultado a partir de los datos."},
		{"q": "Una beca se concede si el promedio es al menos 70 y hay documentos completos. ¿Qué condición representa la regla?", "options": ["promedio >= 70 Y documentos_completos", "promedio >= 70 O documentos_completos", "promedio < 70 Y no documentos_completos"], "answer": 0, "why": "La conjunción exige que se cumplan las dos condiciones."},
		{"q": "Un arreglo guarda 8 notas y sus posiciones empiezan en cero. ¿Cuál es el último índice válido?", "options": ["7", "8", "9"], "answer": 0, "why": "Con ocho elementos indexados desde cero, las posiciones van de 0 a 7."}
	],
	"INF 1210": [
		{"q": "La proposición P es verdadera y Q es falsa. ¿Qué valor tiene P ∧ Q?", "options": ["Falso", "Verdadero", "No se puede evaluar"], "answer": 0, "why": "La conjunción solo es verdadera cuando ambas proposiciones lo son."},
		{"q": "Una relación asigna a cada estudiante exactamente un código. ¿Qué propiedad debe cumplir para ser función?", "options": ["Cada entrada tiene una única salida asociada", "Cada salida debe corresponder a una sola entrada", "Las entradas no pueden repetirse"], "answer": 0, "why": "Una función asigna exactamente una salida a cada elemento del dominio."},
		{"q": "Para demostrar que una afirmación vale para todo entero n desde 1, ¿qué estrategia usa inducción matemática?", "options": ["Probar el caso base y demostrar que el caso n implica n+1", "Comprobar solo n=1 y asumir el resto", "Probar varios valores y concluir sin un paso general"], "answer": 0, "why": "La inducción requiere un caso inicial y un paso inductivo que cubra el siguiente valor."}
	],
	"SIS 2210": [
		{"q": "¿Qué ventaja ofrece separar un programa en funciones pequeñas?", "options": ["Cada función puede resolver y probar una tarea delimitada", "El programa deja de necesitar datos de entrada", "Todas las variables se vuelven globales"], "answer": 0, "why": "La modularidad reduce responsabilidades mezcladas y facilita probar cada parte."},
		{"q": "Una función calcula el total y otra lo muestra. ¿Qué debería entregar la primera a la segunda?", "options": ["El total mediante un valor de retorno o una estructura de salida definida", "La pantalla completa", "Una copia de todas las variables del programa"], "answer": 0, "why": "Una interfaz de función comunica explícitamente el resultado que produjo."},
		{"q": "Al leer un archivo que podría no existir, ¿qué práctica evita que el programa termine inesperadamente?", "options": ["Comprobar el resultado de apertura y manejar el error", "Suponer que siempre está presente", "Leer memoria aunque la apertura falle"], "answer": 0, "why": "La operación debe validar errores y ofrecer una respuesta segura cuando el archivo falta."}
	],
	"SIS 2310": [
		{"q": "En una cola de atención FIFO, ¿a quién se atiende primero?", "options": ["A quien llegó primero", "A quien llegó último", "A quien tenga el dato más corto"], "answer": 0, "why": "FIFO conserva el orden de llegada: primero en entrar, primero en salir."},
		{"q": "En un árbol binario de búsqueda, ¿dónde se ubican normalmente las claves menores que un nodo?", "options": ["En su subárbol izquierdo", "En su subárbol derecho", "Siempre en una lista separada"], "answer": 0, "why": "La regla de orden coloca claves menores a la izquierda y mayores a la derecha."},
		{"q": "Una ruta conecta ciudades y cada camino tiene costo. ¿Qué estructura representa naturalmente esta red?", "options": ["Un grafo ponderado", "Una pila de llamadas", "Una tabla de dispersión sin relaciones"], "answer": 0, "why": "Los vértices representan ciudades, las aristas las rutas y sus pesos los costos."}
	],
	"INF 2410": [
		{"q": "¿Qué salida produce una compuerta AND cuando sus dos entradas son 1?", "options": ["1", "0", "Depende del reloj"], "answer": 0, "why": "La compuerta AND entrega 1 únicamente cuando todas sus entradas son 1."},
		{"q": "¿Qué almacena temporalmente un registro del procesador?", "options": ["Un valor que la CPU necesita usar de inmediato", "Todos los archivos del usuario de forma permanente", "La señal de internet"], "answer": 0, "why": "Los registros son almacenamiento muy pequeño y rápido dentro del procesador."},
		{"q": "Si la CPU debe transferir datos entre memoria y un dispositivo, ¿qué componente coordina ese intercambio?", "options": ["El sistema de entrada/salida y sus controladores", "La tabla de verdad de una compuerta", "El formato de una imagen"], "answer": 0, "why": "La arquitectura de entrada/salida comunica al procesador con los dispositivos."}
	],
	"INF 2430": [
		{"q": "En un modelo entidad-relación de matrícula, ¿qué representa una entidad?", "options": ["Un tipo de objeto del dominio, como Estudiante o Materia", "Una consulta SQL ya ejecutada", "Un índice del disco"], "answer": 0, "why": "Las entidades modelan objetos o conceptos sobre los que se almacenan datos."},
		{"q": "¿Qué consulta obtiene solo las columnas nombre y código de la tabla Materia?", "options": ["SELECT nombre, codigo FROM Materia", "DELETE nombre, codigo FROM Materia", "UPDATE Materia SET nombre, codigo"], "answer": 0, "why": "SELECT elige columnas y FROM indica la tabla consultada."},
		{"q": "¿Qué busca una normalización adecuada del esquema relacional?", "options": ["Reducir duplicación y anomalías de inserción, cambio o borrado", "Guardar todos los datos en una sola columna", "Eliminar las claves que conectan tablas"], "answer": 0, "why": "La normalización organiza dependencias para reducir inconsistencias y anomalías."}
	],
	"INF 3530": [
		{"q": "¿Qué define la arquitectura del conjunto de instrucciones (ISA)?", "options": ["La interfaz de instrucciones visible para el software y soportada por el procesador", "El tamaño físico del gabinete", "La lista de usuarios del sistema operativo"], "answer": 0, "why": "La ISA describe instrucciones, registros y comportamiento que el software puede usar."},
		{"q": "¿Por qué una caché puede acelerar el acceso a memoria?", "options": ["Mantiene cerca datos usados recientemente o con alta probabilidad de reutilizarse", "Guarda una copia de cada archivo sin límite", "Aumenta la frecuencia de la red"], "answer": 0, "why": "La localidad temporal y espacial permite reutilizar datos desde una memoria más rápida."},
		{"q": "Un programa espera continuamente por la memoria principal. ¿Qué cambio podría reducir esa espera?", "options": ["Mejorar la localidad de acceso para aprovechar la caché", "Añadir más instrucciones que no se usan", "Cambiar el nombre de las variables"], "answer": 0, "why": "Accesos con buena localidad aumentan la probabilidad de aciertos en caché."}
	],
	"INF 3520": [
		{"q": "¿Qué propiedad ACID evita que una transacción quede aplicada a medias?", "options": ["Atomicidad", "Aislamiento", "Durabilidad"], "answer": 0, "why": "Atomicidad hace que la transacción se confirme completa o se revierta."},
		{"q": "Dos transacciones modifican a la vez el mismo saldo. ¿Qué mecanismo ayuda a controlar la concurrencia?", "options": ["Bloqueos o control de concurrencia transaccional", "Duplicar las filas antes de cada consulta", "Desactivar las restricciones de integridad"], "answer": 0, "why": "El control de concurrencia coordina operaciones simultáneas para evitar resultados inconsistentes."},
		{"q": "Una consulta filtra muchas filas por el mismo campo y tarda demasiado. ¿Qué objeto puede ayudar, si el patrón de uso lo justifica?", "options": ["Un índice adecuado sobre ese campo", "Una vista sin filtro", "Un trigger que repita la consulta"], "answer": 0, "why": "Un índice puede acelerar búsquedas selectivas, aunque también agrega costo de almacenamiento y actualización."}
	],
	"SIS 3651": [
		{"q": "Antes de diseñar una pantalla para inscribir materias, ¿qué debe aclararse con estudiantes y registro?", "options": ["Qué necesitan hacer, qué reglas aplican y qué restricciones existen", "El color de todos los botones", "Qué lenguaje de programación prefiere cada usuario"], "answer": 0, "why": "El levantamiento identifica necesidades, reglas y límites antes de proponer una solución."},
		{"q": "En un caso de uso de inscripción, ¿quién es un actor?", "options": ["Una persona o sistema externo que interactúa con el sistema", "Una tabla interna de notas", "Una línea de código privada"], "answer": 0, "why": "Los actores representan roles externos que usan o intercambian información con el sistema."},
		{"q": "¿Qué describe principalmente un diagrama de clases UML?", "options": ["Clases, atributos, operaciones y relaciones estructurales", "El orden exacto de clics de una pantalla", "El tráfico físico de una red"], "answer": 0, "why": "El diagrama de clases muestra la estructura estática del modelo de software."}
	],
	"INF 3420": [
		{"q": "¿Qué representa un proceso en un sistema operativo?", "options": ["Un programa en ejecución junto con su estado y recursos asignados", "Un archivo comprimido sin ejecutar", "Una conexión física de red"], "answer": 0, "why": "El sistema operativo administra procesos, su estado de ejecución y sus recursos."},
		{"q": "En round-robin, ¿qué ocurre cuando un proceso agota su quantum y no ha terminado?", "options": ["Vuelve a la cola de listos para recibir otro turno", "Se elimina siempre del sistema", "Bloquea a todos los demás procesos"], "answer": 0, "why": "Round-robin reparte CPU por turnos y reencola procesos que siguen listos."},
		{"q": "¿Qué permite la memoria virtual?", "options": ["Dar a cada proceso un espacio de direcciones y trasladar páginas entre RAM y almacenamiento", "Eliminar la necesidad de memoria física", "Convertir automáticamente cada archivo en proceso"], "answer": 0, "why": "La memoria virtual abstrae y administra espacios de direcciones; no sustituye la RAM."}
	],
	"INF 3620": [
		{"q": "¿Qué identifica una dirección IP en una red?", "options": ["Una interfaz o destino lógico para enrutar paquetes", "El nombre del archivo que se transmite", "La contraseña del router"], "answer": 0, "why": "La dirección IP permite identificar destinos y encaminar paquetes entre redes."},
		{"q": "¿Qué servicio ofrece TCP a una aplicación?", "options": ["Un flujo ordenado y confiable con control de retransmisión", "Entrega sin conexión y sin comprobar pérdidas", "Asignación automática de direcciones IP"], "answer": 0, "why": "TCP ofrece una conexión con entrega ordenada y mecanismos de recuperación de pérdida."},
		{"q": "Un router recibe un paquete para otra red. ¿Qué consulta para decidir el siguiente salto?", "options": ["Su tabla de enrutamiento", "La tabla de archivos del equipo de destino", "El historial del navegador"], "answer": 0, "why": "La tabla de rutas relaciona prefijos de destino con el siguiente salto o interfaz de salida."}
	],
	"SIS 3640": [
		{"q": "Una línea produce 40 piezas por hora y recibe pedidos de 36 por hora. ¿Qué dato debe revisar el equipo antes de aumentar producción?", "options": ["Capacidad efectiva, inventario y variabilidad de la demanda", "Solo el color de las máquinas", "El promedio de notas del personal"], "answer": 0, "why": "La planificación debe contrastar capacidad y demanda y considerar la variación del proceso."},
		{"q": "Una estación limita la salida de toda la línea. ¿Qué intervención conviene analizar primero?", "options": ["Medir su carga y probar cómo cambiaría el flujo al reducir la restricción", "Acelerar todas las estaciones sin medir el resultado", "Aumentar el inventario delante de cada puesto"], "answer": 0, "why": "El cuello de botella marca el ritmo del sistema y debe analizarse con datos de flujo."},
		{"q": "¿Qué indicador ayuda a comparar la producción real con la producción planificada durante un turno?", "options": ["Un indicador de cumplimiento del plan", "La cantidad de colores usados en el tablero", "El número de reuniones del mes"], "answer": 0, "why": "Comparar lo ejecutado con el plan permite detectar desvíos y actuar sobre sus causas."}
	],
	"INF 3510": [
		{"q": "¿Para qué sirve el modelo TCP/IP al estudiar una comunicación?", "options": ["Organiza funciones de red en capas con responsabilidades distintas", "Asigna una nota a cada dispositivo", "Reemplaza las direcciones de destino"], "answer": 0, "why": "La separación en capas ayuda a entender protocolos y ubicar fallos."},
		{"q": "Una red IPv4 usa /24. ¿Cuántos bits quedan para identificar hosts?", "options": ["8", "24", "32"], "answer": 0, "why": "Un prefijo /24 deja 32−24, es decir 8 bits para la parte de host."},
		{"q": "Un servidor responde a ping dentro de la LAN, pero no a un nombre de dominio. ¿Qué componente revisarías primero?", "options": ["La resolución DNS", "El tamaño de la pantalla", "La dirección MAC del teclado"], "answer": 0, "why": "Si hay conectividad IP pero falla el nombre, DNS es una de las primeras comprobaciones."}
	],
	"SIS 2530": [
		{"q": "Una usuaria dice: ‘quiero que la inscripción sea más fácil’. ¿Qué pregunta ayuda a convertirlo en un requisito útil?", "options": ["¿Qué tarea intenta completar y cómo sabremos que quedó más fácil?", "¿Qué color de monitor tiene?", "¿Cuántos archivos hay en su escritorio?"], "answer": 0, "why": "Un requisito debe vincular la necesidad con un resultado observable y verificable."},
		{"q": "¿Qué muestra un caso de uso?", "options": ["Cómo un actor alcanza un objetivo usando el sistema", "La distribución de memoria del servidor", "La secuencia eléctrica de un procesador"], "answer": 0, "why": "Los casos de uso describen interacciones desde la perspectiva de un actor y sus objetivos."},
		{"q": "Un prototipo de baja fidelidad se usa temprano. ¿Qué conviene validar con él?", "options": ["El flujo y la comprensión de la propuesta antes de construirla", "El rendimiento final con miles de usuarios", "La seguridad criptográfica de producción"], "answer": 0, "why": "Un prototipo temprano permite detectar problemas de interacción antes de invertir en implementación."}
	],
	"INF 3631": [
		{"q": "¿Qué distingue la sintaxis de la semántica de un lenguaje?", "options": ["La sintaxis define forma válida; la semántica, el significado de esa forma", "La sintaxis es la velocidad y la semántica es el tamaño", "Ambas significan únicamente el nombre del lenguaje"], "answer": 0, "why": "Un programa puede estar bien escrito sintácticamente y aun así tener un significado incorrecto."},
		{"q": "¿Qué suele hacer un compilador?", "options": ["Traducir un programa a otra representación y reportar errores detectables", "Asignar direcciones IP a sus usuarios", "Crear automáticamente los requisitos del sistema"], "answer": 0, "why": "Un compilador traduce código y verifica aspectos del lenguaje durante ese proceso."},
		{"q": "Una máquina virtual ejecuta bytecode. ¿Qué aporta esta representación intermedia?", "options": ["Permite ejecutar programas mediante un entorno de ejecución definido", "Evita que el programa necesite instrucciones", "Convierte el bytecode en un diagrama UML"], "answer": 0, "why": "El bytecode separa el código fuente del conjunto de instrucciones físico y lo ejecuta una VM."}
	],
	"INF 3911": [
		{"q": "¿Qué función cumplen HTML y CSS en una página web sencilla?", "options": ["HTML estructura el contenido y CSS presenta su apariencia", "CSS guarda registros y HTML enruta paquetes", "HTML cifra contraseñas automáticamente"], "answer": 0, "why": "HTML describe la estructura del documento y CSS controla su presentación."},
		{"q": "¿Qué método HTTP se usa normalmente para solicitar la representación de un recurso sin modificarlo?", "options": ["GET", "DELETE", "PATCH"], "answer": 0, "why": "GET solicita una representación y se define para una lectura segura del recurso."},
		{"q": "Un formulario contiene datos de una materia. ¿Qué debe hacer la aplicación antes de usarlos?", "options": ["Validar el formato y las reglas también en el servidor", "Confiar solo en que el navegador los aceptó", "Insertarlos directamente como código ejecutable"], "answer": 0, "why": "La validación del servidor protege reglas de negocio aunque la validación visual se omita."}
	],
	"INF 3812": [
		{"q": "¿Qué separa una VLAN en una red conmutada?", "options": ["Un dominio lógico de capa 2 dentro de la infraestructura compartida", "Una copia física del router", "Un canal de audio"], "answer": 0, "why": "Las VLAN segmentan redes lógicas sin exigir un switch físico separado para cada grupo."},
		{"q": "¿Qué intercambia OSPF entre routers para calcular rutas dentro de un sistema autónomo?", "options": ["Información de estado de enlace", "Contraseñas de usuarios finales", "Archivos adjuntos de correo"], "answer": 0, "why": "OSPF distribuye estados de enlace y calcula rutas con el algoritmo SPF."},
		{"q": "Una ACL debe bloquear una subred invitada y conservar el acceso de administración. ¿Qué revisarías antes de aplicarla?", "options": ["Orden de reglas, origen, destino y efecto sobre los flujos permitidos", "Solo el nombre de la VLAN", "La cantidad de iconos del tablero"], "answer": 0, "why": "Las ACL se evalúan según reglas y orden; una regla mal ubicada puede bloquear más tráfico del previsto."}
	],
	"INF 2710": [
		{"q": "¿Por qué una contraseña almacenada no debería guardarse como texto plano?", "options": ["Una filtración expondría directamente las credenciales reutilizables", "El texto plano ocupa demasiada pantalla", "La base de datos no admite letras"], "answer": 0, "why": "Se almacenan verificadores derivados con funciones adecuadas y sal, no la contraseña original."},
		{"q": "¿Qué logra la autenticación multifactor?", "options": ["Añade pruebas de categorías distintas a la contraseña", "Hace que todos usen la misma contraseña", "Elimina la necesidad de verificar identidades"], "answer": 0, "why": "Combinar factores distintos reduce el impacto de que solo uno sea comprometido."},
		{"q": "¿Qué debe hacer un firewall con una conexión que no coincide con una regla permitida?", "options": ["Aplicar la política predeterminada definida para ese tráfico", "Reenviarla siempre a todos los equipos", "Convertirla en una copia de seguridad"], "answer": 0, "why": "El filtrado aplica reglas explícitas y una política por defecto para el resto del tráfico."}
	],
	"INF 3731": [
		{"q": "¿Qué hace una búsqueda en anchura (BFS) en un grafo no ponderado?", "options": ["Explora por niveles y encuentra caminos con menor número de aristas", "Elige siempre la arista más cara", "Ordena nodos por nombre"], "answer": 0, "why": "BFS visita vecinos por distancia en aristas y encuentra caminos mínimos en grafos no ponderados."},
		{"q": "En A*, ¿qué representa la heurística h(n)?", "options": ["Una estimación del costo restante desde n hasta la meta", "El costo ya recorrido desde el inicio", "La lista completa de vecinos del nodo"], "answer": 0, "why": "A* combina el costo acumulado g(n) con una estimación h(n) del costo pendiente."},
		{"q": "Para clasificar correos en categorías a partir de ejemplos etiquetados, ¿qué tarea de aprendizaje es?", "options": ["Aprendizaje supervisado", "Búsqueda en anchura", "Compilación de código"], "answer": 0, "why": "El aprendizaje supervisado ajusta un modelo usando ejemplos con respuestas conocidas."}
	],
	"SIS 2520": [
		{"q": "En una simulación de una fila, ¿qué representa el tiempo entre llegadas?", "options": ["El intervalo entre la llegada de una persona y la siguiente", "La duración total del semestre", "La cantidad de servidores disponibles"], "answer": 0, "why": "El tiempo entre llegadas permite modelar cuándo ingresan nuevas entidades al sistema."},
		{"q": "¿Por qué se valida un modelo de simulación frente a datos observados?", "options": ["Para comprobar que representa razonablemente el sistema que se desea estudiar", "Para asegurar que todos los escenarios den el mismo resultado", "Para eliminar la variabilidad del sistema real"], "answer": 0, "why": "La validación contrasta el comportamiento del modelo con el sistema de referencia."},
		{"q": "Al comparar dos configuraciones de una operación con demanda variable, ¿qué conviene hacer?", "options": ["Probar varias corridas y comparar resultados bajo condiciones equivalentes", "Escoger una corrida favorable de cada configuración", "Cambiar los supuestos entre alternativas"], "answer": 0, "why": "Repeticiones y condiciones equivalentes ayudan a distinguir diferencias del ruido aleatorio."}
	],
	"SIS 3630": [
		{"q": "En dinámica de sistemas, ¿qué representa un bucle de realimentación?", "options": ["Una cadena de relaciones donde un cambio vuelve a influir en una variable del sistema", "Una lista de materias sin dependencias", "Un registro que solo guarda una fecha"], "answer": 0, "why": "La realimentación describe cómo los efectos de una variable retornan e influyen en otras variables."},
		{"q": "Si más retraso produce más trabajo pendiente y eso genera aún más retraso, ¿qué comportamiento aparece?", "options": ["Un ciclo reforzador", "Una relación sin dependencia", "Una salida constante garantizada"], "answer": 0, "why": "El cambio inicial se amplifica cuando las relaciones del ciclo refuerzan la misma tendencia."},
		{"q": "¿Qué ayuda a estudiar cómo evoluciona un sistema a lo largo del tiempo?", "options": ["Definir variables, relaciones y condiciones iniciales y observar sus trayectorias", "Mirar una sola cifra sin contexto temporal", "Eliminar todas las relaciones causales"], "answer": 0, "why": "El análisis dinámico requiere observar estados y relaciones durante un horizonte temporal."}
	],
	"SIS 3652": [
		{"q": "¿Qué describe un organigrama organizacional?", "options": ["Relaciones formales de autoridad y coordinación entre áreas o cargos", "La lista de datos de una base relacional", "El orden de instrucciones de un algoritmo"], "answer": 0, "why": "El organigrama representa cómo se distribuyen formalmente roles y dependencias."},
		{"q": "Dos áreas duplican el mismo trabajo por límites de responsabilidad poco claros. ¿Qué conviene revisar?", "options": ["Funciones, responsabilidades y puntos de coordinación", "El tamaño de los monitores", "La cantidad de correos enviados"], "answer": 0, "why": "Aclarar roles y coordinación ayuda a evitar vacíos y duplicaciones organizacionales."},
		{"q": "Al cambiar una estructura organizacional, ¿qué efecto debe analizarse además del organigrama?", "options": ["Cómo cambia el flujo de decisiones y comunicación", "Solo el nombre de las oficinas", "La cantidad de colores del documento"], "answer": 0, "why": "La estructura afecta quién decide, cómo circula la información y cómo se coordinan procesos."}
	],
	"SIS 3662": [
		{"q": "En comercio electrónico, ¿qué paso confirma normalmente la compra antes de procesar el pago?", "options": ["Validar el pedido, disponibilidad y datos de la transacción", "Publicar la contraseña del cliente", "Borrar el inventario antes de revisar el pedido"], "answer": 0, "why": "La plataforma debe verificar la consistencia del pedido y de la transacción antes de confirmarla."},
		{"q": "¿Qué protege una conexión HTTPS durante una compra?", "options": ["La comunicación entre cliente y servicio frente a lectura o alteración en tránsito", "La entrega física del producto", "La exactitud de la descripción comercial"], "answer": 0, "why": "TLS protege el canal de comunicación; no garantiza por sí solo la legitimidad del vendedor."},
		{"q": "Una tienda muestra existencias desactualizadas y acepta pedidos que no puede cumplir. ¿Qué integración revisarías?", "options": ["La sincronización entre inventario, pedidos y confirmación de compra", "La tipografía de la página", "El historial de navegación del comprador"], "answer": 0, "why": "Los estados de inventario y pedido deben mantenerse coordinados para evitar ventas imposibles."}
	],
	"SIS 3753": [
		{"q": "En programación lineal, ¿qué representa una restricción?", "options": ["Un límite o condición que deben respetar las variables de decisión", "El valor de la función objetivo en todos los casos", "Una variable que no participa en el modelo"], "answer": 0, "why": "Las restricciones definen la región factible de soluciones del modelo."},
		{"q": "Si se dispone de horas limitadas para dos proyectos y cada uno aporta distinto beneficio, ¿qué modelo ayuda a asignarlas?", "options": ["Un modelo de optimización con variables, límites y objetivo definidos", "Una lista de tareas sin capacidad ni objetivo", "Un promedio de los nombres de los proyectos"], "answer": 0, "why": "El modelo formaliza decisiones, recursos escasos y el criterio que se quiere optimizar."},
		{"q": "¿Qué pregunta responde un análisis de sensibilidad?", "options": ["Cómo cambia la solución cuando varían parámetros del modelo", "Qué nombre es más corto", "Si todos los datos deben permanecer fijos para siempre"], "answer": 0, "why": "La sensibilidad muestra qué tan dependiente es la decisión de cambios en los datos."}
	],
	"SIS 3763": [
		{"q": "¿Qué expresa la capacidad de una estación de producción?", "options": ["Cuánto trabajo puede procesar bajo condiciones y periodo definidos", "El costo total de todas las materias", "La cantidad de reuniones de planificación"], "answer": 0, "why": "La capacidad depende de recursos, tiempos y condiciones operativas del proceso."},
		{"q": "Un plan carga más trabajo que las horas disponibles en una máquina. ¿Qué ocurre?", "options": ["El programa no es factible hasta ajustar capacidad, secuencia o carga", "La máquina completa el excedente automáticamente", "La demanda deja de existir"], "answer": 0, "why": "Un plan debe respetar las restricciones de capacidad para poder ejecutarse."},
		{"q": "¿Qué dato permite dar seguimiento a una orden durante la producción?", "options": ["Su estado, cantidad y avance por las operaciones", "El color de la sala", "La ubicación del comedor"], "answer": 0, "why": "El control compara el avance real de las órdenes con la secuencia prevista."}
	],
	"SIS 3843": [
		{"q": "Si el objetivo es minimizar costo sin dejar de cumplir una demanda mínima, ¿qué se define en el modelo?", "options": ["Variables de decisión, función de costo y restricciones de demanda", "Solo una lista de resultados deseados", "Una tabla sin unidades ni relaciones"], "answer": 0, "why": "El modelo requiere expresar la decisión, el objetivo y las condiciones de factibilidad."},
		{"q": "¿Qué representa una solución factible?", "options": ["Una asignación que satisface todas las restricciones del modelo", "Siempre la mejor solución posible", "Cualquier conjunto de números elegido al azar"], "answer": 0, "why": "La factibilidad verifica las restricciones; la optimalidad compara el objetivo entre soluciones factibles."},
		{"q": "Un parámetro de disponibilidad cambia. ¿Qué revisión es apropiada?", "options": ["Actualizar el modelo y comparar la decisión con el nuevo valor", "Conservar la solución sin revisar las restricciones", "Eliminar la función objetivo"], "answer": 0, "why": "Los cambios en datos pueden modificar factibilidad y resultados óptimos."}
	],
	"ELT 3890": [
		{"q": "En un lazo de control, ¿qué compara el controlador para corregir el proceso?", "options": ["La medición actual con el valor de referencia", "El nombre del operador con el del equipo", "La cantidad de cables con el tamaño del tablero"], "answer": 0, "why": "El error entre referencia y medición guía la acción de control."},
		{"q": "¿Qué elemento convierte una señal de control en una acción física sobre el proceso?", "options": ["Un actuador", "Un diagrama de flujo", "Una tabla de datos"], "answer": 0, "why": "El actuador modifica el proceso, por ejemplo abriendo una válvula o moviendo un motor."},
		{"q": "Un sensor tiene mucho ruido. ¿Qué efecto puede causar en un control automático?", "options": ["Decisiones inestables o movimientos innecesarios del actuador", "La desaparición de las variables del proceso", "El aumento automático de la precisión"], "answer": 0, "why": "El ruido de medición puede propagarse al control y afectar la respuesta del sistema."}
	],
	"INF 3632": [
		{"q": "¿Qué guía una señal óptica dentro de una fibra?", "options": ["El núcleo y el revestimiento con propiedades que permiten confinamiento de la luz", "El protocolo HTTP", "Un índice de base de datos"], "answer": 0, "why": "La diferencia de propiedades ópticas entre núcleo y revestimiento permite guiar la señal."},
		{"q": "¿Qué indica la atenuación en un enlace de fibra?", "options": ["La pérdida de potencia de la señal a lo largo del medio", "El número de usuarios conectados", "El tamaño de un paquete IP"], "answer": 0, "why": "La atenuación reduce la potencia recibida y debe considerarse en el presupuesto del enlace."},
		{"q": "Si la potencia recibida queda bajo la sensibilidad del receptor, ¿qué problema aparece?", "options": ["El enlace puede no mantener una recepción confiable", "La red cambia de fibra a cobre sin equipo", "Los datos se vuelven automáticamente más rápidos"], "answer": 0, "why": "El presupuesto óptico debe dejar margen suficiente entre potencia transmitida y sensibilidad de recepción."}
	],
	"INF 3642": [
		{"q": "¿Qué determina principalmente una topología de red?", "options": ["Cómo se conectan los nodos y por qué caminos circula el tráfico", "El orden alfabético de los usuarios", "La forma de las ventanas del edificio"], "answer": 0, "why": "La topología describe conexiones y rutas posibles entre componentes."},
		{"q": "Al diseñar una red para un edificio, ¿qué información necesitas antes de dimensionarla?", "options": ["Usuarios, aplicaciones, cobertura, capacidad y restricciones físicas", "Solo el color de los cables", "El modelo de teclado de cada oficina"], "answer": 0, "why": "El diseño debe responder a necesidades y límites reales del sitio y de sus servicios."},
		{"q": "¿Qué conviene verificar en una propuesta de red antes de instalarla?", "options": ["Que cubra requisitos, capacidad, seguridad y puntos de falla", "Que cada equipo tenga la misma marca", "Que las rutas sean las más largas"], "answer": 0, "why": "La validación compara el diseño con los requisitos y riesgos de operación."}
	],
	"INF 3732": [
		{"q": "¿Qué se integra en un servicio telemático?", "options": ["Procesamiento de información y comunicación a través de redes", "Solo un archivo impreso", "Únicamente la alimentación eléctrica"], "answer": 0, "why": "Los servicios telemáticos combinan tecnologías de información y telecomunicación."},
		{"q": "Un servicio funciona en la LAN pero falla desde otra red. ¿Qué frontera revisarías?", "options": ["Direccionamiento, encaminamiento y reglas de acceso entre redes", "El formato de los apuntes", "La cantidad de iconos de escritorio"], "answer": 0, "why": "La comunicación entre redes depende de rutas y políticas de acceso."},
		{"q": "¿Qué debe probarse al integrar dos servicios de comunicación?", "options": ["Intercambio de datos, compatibilidad y recuperación ante fallos", "Solo que ambos tengan un nombre", "Que usen pantallas del mismo tamaño"], "answer": 0, "why": "La integración debe validar contratos, comunicación y comportamiento ante errores."}
	],
	"INF 3742": [
		{"q": "¿Qué describe el ancho de banda de un enlace?", "options": ["La capacidad máxima de transmisión bajo condiciones definidas", "La distancia entre dos oficinas", "La cantidad de claves de una base"], "answer": 0, "why": "El ancho de banda expresa capacidad; el rendimiento real también depende de congestión y otros factores."},
		{"q": "En un enlace compartido, varios usuarios transmiten al mismo tiempo. ¿Qué puede reducir la experiencia?", "options": ["Congestión y competencia por la capacidad disponible", "El uso de direcciones privadas", "La longitud del nombre de usuario"], "answer": 0, "why": "La carga simultánea puede elevar tiempos y reducir el caudal disponible por usuario."},
		{"q": "¿Qué mide la latencia de una comunicación?", "options": ["El tiempo que tarda un dato en ir de origen a destino", "El total de archivos guardados", "La cantidad de puertos de un switch"], "answer": 0, "why": "La latencia mide demora y afecta servicios interactivos incluso cuando el ancho de banda es suficiente."}
	],
	"INF 3811": [
		{"q": "¿Para qué sirve una prueba de regresión?", "options": ["Comprobar que un cambio no dañó funciones que ya trabajaban", "Medir la velocidad de escritura del equipo", "Reemplazar todos los requisitos"], "answer": 0, "why": "Las pruebas de regresión buscan efectos secundarios de cambios en el software."},
		{"q": "Un defecto aparece después de una modificación. ¿Qué ayuda a localizarlo?", "options": ["Reproducirlo, aislar el cambio y revisar pruebas relacionadas", "Cambiar varias partes al azar", "Borrar el historial de versiones"], "answer": 0, "why": "La reproducción controlada y el análisis del cambio reducen el espacio de búsqueda del defecto."},
		{"q": "¿Qué aporta mantener casos de prueba automatizados en el proyecto?", "options": ["Repetir verificaciones de forma consistente después de cambios", "Garantizar que no habrá ningún error", "Evitar revisar los resultados"], "answer": 0, "why": "La automatización acelera comprobaciones repetibles, pero no elimina todos los defectos."}
	],
	"INF 3822": [
		{"q": "¿Qué puede debilitar una señal inalámbrica dentro de un edificio?", "options": ["Distancia, obstáculos e interferencia", "La normalización de una base de datos", "La longitud de una contraseña"], "answer": 0, "why": "La propagación depende del medio, los obstáculos y otras señales presentes."},
		{"q": "¿Qué busca una planificación de cobertura inalámbrica?", "options": ["Ubicar puntos de acceso para cubrir zonas y capacidad requeridas", "Conectar cada usuario con un cable de fibra", "Cambiar el nombre del protocolo"], "answer": 0, "why": "La cobertura y capacidad dependen de ubicación, obstáculos y concentración de usuarios."},
		{"q": "Dos redes cercanas sufren interferencia. ¿Qué ajuste puede ayudar?", "options": ["Revisar canales, potencia y distribución de los puntos de acceso", "Aumentar el brillo de la pantalla", "Duplicar las direcciones IP"], "answer": 0, "why": "Una planificación de canales y potencia reduce interferencias y zonas de mala recepción."}
	],
	"INF 3912": [
		{"q": "En un taller telemático, ¿qué evidencia muestra que un servicio integrado funciona extremo a extremo?", "options": ["Una transacción de prueba completa con datos observables en cada etapa", "Que las computadoras estén encendidas", "Que exista un diagrama sin ejecutar"], "answer": 0, "why": "La prueba extremo a extremo comprueba el recorrido completo entre componentes."},
		{"q": "Una falla ocurre solo bajo carga. ¿Qué registro ayuda a reproducirla?", "options": ["Condiciones de tráfico, tiempos, errores y recursos durante la prueba", "El color de las etiquetas", "Una captura sin hora ni contexto"], "answer": 0, "why": "Los registros con contexto permiten relacionar la falla con carga y recursos."},
		{"q": "Antes de entregar el servicio, ¿qué conviene comprobar además del caso ideal?", "options": ["Errores, límites de capacidad y recuperación de la comunicación", "Solo el nombre del proyecto", "Que no se guarde ningún registro"], "answer": 0, "why": "La validación debe considerar límites y recuperación, no únicamente el camino exitoso."}
	]
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
		"summary": "Enfoque sistémico, optimización de procesos y soluciones para organizaciones.",
		"focus_color": Color("#4d9bff"),
		"description": "La FNI describe esta formación desde el análisis de problemas, el diseño de sistemas, la gestión de proyectos y la optimización de procesos y recursos.",
		"mentions": [
			{"id": "gestion_sistemas", "name": "Dirección y Gestión de Sistemas Empresariales", "focus": "Dirección, diseño y gestión de sistemas empresariales.", "activity": "Detectar cuellos de botella en un proceso y preparar una propuesta de mejora."},
			{"id": "gestion_informacion", "name": "Gestión de la Información", "focus": "Captura, organización, calidad y uso de información para decidir.", "activity": "Rastrear datos inconsistentes desde su origen hasta un tablero de decisiones."},
			{"id": "modelamiento_optimizacion", "name": "Modelamiento y Optimización de Recursos-Procesos", "focus": "Modelos de sistemas y asignación eficiente de recursos y procesos.", "activity": "Simular una operación con recursos limitados y comparar escenarios."}
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
		"summary": "Desarrollo de software y servicios de comunicación e información.",
		"focus_color": Color("#ff4d6d"),
		"description": "La FNI orienta esta carrera a analizar, diseñar e implementar soluciones informáticas y servicios tecnológicos vinculados con las organizaciones.",
		"mentions": [
			{"id": "desarrollo_sw", "name": "Desarrollo de Software", "focus": "Diseño, construcción y validación de aplicaciones y sistemas de software.", "activity": "Recoger requisitos, preparar un prototipo y resolver un error reportado por usuarios."},
			{"id": "telematica", "name": "Telemática", "focus": "Redes, transmisión de datos y servicios de comunicación.", "activity": "Diagnosticar una interrupción siguiendo el recorrido de los datos por la red."}
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

static func semesters_for(program_id: String, mention_id: String = "") -> Array:
	if not mention_id.is_empty():
		var official_plan := Curricula.semesters(program_id, mention_id)
		if not official_plan.is_empty():
			return official_plan
	if program_id == "sistemas" or program_id == "informatica":
		return []
	var program := program_by_id(program_id)
	if program.is_empty(): return []
	return program.get("semesters", []).duplicate(true)

static func all_subjects(program_id: String, mention_id: String = "") -> Array:
	var result: Array = []
	for sem in semesters_for(program_id, mention_id):
		for sub in sem.get("subjects", []):
			var copy: Dictionary = sub.duplicate(true)
			copy["semester"] = sem.get("order", 0)
			copy["semester_name"] = sem.get("name", "")
			result.append(copy)
	return result

static func subject_by_sigla(program_id: String, sigla: String, mention_id: String = "") -> Dictionary:
	for sub in all_subjects(program_id, mention_id):
		if sub.get("sigla", "") == sigla:
			return sub
	return {}

static func course_for_sigla(program_id: String, sigla: String, mention_id: String = "") -> Dictionary:
	var sub := subject_by_sigla(program_id, sigla, mention_id)
	if sub.is_empty(): return {}
	var topics: Array = sub.get("topics", [])
	var questions: Array = _topic_questions(sub, topics)
	if QUIZ_BANK.has(sigla):
		questions = QUIZ_BANK[sigla]
	var partials: Array = []
	for partial_index in range(3):
		var q: Dictionary = questions[partial_index].duplicate(true)
		var options: Array = q["options"].duplicate()
		var rotation := _answer_rotation(sigla, partial_index, options.size())
		var rotated_options: Array = []
		for option_index in range(options.size()):
			rotated_options.append(options[(option_index - rotation + options.size()) % options.size()])
		q["answer"] = (int(q["answer"]) + rotation) % options.size()
		q["options"] = rotated_options
		q["difficulty"] = partial_index + 1
		partials.append(q)
	return {"name": sub["name"], "sigla": sub["sigla"], "semester": sub.get("semester", 0), "desc": sub.get("desc", ""), "topics": topics, "prereq": sub.get("prereq", []), "partials": partials}

static func _topic_questions(subject: Dictionary, topics: Array) -> Array:
	var result: Array = []
	var topic_list := topics.duplicate()
	if topic_list.is_empty():
		topic_list = [subject.get("name", "fundamentos")]
	while topic_list.size() < 3:
		if topic_list.size() == 1:
			topic_list.append("Aplicación práctica de " + str(topic_list[0]))
		else:
			topic_list.append("Integración de " + str(topic_list[0]) + " y " + str(topic_list[1]))
	var name := str(subject.get("name", "la materia"))
	var question_forms := [
		{"prefix": "En %s, ¿qué idea describe mejor el tema «%s»?", "good": "El concepto y el método propio de %s aplicado en %s", "wrong_a": "Un dato sin relación con %s", "wrong_b": "Una decisión que ignora las reglas de %s", "why": "El tema se comprende al relacionar su concepto con el método que usa %s."},
		{"prefix": "En un ejercicio de %s aparece «%s». ¿Qué conviene hacer primero?", "good": "Identificar los datos y aplicar el procedimiento de %s", "wrong_a": "Elegir una respuesta antes de revisar %s", "wrong_b": "Saltar el análisis de %s", "why": "El ejercicio requiere reconocer el tema y usar el procedimiento correspondiente de %s."},
		{"prefix": "¿Qué decisión demuestra que entiendes «%s» dentro de %s?", "good": "Usar %s y comprobar que la solución respeta sus condiciones", "wrong_a": "Ignorar las condiciones de %s", "wrong_b": "Reemplazar %s por una suposición", "why": "Una aplicación correcta de %s considera sus condiciones y valida el resultado."}
	]
	for index in range(3):
		var topic := str(topic_list[index])
		var form: Dictionary = question_forms[index]
		var good := str(form["good"]) % [topic, name] if index == 0 else str(form["good"]) % [topic if index == 2 else name]
		var wrong_a := str(form["wrong_a"]) % [topic]
		var wrong_b := str(form["wrong_b"]) % [topic]
		var why := str(form["why"]) % [name]
		var prompt := str(form["prefix"]) % [name, topic] if index < 2 else str(form["prefix"]) % [topic, name]
		result.append({"q": prompt, "options": [good, wrong_a, wrong_b], "answer": 0, "why": why})
	return result

static func _answer_rotation(sigla: String, partial_index: int, option_count: int) -> int:
	if option_count <= 1:
		return 0
	var total := partial_index
	for value in sigla.to_utf8_buffer():
		total += int(value)
	return total % option_count

static func course(program_id: String, course_index: int, mention_id: String = "") -> Dictionary:
	var subjects := all_subjects(program_id, mention_id)
	if subjects.is_empty() or course_index < 0 or course_index >= subjects.size():
		return {}
	return course_for_sigla(program_id, subjects[course_index].get("sigla", ""), mention_id)
