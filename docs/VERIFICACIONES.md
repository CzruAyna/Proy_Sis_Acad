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

## Límites que siguen abiertos

- Dificultad percibida y sesiones prolongadas con jugadores.
- Rendimiento comparado, otros equipos, GPU y sistemas operativos.
- Reproducción de todos los resultados históricos desde sus versiones.
- Validación institucional de mallas, espacios y trámites.
- Compilación y pruebas de Django y Next.js en esta revisión documental.
