# Bitácora de desarrollo de SIS-INF

Actualizada: 2 de noviembre de 2026. Corte: `b122e96`; 32 commits en 15 fechas.

Esta es la memoria por jornada. El detalle de cada versión, con su mensaje original y archivos de referencia, está en [Historial por commit](HISTORIAL_COMMITS.md). Las fechas siguen Git (UTC−04:00), no horas de dedicación. Las notas personales citadas proceden de los mensajes; no completé jornadas sin registro con experiencias supuestas.

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

**Commits:** `b122e96`.

Implementé las partidas contra rivales locales: ajedrez, billar, ping-pong y Ruta del campus. Los motores quedaron separados de la vista y del expediente académico, con pausa y recuperación por perfil. La búsqueda de ajedrez tiene un presupuesto y la física usa pasos fijos. Aproveché para evitar que el mapa reconstruyera todos los edificios en cada consulta. Faltan partidas con personas para ajustar la dificultad: que el rival funcione no demuestra que el juego resulte cómodo o divertido.

## Revisión de la documentación del 2 de noviembre

Relacioné las entradas que todavía decían «sin commit» con sus versiones reales. Separé la memoria por jornada del detalle técnico y actualicé las guías al nombre SIS-INF, la exploración y los minijuegos ya jugables. Los resultados registrados por entregas anteriores quedan fechados en [Verificaciones](VERIFICACIONES.md); no son una ejecución nueva.

Esta revisión todavía no tiene commit. Las fuentes institucionales, el interior de la sala E, la sede del centro y las pruebas con jugadores continúan pendientes según [Estado actual](ESTADO_ACTUAL.md).
