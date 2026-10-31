# Emblema geométrico y superficies de ruptura

Actualizado: 31 de octubre de 2026. Estado: implementación local, sin commit
creado por esta entrega.

## Presentación vigente

El inicio utiliza un emblema pixelado de fondo, construido con funciones y
geometría. No carga una textura para representar ese emblema dentro del menú.
Los paneles negros adoptan una ruptura de bloques grandes, escalones y capas
oscuras, extendida a las pantallas interiores y tarjetas de contenido. Botones
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
| `fracture_geometry.gd` | Dibuja las capas y bordes escalonados; comparte la geometría entre superficies. |
| `broken_pixel_panel.gd` | Configura aberturas de bloques de 32 unidades y profundidad de 24 para el inicio y el fondo de las páginas. |
| `pixel_style_box.gd` | Mantiene los estados de botones/campos e incorpora la variante de tarjetas con ruptura de 16 unidades. |
| `fracture_animator.gd` | Usa un solo reloj para actualizar las superficies visibles, como máximo una vez cada 0,16 segundos. |
| `game.gd` | Construye el menú, registra superficies y conecta las preferencias de movimiento/consumo. |

Las letras verdes aparecen de forma intermitente en márgenes reservados de
las superficies negras, con entrada/salida gradual. Son fragmentos decorativos
de código; no ejecutan comandos ni representan un sistema conectado. El reloj
guarda referencias débiles a los controles, descarta superficies retiradas y
se detiene con movimiento reducido o bajo consumo. No existe un temporizador
por tarjeta. La temática de cada mención permanece detrás de las tarjetas.

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

## Verificación de esta entrega

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

Siguen pendientes la aprobación visual del usuario, ensayos con jugadores,
otras GPU y medidas de rendimiento comparables. La reducción de trabajo
descrita arriba no se presenta como una medición de velocidad.
