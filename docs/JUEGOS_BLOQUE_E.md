# Sala de juegos del bloque E

Actualizado: 31 de octubre de 2026. Estado: presentación local de frontend;
funcionamiento de los minijuegos pendiente para motor/backend. Sin commit
creado por esta entrega.

## Qué puede recorrer el usuario

En **Explorar la facultad**, el bloque **Sistemas E · Juegos** abre una sala
con cuatro mesas distintas en pixel art. Se conservan el ID `sis_e`, el
ambiente `SIS E` y sus visitas anteriores. Se llega a cada mesa con WASD;
**E / Interactuar** abre su presentación. El cartel del fondo abre el catálogo.
La salida inferior regresa al campus. Los menús conservan identidad, páginas
explícitas, tamaño de texto y navegación sin rueda ni deslizadores.

Las presentaciones muestran el tablero o mesa, descripción, controles
previstos y funcionamiento que falta. **Partida en desarrollo** está
deshabilitado y no envía acciones. Se puede elegir otra mesa o volver a la sala.
No hay resultados, turnos, física, compras ni recompensas ficticias.

| ID estable de presentación | Mesa | Elementos visuales originales |
|---|---|---|
| `billar` | Billar | Paño, seis troneras, taco y bolas. |
| `ping_pong` | Ping-pong | Mesa, líneas, red, paletas y pelota. |
| `ajedrez` | Ajedrez | Tablero 8 × 8 y piezas claras/oscuras. |
| `monopolio` | Monopolio | Tablero ilustrativo, casillas, cartas, dados y fichas. |

`minigame_preview.gd` dibuja la misma familia de mesas en el mundo y en las
pantallas de presentación. Sus dibujos no implementan reglamentos. El tablero
de Monopolio es un esquema original sin logotipos, cartas, textos ni recursos
gráficos comerciales copiados; el nombre solicitado identifica el encargo.

## Procedencia y límites del espacio

La existencia de la sala en E fue indicada por el usuario en este encargo.
El plano aportado identifica **SIS E**, pero no su distribución interior ni
inventario. La posición de las mesas, mobiliario, dimensiones y señalética
son una recreación jugable. Las fotos exteriores consultadas en Google Maps
no confirman ese interior. Se requiere material propio o autorizado antes
de presentarlo como representación del espacio físico actual.

## Nota para el responsable de motor/backend

El encargo actual limita frontend a la presentación. No se modificaron
`student_simulation.gd`, reglas académicas, persistencia académica ni Django.
La exploración continúa guardando únicamente posición y visitas con el
contrato existente. Los juegos deben tener estado independiente del historial
académico; una visita o la apertura de una mesa nunca equivalen a una victoria.

| Pendiente | Responsable y evidencia necesaria | Criterio de cierre |
|---|---|---|
| Modalidades y participantes | Motor/backend + usuario: decidir local por turnos, rival automático o multijugador para cada juego. | Modos y límites de jugadores definidos y versionados. |
| Billar | Motor/backend: elegir variante, modelar física, saque, turnos, troneras, faltas y victoria. | Estado reproducible y validación de cada tiro; frontend recibe posiciones y resultado. |
| Ping-pong | Motor/backend: movimiento, servicio, rival, puntos, sets y pausa. | Simulación y marcador autoritativos con casos de saque/punto/final. |
| Ajedrez | Motor/backend: legalidad, jaque, enroque, promoción, captura al paso, tablas, reloj y abandono según modo. | Estado y jugadas validados por el motor, incluidas posiciones especiales. |
| Monopolio | Motor/backend + usuario: definir reglamento y edición o variante propia antes de poblar casillas/cartas. | Casillas, economía, dados, propiedades, pagos y final con reglas acordadas; revisar recursos/textos antes de incorporarlos. |
| Sesión y recuperación | Motor/backend: nuevo estado versionado independiente, pausa, reinicio, abandono y eventual guardado. | Reanudar sin perder ni alterar perfiles académicos; errores recuperables. |
| Contrato con frontend | Motor/backend y frontend: acordar comandos, estado, errores, eventos y capacidades de cada modo. | Respuesta autoritativa; controles habilitados solo por capacidades confirmadas. |
| Datos del espacio real | Usuario + backend/datos: fotos propias/autorizadas de E, croquis, fecha, responsable, mesas existentes y condiciones de acceso. | Distribución e inventario contrastados con fuentes originales y permisos. |

Propuesta para acordar, **todavía no implementada**: sesión con `game_id`,
`session_id`, `schema_version`, participantes, fase, turno, estado específico,
acciones permitidas y último resultado/error. Los comandos deberían incluir
ID de sesión y versión esperada; el motor valida y devuelve el estado nuevo.
Para física, acordar frecuencia de actualización y representación interpolada
antes de conectar animaciones. No añadir premios académicos ni costos sin un
encargo y un contrato explícitos.

Frontend podrá conectar las pantallas cuando exista ese contrato: selección
de modo, controles de juego, indicador de turno, pausa, resultados y reanudación.
La fuerza del billar se elegirá con botones/pasos, nunca con deslizador;
tableros, cartas y ayudas se consultarán sin rueda.

## Archivos y comprobación

La presentación vive en `game/scripts/minigame_preview.gd`,
`campus_exploration_ui.gd`, `campus_world.gd` y `campus_map.gd`.
`test_games_room.gd` comprueba acceso a pie a las mesas, colisiones, interacción
correcta, regreso a E, tipografía pixel, navegación en nueve combinaciones
de tamaño/texto, botón de partida inactivo y conservación del snapshot académico.
Las ejecuciones y la revisión gráfica de esta entrega se registran en
[la bitácora](BITACORA_DESARROLLO.md). La existencia de una pantalla no marca
como resuelto el funcionamiento de un minijuego.
