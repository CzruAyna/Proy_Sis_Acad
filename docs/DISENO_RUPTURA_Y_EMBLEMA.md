# Emblema geométrico y superficies de ruptura

Actualizado: 31 de octubre de 2026. Estado: implementación local, sin commit
creado por esta entrega.

## Presentación vigente

El inicio utiliza un emblema pixelado de fondo, construido con funciones y
geometría. No carga una textura para representar ese emblema dentro del menú.
Los paneles adoptan una ruptura de bloques grandes y escalones en **negro
puro**, sin rebordes ni capas de otro color, extendida a pantallas interiores
y tarjetas de contenido. Esta precisión sustituye los tonos de las capas
del avance anterior. Los botones del inicio tienen relleno translúcido y
etiquetas opacas; los demás botones, campos y tarjetas conservan su presentación.
Todos mantienen límites legibles para interactuar con precisión.

Los botones del inicio comparten el ancho necesario para su etiqueta más larga,
con un margen de 36 unidades; el panel ajusta su ancho a ese grupo. Se conservan
todas las acciones en un único menú. En las otras vistas permanecen los límites
de ancho, páginas por botones, identidad de partida y colores de carrera.

## Interpretación del emblema

La referencia es el emblema aportado por el usuario, conservado en
`game/assets/branding/sis_inf_logo.png`. Se identificaron aros azul y rojo,
circuito de Sistemas con conexiones triangulares, trazos celestes, red de
nodos, teclado y círculo de Informática con letras «inf» y retícula esférica.

`procedural_career_logo.gd` reconstruye esas formas mediante discos, elipses,
líneas, rectángulos y letras de máscaras pixeladas en una rejilla de 160×160.
Agrupa tramos horizontales en una malla de triángulos y conserva el resultado
en memoria para reutilizarlo: un dibujo de la malla por instancia, sin leer
la imagen de referencia ni generar una textura del logo para el menú.

La versión de fondo utiliza colores oscuros y escala entera. Es una
interpretación artística, no una reproducción institucional exacta. No se
incorpora una afirmación de acreditación vigente; el aro inferior dice
FNI–UTO. El PNG aportado sigue siendo necesario para el icono de Windows.
La autoría y condiciones del emblema de referencia continúan pendientes de
confirmación; el código geométrico no cambia los derechos sobre ese diseño.

## Paneles y animación

| Componente | Función |
|---|---|
| `fracture_geometry.gd` | Dibuja la abertura negra escalonada y la salida simulada de `tree` de ambos sistemas. |
| `menu_cave.gd` | Construye la silueta irregular del inicio, la salida masiva de terminal, grietas y desprendimientos. |
| `broken_pixel_panel.gd` | Configura aberturas de bloques de 32 unidades y profundidad de 24 para el inicio y el fondo de las páginas. |
| `pixel_style_box.gd` | Mantiene los estados de botones/campos e incorpora la variante de tarjetas con ruptura de 16 unidades. |
| `fracture_animator.gd` | Usa un solo reloj para superficies y emblema: intervalo mínimo de 0,05 s en el inicio animado y 0,16 s en las otras vistas. |
| `game.gd` | Construye el menú, registra superficies y conecta las preferencias de movimiento/consumo. |

En el inicio, la terminal está **dentro del mismo menú**, sin prolongación
derecha. Primero escribe `tree -a /campus` o `tree /F /A`; después simula 170
líneas por segundo y alterna sistema cada 24 segundos. Se generan solamente
las filas visibles, hasta 48: el contador puede superar tres mil líneas por
ejecución sin conservar ese historial en memoria ni crear controles por fila.
Las carpetas y archivos son ficticios; no se leen rutas ni se ejecutan comandos.
En las páginas interiores se conserva el árbol breve, con menor intensidad.
La cabecera del inicio queda reservada para título y partida; la salida se
extiende por la zona de acciones dentro del mismo panel.

La silueta del inicio usa ruido determinista en sus cuatro lados y bloques
de 16 unidades dentro de la configuración de ruptura de 32. No repite el
antiguo patrón de filas. Como decisión de frontend, comienza a erosionarse
después de una espera inicial de 12 segundos, con etapas cada 8: primer
desprendimiento a los 20 y desintegración completa a los 92. Los fragmentos
son negros, tienen duración corta y un máximo de
36 fragmentos simultáneos. La escritura se limita a los tramos que siguen
perteneciendo al fondo. Las posiciones, etiquetas y áreas de interacción no
dependen de la erosión: todas las acciones siguen accesibles al terminar.
Volver a entrar al inicio reinicia el efecto.

Los rellenos de los botones principales usan opacidad parcial según estado:
0,32 normal, 0,56 hover y 0,68 presionado/deshabilitado. El contorno se dibuja
por separado, sin un polígono ni sombra opacos que oculten la terminal debajo.
Las etiquetas permanecen opacas, con contorno negro. La transparencia se limita
a los controles del inicio, con un sombreado también translúcido bajo su texto
para que las líneas rápidas no compitan con la etiqueta. No afecta
a la opacidad de las tarjetas informativas.

El emblema reutiliza dos mallas, una para Sistemas y otra para Informática,
además de su representación compuesta estática. Los dos símbolos flotan con
desplazamientos pequeños y distintos, ajustados a píxeles de la rejilla original.
No se regenera la geometría en cada cuadro ni se modifica el icono de Windows.

El reloj guarda referencias débiles a superficies y emblema y descarta los
controles retirados. Movimiento reducido y bajo consumo detienen escritura,
erosión, fragmentos y emblema, dejando una silueta estática. No existe un
temporizador por tarjeta ni otro reloj para el logo. La temática de cada
mención permanece detrás de las tarjetas.

La fuente pixel propia se aplica ahora también a textos pequeños, campos,
selectores, ecuaciones, grafos y modelos didácticos; no solo títulos y botones.
El atlas generado contiene 207 glifos originales, incluidos ASCII, español,
ramas de árbol y notación matemática. Se mantiene la sustitución del motor
para caracteres excepcionales no incluidos, por ejemplo nombres introducidos
con otros alfabetos; no se eliminan esos nombres para imponer el estilo.

No se han medido mejoras de FPS. Las optimizaciones comprobables son el uso
de geometría almacenada una vez, menos fórmulas simultáneas en portada, un
reloj compartido y la eliminación de código y recursos que ya no se utilizan.

## Limpieza y compatibilidad

Se eliminaron el antiguo `campus_vector.svg` y su archivo de importación,
las dos exportaciones locales `CAMPUS EN JUEGO.exe/.pck`, el catálogo de citas
de la portada y su reloj, una fuente de sistema que no se utilizaba, conexiones
de hover sin efecto, una función de fondo vacía y una asignación duplicada.
La exportación vigente es `SIS-INF.exe/.pck`. Se actualizaron nombres en guías
vigentes y la estructura del README del juego.

La ruta `Godot/app_userdata/CAMPUS EN JUEGO` todavía se utiliza para recuperar
las partidas existentes. Se conserva expresamente junto con su prueba de
compatibilidad; cambiarla sin migración haría que los perfiles dejaran de
encontrarse. Las referencias históricas fechadas tampoco se borran: documentan
versiones reales, no marca visible del producto actual.

| Responsable | Pendiente | Criterio de cierre |
|---|---|---|
| Motor/guardado | Eventual migración del directorio anterior a SIS-INF. | Copia recuperable, verificación de perfiles/logros/configuración, pruebas de fallo y conservación del origen. No forma parte de esta limpieza visual. |
| Usuario y documentación | Procedencia y permiso del emblema. | Autor y condiciones del material de referencia confirmados. |
| Frontend y empaquetado | Usabilidad y otras GPU/escalados. | Pruebas de lectura, movimiento reducido y ejecución en otras configuraciones. |

Las referencias y pendientes generales del campus continúan en
[Exploración FNI](EXPLORACION_FNI.md). Los resultados ejecutados de esta entrega
se registran en la bitácora; una lista de pruebas no equivale a su ejecución.

## Verificación del avance anterior de emblema y limpieza

Se ejecutaron diez suites, con **5.678 comprobaciones y cero fallos**:

| Prueba | Comprobaciones |
|---|---:|
| `test_cave_visuals.gd` | 311 |
| `test_compact_navigation.gd` | 2.335 |
| `test_pixel_ui.gd` | 669 |
| `test_neon_visuals.gd` | 123 |
| `test_ambient_layout.gd` | 59 |
| `test_frontend_campus.gd` | 194 |
| `test_exploration_navigation.gd` | 900 |
| `test_building_interiors.gd` | 470 |
| `test_story_navigation.gd` | 596 |
| `test_game_integration.gd` | 21 |

Los registros locales están en `game/.test-artifacts/cave-test_*.log`.
La prueba específica verifica que el logo sea una malla reutilizada, sus
colores y límites, el ancho de los botones, las nueve combinaciones de ventana
y texto, el reloj único, la reducción de movimiento, bajo consumo y la
conservación del estado académico. La comprobación general sigue verificando
el acceso al texto y controles sin rueda.

`capture_cave.gd` generó ocho capturas con perfiles ficticios, sin leer ni
escribir partidas personales. Se inspeccionaron portada, texto al 120%, campus,
materias y opciones con el renderizador real. Las capturas muestrean una fase
válida de la animación verde y la congelan para la inspección. Están en
`game/.test-artifacts/cave/`; el controlador utilizó ANGLE. Se exportó Windows
y se comprobó el arranque aislado headless con salida 0, sin errores de scripts.

## Verificación del avance de terminal, tipografía y campus

Consulta y ejecución: 31/10/2026. Se ejecutaron doce suites con **8.003
comprobaciones y cero fallos**. No se suman repeticiones de una misma suite.

| Suite | Comprobaciones |
|---|---:|
| `test_compact_navigation.gd` | 2.335 |
| `test_cave_visuals.gd` | 311 |
| `test_pixel_ui.gd` | 669 |
| `test_neon_visuals.gd` | 123 |
| `test_ambient_layout.gd` | 59 |
| `test_frontend_campus.gd` | 194 |
| `test_exploration.gd` | 518 |
| `test_exploration_navigation.gd` | 900 |
| `test_building_interiors.gd` | 470 |
| `test_story_navigation.gd` | 596 |
| `test_game_integration.gd` | 21 |
| `test_games_room.gd` | 1.807 |

Registros locales: `game/.test-artifacts/terminal-test_*.log`. La nueva suite
incluye acceso a pie a las mesas, conservación de visitas, interior y estado
académico, tipografía pixel, nueve combinaciones de ventana y texto,
ausencia de controles por rueda, juego todavía inactivo, contorno transitable
de A y vegetación exterior estable al reanudar desde E. También comprueba
que los árboles no se generen dentro de las canchas o su margen.

`capture_terminal_campus.gd` genera trece capturas reales en
`game/.test-artifacts/terminal-campus/`, con perfiles ficticios. Se revisaron
ambos árboles de terminal, bloques de Sistemas, paseo, canchas, sala E y
presentaciones, incluido texto al 120% en 900×640. Durante la revisión se
corrigieron árboles sobre la cancha y rótulos tapados. El campus evita
redibujarse continuamente cuando el personaje permanece quieto; no se midió
la diferencia de FPS.

Se exportó `game/build/SIS-INF.exe` con su `.pck` y se comprobó el arranque
headless en un directorio aislado, salida 0 y sin errores de scripts.
El controlador gráfico recurrió a ANGLE. El entorno restringido emitió un
aviso al leer el almacén de certificados de Windows durante importación,
exportación y arranque; no impidió completarlos. No se ha verificado otra GPU,
una sesión de uso con jugadores ni la distribución física actual del campus.
La lógica de las cuatro partidas permanece pendiente para motor/backend en
[Sala de juegos del bloque E](JUEGOS_BLOQUE_E.md).

## Verificación de terminal continua y desintegración del inicio

31/10/2026. Esta precisión sustituye la prolongación lateral del avance
anterior. Se retiraron `terminal_cave.gd` y su UID; no quedan referencias de
código a ese componente. Se añadió `menu_cave.gd`, se separaron las mallas
del emblema y se mantuvo un único reloj de efectos.

Se ejecutaron ocho suites, **4.771 comprobaciones y cero fallos**:

| Suite | Comprobaciones |
|---|---:|
| `test_dynamic_menu.gd` | 1.059 |
| `test_cave_visuals.gd` | 311 |
| `test_compact_navigation.gd` | 2.335 |
| `test_pixel_ui.gd` | 669 |
| `test_ambient_layout.gd` | 59 |
| `test_neon_visuals.gd` | 123 |
| `test_frontend_campus.gd` | 194 |
| `test_game_integration.gd` | 21 |

Registros: `game/.test-artifacts/dynamic-test_*.log`. La suite nueva comprueba
progresión y final de la erosión, límite de fragmentos/filas, escritura de la
orden, miles de líneas, alternancia de sistema, ausencia del costado y
estabilidad de las acciones en nueve combinaciones de ventana/texto. Comprueba
también el emblema con el reloj compartido, movimiento reducido, bajo consumo
y que se pueda abrir Opciones después de la destrucción.

`capture_dynamic_menu.gd` produjo 32 PNG con el renderizador real: ocho vistas
de escritura, salida masiva, Windows, distintas fases de erosión, texto al 120%
y movimiento reducido, además de 24 cuadros muestreados para una vista animada.
Están en `game/.test-artifacts/dynamic-menu/`; `menu-animado.gif` reúne la
secuencia inicial de seis segundos, muestreada cuatro veces por segundo.
Se revisaron las capturas para despejar la cabecera y proteger las etiquetas
sin ocultar por completo la salida bajo los botones.

Se actualizó `game/build/SIS-INF.exe/.pck`. El arranque headless aislado y el
resultado de exportación se registran en los archivos `dynamic-export.log`
y `dynamic-smoke/`, dentro de `.test-artifacts`. No se midió rendimiento
comparativo ni se verificaron otras GPU o una sesión de uso con jugadores.
El aviso de certificados del entorno restringido y el uso de ANGLE se
mantienen como limitaciones de esta máquina, sin errores de scripts en las
comprobaciones finales.

Siguen pendientes la aprobación visual del usuario, ensayos con jugadores,
otras GPU y medidas de rendimiento comparables. La reducción de trabajo
descrita arriba no se presenta como una medición de velocidad.
