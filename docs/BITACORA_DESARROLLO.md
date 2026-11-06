# Bitácora de desarrollo de SIS-INF

## 6 de noviembre de 2026: cerrar contratos y reducir trabajo repetido

Cambios locales sobre `e206909`, sin commit propio. Revisé las notas de frontend
y conecté escaleras, plantas, rutinas de personajes, caricias y logros con el
guardado. Los NPC usan la misma población visual y rutas sobre los caminos;
sus clases son ficticias y no afectan las notas. El usuario eligió 1 entre 100
para Piedritas, con un solo sorteo conservado por recorrido.

La colisión consulta ahora un índice espacial y la ruptura reutiliza geometría
en una caché acotada. Se redujeron consultas de contexto y copias de progreso,
y bajo consumo deja estático el fondo decorativo. La medición local de estas
funciones bajó; no la presento como una garantía de FPS en cualquier PC.

La matriz de nueve suites suma 9.902 aserciones sin fallos y se generaron cinco
capturas. Los detalles y límites están en [Verificaciones](VERIFICACIONES.md).
Dejé para frontend el acabado de animaciones y para datos las plantas,
horarios, equipamiento y fuentes originales en
[Vida del campus y rendimiento](VIDA_CAMPUS_Y_RENDIMIENTO.md).


## 6 de noviembre de 2026: caminos, inicio e interiores

Cambios locales sin commit propio. El usuario señaló los caminos que se
encimaban y pidió cuatro acciones en el inicio. Se unificó el dibujo de la
red vial por capas, se suavizaron giros y se incorporó la rosa con norte a la
derecha. Jugar conserva partidas y exploración; Simular reúne las demostraciones.

Se revisaron fotografías de RTvU–UTO y referencias institucionales para variar
las proporciones, ventanales y mobiliario de los interiores. Las medidas siguen
siendo ilustrativas. Tamaño, colisión, aparición y salida ahora comparten un
perfil por ambiente. Se actualizaron las láminas 8×8 y la compilación Windows.
Fuentes y responsabilidades en [Caminos, inicio y ambientes](CAMINOS_MENU_Y_AMBIENTES.md);
las once suites y sus límites están en [Verificaciones](VERIFICACIONES.md).

## 4 de noviembre de 2026: matriz 8×8 y escala del campus

Cambios locales sin commit propio. El usuario pidió retirar los originales
de referencia del sistema, obtener una matriz mayor para corregir dimensiones
y aumentar los personajes y su avance. Se retiraron los dos planos, la copia
del logo original y el conversor, conservando los originales en Descargas.
La consulta de Google Maps sí permitió ver la Ciudad Universitaria en satélite;
su fecha de captura no quedó confirmada. Se ajustaron cubiertas y se registró
qué fachadas y plantas todavía necesitan fotos fechadas.

El mapa ahora se revisa en 64 celdas de 1536×1088 unidades. Se ampliaron sprites,
huella de pies, puertas y velocidades; 51 personajes variados realizan paseos
ambientales locales. Los horarios y la asistencia a aulas siguen para motor.
Los contratos y referencias están en [Matriz 8×8](MAPA_8X8_Y_PERSONAJES.md),
y las comprobaciones de esta entrega en [Verificaciones](VERIFICACIONES.md).

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

## 3 de noviembre de 2026: Entrada a las mesas y demostración automática

**Estado:** cambios locales, sin commit nuevo.

El usuario reportó que el personaje se separaba de su sombra al mirar a la
izquierda y que entrar a una mesa cerraba el juego. Corregí el anclaje del
reflejo y reproduje un acceso al viewport después de retirar el campus durante
la entrada de teclado. Ahora la entrada se consume primero y las señales que
cambian de pantalla se atienden de forma diferida. Las pruebas anteriores
llamaban a `interact()` directamente; añadí eventos reales de E, Enter y ratón
para cubrir ese camino. No se obtuvo un registro nativo del cierre completo.

Añadí una terminal de presentación separada: resumen de ambas carreras y cinco
menciones, recorrido completo por materias, escritura progresiva y repetición.
El guion usa el catálogo existente y no modifica una partida. Dejé una columna
de esquemas y el contrato para que frontend incorpore las animaciones. El icono
del EXE y la ventana pasó a una síntesis geométrica pixel art del emblema, con
PNG e ICO generados desde código. Ajusté la separación del inicio para mantener
todas las acciones visibles al añadir el nuevo modo.

Ejecuté cinco suites: 5.553 aserciones y cero fallos en la matriz final; generé
ocho capturas y exporté/arranqué el ejecutable actualizado. La matriz, el fallo
reproducido y los límites están en [Verificaciones](VERIFICACIONES.md). Falta
evaluar una exposición prolongada, integrar las animaciones de frontend y
contrastar el contenido con programas y normas vigentes según
[Modo demostrativo](MODO_DEMOSTRATIVO.md).

### Ampliación: jugar sobre el tablero

**Estado:** cambios locales del mismo día, sin commit nuevo.

El usuario confirmó que los juegos funcionan y pidió piezas de ajedrez sin
letras, billar más cercano a las mecánicas de ocho bolas, ping-pong más dinámico
y una Ruta del campus que dependa menos de botones exteriores. Amplié el lienzo
de los juegos y trasladé al tablero los dados, las propiedades, la promoción y
los controles de billar. Las piezas tienen siluetas propias de 32×40; los
tableros comparten la ruptura negra del inicio. La economía de Ruta del campus
conserva su variante de veinte casillas, ahora con consulta, casas y recorrido
visual de las fichas.

El billar pasó a dieciséis cuerpos, grupos, faltas, bola en mano, efectos arcade
y negra en tronera elegida. El tiro se prepara retirando el taco y se ejecuta
al soltar; no añadí una barra deslizante. Guardé el motor de seis bolas como
compatibilidad para las sesiones existentes: sólo Reiniciar las cambia a ocho.
En ping-pong añadí impulso con recuperación y una devolución sensible al
movimiento de la paleta. La pausa de la terminal prepara un personaje aleatorio
y emite un contrato; su diseño y la abertura siguen para frontend, como pidió
el usuario.

La matriz de esta ampliación reúne siete suites y 14.422 aserciones sin fallos,
con doce capturas gráficas. Los casos nuevos comprueban reglas de ocho bolas,
gestos del taco, colocación, dados, compras y mensajes de pausa. El alcance y
los resultados se registran por separado en [Verificaciones](VERIFICACIONES.md).
Faltan sesiones humanas para ajustar puntería y ritmo, el arte de pausa y
pruebas en otros equipos. No cambié reglas académicas ni servicios web.

### 3 de noviembre de 2026: campus ampliado y diseños de vida del campus

Cambios locales sin commit propio. El usuario entregó un plano marcado y pidió
un mapa mucho mayor, con las distancias, áreas verdes, caminos, fuentes y
elementos del campus. Se amplió a 12288 × 8704 unidades de juego y se separó
el bosque del ingreso de los jardines. Se añadieron estacionamientos, laguna
de Civil, asientos FNI y quirquinchos diferenciados. El terreno, los árboles
y los detalles de las cubiertas se dibujan según la región visible; el arte
procedural se conserva en caché.

Las fotos aportadas sirven de referencia para el Chivato de piedra y Piedritas
de bronce. E abre sus fichas mediante ruptura central y conserva el recorrido
al cerrarlas. La fecha del 3 de julio de 1906 procede de FNI-UTO; la organización
en recuerdo de Piedritas se identifica como relato pendiente de respaldar.
Se prepararon planos de dos niveles para el bloque 100 y cinco para el bloque
en cruz, más profesionales, estudiantes y perros variados. Los paseos, clases,
caricias, logros, encuentro raro y cambio de planta se dejaron como contratos
de motor/backend, sin simular que ya estuvieran funcionando.

Cuatro suites de esta ampliación sumaron 3.664 aserciones sin fallos; se
generaron veinte capturas y se exportó Windows. El arranque aislado del binario
terminó con salida cero. Los registros y límites reales están en
[Verificaciones](VERIFICACIONES.md); las fuentes, IDs y tareas de cada área,
en [Campus ampliado](CAMPUS_AMPLIADO_Y_VIDA_DEL_CAMPUS.md). Se mantuvieron los
cambios paralelos de minijuegos y terminal. No se modificó el motor académico.
