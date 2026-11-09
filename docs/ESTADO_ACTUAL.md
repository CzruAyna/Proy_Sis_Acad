# Estado actual de SIS-INF

Revisión del 9 de noviembre de 2026. Código de referencia `4095c2e`.

La [bitácora](BITACORA_DESARROLLO.md) conserva la evolución por jornada. El
[historial de pushes](HISTORIAL_PUSHES.md) indica qué cambió en cada envío.

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
| Inicio | Jugar, Simular, Opciones y Salir en un panel centrado. Opciones tiene categorías. | [Menús y mapa](MENUS_MAPA_Y_PERIMETRO.md) |
| Simular | Historia con semilla y terminal automática en bucle para ambas carreras y sus menciones. | [Historia](MODULO_HISTORIA_CARRERA.md) · [Demostración](MODO_DEMOSTRATIVO.md) |
| Exploración | Mapa `fni_ciudad_v3`, con flecha, zoom y rótulos. Pasillos, aulas, pisos transitables y enlaces al expediente. | [Exploración](EXPLORACION_FNI.md) · [Cartografía](CARTOGRAFIA_FNI_Y_ESCALA.md) |
| Vida del campus | NPC con rutinas ficticias, perros acariciables, logros globales y encuentro raro de Piedritas con sorteo de 1/100 por recorrido. | [Vida y rendimiento](VIDA_CAMPUS_Y_RENDIMIENTO.md) |
| Sala E | Ajedrez, billar de ocho bolas, ping-pong y Ruta del campus contra rivales locales, con pausa y recuperación. | [Sala de juegos](JUEGOS_BLOQUE_E.md) |
| API y web | Catálogo, oferta, inscripción autenticada y actas; recorrido separado del juego. | [Arquitectura](ARQUITECTURA.md) |

El perímetro y el tránsito exterior forman parte de la recreación. Las 64
láminas del atlas se usan para revisar la geometría fuera del mapa jugable.

## Persistencia y separación de responsabilidades

El perfil mantiene tres grupos distintos:

- `simulation`: expediente académico. Lo modifica el motor del estudiante.
- `campus_exploration`: posición, orientación exterior, edificio, aula,
  planta, visitas y estado de las rutinas del campus.
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

`campus_collision.gd` usa un índice para las consultas exteriores.
`campus_world.gd` reutiliza los límites de colisión de cada recinto y planta,
omite comprobaciones por ejes inmóviles y emite un único estado al volver
al pasillo. Al cargar campos espaciales malformados, el ingreso y la planta
baja sirven de respaldo según el campo afectado.

## Qué está comprobado y qué falta

La entrega de depuración del 9 de noviembre registró 29 suites de Godot,
113.728 aserciones y un arranque aislado de la exportación Windows.
Los resultados por entrega y sus límites están en [Verificaciones](VERIFICACIONES.md).

| Responsable | Pendiente | Criterio para cerrarlo |
|---|---|---|
| Autor y backend/datos | Versiones de mallas, cohortes, requisitos y normativa. | Originales identificados y datos contrastados; véase [Fuentes](PARA_BACKEND_DATOS_Y_FUENTES.txt). |
| Autor y frontend | Planta interior, distribución y equipamiento de la sala E. | Fotos o croquis autorizados; el testimonio no confirma las medidas. |
| Autor y frontend | Sede del centro. | Plano original todavía no recibido. |
| Autor y frontend | Puertas, perímetro, plantas y distancias de referencia. | Fotos fechadas, un croquis de accesos y mediciones del recorrido. |
| Frontend | Ilustraciones laterales y arte del personaje al pausar la demostración. | Integrar el arte y verificar una sesión prolongada con movimiento reducido. |
| Motor y jugadores | Dificultad, duración y sesiones prolongadas de los minijuegos. | Partidas humanas con observaciones y ajustes medidos. |
| Motor recreativo | Posiciones muertas complejas, reloj y protocolo arbitral de ajedrez. | Alcance y casos de referencia acordados; no se declara cobertura arbitral completa. |
| Backend | Validaciones y casos límite de la inscripción web. | Pruebas de periodos, carga y concurrencia sobre PostgreSQL. |
| Empaquetado | Distribución descargable, otras plataformas y otros equipos. | Paquetes y ejecuciones verificables; un preset local no acredita disponibilidad pública. |
| Autor y empaquetado | Recursos ajenos y dependencias del paquete. | Procedencia y condiciones de uso registradas en [Licencia](LICENCIA_CODIGO_LIBRE.md). |

La apariencia de edificios y los pagos/documentos del recorrido siguen siendo
recreaciones. El nombre del archivo del plano y las referencias consultadas no
demuestran por sí solos vigencia, exactitud de interiores ni autorización para
redistribuir todos los materiales.
