# Sala de juegos del bloque E

Actualizado: 2 de noviembre de 2026. Estado: cuatro minijuegos locales jugables
contra rivales automáticos, incorporados en `b122e96`. La
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
| billar | Duelo de seis bolas; cada embocada vale un punto. Embocar conserva turno. Sin contacto o embocar la blanca es falta: cambia turno y las bolas de ese tiro cuentan al rival. La blanca se repone sin solapamientos. Termina al vaciar la mesa o tras 40 tiros. | Clic para apuntar, giro ±10°, fuerza por pasos y Tirar/Espacio. |
| ping_pong | Duelo arcade. Gana al llegar a 7 con dos de ventaja; a 11 se decide sin ventaja. El servicio cambia cada dos puntos. | Clic en la mesa para foco; W/S, flechas, ratón o botones de paleta; Sacar/Espacio. |
| ajedrez | Blancas humanas, negras automáticas, sin reloj. Jaque, mate, ahogado, enroque, captura al paso y promoción a dama/torre/alfil/caballo. Reclamo por tres repeticiones o 50 movimientos completados; cinco repeticiones y 75 movimientos son automáticos. Material insuficiente en casos comunes. | Origen/destino con ratón o flechas/Enter; destinos legales resaltados, selector de promoción, tablas y abandono. |
| monopolio | **Ruta del campus**, variante propia de 20 casillas. Dos participantes; 600 créditos iniciales; 100 por pasar Inicio; propiedades de 90–180; renta de una quinta parte del precio por cada nivel; hasta dos mejoras de 70. Sucesos +60/+80/−40/−60, servicios de 45, descanso de un turno y liquidación a mitad de precio. Bancarrota pierde; a 40 turnos gana el patrimonio mayor. | Dados, Comprar, Mejorar y Pasar turno. |

Billar y ping-pong son adaptaciones arcade, no reglamentos de competición.
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
| Ping-pong | Predice el encuentro con la paleta mediante reflexión analítica en los bordes. | Reacción cada 0,18 s, velocidad de 174 frente a 250 del jugador y error estable de hasta 44 unidades por intercambio. No se teletransporta. |
| Ruta del campus | Decide compras y mejoras por presupuesto y reserva de liquidez. | Conserva 130 para comprar y mejora con al menos 240. Usa los mismos dados, precios y reglas que el jugador. |

La dificultad se comprobó mecánicamente; la sensación de facilidad requiere
sesiones con jugadores. No hay un ajuste oculto que cambie resultados ya
decididos ni se utilizan datos académicos para decidir victorias.

## Motores y presentación

| Archivo en game/scripts | Responsabilidad |
|---|---|
| recreation_game.gd | Revisión, turno, pausa, final, serialización y validación común. |
| chess_game.gd | Tablero plano de 64 enteros, legalidad, búsqueda y finales. |
| pool_game.gd | Siete bolas, colisiones, troneras, faltas y tiros automáticos. |
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

| Área / responsable | Estado comprobado | Pendiente y criterio de cierre |
|---|---|---|
| Motor de minijuegos | Cuatro partidas, rivales, final, pausa, reinicio y recuperación. | Ampliar modos cuando se soliciten; no hay multijugador ni torneo. |
| Frontend / jugadores | Tablero y acciones visibles juntos en los tamaños/textos probados. | Sesión humana para ajustar dificultad con resultados observados. |
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

capture_minigames.gd genera once capturas con perfiles ficticios en
game/.test-artifacts/minigames/, incluyendo 900×640 con texto al 120%.
Los resultados registrados por esa entrega figuran en [Verificaciones](VERIFICACIONES.md).
