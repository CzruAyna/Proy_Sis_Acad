# Identidad visual del juego

Actualizado el 28 de octubre de 2026.

El juego mantiene fondos oscuros y utiliza una identidad de color continua desde la selección de carrera hasta el campus, materias, malla, trámites, historial, auxiliatura, estudio, graduación y logros de la partida.

| Carrera | Color principal | Luz neón |
|---|---|---|
| Ingeniería de Sistemas | Azul `#338AFF` | Azul luminoso `#39BCFF` |
| Ingeniería Informática | Rojo `#FF2934` | Rojo luminoso `#FF393D` |

## Fondos por mención

| Mención | Motivo de fondo |
|---|---|
| Dirección y Gestión de Sistemas Empresariales | Flujo de procesos, análisis, decisiones y control. |
| Gestión de la Información | Bases de datos, captura, modelado y análisis de información. |
| Modelamiento y Optimización de Recursos-Procesos | Curvas, restricciones y búsqueda de una solución óptima. |
| Desarrollo de Software | Código, funciones, validación y pruebas. |
| Telemática | Nodos, enlaces y comunicaciones en red. |

Los motivos se dibujan detrás de los controles. La mención también se identifica con un rótulo y una relación conceptual al pie del fondo. Los paneles oscuros permiten mantener legibles los textos de la actividad.

## Implementación

- `game/scripts/neon_visuals.gd` centraliza paletas, motivos y primitivas de luz para texto, trayectorias, líneas y anillos.
- `game/scripts/game.gd` aplica la identidad de la partida al construir cada pantalla. Los botones, tarjetas, foco, campos, selectores y deslizadores comparten la misma paleta.
- `game/scripts/curriculum_graph.gd` ocupa todo el ancho de la página. Distribuye los nodos con separación y dirige aristas curvas fuera de las esferas, con flechas y luz del color de carrera. Los nodos tienen iluminación lateral, reflejo, sombra y una ligera variación de tamaño para dar profundidad. Las pequeñas marcas de estado siguen diferenciando aprobación, reprobación, inscripción y bloqueo.
- `game/scripts/study_demo.gd` y `study_model.gd` reciben la paleta de la partida: las demostraciones ya no conservan una superficie beige ni colores que contradigan la carrera.
- Las ecuaciones e integrales de la portada tienen halos y núcleos claros sin alterar la estructura de los símbolos.

El resplandor se construye con trazos y sombras 2D compatibles con el renderizador de compatibilidad. No depende de activar bloom ni de cambiar de motor gráfico. El modo de bajo consumo reduce capas y sombras; la reducción de animaciones sigue controlando el movimiento del grafo. Los fondos temáticos son estáticos.

Se conservan los cambios académicos recientes: nombre obligatorio, materias iniciales asignadas en el primer semestre y catálogo de logros públicos y ocultos. Esta entrega no modifica las reglas ni el formato de las partidas.

## Malla ampliada e interactiva

El panel lateral vacío se eliminó. Al seleccionar una materia, su ficha aparece debajo del grafo, junto a la lista accesible equivalente. La barra de semestre y herramientas es compacta.

Se pueden arrastrar las esferas para reorganizar las conexiones, arrastrar el fondo para desplazar la vista y utilizar la rueda o los botones −/+ para cambiar el zoom. «Restablecer» recupera el encuadre y la distribución del semestre. Las flechas y Enter mantienen la selección por teclado. El dibujo queda recortado dentro de su lienzo al hacer zoom.

La distribución manual se conserva al navegar entre pantallas y semestres durante la sesión, siempre que siga siendo válida tras un cambio de tamaño. Las posiciones se guardan como coordenadas relativas de presentación; no se escriben en la partida ni alteran requisitos o resultados académicos. Las dos texturas de esfera se generan una vez y se reutilizan, también en modo de bajo consumo.

### Conexiones protegidas

`game/scripts/graph_routing.gd` comprueba las mismas polilíneas que se dibujan. Exige al menos 24 unidades de separación entre aristas, suficiente para que sus halos tampoco se superpongan, y evita las esferas ajenas a cada conexión. Cada rama sale por un puerto distinto de la esfera. Los grupos de conexiones ocupan áreas separadas y el lienzo crece en altura cuando hace falta.

Un arrastre que provocaría un cruce, contacto, solapamiento de nodos o paso por otra esfera se rechaza antes de dibujarse. Las posiciones antiguas y las restauradas tras redimensionar pasan por la misma comprobación. El zoom y el desplazamiento transforman el conjunto completo; no alteran su separación relativa. Los nodos permanecen quietos: la animación recorre las aristas, sin mover los extremos comprobados.

Los 50 semestres actuales mantienen una esfera por materia. Para datos futuros que no permitan esa disposición, existe una vista por conexiones que repite referencias visuales identificadas de las materias, en espacios separados. Conserva todas las relaciones, sin ocultarlas ni cambiar los requisitos académicos.

## Verificación

```powershell
.\game\.tools\Godot_v4.7.2-stable_win64_console.exe --headless --path game --script res://tests/test_neon_visuals.gd
.\game\.tools\Godot_v4.7.2-stable_win64_console.exe --headless --path game --script res://tests/test_frontend_campus.gd
.\game\.tools\Godot_v4.7.2-stable_win64_console.exe --headless --path game --script res://tests/test_player_rules.gd
.\game\.tools\Godot_v4.7.2-stable_win64_console.exe --headless --path game --script res://tests/test_graph_interaction.gd
.\game\.tools\Godot_v4.7.2-stable_win64_console.exe --headless --path game --script res://tests/test_graph_clearance.gd
```

La prueba visual comprueba las dos carreras y las cinco menciones en las siete áreas, la identidad de los controles, la reducción de sombras y la ausencia de cambios de estado del motor al navegar.

La entrega inicial de identidad visual completó **2.030 comprobaciones sin fallos**. La ampliación de la malla verifica además selección y arrastre, rutas en todos los semestres de las cinco menciones, relieve de las esferas, zoom, desplazamiento, restablecimiento y conservación de la distribución sin modificar la simulación.

La verificación de la malla con conexiones protegidas completó **7.283 comprobaciones sin fallos**: 5.710 de separación, 1.235 de interacción y geometría, 194 de frontend, 123 de identidad visual y 21 de integración. Incluye tres anchos, texto al 80% y 120%, 2.400 intentos de arrastre y una comprobación geométrica independiente de las rutas. Se revisaron las capturas con el renderizador real y se volvió a exportar el ejecutable de Windows.

`game/tests/capture_neon.gd` genera 31 capturas con el renderizador real, usando perfiles ficticios y sin cargar ni guardar partidas personales. Incluye las cinco menciones en campus, grafo inicial, grafo avanzado y estudio, además de selección, formularios, graduación y logros. Añade una vista completa de las conexiones protegidas a 1152×900. Los resultados se conservan localmente en `game/.test-artifacts/neon/`. La captura necesita un entorno gráfico y no se ejecuta con `--headless`.
