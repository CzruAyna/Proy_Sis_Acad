# Registro de verificaciones

Revisión documental: 2 de noviembre de 2026. Corte de código: `b122e96`.

## Resultados registrados por las entregas

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

## Alcance de esta revisión

### Ejecución nueva del 3 de noviembre de 2026

Cambios locales sin commit nuevo; no sumar estos resultados a los de versiones
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

### Revisión documental del 2 de noviembre

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

## Límites generales que siguen abiertos

- Dificultad percibida y sesiones prolongadas con jugadores.
- Rendimiento comparado, otros equipos, GPU y sistemas operativos.
- Reproducción de todos los resultados históricos desde sus versiones.
- Validación institucional de mallas, espacios y trámites.
- Compilación y pruebas de Django y Next.js en esta revisión documental.
