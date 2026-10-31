# Identidad visual del juego

Actualizado el 31 de octubre de 2026.

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

Los motivos se dibujan como una capa ambiental desenfocada detrás de tarjetas opacas. No contienen marcos de aplicación, ventanas falsas ni rótulos al pie. Software muestra escritura de HTML y código; Telemática, comandos de configuración y puertos de red. Las otras menciones utilizan datos, procesos y optimización. Los textos ambientales son ilustraciones decorativas, no información institucional ni configuraciones operativas.

## Implementación

### Estilo pixel art vigente

El cambio solicitado el 30/10 aplica pixel art a los controles del juego,
conservando los recorridos interiores. La revisión del inicio del 31/10 se
describe abajo. No cambia
las reglas académicas ni los archivos de guardado.

- `pixel_style_box.gd` dibuja marcos escalonados, sombras desplazadas y relieve
  de botones. Hover, pulsación y foco tienen estados distintos; los controles
  no rotan ni se escalan al pasar el ratón.
- `assets/fonts/campus_pixel.fnt` y su atlas contienen 119 glifos originales,
  con tildes, ñ y símbolos de navegación. `tools/generate_pixel_font.py` conserva
  sus máscaras y permite regenerarlos con Python sin dependencias externas.
  Títulos y acciones utilizan esa fuente. Los párrafos y campos conservan una
  fuente de lectura; los símbolos adicionales tienen una fuente de respaldo.
- Los sprites originales de las cinco menciones se generan en 32×24 píxeles
  mediante `pixel_mention_sprite.gd`. Se muestran a escala entera y se reutilizan.
- Las esferas mantienen volumen, luz y sombra mediante bloques de color y
  muestreo vecino más próximo. No se cambia su geometría de interacción ni la
  validación de conexiones. El cosmos del inicio utiliza discos de baja resolución.
- El ambiente por mención conserva animación tenue y desenfoque, con muestreo
  escalonado. Opciones tiene fondo quieto. Bajo consumo y movimiento reducido
  mantienen sus controles existentes.

La escala tipográfica admite los ajustes 80%, 100% y 120%. El filtrado cercano
mantiene píxeles definidos, aunque un tamaño no entero o el escalado del sistema
puede producir píxeles de diferente ancho. Se prioriza conservar el acceso al
texto y las acciones en todas las páginas.

Las fuentes, sprites y marcos añadidos son recursos propios bajo
`GPL-3.0-or-later`; no se incorporan paquetes gráficos de terceros.

### Componentes compartidos

- `game/scripts/neon_visuals.gd` centraliza paletas, motivos y primitivas de luz para texto, trayectorias, líneas y anillos.
- `game/scripts/mention_ambient.gd` dibuja los motivos en una superficie de 600×340 y aplica un filtro de desenfoque. Actualiza la animación a un máximo de diez veces por segundo. No captura el ratón y se oculta al volver al inicio.
- `game/scripts/game.gd` aplica la identidad de la partida al construir cada pantalla. Los botones, tarjetas, foco, campos y selectores comparten la misma paleta.
- `game/scripts/curriculum_graph.gd` ocupa todo el ancho de la página. Distribuye los nodos con separación y dirige aristas curvas fuera de las esferas, con flechas y luz del color de carrera. Los nodos tienen iluminación lateral, reflejo, sombra y una ligera variación de tamaño para dar profundidad. Las pequeñas marcas de estado siguen diferenciando aprobación, reprobación, inscripción y bloqueo.
- `game/scripts/study_demo.gd` y `study_model.gd` reciben la paleta de la partida: las demostraciones ya no conservan una superficie beige ni colores que contradigan la carrera.
- Las ecuaciones e integrales de la portada tienen halos y núcleos claros sin alterar la estructura de los símbolos.

El resplandor se construye con trazos y sombras 2D compatibles con el renderizador de compatibilidad. No depende de activar bloom ni de cambiar de motor gráfico. Bajo consumo reduce capas y sombras y detiene la animación ambiental. Reducir movimiento también deja el ambiente estático. Los nodos del grafo no se mueven automáticamente.

Se conservan los cambios académicos recientes: nombre obligatorio, materias iniciales asignadas en el primer semestre y catálogo de logros públicos y ocultos. Esta entrega no modifica las reglas ni el formato de las partidas.

## Malla ampliada e interactiva

El panel lateral vacío se eliminó. Las materias se presentan en tarjetas con nombre, estado y la acción «Ver materia». La ficha seleccionada aparece sola en una página con ancho de lectura contenido y «Volver al grafo»; la lista no se mezcla con esa ficha. La barra de semestre y herramientas es compacta.

Se pueden arrastrar las esferas para reorganizar las conexiones y arrastrar el fondo para desplazar la vista. Los botones −/+, «Ver todo» y las cuatro flechas de la vista permiten explorar sin rueda. «Restablecer» recupera la distribución del semestre. Las flechas del teclado y Enter mantienen la selección. El dibujo queda recortado dentro de su lienzo al hacer zoom. La ficha seleccionada se abre en una página accesible mediante botones.

La distribución manual se conserva al navegar entre pantallas y semestres durante la sesión, siempre que siga siendo válida tras un cambio de tamaño. Las posiciones se guardan como coordenadas relativas de presentación; no se escriben en la partida ni alteran requisitos o resultados académicos. Las dos texturas de esfera se generan una vez y se reutilizan, también en modo de bajo consumo.

### Conexiones protegidas

`game/scripts/graph_routing.gd` comprueba las mismas polilíneas que se dibujan. Exige al menos 24 unidades de separación entre aristas, suficiente para que sus halos tampoco se superpongan, y evita las esferas ajenas a cada conexión. Cada rama sale por un puerto distinto de la esfera. Los grupos de conexiones ocupan áreas separadas y el lienzo crece en altura cuando hace falta.

Un arrastre avanza dentro de su recorrido hasta una posición segura antes de provocar un cruce, contacto, solapamiento de nodos o paso por otra esfera. Las posiciones antiguas y las restauradas tras redimensionar pasan por la misma comprobación. El zoom y el desplazamiento transforman el conjunto completo; no alteran su separación relativa. Los nodos permanecen quietos: la animación recorre las aristas, sin mover los extremos comprobados.

Una materia reprobada que siga pendiente se incorpora también al consultar semestres posteriores. Se identifica en ámbar, con su semestre de origen y el rótulo «RECURSAR». La reinscripción no borra ese contexto; una aprobación consolidada lo elimina de las pendientes. El encuadre inicial conserva un tamaño legible y prioriza ese contexto. «Ver todo» ofrece una vista general voluntaria.

Al cambiar de periodo, la consulta inicial se actualiza al nivel de las materias inscritas. «Mi periodo» permite recuperar esa vista después de explorar otros semestres del plan. La cabecera distingue el periodo de la partida del semestre curricular consultado.

## Pantallas compactas y navegación sin rueda

La regla permanente está en `REGLAS_USUARIO.txt`; `AGENTS.md` obliga a leerla antes de trabajar. No se utilizan deslizadores, barras de desplazamiento ni listas desplegables que requieran rueda.

- Las páginas comunes se centran y limitan a 880 unidades de ancho. La malla dispone de hasta 1100, con espacio propio para explorar.
- Desde el 31/10 el inicio reúne todas las acciones en un solo contenedor de altura contenida, sin páginas. `broken_pixel_panel.gd` dibuja una abertura negra con bordes fragmentados y píxeles sueltos; no usa el marco ordinario de las tarjetas. Logo y cosmos se conservan, sin un segundo panel de citas. Las acciones tienen el mismo ancho y tipografía compacta; se comprueban con partida reciente y letras al 120%. El campus agrupa las acciones de malla y auxiliatura y ofrece un único acceso de guardar/salir.
- Los botones comunes ajustan su ancho al texto, hasta 300 unidades; las opciones de selección y los menús pequeños tienen sus propios límites.
- `paged_view.gd` organiza tarjetas y filas completas en páginas y mantiene visibles los botones anterior/siguiente y Atrás. La navegación de página se oculta cuando no hace falta. Los formularios permanecen en el árbol para conservar lo escrito al cambiar de página.
- `choice_picker.gd` reemplaza las listas desplegables largas por búsqueda y grupos de cuatro opciones con botones de página.
- La cabecera de partida identifica espacio de guardado, jugador, carrera y periodo. El pie recuerda que se trata de una simulación educativa.
- Opciones explica cada ajuste, muestra su estado y permite cambiar el texto a 80%, 100% o 120% con botones y una muestra. Su fondo es estático para facilitar la lectura.
- Las demostraciones usan «Disminuir» y «Aumentar». La consola opcional F10 también utiliza páginas; no contiene un registro desplazable.

`docs/PARA_BACKEND_DATOS_Y_FUENTES.txt` registra la revisión solicitada a backend y los originales que el usuario deberá aportar. Las reglas del motor y las partidas no cambian con esta presentación. La información institucional pendiente no se convierte en oficial por aparecer en el juego.

Los 50 semestres actuales mantienen una esfera por materia. Para datos futuros que no permitan esa disposición, existe una vista por conexiones que repite referencias visuales identificadas de las materias, en espacios separados. Conserva todas las relaciones, sin ocultarlas ni cambiar los requisitos académicos.

## Verificación

### Entrega pixel art del 30/10/2026

Se ejecutaron nueve suites, con **10.898 comprobaciones y cero fallos**:
634 de pixel art, 2.323 de navegación compacta, 194 del frontend, 123 de
identidad visual, 58 de ambiente/composición, 1.239 de interacción del grafo,
5.710 de separación de conexiones, 596 de navegación de historia y 21 de
integración. Los registros locales son `game/.test-artifacts/pixel-test_*.log`.
La prueba de composición se actualizó para incluir el acceso a Historia,
incorporado antes de esta entrega; con partida reciente son siete acciones.

`game/tests/test_pixel_ui.gd` verifica tildes y símbolos, escalado de texto,
cinco sprites distintos, marcos compartidos en las siete áreas, opacidad,
relieve de pulsación, volumen pixelado y conservación del estado académico.
`game/tests/capture_pixel.gd` genera 19 capturas con perfiles ficticios, sin
leer ni guardar partidas personales. Se inspeccionaron inicio, menciones,
campus de ambas carreras, grafo, formulario, opciones y estudio, incluyendo
900×640 con letras al 120%. Las capturas están en
`game/.test-artifacts/pixel/`; el renderizador utilizó ANGLE por el controlador
de vídeo del equipo.

Se exportó Windows con la fuente y los recursos pixel y se comprobó su arranque
aislado en modo headless, con salida 0 y sin errores de scripts. La evaluación con
jugadores y el comportamiento en otras GPU, sistemas operativos y escalados
de pantalla permanecen sin verificar; corresponden a frontend y empaquetado.

### Comprobaciones e historial anteriores

```powershell
.\game\.tools\Godot_v4.7.2-stable_win64_console.exe --headless --path game --script res://tests/test_neon_visuals.gd
.\game\.tools\Godot_v4.7.2-stable_win64_console.exe --headless --path game --script res://tests/test_frontend_campus.gd
.\game\.tools\Godot_v4.7.2-stable_win64_console.exe --headless --path game --script res://tests/test_player_rules.gd
.\game\.tools\Godot_v4.7.2-stable_win64_console.exe --headless --path game --script res://tests/test_graph_interaction.gd
.\game\.tools\Godot_v4.7.2-stable_win64_console.exe --headless --path game --script res://tests/test_graph_clearance.gd
.\game\.tools\Godot_v4.7.2-stable_win64_console.exe --headless --path game --script res://tests/test_compact_navigation.gd
.\game\.tools\Godot_v4.7.2-stable_win64_console.exe --headless --path game --script res://tests/test_ambient_layout.gd
```

La prueba visual comprueba las dos carreras y las cinco menciones en las siete áreas, la identidad de los controles, la reducción de sombras y la ausencia de cambios de estado del motor al navegar.

La entrega inicial de identidad visual completó **2.030 comprobaciones sin fallos**. La ampliación de la malla verifica además selección y arrastre, rutas en todos los semestres de las cinco menciones, relieve de las esferas, zoom, desplazamiento, restablecimiento y conservación de la distribución sin modificar la simulación.

La entrega anterior de conexiones protegidas completó **7.283 comprobaciones sin fallos**. La navegación compacta añade comprobaciones de acceso completo a texto y acciones mediante botones, ausencia de controles desplazables, selección con búsqueda, letras al 120%, demostraciones, consola y conservación de una reprobada del primer semestre en la malla posterior.

La regresión del 29/10/2026 completó **11.238 comprobaciones sin fallos**: 2.247 de navegación compacta, 5.710 de separación de aristas, 1.235 de interacción del grafo, 194 del frontend, 123 de identidad visual, 58 de reglas del jugador, 21 de integración, 18 de guardado y 1.632 del motor académico. La navegación se comprueba en 900×640, 1152×720 y 1600×900 con letras al 100% y 120%. Se exportó el ejecutable y se verificó su arranque aislado con salida 0.

La corrección posterior de proporciones, fichas y ambientes completó **2.698 comprobaciones sin fallos**: 2.303 de navegación compacta, 194 del frontend, 123 de identidad visual, 57 de ambiente/composición y 21 de integración. Se revisaron el menú original, Software, Telemática y la ficha aislada con el renderizador real. Las cinco menciones respetan reducción de movimiento y bajo consumo. Se volvió a exportar Windows y su arranque aislado terminó con salida 0.

`game/tests/capture_neon.gd` genera 38 vistas con el renderizador real y dos superficies ambientales sin filtro para inspección, usando perfiles ficticios y sin cargar ni guardar partidas personales. Incluye las cinco menciones en campus, grafo inicial, grafo avanzado y estudio, además de selección, formularios, graduación y logros. Añade opciones, tamaño de letra, una reprobada arrastrada, una vista amplia a 1152×900 y las fichas/ambientes corregidos de Software y Telemática. Los resultados se conservan localmente en `game/.test-artifacts/neon/`. La captura necesita un entorno gráfico y no se ejecuta con `--headless`.
