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
- `game/scripts/curriculum_graph.gd` utiliza conexiones luminosas, aros y núcleos de alto contraste del color de carrera. Las pequeñas marcas de estado y las etiquetas siguen diferenciando aprobación, reprobación, inscripción y bloqueo.
- `game/scripts/study_demo.gd` y `study_model.gd` reciben la paleta de la partida: las demostraciones ya no conservan una superficie beige ni colores que contradigan la carrera.
- Las ecuaciones e integrales de la portada tienen halos y núcleos claros sin alterar la estructura de los símbolos.

El resplandor se construye con trazos y sombras 2D compatibles con el renderizador de compatibilidad. No depende de activar bloom ni de cambiar de motor gráfico. El modo de bajo consumo reduce capas y sombras; la reducción de animaciones sigue controlando el movimiento del grafo. Los fondos temáticos son estáticos.

Se conservan los cambios académicos recientes: nombre obligatorio, materias iniciales asignadas en el primer semestre y catálogo de logros públicos y ocultos. Esta entrega no modifica las reglas ni el formato de las partidas.

## Verificación

```powershell
.\game\.tools\Godot_v4.7.2-stable_win64_console.exe --headless --path game --script res://tests/test_neon_visuals.gd
.\game\.tools\Godot_v4.7.2-stable_win64_console.exe --headless --path game --script res://tests/test_frontend_campus.gd
.\game\.tools\Godot_v4.7.2-stable_win64_console.exe --headless --path game --script res://tests/test_player_rules.gd
```

La prueba visual comprueba las dos carreras y las cinco menciones en las siete áreas, la identidad de los controles, la reducción de sombras y la ausencia de cambios de estado del motor al navegar.

La regresión de esta entrega completó **2.030 comprobaciones sin fallos**: 1.632 del motor, 18 de guardado, 21 de integración, 178 de frontend, 58 de reglas del jugador y 123 de identidad visual.

`game/tests/capture_neon.gd` genera 25 capturas con el renderizador real, usando perfiles ficticios y sin cargar ni guardar partidas personales. Incluye las cinco menciones en campus, grafo y estudio, además de selección, formularios, graduación y logros. Los resultados se conservan localmente en `game/.test-artifacts/neon/`. La captura necesita un entorno gráfico y no se ejecuta con `--headless`.
