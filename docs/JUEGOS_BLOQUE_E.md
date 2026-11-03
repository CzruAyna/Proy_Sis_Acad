# Sala de juegos del bloque E

Corrección del 03/11/2026: la apertura desde el mundo se difiere hasta terminar
el evento de teclado/ratón. El manejador consume la entrada antes de emitir la
señal y detiene el movimiento. Se reproducía un acceso a viewport nulo después
de retirar el campus; ahora se comprueban E, Enter y el botón en las cuatro
mesas con eventos reales de viewport. Este hallazgo explica un fallo de entrada;
no se obtuvo un registro nativo del cierre completo reportado por el usuario.

Actualizado: 3 de noviembre de 2026. Estado: cuatro minijuegos locales jugables
contra rivales automáticos. La ampliación actual todavía no tiene commit.
Las primeras partidas se incorporaron en `b122e96`. La
presentación del 31/10 y su contrato propuesto se conservan como antecedente
en [la bitácora](BITACORA_DESARROLLO.md).

## Acceso y controles

Explorar la facultad → **Sistemas E · Juegos**. Se llega a las mesas con WASD;
E / Interactuar abre la partida. El cartel del fondo abre el catálogo. Se puede
elegir otra mesa y volver al mismo interior, conservando su ID sis_e, su
ambiente SIS E y sus visitas.

Las partidas incluyen rival, reglas, pausa, resultado, reinicio y reanudación.
Los tableros y acciones funcionan sin rueda ni deslizadores. La identidad de
partida permanece visible. P/Pausa detiene también al rival. Perder el foco de
la aplicación pausa el juego y libera las teclas.

| ID | Variante y final | Controles |
|---|---|---|
| billar | Ocho bolas: quince numeradas y blanca; lisas/rayadas se asignan tras una embocada legal posterior a la apertura. Hay faltas, bola en mano, efectos arcade y negra final en tronera anunciada. | Clic apunta; mantener, retirar el taco y soltar dispara. Flechas afinan ángulo/fuerza; Espacio tira. Arrastrar blanca cuando esté en mano, elegir contacto en su diagrama y anunciar tronera pulsando el agujero. Clic derecho/Escape cancela la preparación. |
| ping_pong | Duelo arcade. Gana al llegar a 7 con dos de ventaja; a 11 se decide sin ventaja. Servicio alterno cada dos puntos. La paleta en movimiento influye en la devolución; impulso de 0,28 s con recuperación de 3 s. | W/S, flechas o ratón; Espacio/clic en mesa saca. Shift, clic derecho o zona Impulso acelera la paleta. |
| ajedrez | Blancas humanas, negras automáticas, sin reloj. Jaque, mate, ahogado, enroque, captura al paso, promoción y tablas; reglas anteriores conservadas. | Tablero ampliado, seis siluetas originales de 32×40 sin letras, leyenda visual, selección y promoción junto al tablero. Ratón o flechas/Enter. |
| monopolio | **Ruta del campus**, variante propia de 20 casillas. Dos participantes; 600 créditos iniciales; 100 por pasar Inicio; propiedades de 90–180; renta de una quinta parte del precio por cada nivel; hasta dos mejoras de 70. Sucesos +60/+80/−40/−60, servicios de 45, descanso de un turno y liquidación a mitad de precio. Bancarrota pierde; a 40 turnos gana el patrimonio mayor. | Dados con puntos pulsables; fichas que recorren casillas, inspección de cada propiedad, casas y patrimonio. Comprar/construir/finalizar en el tablero; Espacio/Enter lanza o pasa. |

Billar y ping-pong son adaptaciones arcade, no reglamentos de competición.
Los controles de billar toman como referencia las explicaciones oficiales de
[puntería, retirada del taco y efecto de Miniclip](https://support.miniclip.com/hc/en-us/articles/35451942766865-Basic-Controls-Improving-your-skills-8-Ball-Pool)
y [colocación de blanca y efectos](https://support.miniclip.com/hc/en-us/articles/203747476-How-to-Move-the-Cue-Ball-8-Ball-Pool).
Se implementaron física, dibujos y controles propios; no se copiaron recursos,
interfaz comercial, economía de tacos ni servicios de ese producto.
Ruta del campus no reproduce una edición comercial: casillas, textos y dibujos
son originales y sus créditos no son dinero real. Las reglas básicas y
especiales de ajedrez se contrastaron con las
[Leyes FIDE de 2023](https://handbook.fide.com/chapter/e012023); no se afirma
certificación arbitral ni cobertura de todas las posiciones muertas. No hay
reloj ni reclamo preventivo anunciando la próxima jugada.

## Rivales y dificultad

| Juego | Decisión del rival | Límites deliberados |
|---|---|---|
| Ajedrez | Negamax con poda alfa-beta, capturas/promociones ordenadas, evaluación de material/centro y caché de jugadas legales. | Dos medias jugadas, máximo 2.400 nodos y elección entre hasta cuatro jugadas cercanas a la mejor. Búsqueda repartida entre fotogramas: un candidato inicial por paso. Sin motor externo. |
| Billar | Evalúa seis troneras y bolas activas; calcula bola fantasma, obstáculos de los segmentos, corte y fuerza según recorrido/fricción. | Un tiro por turno, error angular y fuerza limitada. No coloca bolas directamente en una tronera. |
| Ping-pong | Predice el encuentro con la paleta mediante reflexión analítica en los bordes. | Reacción cada 0,18 s, velocidad de 174 frente a 250 del jugador y error estable de hasta 44 unidades. El jugador puede acelerar a 390 por un instante. No se teletransporta. |
| Ruta del campus | Decide compras y mejoras por presupuesto y reserva de liquidez. | Conserva 130 para comprar y mejora con al menos 240. Usa los mismos dados, precios y reglas que el jugador. |

La dificultad se comprobó mecánicamente; la sensación de facilidad requiere
sesiones con jugadores. No hay un ajuste oculto que cambie resultados ya
decididos ni se utilizan datos académicos para decidir victorias.

## Motores y presentación

La superficie usa un lienzo lógico de 1000×600, ajustado a la ventana y con más
ancho disponible que las fichas de lectura. Las acciones principales se pulsan
en la propia mesa/tablero; sólo pausa, reglas, reinicio y regreso quedan fuera.
El marco negro recortado usa `MenuCave.frame`, compartido con el inicio; su
geometría se calcula al cambiar el tamaño y se dibuja por tramos de fila.
Las piezas se generan una vez y se reutilizan. El texto del tablero respeta
80/100/120 %, manteniendo los números pequeños de las bolas ligados a su dibujo.
No hay rueda, barras de potencia ni deslizadores: la fuerza depende del gesto
físico de retirar el taco; el indicador de fuerza es sólo texto.

| Archivo en game/scripts | Responsabilidad |
|---|---|
| recreation_game.gd | Revisión, turno, pausa, final, serialización y validación común. |
| chess_game.gd | Tablero plano de 64 enteros, legalidad, búsqueda y finales. |
| pool_game.gd | Dieciséis bolas, colisiones, seis troneras, grupos, negra, bola en mano, efectos y tiros automáticos. |
| legacy_pool_game.gd | Motor original de seis bolas, usado exclusivamente para conservar partidas guardadas anteriores. |
| chess_piece_art.gd | Doce texturas originales de seis piezas en dos colores, generadas y almacenadas en caché. |
| pong_game.gd | Pelota/paletas, servicio, marcador y predicción del rival. |
| campus_property_game.gd | Economía y turnos de Ruta del campus; arrays indexados de dueños y mejoras. |
| minigame_board.gd | Dibujo pixel art, selección, controles y actualización; no determina victorias. |
| minigame_session_ui.gd | Acciones habilitadas por estado, sesiones por perfil, reglas y guardado. |
| minigame_preview.gd | Arte compartido y catálogo; se conserva porque lo usa la sala física. |

Los motores son RefCounted, independientes del árbol de interfaz y de
student_simulation.gd. No se añadieron servicios Django ni dependencias.

La física usa un número fijo de cuerpos y paso de 1/120 s, acumula tiempo y
limita saltos largos. La búsqueda evita generar todas las respuestas legales
en hojas que no están en jaque; conserva la comprobación de mate cuando
procede. La caché de jugadas admite 128 posiciones, se invalida al jugar y
devuelve copias aisladas. Las posiciones
históricas se conservan desde el último movimiento irreversible y la notación
está acotada.

También se corrigió un coste del campus: campus_map.gd reconstruía los 40
bloques en cada consulta por ID. Ahora prepara un índice una vez y devuelve
una copia aislada del bloque solicitado. Se conserva el contrato público y
se verifica que modificar una copia no contamina futuras consultas.

## Sesiones y persistencia

Las partidas nuevas de billar guardan `data.rules = campus-eight-ball-v1`.
Si un guardado antiguo contiene siete bolas y no tiene esa marca, se abre con
`legacy_pool_game.gd`; conserva sus resultados y reglas anteriores. Se indica
en la cabecera. **Reiniciar** crea ocho bolas de forma explícita. No se convierte
ni elimina una sesión antigua silenciosamente. El tiro nuevo conserva grupos,
contacto inicial, troneras, efecto y resto del paso físico para reanudarlo.

Las acciones usan command(acción, revisión_esperada). El motor valida fase,
turno y revisión. Una acción antigua o inválida devuelve error sin ejecutar
otro turno. La física y los pasos del rival usan advance(delta).

El perfil mantiene un campo independiente:

    minigames.version = 1
    minigames.sessions[game_id] = {
      version, game_id, session_id, revision, turn, phase,
      winner, message, rng, data
    }

data contiene exclusivamente el estado del juego correspondiente. El estado
aleatorio de 64 bits se guarda como texto para evitar pérdida de precisión
en JSON. Se mantienen hasta cuatro sesiones, una por mesa. La recuperación
carga en pausa y abrir la partida la activa. La visita libre conserva sesiones
solo mientras la aplicación está abierta.

Se actualiza el perfil en cambios discretos, pausa o salida y se capturan las
coordenadas físicas al guardar. No se escribe por fotograma ni al seleccionar
una pieza sin moverla. Se usa el almacén atómico con respaldo existente.
No se añaden premios, matrículas, notas o logros globales por ganar. Cambiar de
perfil separa las sesiones.

## Revisión de funcionalidades y pendientes

### Reglas concretas del billar local

La primera embocada válida después de la apertura asigna grupos. Se conserva
turno al embocar una propia; las bolas ajenas que entren no se reponen. Son
faltas embocar blanca, no tocar bola, tocar primero un objetivo incorrecto o
no producir banda/embocada después del contacto. Con la mesa abierta no se
puede tocar primero la negra. La apertura sin embocadas exige cuatro bolas
distintas en banda; negra en apertura se repone. La blanca puede moverse detrás
de la línea al abrir y por toda la mesa después de una falta, sin superponerse
a bolas ni colocarse sobre una tronera.

La negra exige haber limpiado el grupo al comenzar el tiro y anunciar su
tronera. Embocarla antes, con falta, junto con la última propia o en otro
agujero pierde. Se trata de una variante recreativa: no implementa salto,
masa, física tridimensional, reloj ni protocolo completo de competición.
El efecto aplica una respuesta limitada de seguimiento/retroceso/lateral;
no representa una simulación rígida completa de rotación de una esfera.

### Aspectos todavía pendientes

| Área / responsable | Estado comprobado | Pendiente y criterio de cierre |
|---|---|---|
| Motor de minijuegos | Cuatro partidas, rivales, final, pausa, reinicio y recuperación. | Ampliar modos cuando se soliciten; no hay multijugador ni torneo. |
| Frontend / jugadores | Tableros ampliados, controles directos y marco quebrado. | Sesiones humanas para ajustar facilidad de apuntado y dificultad. |
| Motor de ajedrez | Perft inicial 20/400/8.902, reglas especiales y finales comunes. | Posiciones muertas complejas, reloj y protocolo arbitral completo no incluidos. Requieren casos de referencia y un alcance acordado. |
| Backend/datos | Reglas académicas existentes conservadas. | Verificar mallas, trámites y vínculo aula–materia–paralelo con los originales de [Datos y fuentes](PARA_BACKEND_DATOS_Y_FUENTES.txt). |
| Usuario + frontend/arte | Sala E recreada según indicación del usuario. | Fotos/croquis autorizados, fecha e inventario. Las fotos exteriores no confirman ese interior. |
| Usuario + frontend | Exploración de la ciudad universitaria disponible. | Plano de la sede del centro todavía no recibido. |
| Empaquetado / calidad | Compilación y arranque locales registrados en bitácora. | Otras GPU, sistemas y sesiones prolongadas requieren comprobaciones propias. |

## Verificación

Desde la raíz con Godot 4.7.2:

    godot --headless --path game --script res://tests/test_recreation_models.gd
    godot --headless --path game --script res://tests/test_recreation_ui.gd
    godot --headless --path game --script res://tests/test_games_room.gd

Las pruebas cubren legalidad y deshacer de ajedrez, mate, enroque, promoción,
al paso, repeticiones, presupuesto y búsqueda cooperativa; física, faltas,
puntos y capacidad de los rivales para jugar; 30 partidas económicas acotadas;
JSON, revisión obsoleta y recuperación; controles, identidad, ausencia de
desplazadores y conservación del snapshot académico.

`test_eight_ball.gd` comprueba apertura, grupos, faltas, troneras, finales,
efectos serializados, física reanudada y compatibilidad. `test_recreation_surface.gd`
comprueba gestos, piezas distintas, casillas sin cruces, dados, compras,
construcción e impulso. La secuencia visual del peón/dados no altera el resultado
del modelo: al guardar se conserva la casilla resuelta, no una posición intermedia.
`capture_recreation_surface.gd` genera doce capturas en
`game/.test-artifacts/recreation-v2/` con los tamaños 900×640, 1152×720 y 1600×900.

capture_minigames.gd genera once capturas con perfiles ficticios en
game/.test-artifacts/minigames/, incluyendo 900×640 con texto al 120%.
Los resultados registrados por esa entrega figuran en [Verificaciones](VERIFICACIONES.md).
