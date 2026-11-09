# Bitácora de desarrollo de SIS-INF

Revisión del 9 de noviembre de 2026. Corte `4095c2e`.

La bitácora sigue las fechas de los commits en UTC−04:00. El [historial de pushes](HISTORIAL_PUSHES.md) registra los envíos y el [historial técnico](HISTORIAL_COMMITS.md) conserva sus mensajes y archivos. Las horas de Git son marcas del registro. Las notas personales entre comillas proceden de los mensajes originales.

## 15 de octubre de 2026: Arranque del sistema académico

**Commits:** `242e755`, `8302683`.

Empecé por ordenar el proyecto: backend, frontend y documentos de reglas. Django me resultaba más fácil de seguir por Python; la parte difícil era pasar lo que conocía de la facultad a condiciones concretas: quién puede hacer algo, qué datos necesita y cuándo corresponde hacerlo. Dejé la base preparada para el catálogo, todavía sin presentar los directorios vacíos como módulos terminados.

## 18 de octubre de 2026: La web empieza a consultar datos

**Commits:** `8162267`, `6f5ced9`, `f97e336`.

Primero trabajé en la portada. Después conecté carreras, planes y materias con la API, y añadí aulas, docentes, paralelos y sesiones. Ya podía recorrer la oferta desde la interfaz en lugar de mantenerla como datos de muestra. La malla necesitaba relaciones válidas: incorporé comprobaciones de duplicados, autorreferencias y ciclos.

## 19 de octubre de 2026: Inscripción, acceso y notas

**Commits:** `bace499`, `c9ecbed`, `cca8f0e`.

Añadí la inscripción con control de cupos y el panel del estudiante. Si el paralelo elegido se llena, el servicio intenta los siguientes de la misma materia y periodo. Luego conecté el panel docente con actas y notas: el cierre exige registros completos y una corrección posterior deja auditoría. La inscripción y la calificación empezaban a formar un recorrido más completo.

## 20 de octubre de 2026: No bastaba con tener cupo

**Commits:** `122d1d3`.

Amplié la inscripción para comprobar requisitos y carga académica. Añadí la evaluación de seis o siete materias y una respuesta de elegibilidad con motivos de rechazo. También mejoré el horario del panel. El commit quedó como «horarios», aunque la mayor parte del trabajo fue validar qué podía inscribir el estudiante; el generador automático de horarios seguía pendiente.

## 21 de octubre de 2026: Cambio de rumbo: el juego

**Commits:** `3dc9d7d`.

La idea se fue apartando de una réplica del sistema. Había visto varios proyectos parecidos y quería algo que pudiera mostrar en ferias y EXPOTECO. Incorporé el juego web y la primera versión de escritorio con Godot, y conservé la gestión en /sistema. El código registra el cambio aquí; la decisión venía de revisar para qué quería utilizar el proyecto.

## 22 de octubre de 2026: Un avance pequeño en la selección

**Commits:** `5ee374a`.

Añadí enfoques de muestra para las carreras y conservé la elección en la partida. Era una selección provisional, antes de concentrar las mallas en Sistemas e Informática. En el mensaje dejé una explicación bastante directa del tamaño de la entrega: «me quede sin luz, bueno poquito es algo».

## 23 de octubre de 2026: Materias, mallas y ventana

**Commits:** `fde9e82`, `a8af2b5`, `45653c6`.

Trabajé en los recorridos del juego y en una ventana que pudiera adaptarse mejor. La versión todavía se llamaba UNI SIMULATOR y tenía una modalidad individual y otra local por turnos. Después añadí las mallas de Sistemas e Informática y el grafo curricular. Eso cambió el catálogo: las materias empezaron a tener un lugar concreto en el semestre y sus requisitos.

## 24 de octubre de 2026: Portada y continuidad entre partidas

**Commits:** `154aa6a`, `f861963`.

Desarrollé la portada científica, el arte de las menciones y las primeras demostraciones de estudio. El nombre pasó a CAMPUS EN JUEGO. Añadí transiciones, logros globales y bajo consumo, para que el progreso no dependiera solo de una partida. El primer commit está registrado a las 00:18; mantengo esa fecha sin convertirla en horas de trabajo supuestas.

## 25 de octubre de 2026: Separar el motor de las pantallas

**Commits:** `f2e23de`, `0d5b259`.

Extraje las reglas a un motor individual y separé trámites, comandos y guardado. El recorrido quedó centrado en el estudiante, con historial, auxiliatura y titulación. Después conecté las vistas del campus con ese estado y añadí formularios. Era importante que una pantalla no pudiera dar por aprobado un resultado o un trámite por su cuenta. Incorporé pruebas del motor y de sus conexiones con la interfaz.

## 26 de octubre de 2026: Nombre y logros que faltaban

**Commits:** `fd84010`.

Corregí la creación de partidas: el nombre pasó a ser obligatorio y se conserva al retroceder. Ajusté también la asignación del primer semestre y ordené los logros públicos y ocultos. El propio mensaje del commit menciona esos dos problemas; aquí el arreglo es concreto, no solo una mejora general de la interfaz.

## 28 de octubre de 2026: Identidad por carrera y grafo utilizable

**Commits:** `fa203e7`, `23b5dd0`.

Unifiqué la identidad azul de Sistemas y roja de Informática en las pantallas del juego. Después amplié la malla con arrastre, zoom y distribución conservada durante la sesión. Separé la validación de conexiones del dibujo para comprobar los cruces y las distancias. Mover una esfera debía mejorar la vista, no cambiar sus requisitos ni tapar una relación.

## 29 de octubre de 2026: Navegación clara e historia demostrativa

**Commits:** `32d6a59`, `e486e77`.

Reemplacé la rueda y los deslizadores por páginas, botones y selectores. Separé los ambientes de mención y dejé registradas las reglas y las fuentes que faltaban. Añadí una historia de carrera que genera un recorrido con semilla reproducible y sin ocupar los guardados del jugador. También amplié el movimiento de ramas del grafo. La idea era poder mostrar un recorrido completo sin tener que jugar cada semestre en una exposición.

## 30 de octubre de 2026: Documentación, pixel art y SIS-INF

**Commits:** `78cc2f2`, `b1aef99`, `b28cf38`, `389dc82`.

Ordené las guías del repositorio y la licencia libre, y dejé la bitácora vinculada con el historial. Después pasé la interfaz a pixel art: es un estilo que me gusta y quedó como dirección del juego. Al cerrar el día cambié el nombre a SIS-INF y añadí la exploración basada en el plano aportado. El personaje puede caminar, entrar en ambientes y consultar el progreso; una visita no concede notas ni completa trámites.

## 31 de octubre de 2026: Edificios, emblema y terminal del menú

**Commits:** `a663c1a`, `f49ec69`, `6515d1c`, `865d7e1`.

Amplié los edificios con pasillos y ambientes distintos. Recreé el emblema con geometría y trabajé en la ruptura del menú hasta dejar la terminal dentro del mismo contenedor. Varié fachadas, árboles y canchas y añadí las mesas de la sala E. En esa versión las mesas eran presentación, todavía sin partidas jugables. La última entrega acotó las líneas y los fragmentos de la animación para no acumular objetos sin límite.

## 2 de noviembre de 2026: Las mesas ya se pueden jugar

**Commits:** `b122e96`, `564a85e`.

Implementé las partidas contra rivales locales: ajedrez, billar, ping-pong y Ruta del campus. Los motores quedaron separados de la vista y del expediente académico, con pausa y recuperación por perfil. La búsqueda de ajedrez tiene un presupuesto y la física usa pasos fijos. Aproveché para evitar que el mapa reconstruyera todos los edificios en cada consulta. Faltan partidas con personas para ajustar la dificultad: que el rival funcione no demuestra que el juego resulte cómodo o divertido.

Después ordené los primeros 32 commits y separé las funciones disponibles, las pruebas y los pendientes. En el mensaje de ese envío dejé «Wachando nomas, creo que sera todo por hoy».

## 3 de noviembre de 2026 · la terminal y las mesas

**Commits:** `b3d549b`, `1977fd8`.

Corregí el sprite al mirar a la izquierda y el cambio de pantalla al abrir una mesa. La prueba anterior llamaba a `interact()` directamente. Añadí casos con E, Enter y clic para recorrer la entrada que podía quedarse sin viewport. De paso preparé el icono pixel art y una terminal automática que explica las carreras y las cinco menciones en bucle.

En la segunda entrega pasé el billar a ocho bolas y conservé el motor antiguo para las partidas de seis. Redibujé las piezas de ajedrez, añadí impulso en ping-pong y moví los dados y las compras de Ruta del campus al tablero. También amplié el campus con los bloques de varios niveles y las fichas de Piedritas y el Chivato. Los pisos y los personajes todavía eran diseños en este corte. La pausa de la terminal ya elegía un arquetipo, con su arte pendiente.

[Demostración automática](MODO_DEMOSTRATIVO.md) · [Sala E](JUEGOS_BLOQUE_E.md) · [Campus ampliado](CAMPUS_AMPLIADO_Y_VIDA_DEL_CAMPUS.md)

## 4 de noviembre de 2026 · una matriz para revisar el mapa

**Commit:** `c0bd256`.

Retiré del proyecto las copias de los planos y del logo original. Preparé 64 láminas para comparar distancias y aumenté el tamaño de los personajes, su velocidad y la huella de colisión. Añadí paseos ambientales alrededor de los sectores. La vista satelital ayudó con las cubiertas, pero la fecha de captura quedó sin confirmar. [Matriz 8×8 y personajes](MAPA_8X8_Y_PERSONAJES.md)

## 6 de noviembre de 2026 · caminos, pisos y personajes

**Commits:** `e206909`, `113037c`, agrupados en un push.

El inicio estaba cargado de botones. Lo reduje a Jugar, Simular, Opciones y Salir. Uní el dibujo de los caminos y añadí la rosa con el norte a la derecha. Separé los tamaños y las colisiones por ambiente para que las aulas y laboratorios se pudieran diferenciar también al caminar.

Conecté las escaleras, las rutinas ficticias de los NPC, las caricias y los logros con el guardado. Dejé un sorteo de Piedritas de 1 entre 100 por recorrido, como se acordó. Para reducir el trabajo repetido usé un índice de colisiones exteriores y una caché para la ruptura del menú. En bajo consumo dejé estático el fondo decorativo. [Caminos e interiores](CAMINOS_MENU_Y_AMBIENTES.md) · [Vida y rendimiento](VIDA_CAMPUS_Y_RENDIMIENTO.md)

## 8 de noviembre de 2026 · un mapa para caminar y otro para revisar

**Commits:** `f79e107`, `72b6443`.

Calibré el mapa con OpenStreetMap y separé las proporciones del terreno de la velocidad del personaje. Así pude acortar las caminatas sin encoger cada edificio. Conservé las 64 láminas en el atlas de revisión y dejé en el mapa jugable la flecha, los rótulos y el zoom.

Después centré Inicio y Jugar, agrupé las opciones por categoría y marqué mejor el foco y el puntero. Añadí la malla, el muro y el tránsito ambiental exterior. Los acabados del perímetro y las puertas reales siguen sujetos a fotos o planos fechados. [Cartografía y escala](CARTOGRAFIA_FNI_Y_ESCALA.md) · [Menús y perímetro](MENUS_MAPA_Y_PERIMETRO.md)

## 9 de noviembre de 2026 · volver al piso correcto

**Commit:** `4095c2e`.

Hice que volver de un aula actualice una sola vez el pasillo de su planta. Revisé la recuperación de datos malformados y reutilicé las colisiones interiores mientras no cambie el recinto. Quité el prototipo de paseos cuando el controlador de vida asumió su población. En el mensaje quedó «por el momento un cafecito sera».

Las 29 suites y el arranque aislado de la exportación están registrados en [Verificaciones](VERIFICACIONES.md). La medición de colisiones corresponde a una escena y una máquina.
