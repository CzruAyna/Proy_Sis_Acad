# Emblema geométrico y superficies de ruptura

Actualizado: 31 de octubre de 2026. Estado: implementación local, sin commit
creado por esta entrega.

## Presentación vigente

El inicio utiliza un emblema pixelado de fondo, construido con funciones y
geometría. No carga una textura para representar ese emblema dentro del menú.
Los paneles adoptan una ruptura de bloques grandes y escalones en **negro
puro**, sin rebordes ni capas de otro color, extendida a pantallas interiores
y tarjetas de contenido. Esta precisión sustituye los tonos de las capas
del avance anterior. Botones
y campos mantienen límites continuos para leerlos e interactuar con precisión.

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
| `broken_pixel_panel.gd` | Configura aberturas de bloques de 32 unidades y profundidad de 24 para el inicio y el fondo de las páginas. |
| `pixel_style_box.gd` | Mantiene los estados de botones/campos e incorpora la variante de tarjetas con ruptura de 16 unidades. |
| `fracture_animator.gd` | Usa un solo reloj para actualizar las superficies visibles, como máximo una vez cada 0,16 segundos. |
| `game.gd` | Construye el menú, registra superficies y conecta las preferencias de movimiento/consumo. |
| `terminal_cave.gd` | Continúa la misma abertura detrás del inicio para mostrar el árbol junto a los botones; no es otra ventana ni un menú. |

La salida verde alterna un árbol con `tree -L 3` de Linux y otro con `tree /A`
de Windows. Se escribe por líneas, permanece y se desvanece. En el inicio,
una prolongación irregular del mismo fondo deja visible el árbol junto a
los botones, sin ensanchar sus controles ni agregar otra ventana. En las
páginas interiores queda más tenue para mantener la legibilidad. Los nombres
de carpetas son ilustrativos: no se leen rutas personales ni se ejecutan
comandos. El reloj
guarda referencias débiles a los controles, descarta superficies retiradas y
se detiene con movimiento reducido o bajo consumo. No existe un temporizador
por tarjeta. La temática de cada mención permanece detrás de las tarjetas.

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

Siguen pendientes la aprobación visual del usuario, ensayos con jugadores,
otras GPU y medidas de rendimiento comparables. La reducción de trabajo
descrita arriba no se presenta como una medición de velocidad.
