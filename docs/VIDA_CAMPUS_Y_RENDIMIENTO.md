# Vida del campus y bajo consumo

Entrega del 6 de noviembre de 2026, incorporada en `113037c`. Se revisaron
los contratos de [campus ampliado](CAMPUS_AMPLIADO_Y_VIDA_DEL_CAMPUS.md),
[matriz 8×8](MAPA_8X8_Y_PERSONAJES.md) y
[caminos e interiores](CAMINOS_MENU_Y_AMBIENTES.md). Esta actualización resuelve
los contratos de motor descritos debajo; no confirma planos ni horarios reales.

## Funciones disponibles

| Contrato | Implementación y límite |
|---|---|
| CAMPUS-NPC-01 | Los mismos personajes del catálogo caminan por la red de caminos mediante A*, esperan, entran en un ambiente y salen tras una clase ficticia. Cada instancia conserva ID, posición y actividad. Los caminos en curso se recalculan desde la posición guardada. No registran asistencia ni notas del jugador. |
| CAMPUS-DOG-01 | E junto a un perro abre su ficha; Acariciar comprueba distancia e instancia, produce una reacción y evita duplicar la acción durante ella. El catálogo de diseños no concede caricias. |
| CAMPUS-DOG-02 | Piedritas aparece con probabilidad **1/100**, elegida expresamente por el usuario. El sorteo ocurre una vez al inicializar el recorrido y queda en el guardado. Cargar o consultar progreso no vuelve a sortear. Un recorrido antiguo recibe el estado al abrirlo por primera vez con esta versión. |
| CAMPUS-DOG-03 / CAMPUS-MEMORY-01 | Logros públicos por acariciar y visitar ambos monumentos, más un secreto por acariciar la variante rara. Se registran globalmente sin duplicados; los secretos pendientes conservan su nombre oculto. |
| CAMPUS-FLOOR-01 | E en la escalera permite subir/bajar un piso adyacente. Bloque 100: dos niveles; Básicas: PB y cuatro pisos. Puertas y colisiones corresponden a la planta actual, guardada con el ambiente. Los baños recreados están en PB, 2 y 4. |

Las aulas nuevas sin código confirmado usan nombres internos provisionales;
la distribución no sustituye una planta institucional. Se conservan los códigos
anteriores, la recuperación de guardados y la carpeta histórica de usuario.
Los visitantes sin partida mantienen su recorrido en memoria durante la sesión.

## Trabajo que se evita

- `campus_collision.gd` indexa edificios, obstáculos y laguna por celdas de 512
  unidades. Solo consulta candidatos cercanos y conserva la comprobación exacta
  contra polígonos y radio de los pies.
- `campus_routes.gd` construye el grafo de caminos al iniciar el mundo. Las
  búsquedas A* se ejecutan al cambiar destino, con presupuesto de una por
  actualización; no se busca un camino por personaje en cada fotograma.
- `campus_life.gd` actualiza personajes cercanos a intervalos de 0,1 s y lejanos
  a 0,8 s; usa celdas para separación entre vecinos. La población no se duplica
  al añadir las rutinas. El estado persiste en `campus_exploration.life`.
- La geometría de ruptura se reutiliza con una caché limitada a 16 entradas.
  Se dibujan tramos contiguos por fila y se animan hasta 36 fragmentos.
- La exploración consulta el contexto a 10 Hz y prepara el progreso en movimiento
  como máximo cuatro veces por segundo. Salir o cambiar de pantalla captura
  además el estado exacto; esto no difiere un guardado solicitado por el jugador.
- Límite normal: 60 FPS. Bajo consumo: 30 FPS y fondo decorativo estático.
  Al perder foco: 10 FPS; al recuperarlo se restaura el límite seleccionado.
  Las reglas de los minijuegos conservan su propio paso físico.

Movimiento reducido no congela las rutinas funcionales. Abrir una ficha o pausar
la exploración sí detiene el mundo. No se modificaron Django, Next.js, notas,
matrícula, trámites ni condiciones de excelencia.

## Medición y comprobaciones

Microbenchmark local en Intel i5-7200U, Godot 4.7.2 headless. Una ejecución antes
y otra después, con la misma secuencia y resultados de colisión:

| Operación | Antes | Después |
|---|---:|---:|
| 5.000 consultas de colisión | 263.926 µs | 53.670 µs |
| 120 consultas de geometría estable de ruptura | 4.236.157 µs | 19.833 µs |

La segunda medición amortiza la construcción mediante caché. Son tiempos de CPU
de funciones concretas, no FPS, memoria total ni garantía para otro equipo.
Reproducir con `game/tools/benchmark_lightweight.gd`; los JSON y logs locales
están en `game/.test-artifacts/` y no forman parte de la distribución.
La matriz ejecutada está en [Verificaciones](VERIFICACIONES.md).

## Coordinación y pendientes

| Responsable | Evidencia y trabajo pendiente | Criterio de cierre |
|---|---|---|
| Frontend | Consumir `state`, `instance_id`, `building_id`, `room_name`, `floor` y las acciones existentes. Conservar un único elenco y no implementar un segundo sorteo ni conceder logros desde el catálogo. El corazón y los ocupantes de aula actuales son una representación mínima. | Animaciones finales conectadas a la misma instancia y comprobadas con guardado y movimiento reducido. Retirar las notas temporales al integrarlas. |
| Frontend | El personaje de pausa y las animaciones laterales de la terminal siguen en [Modo demostrativo](MODO_DEMOSTRATIVO.md). | Arte original y animaciones sobre el contrato existente, sin cambiar la simulación. |
| Frontend | Al cambiar geometría del mapa, revisar accesos, puntos de unión de caminos, radio 12 y pasillos libres. Las rutas no atraviesan edificios u obstáculos aunque visualmente haya asfalto. | Recorridos humanos y de NPC por todos los accesos modificados sin bloqueos. |
| Backend/datos y usuario | Aportar plantas originales de bloque 100 y Básicas, códigos de aulas, accesos y baños; horarios/aulas si se desea una asignación real; inventario y fotos fechadas de equipamiento; placas y respaldo de la historia de los monumentos. Consultar originales externamente, sin incorporarlos como recursos. | Documentos con entidad, versión, procedencia y condiciones registradas en [Datos y fuentes](PARA_BACKEND_DATOS_Y_FUENTES.txt). Hasta entonces todo recorrido y equipamiento sigue siendo ilustrativo. |
| Motor/QA | Faltan sesiones largas, recorrido exhaustivo de cada pareja de destinos y mediciones de memoria/FPS en otros equipos. A* tiene conexiones acotadas; un destino inaccesible espera y reintenta, sin teletransportar. | Perfil de CPU/GPU/memoria y sesiones reales en un equipo objetivo de pocos recursos. |
| Autor/empaquetado | Los originales retirados siguen presentes en commits antiguos; los derechos de la identidad institucional y datos históricos todavía requieren revisión. | Procedencia aclarada y revisión del material concreto que se distribuya. El paquete actual no incluye esas fotos ni mapas originales. |

El código nuevo es original, sin dependencias ni recursos externos nuevos, y
mantiene GPL-3.0-or-later. Los avisos del motor y derechos de terceros se
conservan según [Licencia](LICENCIA_CODIGO_LIBRE.md).
