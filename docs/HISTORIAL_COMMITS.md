# Historial técnico por commit

Revisión: 2 de noviembre de 2026. Corte: `b122e96`.

Revisé los 32 commits disponibles en `main`: mensaje completo, archivos y diferencias. Los títulos originales se conservan tal como fueron escritos; el encabezado técnico explica el cambio. Las notas personales entre comillas son extractos del mensaje original, no recuerdos añadidos.

Para leer el avance por jornada, véase [Bitácora](BITACORA_DESARROLLO.md). Para el producto vigente, [Estado actual](ESTADO_ACTUAL.md). Las pruebas mencionadas son archivos añadidos o modificados; los resultados de ejecución se separan en [Verificaciones](VERIFICACIONES.md).

## 15 de octubre de 2026

### 242e755: Inicio del repositorio

**Mensaje original:** `Initial commit`. **Hora:** 19:58:27 (UTC−04:00).

Inicié el control de versiones con la configuración de atributos de Git. Todavía no había aplicaciones ni lógica académica.

**Archivos de referencia:** `.gitattributes`.

### 8302683: Base de Django y Next.js

**Mensaje original:** `Estructura inicial del Proyecto`. **Hora:** 22:07:21 (UTC−04:00).

Preparé el backend, el frontend y los ajustes de desarrollo local. Añadí el usuario con roles, las dependencias, la plantilla de entorno y los primeros documentos de requisitos. Los módulos reservados con .gitkeep seguían siendo planificación, no funciones implementadas.

**Archivos de referencia:** `backend/config/settings/base.py`, `backend/apps/usuarios/models.py`, `docs/ESPECIFICACION_FUNCIONAL.md`.

## 18 de octubre de 2026

### 8162267: Primera composición de la web

**Mensaje original:** `diseñito simplesito`. **Hora:** 19:32:32 (UTC−04:00).

Reorganicé la portada y sus estilos: navegación, bloques de contenido y presentación de los módulos. El cambio se concentra en la interfaz; todavía no conecta un catálogo académico nuevo.

**Archivos de referencia:** `frontend/src/app/page.tsx`, `frontend/src/app/globals.css`.

### 6f5ced9: Catálogo académico conectado

**Mensaje original:** `catalogo y consulta`. **Hora:** 20:03:38 (UTC−04:00).

Incorporé carreras, planes, materias, periodos y requisitos como modelos, con migraciones, administración y consultas públicas. Añadí el componente que consulta el catálogo y presenta materias por semestre. La validación de requisitos contempla duplicados, autorreferencias y ciclos.

**Archivos de referencia:** `backend/apps/academico/models.py`, `backend/apps/academico/views.py`, `frontend/src/components/catalogo-academico.tsx`.

### f97e336: Oferta por paralelos

**Mensaje original:** `consultas`. **Hora:** 21:11:59 (UTC−04:00).

Añadí aulas, habilitación de docentes, paralelos y sesiones semanales. La API consulta la oferta abierta y la interfaz muestra horarios y ocupación. Las validaciones de aulas e intervalos pertenecen a la oferta y no equivalen a un generador automático de horarios.

**Archivos de referencia:** `backend/apps/oferta/models.py`, `backend/apps/oferta/views.py`, `frontend/src/components/oferta-academica.tsx`.

## 19 de octubre de 2026

### bace499: Inscripción con control de cupos

**Mensaje original:** `cosa de inscribirse`. **Hora:** 09:23:39 (UTC−04:00).

Implementé inscripción y retiro para estudiantes autenticados. El servicio usa transacciones y bloquea los paralelos candidatos para comprobar cupos; si el solicitado se llena, recorre los siguientes de la misma materia y periodo.

**Archivos de referencia:** `backend/apps/inscripciones/services.py`, `backend/apps/inscripciones/views.py`.

### c9ecbed: Panel del estudiante

**Mensaje original:** `ya no se we`. **Hora:** 09:39:02 (UTC−04:00).

Añadí el acceso del estudiante y sus acciones de inscripción desde la web. Ajusté el modelo de usuario y los estilos asociados. En esta versión también sustituí la licencia MIT inicial por un aviso de uso libre propio; esa declaración histórica fue retirada más adelante y no es la licencia actual.

**Archivos de referencia:** `frontend/src/components/inscripciones-panel.tsx`, `backend/apps/usuarios/models.py`, `LICENSE`.

### cca8f0e: Actas, notas y correcciones

**Mensaje original:** `gestion`. **Hora:** 21:34:52 (UTC−04:00).

Incorporé las actas por paralelo, carga de notas, cierre y corrección auditada. El cierre actualiza el resultado de las inscripciones; una corrección posterior conserva valores anterior y nuevo, motivo y trámite. Añadí el panel docente para utilizar ese flujo.

**Archivos de referencia:** `backend/apps/notas/services.py`, `backend/apps/notas/models.py`, `frontend/src/components/actas-docente.tsx`.

## 20 de octubre de 2026

### 122d1d3: Elegibilidad y carga académica

**Mensaje original:** `horarios`. **Hora:** 09:35:46 (UTC−04:00).

Amplié el servicio de inscripción con requisitos, corequisitos y límite de seis o siete materias según el promedio calculado. Añadí la consulta de elegibilidad y más información del horario en el panel. El título original dice «horarios», pero el cambio principal está en esas validaciones.

**Archivos de referencia:** `backend/apps/inscripciones/services.py`, `backend/apps/inscripciones/views.py`, `frontend/src/components/inscripciones-panel.tsx`.

## 21 de octubre de 2026

### 3dc9d7d: Paso hacia el juego

**Mensaje original:** `cambiso grandes`. **Hora:** 13:39:21 (UTC−04:00).

Incorporé un juego web y el proyecto de escritorio Godot. La gestión académica quedó en /sistema y la portada pasó a la demostración. El juego empezó con catálogo, escena, controlador y preset de exportación; conservé la aplicación web como componente separado.

**Archivos de referencia:** `frontend/src/components/juego-academico.tsx`, `game/scripts/game.gd`, `game/project.godot`.

## 22 de octubre de 2026

### 5ee374a: Enfoques de carrera provisionales

**Mensaje original:** `avance pequeño`. **Hora:** 12:42:15 (UTC−04:00).

Añadí opciones de enfoque para las carreras de muestra y un paso de selección antes de crear la partida. La elección se conserva en el perfil. Esas opciones provisionales se sustituyeron después por el contenido de Sistemas e Informática.

**Archivos de referencia:** `game/scripts/catalog.gd`, `game/scripts/game.gd`.

> Nota original: «me quede sin luz, bueno poquito es algo».

## 23 de octubre de 2026

### fde9e82: Flujos de partida y presentación

**Mensaje original:** `arreglitos`. **Hora:** 18:59:25 (UTC−04:00).

Amplié el controlador y documenté la ejecución y exportación del juego, entonces llamado UNI SIMULATOR. El README de esa etapa distingue una partida individual y una modalidad local por turnos. También ajusté lectura, opciones y representación gráfica.

**Archivos de referencia:** `game/scripts/game.gd`, `game/README.md`, `game/project.godot`.

### a8af2b5: Ventana y catálogo

**Mensaje original:** `pantallita`. **Hora:** 20:49:42 (UTC−04:00).

Ajusté ventana, tamaño mínimo y redimensionamiento, y amplié la selección del catálogo. La entrega todavía incluye un respaldo catalog.gd.bak que se eliminó en el siguiente commit.

**Archivos de referencia:** `game/project.godot`, `game/scripts/catalog.gd`, `game/scripts/game.gd`.

### 45653c6: Mallas y requisitos en el juego

**Mensaje original:** `Correcciones a grandes rasgos`. **Hora:** 22:30:28 (UTC−04:00).

Concentré el contenido en Sistemas e Informática, añadí sus mallas y el grafo curricular y adapté el recorrido por materias. Retiré el respaldo del catálogo y el archivo de licencia de aquella etapa. La licencia vigente se incorporó el 30 de octubre.

**Archivos de referencia:** `game/scripts/uto_curricula.gd`, `game/scripts/curriculum_graph.gd`, `game/scripts/catalog.gd`.

## 24 de octubre de 2026

### 154aa6a: Portada científica y estudio

**Mensaje original:** `portada y animaciones`. **Hora:** 00:18:55 (UTC−04:00).

Desarrollé la portada animada y consolidé el nombre CAMPUS EN JUEGO. Añadí arte por mención, demostraciones de estudio y ajustes de la malla. El commit se registró a las 00:18 del día 24; eso no determina cuándo comenzó la sesión.

**Archivos de referencia:** `game/scripts/game.gd`, `game/scripts/mention_art.gd`, `game/scripts/study_demo.gd`.

### f861963: Transiciones y perfil global

**Mensaje original:** `correciones y mejoras simples`. **Hora:** 10:53:35 (UTC−04:00).

Amplié las transiciones y la presentación del menú, incorporé el perfil de logros globales y la opción de bajo consumo. El cambio está concentrado en game.gd y conserva progreso entre partidas.

**Archivos de referencia:** `game/scripts/game.gd`.

## 25 de octubre de 2026

### f2e23de: Motor individual y expedientes

**Mensaje original:** `implementando lo academico pe`. **Hora:** 19:38:36 (UTC−04:00).

Extraje la simulación del controlador: inscripción, cursado, historial, trámites, auxiliatura y titulación. Separé comandos, definiciones de procedimientos y guardado con temporal y respaldo. El recorrido pasó a centrarse en un estudiante y añadí pruebas del motor, persistencia e integración.

**Archivos de referencia:** `game/scripts/student_simulation.gd`, `game/scripts/simulation_save_store.gd`, `docs/SIMULACION_ESTUDIANTE.md`.

**Pruebas tocadas en esta versión:** `test_game_integration.gd`, `test_simulation_storage.gd`, `test_student_simulation.gd`.

### 0d5b259: Campus con navegación común

**Mensaje original:** `actualizando la interfaz`. **Hora:** 20:04:43 (UTC−04:00).

Conecté el motor con las pantallas de materias, malla, trámites, historial, auxiliatura y graduación. Separé las vistas en student_campus.gd y los modelos didácticos de estudio. Añadí formularios, pruebas del frontend y capturas aisladas; la interfaz obtiene el estado del motor mediante snapshot().

**Archivos de referencia:** `game/scripts/student_campus.gd`, `game/scripts/study_model.gd`, `game/tests/test_frontend_campus.gd`.

**Pruebas tocadas en esta versión:** `test_frontend_campus.gd`.

## 26 de octubre de 2026

### fd84010: Nombre obligatorio y logros

**Mensaje original:** `problema del nombre y logros`. **Hora:** 14:36:18 (UTC−04:00).

Corregí el flujo que permitía iniciar sin nombre y conservé ese dato al retroceder entre selecciones. Ajusté las materias iniciales y ordené los logros públicos y ocultos con identificadores estables. Añadí pruebas de creación y reglas del jugador.

**Archivos de referencia:** `game/scripts/achievement_catalog.gd`, `game/scripts/student_simulation.gd`, `game/tests/test_player_rules.gd`.

**Pruebas tocadas en esta versión:** `test_player_rules.gd`, `test_student_simulation.gd`.

## 28 de octubre de 2026

### fa203e7: Identidad visual por carrera

**Mensaje original:** `Interfaz interna`. **Hora:** 15:02:25 (UTC−04:00).

Centralicé paletas y efectos en neon_visuals.gd: Sistemas azul e Informática roja, con motivos de las cinco menciones. Apliqué esa identidad a controles, estudio y vistas de la partida; añadí pruebas y capturas de las combinaciones.

**Archivos de referencia:** `game/scripts/neon_visuals.gd`, `game/scripts/game.gd`, `docs/DISENO_VISUAL_CAMPUS.md`.

**Pruebas tocadas en esta versión:** `test_neon_visuals.gd`.

### 23b5dd0: Malla interactiva con rutas protegidas

**Mensaje original:** `Correcciones de la itnerfaz itnerna por carreras`. **Hora:** 15:46:02 (UTC−04:00).

Amplié el grafo y añadí arrastre, zoom, desplazamiento y conservación de la distribución durante la sesión. Separé la validación geométrica en graph_routing.gd para evitar cruces, contactos y paso por nodos ajenos. Añadí pruebas de interacción y separación con un contraste geométrico independiente.

**Archivos de referencia:** `game/scripts/curriculum_graph.gd`, `game/scripts/graph_routing.gd`, `game/tests/test_graph_clearance.gd`.

**Pruebas tocadas en esta versión:** `test_frontend_campus.gd`, `test_graph_clearance.gd`, `test_graph_interaction.gd`.

## 29 de octubre de 2026

### 32d6a59: Navegación sin rueda y ambientes

**Mensaje original:** `notas de cosas y mejora de interfaz`. **Hora:** 17:31:48 (UTC−04:00).

Sustituí desplazadores y deslizadores por páginas, botones y selectores. Añadí paged_view.gd, choice_picker.gd y los ambientes desenfocados por mención; registré las reglas permanentes y las fuentes institucionales que faltan. La revisión abarcó opciones, campus, grafos y estudio.

**Archivos de referencia:** `game/scripts/paged_view.gd`, `game/scripts/choice_picker.gd`, `game/scripts/mention_ambient.gd`.

**Pruebas tocadas en esta versión:** `test_ambient_layout.gd`, `test_compact_navigation.gd`, `test_frontend_campus.gd`, `test_game_integration.gd`, `test_graph_clearance.gd`, `test_graph_interaction.gd`.

### e486e77: Historia de carrera y movimiento de ramas

**Mensaje original:** `grafos movimiento y modulo de simulacion aleatoria`. **Hora:** 18:02:34 (UTC−04:00).

Añadí una demostración que recorre una carrera con semilla reproducible y perfiles aislados. Utiliza las reglas del motor sin escribir partidas ni logros del jugador. Amplié el grafo con movimiento y giro de ramas dentro de las condiciones de separación.

**Archivos de referencia:** `game/scripts/career_story.gd`, `game/scripts/career_story_ui.gd`, `game/scripts/curriculum_graph.gd`.

**Pruebas tocadas en esta versión:** `test_career_story.gd`, `test_graph_interaction.gd`, `test_story_navigation.gd`.

## 30 de octubre de 2026

### 78cc2f2: Documentación de componentes

**Mensaje original:** `docs: documentracion y reglas de proyecto`. **Hora:** 19:18:22 (UTC−04:00).

Reorganicé el README alrededor del juego de escritorio y añadí el índice, la arquitectura y las instrucciones de desarrollo local. Precisé el cierre obligatorio de reglas en AGENTS.md y la separación entre documentación vigente e histórica.

**Archivos de referencia:** `README.md`, `docs/ARQUITECTURA.md`, `docs/DESARROLLO_LOCAL.md`.

### b1aef99: Bitácora, reglas y GPL

**Mensaje original:** `docs: reglas, bitacorta y licencia libre`. **Hora:** 19:30:00 (UTC−04:00).

Incorporé la guía documental, la bitácora y la licencia GPLv3 o posterior para el código y la documentación propios. Registré las reglas de cierre con summary y las revisiones pendientes de procedencia y licencias de terceros. Los cambios ya están en este commit; la antigua nota «sin commit» dejó de ser vigente.

**Archivos de referencia:** `LICENSE`, `docs/GUIA_DOCUMENTACION.md`, `docs/LICENCIA_CODIGO_LIBRE.md`.

### b28cf38: Interfaz pixel art

**Mensaje original:** `feat: aplicar estilo pixelart`. **Hora:** 20:16:43 (UTC−04:00).

Cambié fuente, paneles, botones, esferas y arte de menciones al estilo pixel art. Añadí la fuente bitmap, su generador y pruebas visuales; conservé navegación y colores por carrera. Registré el formato obligatorio de los summaries y el alcance de frontend.

**Archivos de referencia:** `game/scripts/pixel_style_box.gd`, `game/assets/fonts/campus_pixel.fnt`, `game/tests/test_pixel_ui.gd`.

**Pruebas tocadas en esta versión:** `test_ambient_layout.gd`, `test_pixel_ui.gd`.

> Nota original: «hay ago que me encanta de los juegos, que es el pixelart».

### 389dc82: SIS-INF y exploración del campus

**Mensaje original:** `feat: exploracion y nombre cambiado`. **Hora:** 20:46:42 (UTC−04:00).

Cambié el nombre visible a SIS-INF y añadí el mapa basado en el plano aportado, un personaje con colisiones, acceso a aulas, mapa y progreso. Separé campus_exploration del expediente y conservé la ruta anterior de datos para recuperar partidas. El emblema y el plano mantienen su procedencia y derechos propios.

**Archivos de referencia:** `game/project.godot`, `game/scripts/campus_world.gd`, `game/scripts/campus_exploration_ui.gd`.

**Pruebas tocadas en esta versión:** `test_ambient_layout.gd`, `test_exploration.gd`, `test_exploration_navigation.gd`, `test_frontend_campus.gd`.

## 31 de octubre de 2026

### a663c1a: Edificios con pasillos y menú único

**Mensaje original:** `feat(ui): ampliacion de edificios y menu principal`. **Hora:** 10:41:28 (UTC−04:00).

Amplié los bloques con varios ambientes mediante pasillos y puertas. Incorporé nombres de laboratorios como referencias por comprobar, interiores diferenciados y pruebas de recorridos. Compacté el inicio en un solo menú con contorno roto, manteniendo visibles sus acciones.

**Archivos de referencia:** `game/scripts/campus_map.gd`, `game/scripts/campus_world.gd`, `game/tests/test_building_interiors.gd`.

**Pruebas tocadas en esta versión:** `test_building_interiors.gd`, `test_compact_navigation.gd`.

### f49ec69: Emblema geométrico y ruptura

**Mensaje original:** `feat(ui): logo carrera y ampliacion`. **Hora:** 11:08:12 (UTC−04:00).

Recreé el emblema mediante geometría pixelada y separé forma y animación de las superficies rotas. Retiré el SVG y código de la marca anterior que ya no se utilizaban; mantuve la ruta histórica de partidas. Añadí pruebas y capturas del nuevo lenguaje visual.

**Archivos de referencia:** `game/scripts/procedural_career_logo.gd`, `game/scripts/fracture_geometry.gd`, `game/scripts/fracture_animator.gd`.

**Pruebas tocadas en esta versión:** `test_cave_visuals.gd`, `test_exploration_navigation.gd`.

### 6515d1c: Campus variado y presentación de la sala E

**Mensaje original:** `feat(ui): menu mejorado, campus mejorado y sala de juegos`. **Hora:** 12:04:59 (UTC−04:00).

Varié edificios, árboles, recorridos y canchas con una geometría compartida por dibujo y colisión. La ruptura pasó a negro puro y extendí la fuente pixel a texto pequeño. Añadí la sala E con cuatro mesas y sus vistas previas; las partidas aún estaban deshabilitadas en esta versión.

**Archivos de referencia:** `game/scripts/campus_architecture.gd`, `game/scripts/minigame_preview.gd`, `docs/JUEGOS_BLOQUE_E.md`.

**Pruebas tocadas en esta versión:** `test_games_room.gd`.

### 865d7e1: Terminal interior y desintegración

**Mensaje original:** `feat(ui): terminal terminada en el menu`. **Hora:** 12:33:54 (UTC−04:00).

Integré la salida simulada de tree dentro del mismo menú, con botones translúcidos y una abertura que pierde bloques sin perder sus acciones. Acoté filas y fragmentos para evitar un historial ilimitado, añadí movimiento del emblema y retiré terminal_cave.gd al sustituirlo por menu_cave.gd.

**Archivos de referencia:** `game/scripts/menu_cave.gd`, `game/scripts/procedural_career_logo.gd`, `game/tests/test_dynamic_menu.gd`.

**Pruebas tocadas en esta versión:** `test_dynamic_menu.gd`.

## 2 de noviembre de 2026

### b122e96: Minijuegos jugables y optimización del mapa

**Mensaje original:** `feat: habilita minijuegos contra IA y optimiza el campus`. **Hora:** 17:35:26 (UTC−04:00).

Habilité ajedrez, billar, ping-pong y Ruta del campus contra rivales locales. Separé sus motores de las vistas y del expediente académico, con revisión de acciones, pausa y serialización de sesiones. Añadí búsqueda acotada de ajedrez, física de paso fijo y un índice de edificios que devuelve copias aisladas; incorporé pruebas de modelos e interfaz.

**Archivos de referencia:** `game/scripts/recreation_game.gd`, `game/scripts/minigame_session_ui.gd`, `game/scripts/campus_map.gd`.

**Pruebas tocadas en esta versión:** `test_games_room.gd`, `test_recreation_models.gd`, `test_recreation_ui.gd`.

## Esta revisión documental

La actualización del 2 de noviembre que añade este catálogo y reconcilia los documentos todavía no tiene commit. No modifica los mensajes ni reescribe el historial. El cambio más reciente del producto sigue siendo `b122e96`.
