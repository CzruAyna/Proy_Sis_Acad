# Registro de verificaciones

## Candidato 0.1.0-beta.1 · 10 de noviembre de 2026

- Windows x64. Dos instalaciones consecutivas en una carpeta de prueba.
  Se comprobó el acceso de Inicio, el registro de desinstalación y el
  arranque headless del juego instalado. Con el ejecutable bloqueado, el
  desinstalador conservó los archivos y el registro. Al liberar el archivo,
  retiró la instalación y el acceso directo y conservó el perfil de prueba.
- Linux x86_64. Se comprobaron la arquitectura ELF, el PCK y los permisos
  de ejecución. Se ensayó el instalador en un entorno simulado con una
  ruta que contiene espacios, incluida la reinstalación, la desinstalación
  y el rechazo de una arquitectura distinta. Falta el arranque en Linux.
- macOS Universal. Se comprobaron las dos arquitecturas del binario, los
  permisos de ejecución, el PCK y los recursos de firma. Quedan pendientes
  una prueba en macOS y la notarización.
- Pasaron seis suites de navegación, malla, vida del campus y partida
  con 6.743 aserciones. Se retiraron cinco comprimidos redundantes u
  obsoletos, por un total de 46.478.262 bytes.

Los archivos de prueba y el procedimiento para reproducir el empaquetado
se describen en [Instaladores de SIS-INF](INSTALADORES_BETA.md).

## Ejecución del 9 de noviembre de 2026 · ramas, terreno y misiones

Cambios locales sobre `4cd9fdc`. Godot 4.7.2 en Windows, con perfiles
aislados. Se completaron **15 suites con 95.165 aserciones y cero fallos**.
El total incluye 74.725 aserciones de la historia demostrativa.

- `graph_interaction` verificó en los cinco planes el enlace acumulado de
  `SIS 1110` a `SIS 2210`, el cambio de rama, el encuadre y que el plan
  completo conserve todas las correlativas. `graph_clearance` y la misma
  suite comprobaron separación de aristas y esferas.
- `exploration_navigation`, `exploration_handoff` y `frontend_campus`
  verificaron el zoom con rueda y teclado, el acceso con clic y E, el paso
  de matrícula a inicio y parcial, y el regreso al recorrido. Se comprobó
  el anclaje del sprite y la navegación con el texto aumentado.
- Se revisaron cinco capturas de la misión, el terreno, el mapa, el grafo
  inicial, la rama ampliada y la ficha. El ejecutable de Windows arrancó
  en headless con código 0. Godot avisó sobre el almacén de certificados
  del entorno de prueba. Queda pendiente una partida completa en ese
  ejecutable y las confirmaciones descritas en
  [Ramas, terreno y misiones](RAMAS_TERRENO_Y_MISIONES.md).

## Ejecución del 9 de noviembre de 2026 · exploración contextual y malla

Cambios locales sobre `286f86a`. Godot 4.7.2 en Windows con perfiles aislados.
La matriz de esta entrega reúne **17 suites y 97.380 aserciones sin fallos**.
Cada suite se cuenta una vez. Para exploración se usó la repetición posterior
al ajuste visual del reloj.

| Grupo | Suites | Aserciones |
|---|---|---:|
| Inicio, campus y navegación | `dynamic_menu`, `cave_visuals`, `compact_navigation`, `frontend_campus`, `ambient_layout`, `player_rules` | 3.067 |
| Malla y demostración | `graph_interaction`, `graph_clearance`, `neon_visuals`, `career_story` | 82.254 |
| Exploración e interiores | `exploration_navigation`, `exploration`, `large_campus`, `natural_campus`, `campus_life`, `building_interiors`, `games_room` | 12.059 |

Se comprobó el encuadre inicial de esferas de los cinco planes, el
arrastre con separación de aristas y la ficha con Enter y clic fuera.
Se probó la navegación con letra al 120 %, el acceso a la ventanilla
con E y el ciclo visual completo. Se revisaron capturas del inicio,
campus, Materias, malla, ficha, retorno y exploración de día y noche.

Se exportó Windows x64 y el ejecutable arrancó en modo headless con código 0.
Godot emitió el aviso de lectura del almacén de certificados del entorno
aislado. Quedan pendientes una sesión completa con ese ejecutable y la
validación institucional descrita en
[Exploración contextual y malla](EXPLORACION_CONTEXTUAL_Y_MALLA.md).

La revisión documental del 9 de noviembre de 2026 contrastó el historial de
commits con los movimientos de `origin/main` y revisó las guías contra el
código. Los resultados que siguen corresponden a las ejecuciones de sus
respectivas entregas.

## Ejecución del 9 de noviembre de 2026 · depuración

Cambios sobre `72b6443` incorporados en `4095c2e`, con Godot 4.7.2 en
Windows. Pasaron las 29
suites de `game/tests/test_*.gd`, con 113.728 aserciones. Se repitieron las
11 suites de exploración, interiores y sala E afectadas por los últimos
ajustes. Se aisló el directorio de partidas para las pruebas.

La cobertura nueva comprueba entradas a aulas en cada piso, una sola
actualización de estado al regresar al pasillo, reanudación y recuperación
ante campos de guardado malformados. Las pruebas de interacción usan E,
Enter y clic para abrir los juegos y prueban P y M desde el campus.

En una medición local de cinco repeticiones de 30.000 consultas en LSIA-1,
la mediana bajó de 654 a 274 ms. Las dos versiones aceptaron los mismos
18.636 puntos. Un paso horizontal de 0,1 s hizo 4 consultas exteriores
frente a 8, con el mismo desplazamiento. Los tiempos corresponden a la
colisión aislada. Queda por medir FPS sostenidos y consumo en otros equipos.
Los registros locales están en `game/.test-artifacts/audit-1109-final/`.

Se regeneraron `game/build/SIS-INF.exe` y `SIS-INF.pck`. El registro del
exportador confirma que el paquete contiene la cartografía derivada. El
ejecutable arrancó en modo headless con un perfil aislado y salió con código
0. Los recorridos y minijuegos se probaron con el proyecto fuente.

## Ejecución del 8 de noviembre de 2026 · menús y perímetro

Cambios incorporados en `72b6443`, Godot 4.7.2 en Windows. Se usaron
directorios de prueba independientes de las partidas personales.

| Suite | Aserciones | Fallos |
|---|---:|---:|
| `test_compact_navigation` | 2.228 | 0 |
| `test_dynamic_menu` | 663 | 0 |
| `test_cave_visuals` | 275 | 0 |
| `test_exploration_navigation` | 428 | 0 |
| `test_exploration` | 524 | 0 |
| `test_large_campus` | 1.423 | 0 |
| `test_natural_campus` | 4.658 | 0 |
| `test_campus_life` | 2.731 | 0 |
| `test_player_rules` | 64 | 0 |
| `test_grid8_and_cast` | 711 | 0 |
| `test_games_room` | 1.714 | 0 |
| `test_exploration_handoff` | 34 | 0 |
| **Subtotal de suites aprobadas** | **15.453** | **0** |
| `test_building_interiors` | 434 | 17 |

Una copia limpia de `f79e107` reprodujo los 17 fallos de interiores en el
mismo orden. Afectan las comprobaciones de entrada con E, registro de aula y
colisión interior. La depuración del 9 de noviembre vuelve a cubrir esos
recorridos en `4095c2e`.

Se comprobó el inicio centrado en tres tamaños de ventana y el acceso a
controles con escala de letras de hasta 120 %. En el mapa se verificaron
el zoom, la posición de la flecha, el desplazamiento por teclas, el
restablecimiento y la ausencia de acciones de destino. Las 40 entradas del
exterior resultaron transitables. Se verificó el bloqueo de la malla y el
muro y la abertura del ingreso. Tras sumar el cerco, Física y Sistemas A
se mantienen en 6,31 s y 14,67 s. Básicas pasa de 14,03 s a 14,27 s.

Se generaron siete capturas gráficas a 1152 × 720 del inicio, el foco,
Jugar, Opciones, el acceso y el mapa en dos escalas. El controlador gráfico
usó ANGLE. La exportación Windows x64 empaquetó el perímetro y el JSON
cartográfico. El arranque aislado terminó con código 0 y emitió el aviso
de certificados de Windows. Queda pendiente un recorrido manual completo
en el ejecutable exportado.

## Ejecución del 8 de noviembre de 2026 · cartografía y escala

Cambios incorporados en `f79e107`, Godot 4.7.2 en Windows, con datos de usuario
aislados de las partidas personales.

| Suite | Aserciones | Fallos |
|---|---:|---:|
| `test_exploration` | 524 | 0 |
| `test_grid8_and_cast` | 711 | 0 |
| `test_campus_life` | 2.728 | 0 |
| `test_large_campus` | 2.051 | 0 |
| `test_natural_campus` | 4.631 | 0 |
| `test_exploration_handoff` | 34 | 0 |
| `test_games_room` | 1.728 | 0 |
| **Total** | **12.407** | **0** |

Se comprobó la llegada a las 40 entradas, tres caminatas con colisiones y
una migración v2 con visitas y encuentro de Piedritas. Los tiempos, escala y
límites de la medición están en [Cartografía y escala](CARTOGRAFIA_FNI_Y_ESCALA.md).
La conversión del recorte externo reprodujo el JSON empaquetado byte por byte.
Se generaron capturas con el renderizador gráfico y se revisaron el ingreso
y el mapa de orientación. El atlas contiene 64 celdas con límites comprobados,
66 PNG de dimensiones verificadas y un ZIP cuya prueba de integridad pasó.

Se exportaron `SIS-INF.exe` y su `.pck`, que incluye el JSON cartográfico.
El arranque headless del ejecutable terminó con código 0. Godot informó que
no pudo leer los certificados de Windows durante el arranque aislado. Las
pruebas son locales. Quedan pendientes mediciones de campo y comprobar una
sesión completa con el ejecutable exportado.

## Ejecución del 6 de noviembre de 2026: vida y bajo consumo

Cambios incorporados en `113037c`. Godot 4.7.2, Windows.
Estas suites se ejecutaron nuevamente; no se suman a resultados históricos.

| Suite | Aserciones | Fallos |
|---|---:|---:|
| `test_campus_life` | 2.728 | 0 |
| `test_natural_campus` | 4.641 | 0 |
| `test_dynamic_menu` | 645 | 0 |
| `test_cave_visuals` | 230 | 0 |
| `test_grid8_and_cast` | 711 | 0 |
| `test_player_rules` | 64 | 0 |
| `test_exploration` | 558 | 0 |
| `test_recreation_surface` | 291 | 0 |
| `test_exploration_handoff` | 34 | 0 |
| **Total de esta matriz** | **9.902** | **0** |

`test_campus_life` compara 2.500 posiciones contra la colisión anterior,
recorre aulas y baños de cada planta, comprueba guardado, rareza, caricias,
logros, datos malformados, límites de caché/FPS y botones reales de escaleras.
En 120 segundos de rutina simulada, 15 personajes alcanzaron clases y hubo
132 búsquedas de rutas. No prueba todas las combinaciones posibles de destinos.
Las expectativas de los tests anteriores se actualizaron para el catálogo
ampliado de logros y para rutinas funcionales que siguen con movimiento reducido.

`capture_campus_life.gd` generó cinco vistas de 1152×720 con datos ficticios,
sin guardar partidas personales. Se revisaron escaleras, acción de caricia y
opciones de bajo consumo. El controlador gráfico emitió un aviso de OpenGL y
usó ANGLE sobre AMD Radeon R5 M330; no hubo errores de scripts en esa captura.
Los logs/capturas están en `game/.test-artifacts/` y se excluyen de la entrega.

Se exportó `game/build/SIS-INF.exe` con su `.pck`. El arranque headless aislado
del binario terminó con código 0 y log sin errores. El primer intento bajo
aislamiento informó que no podía leer los certificados de Windows; se repitió
fuera de esa restricción con un directorio de usuario de prueba y quedó limpio.
Esta comprobación confirma el arranque, no una sesión completa en el binario.
Se prepararon ZIP locales de Windows x64 y fuentes correspondientes, con GPL
y avisos extraídos del motor; se comprobó la integridad de ambos archivos.

Los tiempos comparados y sus límites están en
[Vida del campus y rendimiento](VIDA_CAMPUS_Y_RENDIMIENTO.md). No se midieron
FPS sostenidos, memoria de una sesión larga ni rendimiento en otro equipo.

## Caminos, inicio y ambientes: 06/11/2026

Cambios incorporados en `e206909`. Se ejecutaron once suites con Godot 4.7.2
y datos ficticios. Cada registro está en `game/.test-artifacts/nov6-<nombre>.log`.
Los resultados corresponden a esta entrega; no se suman a los cortes anteriores.

| Script `test_<nombre>.gd` | Aserciones | Fallos |
|---|---:|---:|
| `natural_campus` | 4.641 | 0 |
| `exploration` | 558 | 0 |
| `building_interiors` | 425 | 0 |
| `dynamic_menu` | 645 | 0 |
| `exploration_navigation` | 936 | 0 |
| `large_campus` | 2.079 | 0 |
| `games_room` | 1.728 | 0 |
| `career_presentation` | 2.803 | 0 |
| `career_story` | 74.725 | 0 |
| `grid8_and_cast` | 711 | 0 |
| `exploration_handoff` | 34 | 0 |

Total: **89.285 aserciones sin fallos**. Una aserción no equivale a un caso
de usuario independiente. La mayor parte procede de los recorridos múltiples
de la historia de carrera. La suite nueva comprueba orientación, conexión de
caminos, acceso a todos los ambientes, mobiliario sólido, corredor central,
salida y actividades; también los cuatro botones del inicio con/sin guardados,
Jugar y Simular a 900×640, 1152×720 y 1600×900, con letras de 80 %, 100 % y 120 %.

Durante la implementación se corrigió una inferencia de tipo en el renderizador.
La primera revisión de navegación detectó que Simular ocultaba la identidad
de una partida activa: ahora se conserva en Jugar y Simular. La comprobación
de curvas distingue un tramo recto sin giros, que debe conservar sus extremos.
La importación final utilizó un perfil aislado y terminó sin errores de script.

La sesión gráfica produjo **16 capturas** en `nov6-diseno/`: inicio, Jugar,
Simular, mapa, sala de juegos, diez ambientes y un empalme. Se revisaron las
proporciones, mobiliario, márgenes y orientación; se corrigió el desborde de
baldosas antes de regenerar las capturas. La comprobación de cuatro muestras
del renderizado del cruce confirmó superficie continua (`ROAD_JUNCTION_RASTER:
true`, en `nov6-captures.log`). La sesión gráfica usó ANGLE.

El exportador regeneró 64 láminas de 1600×1520, índice de 1632×1272 y conjunto
de 6144×4352. Se validaron los 66 PNG, códigos A1–H8, intervalos, fecha y
orientación del JSON, enlaces del documento nuevo y ZIP. Registro gráfico:
`nov6-map-export.log`; auditoría local reproducible: `nov6_audit.py`.

La exportación Windows terminó con salida cero (`nov6-build.log`). El arranque
del ejecutable con perfil aislado también terminó con salida cero
(`nov6-smoke.log`). Se montó el PCK y se comprobaron los cuatro botones,
accesos de Jugar/Simular y tamaño nuevo de Física; no estaban los originales de
planos/logo (`nov6-pack-audit.log`). Los avisos del almacén de certificados
del equipo no impidieron estas operaciones locales. No se verificó red.

Las fotografías de RTvU–UTO se observaron en el navegador y no se copiaron al
proyecto. Siguen pendientes dimensiones y plantas reales, asignación de cada
foto a un aula, interacción con equipos, ocupación interior por NPC y
rendimiento en otros equipos. No se modificaron reglas académicas, Django,
Next.js ni partidas personales. [Contrato y fuentes](CAMINOS_MENU_Y_AMBIENTES.md).

## Matriz 8×8, retirada de originales y personajes: 04/11/2026

Cambios incorporados en `c0bd256`. Se ejecutaron estas siete suites con Godot
4.7.2 y perfiles ficticios. Registros en `game/.test-artifacts/`:

| Script en `game/tests/` | Aserciones | Fallos | Registro |
|---|---:|---:|---|
| `test_grid8_and_cast.gd` | 711 | 0 | `grid8-cast-tests.log` |
| `test_exploration.gd` | 558 | 0 | `grid8-exploration-tests.log` |
| `test_building_interiors.gd` | 479 | 0 | `grid8-interiors-tests.log` |
| `test_large_campus.gd` | 2.075 | 0 | `grid8-large-tests.log` |
| `test_exploration_navigation.gd` | 932 | 0 | `grid8-navigation-tests.log` |
| `test_exploration_handoff.gd` | 34 | 0 | `grid8-handoff-tests.log` |
| `test_games_room.gd` | 1.740 | 0 | `grid8-games-room-tests.log` |

Total de esta matriz de pruebas: **6.529 aserciones sin fallos**. No se suman
con ejecuciones anteriores. Los casos nuevos comprueban cobertura de las 64
celdas, coordenadas, retirada de originales, aumento de sprite/radio/velocidad,
ajuste local de un guardado, 24 estudiantes diferentes, 51 paseantes,
obstáculos durante el paseo, pausa, movimiento reducido, regreso desde un
interior y redibujado al detenerse. Las suites de interfaz recorren páginas
y fichas al 100 % y 120 %, sin rueda ni deslizadores. El acceso a mesas sigue
probando E, Enter y el botón visible.

La primera ejecución de exploración detectó que redondear la puerta a una
rejilla de 16 unidades situaba el punto de prueba dentro de la huella ampliada
de la pared. Se comprueba ahora una celda exterior y el tramo libre hasta la
puerta. La tolerancia diagonal pasó a 0,01 unidades para los redondeos de
Vector2 a mayor velocidad y coordenadas grandes. También se corrigió un error
de inferencia de tipo durante la implementación antes de repetir las suites.

El exportador produjo 64 láminas de 1600×1520, un índice de 1632×1272 y el mapa
completo de 6144×4352, con JSON y ZIP. La comprobación de archivos validó las
dimensiones de los 66 PNG, 64 códigos de celda, cobertura sin huecos, 67
referencias de elementos y enlaces de documentación. Se revisaron el índice
y una lámina detallada. La captura de interfaz produjo 21 PNG: se revisaron
el personaje y perros ampliados, la guía de coordenadas, retratos, personal,
planos y laboratorios. Los registros son `grid8-map-export.log` y
`grid8-capture.log`; las sesiones gráficas usaron ANGLE.

La exportación Windows terminó con salida cero. Se montó el PCK con Godot:
los dos planos y el PNG del logo original no estaban disponibles ni tenían
sus metadatos de importación; el icono pixel art sí estaba presente. El
ejecutable arrancó con perfil aislado y terminó con salida cero. Registros:
`grid8-export.log`, `grid8-pack-audit.log` y `grid8-smoke.log`. La importación,
exportación y arranque informaron el aviso del almacén de certificados del
equipo, sin impedir esas operaciones locales; no se validaron funciones de red.

La consulta de Google Maps sí permitió ver el campus en satélite; la fecha de
la imagen no quedó confirmada. Falta validar fachadas, plantas, escala en
metros y rendimiento en otros equipos. Los paseos son ambientales y no prueban
horarios, asistencia a clases, caricias, rareza ni logros. Fuentes y contratos en
[Matriz 8×8 y personajes](MAPA_8X8_Y_PERSONAJES.md). No se modificaron partidas
personales ni se ejecutaron servicios Django o Next.js.

## Campus ampliado: ejecución del 03/11/2026

Cambios locales sin commit propio, posteriores a la exportación de minijuegos
registrada arriba. Se ejecutaron estas cuatro suites con Godot 4.7.2, sobre el
checkout compartido y usando perfiles ficticios. Los registros están bajo
`game/.test-artifacts/`, excluidos del control de versiones.

| Script en `game/tests/` | Aserciones | Fallos | Registro |
|---|---:|---:|---|
| `test_large_campus.gd` | 1.735 | 0 | `large-test.log` |
| `test_exploration.gd` | 518 | 0 | `large-regression-exploration.log` |
| `test_building_interiors.gd` | 479 | 0 | `large-regression-interiors.log` |
| `test_exploration_navigation.gd` | 932 | 0 | `large-regression-navigation.log` |

Total de esta ejecución: **3.664 aserciones sin fallos**; no se suman con los
totales históricos ni con las suites paralelas de minijuegos. Cubren accesos,
interiores, guardado, migración del mapa anterior, colisiones del agua y bases,
diseños, planos, apertura con E, pausa, regreso, foco y fichas completas a
900 × 640 y 1152 × 720 con texto al 100 % y 120 %. No se hallaron errores de
script en esos cuatro registros. La prueba de accesibilidad global usa una
rejilla de 16 unidades para mantener acotada la búsqueda en el mapa ampliado;
los interiores y puertas mantienen sus comprobaciones puntuales.

`capture_large_campus.gd` produjo veinte capturas de 1152 × 720 en
`game/.test-artifacts/large-campus/`. Se revisaron visualmente el ingreso,
las fichas y retratos de las dos estatuas, bosque, laguna, catálogo, planos y
laboratorios. Las capturas usan un perfil aislado, con animaciones desactivadas.
El controlador de esta GPU cambió automáticamente a ANGLE; no hubo errores de
script en la captura. El efecto animado de ruptura no se midió fotograma a
fotograma ni se hizo una sesión humana completa del campus.

La importación y la exportación `Windows Desktop` terminaron con salida cero.
Se actualizaron `game/build/SIS-INF.exe` y `SIS-INF.pck`; el arranque headless
del ejecutable, con perfil aislado y `--quit-after 5`, terminó con salida cero.
Registros: `large-import.log`, `large-export.log` y `large-smoke.log`. Godot
informó `Failed to read the root certificate store` durante esas operaciones;
no impidió importar, exportar ni arrancar el juego local. No se verificaron
funciones de red ni el almacén de certificados del equipo. El arranque del
binario no sustituye una prueba interactiva de todas sus pantallas.

Pendientes de esta ampliación: verificación de plantas y datos institucionales,
fuentes originales de Piedritas y su organización, recorridos y horarios de
NPC, caricias/logros, rareza y cambio de planta del motor. Los contratos están
en [Campus ampliado](CAMPUS_AMPLIADO_Y_VIDA_DEL_CAMPUS.md). No se ejecutaron
Django ni Next.js ni se modificaron partidas personales.

## Ampliación de tableros del 3 de noviembre de 2026

Cambios locales posteriores a la primera corrección del día; sin commit nuevo.
No sumar este total al de otras entregas: se repiten suites de regresión.
Comando base desde la raíz, con Godot 4.7.2 para Windows:

```powershell
.\game\.tools\Godot_v4.7.2-stable_win64_console.exe --headless --path game --script res://tests/NOMBRE.gd
```

| `NOMBRE` | Aserciones | Fallos |
|---|---:|---:|
| `test_eight_ball` | 179 | 0 |
| `test_recreation_surface` | 291 | 0 |
| `test_recreation_ui` | 154 | 0 |
| `test_games_room` | 1.737 | 0 |
| `test_career_presentation` | 2.781 | 0 |
| `test_exploration_handoff` | 34 | 0 |
| `test_recreation_models` | 9.246 | 0 |
| Total de esta ampliación | 14.422 | 0 |

La prueba de modelos conserva el motor antiguo de seis bolas y comprueba el
nuevo mediante la fábrica de sesiones; los casos específicos de ocho bolas
están en `test_eight_ball`. Esta última cubre grupos, apertura, negra legal,
negra anticipada, tronera equivocada, blanca embocada, colocación, contactos,
bandas, JSON y reanudación de un tiro. La prueba de superficie usa eventos de
ratón y teclado en las acciones principales, además de comprobar piezas
distintas, caché, casillas sin superposición e impulso humano con saque rival.

La prueba de presentación comprueba elección y persistencia del personaje de
pausa, ausencia de repetición inmediata y los mensajes de pausa/continuación a
frontend. Esto **no verifica el diseño del personaje**: todavía está pendiente.

`capture_recreation_surface.gd` produjo doce capturas reales en
`game/.test-artifacts/recreation-v2/`: cuatro tableros, apertura física, impulso,
dados animados, cuatro vistas a 900×640/120 % y ajedrez a 1600×900. Se revisaron
visualmente piezas, bolas, troneras, texto, propiedades y marco. El controlador
gráfico informa el cambio automático de AMD/OpenGL a ANGLE. No se usaron
partidas personales. Los registros de las tres suites nuevas/ampliadas se
conservan como `.log` en esa carpeta local ignorada.

El primer intento de registrar las suites usó una ruta `res://` en `--log-file`,
que Godot rechaza antes de iniciar. Se corrigió a ruta absoluta de Windows;
las aserciones del primer intento también terminaron sin fallos. Un ensayo
anterior detectó la conversión de enteros a decimales en JSON para los grupos;
el cargador ahora valida y normaliza los identificadores antes de compararlos.

La exportación `Windows Desktop` terminó con salida cero; su registro es
`game/.test-artifacts/recreation-v2/export.log`. El ejecutable se abrió con
renderizador gráfico y perfil aislado y finalizó con salida cero. Esa prueba
confirma arranque/cierre: el intento de cargar un script externo mediante
`--script` no ejecutó el arnés en la plantilla release, por lo que **no se
contabiliza como prueba de las cuatro mesas dentro del binario**. Las mesas
se comprobaron con las suites y las capturas del proyecto. No se conservó
ese arnés externo sin uso. Los cambios paralelos del campus aparecidos después
de esa exportación quedan fuera de esta comprobación de minijuegos.

## Láminas por cuadrantes del 03/11/2026

Se comprobó la sintaxis de `tools/export_campus_quadrants.gd` y se ejecutó su
renderizador gráfico con perfil aislado. Produjo cuatro láminas de 3200 × 2760,
un mapa unido de 6144 × 4352, un índice de 1632 × 1272 y un JSON de referencias.
Los cuatro cuadrantes incluyen 15, 15, 19 y 25 marcadores respectivamente, con
repetición de los elementos que atraviesan el corte. Se revisaron visualmente
los rótulos, leyendas y correspondencia del mapa. Una comprobación de los
archivos validó los seis tamaños PNG, 67 códigos únicos, porcentajes válidos,
ausencia de códigos duplicados en cada cuadrante y enlaces locales existentes.
No se ejecutaron otra vez las
suites de juego ni se exportó un binario nuevo para esta entrega de imágenes.
El script queda fuera del paquete del juego mediante la exclusión de `tools/*`.
Los registros y límites se explican en
[Mapa para correcciones](MAPA_PARA_CORRECCIONES.md).

## Ejecución del 3 de noviembre de 2026 · terminal y apertura de mesas

Cambios incorporados en `b3d549b`; no sumar estos resultados a los de versiones
anteriores. Motor: Godot 4.7.2, Windows. Comando desde la raíz:

```powershell
.\game\.tools\Godot_v4.7.2-stable_win64_console.exe --headless --path game --script res://tests/NOMBRE.gd
```

| `NOMBRE` | Aserciones | Fallos |
|---|---:|---:|
| `test_exploration_handoff` | 34 | 0 |
| `test_career_presentation` | 2.771 | 0 |
| `test_building_interiors` | 479 | 0 |
| `test_games_room` | 2.097 | 0 |
| `test_recreation_ui` | 172 | 0 |
| Total de esta ejecución | 5.553 | 0 |

Se inspeccionaron también las salidas: el primer ensayo de entrada reprodujo
`Cannot call method 'set_input_as_handled' on a null value` en
`campus_world.gd`, aunque el proceso devolvía cero. La ejecución final de la
nueva prueba no contiene ese error y cubre E, Enter, botón, mapa y progreso.
El primer ensayo del menú detectó altura excesiva al 120 % con una partida
reciente; se redujo su separación y la matriz final quedó sin fallos.

`capture_exploration_presentation.gd` produjo ocho capturas reales a 900×640,
texto 120 %, en `game/.test-artifacts/presentation/`: menú, terminal, personaje
en ambas direcciones y apertura de cuatro mesas mediante entrada de teclado.
Se revisaron visualmente terminal, anclaje e icono; el resto acredita que se
generaron las vistas, no una evaluación prolongada de dificultad. La ejecución
gráfica final sólo informa el cambio automático del controlador AMD a ANGLE.

La exportación release de `Windows Desktop` terminó con código cero y generó
`game/build/SIS-INF.exe` y su `.pck`. El ejecutable arrancó en modo headless,
con perfil de prueba aislado y `--quit-after 5`, sin errores, salida cero.
Se extrajo del EXE su icono nativo y se comprobó el diseño pixel art. Los ICO
incluyen tamaños 16, 24, 32, 48, 64, 128 y 256; el icono de ventana se asigna
también con `DisplayServer.set_icon()`.

No se realizó una exhibición durante horas, una auditoría de normas vigentes
ni una comprobación en otros equipos/cachés de la barra de tareas de Windows.
El bucle se verificó en tiempo simulado. El contrato pendiente de animaciones
y de contenidos institucionales está en [Modo demostrativo](MODO_DEMOSTRATIVO.md).

## Revisión documental del 2 de noviembre

Se contrastan mensajes completos, diferencias, rutas, reglas y documentación.
El detalle de cada commit está en [Historial](HISTORIAL_COMMITS.md). Los
resultados nuevos, si se ejecuta alguna suite, deben registrarse por separado
con comando, versión, salida y ubicación del registro.

Las pruebas gráficas necesitan renderizador y perfiles ficticios. Las pruebas
del modelo no sustituyen una revisión visual o partidas con jugadores. Para
ejecutar las suites, consultar [Desarrollo local](DESARROLLO_LOCAL.md).

## Ejecución acotada del 2 de noviembre

Código: `b122e96`, sin cambios en los scripts. Motor: Godot 4.7.2.
Se ejecutaron tres suites en modo headless, con `APPDATA` y `LOCALAPPDATA`
apuntando a un directorio de revisión aislado.

| Script en `game/tests/` | Comprobaciones | Fallos | Salida |
|---|---:|---:|---:|
| `test_recreation_models.gd` | 9.246 | 0 | 0 |
| `test_game_integration.gd` | 21 | 0 | 0 |
| `test_simulation_storage.gd` | 18 | 0 | 0 |
| **Total de esta ejecución** | **9.285** | **0** | |

Godot emitió `Failed to read the root certificate store` al arrancar.
Los procesos finalizaron con salida 0 y no hubo fallos de las aserciones.
El mensaje no se oculta ni se toma como comprobación de funciones de red.

Los registros quedan en `tmp/revision_2026_11_02/tests/` de la carpeta externa
de documentación, uno por suite. No se ejecutaron las otras 18 suites,
las capturas del juego ni pruebas de backend o frontend web en esta revisión.
Esto verifica un alcance concreto, no todas las funciones del producto.

## Resultados registrados hasta el 2 de noviembre

Esta tabla conserva lo que los documentos de cada versión informaron. No
equivale a ejecutar otra vez esos tests ni a recuperar todos sus registros
locales. Una comprobación es una aserción del script; no necesariamente un
caso de usuario distinto. Los totales pertenecen a versiones diferentes y
no deben sumarse como cobertura acumulada.

| Commit | Suites informadas | Comprobaciones informadas | Capturas informadas | Documento de esa versión |
|---|---:|---:|---:|---|
| `0d5b259` | 4 | 1.826 | 12 | `docs/PENDIENTES_FRONTEND_SIMULACION.md` |
| `23b5dd0` | 5 | 7.283 | 31 | `docs/DISENO_VISUAL_CAMPUS.md` |
| `b28cf38` | 9 | 10.898 | 19 | `docs/BITACORA_DESARROLLO.md` |
| `389dc82` | 8 | 6.305 | 10 | `docs/BITACORA_DESARROLLO.md` |
| `a663c1a` | 7 | 4.497 | 8 | `docs/BITACORA_DESARROLLO.md` |
| `f49ec69` | 10 | 5.678 | 8 | `docs/BITACORA_DESARROLLO.md` |
| `6515d1c` | 12 | 8.003 | 13 | `docs/BITACORA_DESARROLLO.md` |
| `865d7e1` | 8 | 4.771 | 32 | `docs/BITACORA_DESARROLLO.md` |
| `b122e96` | 5 | 12.004 | 11 | `docs/BITACORA_DESARROLLO.md` |

La referencia es el contenido del documento en ese commit, no su versión
actual. Los archivos de `game/.test-artifacts/` son locales e ignorados por Git.
La ausencia de un log en otra copia del repositorio no prueba que la ejecución
no ocurriera, pero impide verificar ese resultado únicamente con ese archivo.

En `b122e96` la matriz registrada fue: modelos recreativos 9.246, interfaz
recreativa 172, sala E 2.095, interiores 470 e integración 21. El diagnóstico de
ajedrez de 474 nodos y 210 ms corresponde a una ejecución y una posición; no
es una medición de FPS ni una garantía de rendimiento general.

## Límites generales pendientes

- Dificultad percibida y sesiones prolongadas con jugadores.
- Rendimiento comparado, otros equipos, GPU y sistemas operativos.
- Reproducción de todos los resultados históricos desde sus versiones.
- Validación institucional de mallas, espacios y trámites.
- Compilación y pruebas de Django y Next.js en esta revisión documental.
