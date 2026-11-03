# Estado actual de SIS-INF

Revisión: 2 de noviembre de 2026. Código de referencia: `b122e96`.

Actualización local del 03/11/2026, sin commit nuevo: se corrigieron el anclaje
del personaje hacia la izquierda y la retirada del campus durante la entrada
al abrir mesas. Se añadió el icono pixel art y la
[demostración automática](MODO_DEMOSTRATIVO.md). Las animaciones laterales
ilustradas siguen pendientes de frontend; ya existe el contrato y una columna
con esquemas explicativos. Las entradas restantes conservan el corte anterior.

## Qué se puede utilizar

SIS-INF es el juego de escritorio Godot. Conserva la simulación del estudiante,
la historia demostrativa y la exploración de un campus recreado. La API Django
y la web Next.js permanecen en el repositorio, pero no son necesarias para
ejecutar la partida local.

| Área | Implementación en el código | Guía de detalle |
|---|---|---|
| Recorrido académico | Inscripción, cursado, intentos, cambios de plan, trámites, auxiliatura y titulación. | [Simulación](SIMULACION_ESTUDIANTE.md) |
| Presentación | Pixel art, identidad azul/roja, ambientes por mención y navegación con botones. | [Diseño visual](DISENO_VISUAL_CAMPUS.md) |
| Malla | Selección, movimiento de nodos y ramas, giro, zoom por botones y validación geométrica. | [Diseño visual](DISENO_VISUAL_CAMPUS.md) |
| Inicio | Menú único, terminal simulada interior, desintegración visual y emblema geométrico. | [Ruptura y emblema](DISENO_RUPTURA_Y_EMBLEMA.md) |
| Historia | Recorrido con semilla y reglas del motor, aislado de partidas y logros. | [Historia](MODULO_HISTORIA_CARRERA.md) |
| Exploración | Personaje, colisiones, pasillos, aulas, orientación y accesos al expediente. | [Exploración](EXPLORACION_FNI.md) |
| Sala E | Ajedrez, billar, ping-pong y Ruta del campus contra rivales locales, con pausa y recuperación. | [Sala de juegos](JUEGOS_BLOQUE_E.md) |
| API y web | Catálogo, oferta, inscripción autenticada y actas; recorrido separado del juego. | [Arquitectura](ARQUITECTURA.md) |

La versión del 31 de octubre solo presentaba las mesas. Las partidas se
habilitaron en `b122e96`, el 2 de noviembre. El contrato de frontend del 31
queda como antecedente, no como una limitación todavía vigente.

## Persistencia y separación de responsabilidades

El perfil mantiene tres grupos distintos:

- `simulation`: expediente académico. Lo modifica el motor del estudiante.
- `campus_exploration`: posición, ambiente y visitas al campus.
- `minigames`: hasta cuatro sesiones recreativas, con versión, revisión y estado
  aleatorio serializado como texto.

La historia demostrativa utiliza una simulación aislada. La visita libre
mantiene sesiones en memoria; no ocupa una partida. Ganar una mesa no concede
notas, matrículas ni logros académicos.

El nombre visible es SIS-INF. La ruta de usuario conserva
`Godot/app_userdata/CAMPUS EN JUEGO` para recuperar guardados anteriores.
Esa ruta no es una marca pendiente de retirar. El preset de Windows genera
`game/build/SIS-INF.exe` y su `.pck`; ambos deben conservarse juntos.

## Decisiones técnicas de las últimas entregas

Los motores recreativos reciben `command(action, expected_revision)` y avanzan
mediante `advance(delta)`. Rechazan acciones obsoletas y validan fase y turno.
La presentación muestra el resultado y guarda en cambios discretos; no escribe
el estado completo en cada fotograma.

El ajedrez utiliza negamax con poda alfa-beta y presupuesto de búsqueda.
Billar y ping-pong usan paso físico fijo y rivales acotados. Ruta del campus
es una variante propia, con economía y duración limitadas. Los parámetros de
dificultad y la reproducción de sucesos pertenecen al juego, no a estadísticas
universitarias.

`campus_map.gd` prepara un índice por ID y devuelve copias de los edificios.
Así evita reconstruir todo el catálogo en cada consulta sin compartir objetos
mutables con sus consumidores. La terminal también acota líneas y fragmentos;
no mantiene una salida infinita en memoria.

## Qué está comprobado y qué falta

El historial documenta el código y las pruebas incorporadas. Los resultados de
ejecución de otras entregas se conservan en [Verificaciones](VERIFICACIONES.md).
No se presenta su total como una batería nueva ni se suman comprobaciones de
versiones distintas.

| Responsable | Pendiente | Criterio para cerrarlo |
|---|---|---|
| Autor y backend/datos | Versiones de mallas, cohortes, requisitos y normativa. | Originales identificados y datos contrastados; véase [Fuentes](PARA_BACKEND_DATOS_Y_FUENTES.txt). |
| Autor y frontend | Planta interior, distribución y equipamiento de la sala E. | Fotos o croquis autorizados; el testimonio no confirma las medidas. |
| Autor y frontend | Sede del centro. | Plano original todavía no recibido. |
| Motor y jugadores | Dificultad, duración y sesiones prolongadas de los minijuegos. | Partidas humanas con observaciones y ajustes medidos. |
| Motor recreativo | Posiciones muertas complejas, reloj y protocolo arbitral de ajedrez. | Alcance y casos de referencia acordados; no se declara cobertura arbitral completa. |
| Backend | Validaciones y casos límite de la inscripción web. | Pruebas de periodos, carga y concurrencia sobre PostgreSQL. |
| Empaquetado | Distribución descargable, otras plataformas y otros equipos. | Paquetes y ejecuciones verificables; un preset local no acredita disponibilidad pública. |
| Autor y empaquetado | Recursos ajenos y dependencias del paquete. | Procedencia y condiciones de uso registradas en [Licencia](LICENCIA_CODIGO_LIBRE.md). |

La apariencia de edificios y los pagos/documentos del recorrido siguen siendo
recreaciones. El nombre del archivo del plano y las referencias consultadas no
demuestran por sí solos vigencia, exactitud de interiores ni autorización para
redistribuir todos los materiales.
