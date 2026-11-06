# Caminos continuos, inicio sencillo y ambientes variados

Estado: 6 de noviembre de 2026. Cambios locales de frontend Godot, sin commit
propio. Se aplica la regla 27 y se conservan los guardados y reglas académicas.

## Qué cambia

El inicio muestra únicamente **Jugar, Simular, Opciones y Salir**, incluso
cuando existen partidas. Jugar reúne continuar, nueva carrera, partidas,
exploración y logros. Simular conserva la presentación automática y la historia
variable; ninguna modifica por sí sola el expediente del jugador. La ruptura
negra, terminal interior, botones translúcidos y movimiento reducido continúan.

Los caminos antes se dibujaban completos uno tras otro: el borde de una vía
quedaba encima del asfalto de otra. `campus_roads.gd` dibuja primero todos los
bordes y después las superficies de toda la red, con extremos redondeados y
giros suavizados en una rejilla de dos unidades. Se conectó el extremo del
recorrido oeste con el eje del ingreso y el acceso lateral de Biblioteca.
El terreno general es tierra; se mantienen los jardines marcados y el bosque.

La rosa pixel art está arriba a la derecha del mapa de orientación y de las
láminas exportadas. **Norte a la derecha, sur a la izquierda, este abajo y
oeste arriba**, según la indicación expresa del usuario. Esta orientación no
convierte el esquema en un levantamiento topográfico. Las celdas siguen siendo
1536×1088 unidades de juego y no metros.

## Interiores y colisiones

`campus_room_layout.gd` concentra tamaño, muebles, huellas, aparición y salida;
`campus_room_art.gd` dibuja esos mismos muebles. El mundo, la cámara y la
interacción consultan ese contrato para evitar salidas o colisiones ancladas
al antiguo rectángulo único de 480×320.

| Uso recreado | Proporciones en unidades de juego | Diferencias de presentación |
|---|---|---|
| Aulas | 640×400, 480×560, 704×448 o 576×416 | Aulas largas o anchas, pupitres individuales o bancos compartidos, ladrillo, ventanas y cortinas. |
| Computación | 672×448 o 576×544 | Puestos con monitor, teclado, proyector y armario de equipos. |
| Física | 640×480 | Mesones, péndulos y equipos de medición ilustrativos. |
| Química | 768×480 | Islas de trabajo y material de laboratorio ilustrativo. |
| Física virtual | 640×416 | Puestos informáticos y pizarra temática. |
| Biblioteca | 608×480 | Estanterías y mesas de lectura. |
| Oficinas | 560×400 | Mostradores, archivo y espera. |
| Comedor | 720×480 | Mesas y bancos largos. |
| Sala de juegos E | 480×320 | Se conservan mesas, puntos de interacción y entrada a los cuatro minijuegos. |

Las proporciones son decisiones gráficas, **no medidas reales**. Las variantes
se eligen de forma estable por ID de bloque/aula. No se afirma que una foto
corresponda a un aula concreta del esquema si la fuente no la identifica.

## Referencias externas revisadas

| Fuente | Evidencia y uso | Límite |
|---|---|---|
| Captura satelital aportada en el mensaje del 06/11/2026. | Caminos curvos, tierra predominante y sectores verdes; orientación expresamente indicada por el usuario. | Sin escala física ni fecha de captura confirmada. No se copió al proyecto. |
| [RTvU–UTO, entrega de mobiliario del 22/05/2026](https://rtvu.uto.edu.bo/2026/05/22/el-centro-facultativo-saliente-de-la-fni-entrega-mobiliario-para-estudiantes-de-ciclo-basico/). | Se observaron en el navegador las fotos enlazadas `97033-1024x576.jpg` y `97030-1024x576.jpg`: aula alargada con ladrillo visto, ventanas y cortinas; mesas con bancos largos en un espacio exterior. | La publicación tiene fecha; las tomas no acreditan dimensiones, planta o aula exacta. Los bancos de la segunda foto no se presentan como inventario interior confirmado. |
| [Ingeniería Química, Aulas](https://quimica.fni.uto.edu.bo/index.php/es/aulas). | Describe capacidades variadas, iluminación y ventilación, y separación respecto de laboratorios. Sirve para evitar uniformar todos los ambientes. | Texto de acreditación ARCU-SUR 2025; no confirma medidas actuales ni la distribución recreada. |
| [SIS-INF, Computación](https://www.sisinf.fni.uto.edu.bo/computacion/). | Publica nombres de laboratorios y equipamiento informático. | Las imágenes asociadas a responsables no se usan como fotos del interior. El número de puestos dibujado es ilustrativo. |

Las imágenes se consultaron externamente, sin descargar originales ni añadir
fotografías al repositorio o al ejecutable. El arte incorporado es código
propio, con el régimen de licencia vigente del proyecto.

## Pendientes de motor/backend y datos

| Responsable | Evidencia actual | Material o funcionalidad necesaria | Criterio de cierre |
|---|---|---|---|
| Backend/datos y usuario | Variantes gráficas y fotografías sin asignación exacta. | Croquis acotados por aula, fotos fechadas con bloque/aula/planta, cantidad y tipo de mobiliario y ubicación de puertas. | Sustituir cada variante provisional por un perfil confirmado, manteniendo IDs y visitas. |
| Motor de exploración | Cada perfil publica tamaño, aparición, salida y obstáculos en `CampusMap`. | Consultar esos datos al integrar NPC interiores, ocupación y cambios de piso; respetar radios de `campus_scale.gd`. | NPC y jugador alcanzan entradas, puestos y escaleras sin atravesar muebles ni usar coordenadas fijas del aula antigua. |
| Motor de actividades | La tecla E conserva la consulta de actividades. | Modelar uso real de equipos, prácticas de Física/Química, disponibilidad y horarios antes de darles efectos jugables. | Señales y estados persistentes definidos por motor; frontend muestra su resultado sin deducir reglas académicas. |
| Backend/datos | Terreno y orientación según el usuario. | Escala o puntos de control y correcciones por celda para precisar anchos y trazados. | Contrastar varias distancias antes de publicar metros; conservar la matriz de revisión. |

## Comprobaciones y artefactos

El registro de ejecución está en [Verificaciones](VERIFICACIONES.md).
`test_natural_campus.gd` verifica conexiones, orientación, todos los interiores,
salidas y acceso a actividades, además del menú con/sin guardados y navegación
a distintas resoluciones y tamaños de letra. `capture_natural_campus.gd`
genera capturas y comprueba en el renderizado que el empalme conserva asfalto
continuo. Las láminas 8×8 se regeneran con el exportador existente.
