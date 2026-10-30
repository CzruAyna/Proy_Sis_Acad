# Bitácora de desarrollo

Actualizada: 30 de octubre de 2026.

## Alcance del registro

Esta bitácora relaciona los avances con el historial local disponible: 24 commits
en 13 fechas, del 15 al 30 de octubre de 2026, hasta `78cc2f2`. El registro está
redactado en primera persona para la memoria del autor. Describe archivos y
cambios comprobables; las explicaciones personales proceden de su relato.

Las fechas corresponden al registro en Git, en UTC−04:00. No representan horas
de dedicación ni acreditan que todo el trabajo se haya realizado en ese día.
Las comprobaciones de esta reconstrucción son documentales: historial, archivos
y diferencias. No se han ejecutado de nuevo las pruebas de cada versión.

El estado actual está descrito en [Arquitectura](ARQUITECTURA.md),
[Diseño visual](DISENO_VISUAL_CAMPUS.md) y
[Simulación individual](SIMULACION_ESTUDIANTE.md). Una interfaz descrita en una
entrada antigua puede haber sido sustituida después.

## 15 de octubre: estructura inicial
**Commits:** `242e755`, `8302683`.

Creé el repositorio y preparé la estructura del sistema académico.
Separé el backend y el frontend, incorporé las dependencias iniciales y
definí la configuración de desarrollo local. En Django añadí un usuario
basado en `AbstractUser`, con CI y rol académico, y lo declaré como
modelo de autenticación del proyecto.

En esta primera etapa necesitaba convertir procesos que conocía por
experiencia en reglas que pudieran programarse. Fui reuniendo información
de situaciones cotidianas y deduciendo sus elementos principales:
quién interviene, qué datos requiere una operación y qué condiciones
deben cumplirse para realizarla. Esta dificultad marcó el trabajo inicial
de especificación; no he asignado a un solo día todo ese levantamiento.

Dejé una especificación funcional, un modelo de datos inicial, reglas
identificadas como R1–R13 y un orden de implementación. Los módulos de
dominio todavía estaban mayormente reservados como directorios.
La base quedó preparada para incorporar el catálogo y las operaciones
académicas.

## 18 de octubre: catálogo y oferta académica
**Commits:** `8162267`, `6f5ced9`, `f97e336`.

Trabajé en la presentación de la portada y después incorporé el núcleo
académico: carreras, planes, materias, prerrequisitos y periodos.
Añadí migraciones, administración, serializadores y consultas de API.
Conecté el catálogo de Next.js con esos recursos y agrupé las materias
por semestre.

Representé los requisitos como relaciones entre materias. Para mantener
coherencia en la malla añadí comprobaciones de relaciones duplicadas,
autorreferencias y ciclos. Con ello el catálogo dejó de ser solamente
contenido de la interfaz y pasó a tener una estructura de dominio.

En la oferta incorporé aulas, habilitación de docentes, paralelos y
sesiones de clase. Añadí validaciones de capacidad e intervalos horarios
y publiqué la consulta de paralelos abiertos. Los cambios se distribuyeron
principalmente entre `backend/apps/academico/`,
`backend/apps/oferta/` y los componentes de catálogo y oferta
del frontend.

## 19 de octubre: inscripción y gestión de notas
**Commits:** `bace499`, `c9ecbed`, `cca8f0e`.

Implementé la inscripción autenticada y el retiro de materias.
Concentré la asignación de cupos en un servicio transaccional:
si el paralelo solicitado está lleno, el servicio intenta los siguientes
paralelos abiertos de la misma materia y periodo. El panel del estudiante
permite consultar sus inscripciones y realizar estas operaciones.

Después incorporé actas, notas y correcciones. Separé la carga ordinaria
del cierre de acta. El cierre exige notas completas, actualiza el resultado
de cada inscripción y registra al usuario responsable. Una corrección
posterior necesita permisos administrativos y genera un registro con el
puntaje anterior, el nuevo, el motivo y la referencia del trámite.

En el frontend añadí el panel docente. Al finalizar esta fecha el sistema
ya tenía un recorrido que conectaba oferta, inscripción y calificación.
Las estructuras nuevas se encuentran en
`backend/apps/inscripciones/` y `backend/apps/notas/`.

## 20 de octubre: requisitos y carga académica
**Commits:** `122d1d3`.

Amplié la inscripción para evaluar prerrequisitos, corequisitos y carga
académica. Calculé el promedio ponderado del periodo ordinario anterior
a partir de notas de actas cerradas. El límite queda en seis materias,
o siete cuando el promedio alcanza 65.

Añadí una consulta de elegibilidad para devolver la habilitación y sus
motivos junto con los paralelos del periodo. El frontend utiliza esa
información para explicar por qué una materia puede o no inscribirse.
También amplié la presentación del horario del estudiante.

El cambio se concentra en el servicio y la vista de inscripciones y en
`inscripciones-panel.tsx`. Esta entrega implementó validaciones
y consulta del horario; la generación automática de combinaciones de
paralelos continuó como trabajo pendiente.

## 21 de octubre: incorporación del juego
**Commits:** `3dc9d7d`.

Incorporé una experiencia de juego en la web y añadí el proyecto Godot.
En Next.js trasladé la interfaz de gestión a `/sistema` y utilicé
la portada para el componente `JuegoAcademico`.
La versión de escritorio comenzó con escena principal, catálogo,
controlador y configuración de exportación.

Este cambio corresponde a la evolución del propósito del proyecto:
aprovechar la base académica para representar el recorrido del estudiante
en una demostración interactiva. La fecha identifica la incorporación
del código del juego; la reflexión que dio lugar al cambio fue parte de
la evolución del trabajo.

Conservé el sistema web en el repositorio y desarrollé la aplicación
de escritorio dentro de `game/`. A partir de esta etapa el
historial concentra la mayor parte de los cambios en el juego.

## 22 de octubre: selección de enfoques
**Commits:** `5ee374a`.

Amplié el catálogo de muestra con opciones de enfoque o mención y añadí
una pantalla de selección antes de crear la partida.
Guardé la opción elegida en el perfil para que continuara disponible
durante el recorrido.

Los cambios afectaron `game/scripts/catalog.gd` y
`game/scripts/game.gd`. Las opciones de esta versión eran
provisionales; posteriormente las sustituí por el contenido centrado
en Sistemas e Informática.

## 23 de octubre: mallas y avance por materias
**Commits:** `fde9e82`, `a8af2b5`, `45653c6`.

Amplié los flujos de partida y ajusté la ventana para permitir
redimensionamiento y mejorar la lectura. En esta etapa el README
registraba el nombre *UNI SIMULATOR* y describía modalidades
individual y local por turnos.

Después incorporé las mallas de Sistemas e Informática en
`uto_curricula.gd` y añadí un componente de grafo curricular.
El catálogo pasó a relacionar materias, semestres y requisitos
con mayor detalle. Adapté el recorrido para consultar materias y
revisar sus dependencias.

El cambio redujo el contenido de muestra y concentró el juego en
las carreras que podía relacionar con mi experiencia y con las
exposiciones conjuntas. La malla se convirtió en una parte funcional
del recorrido, además de una vista informativa.

## 24 de octubre: portada, estudio y logros globales
**Commits:** `154aa6a`, `f861963`.

Trabajé en la portada con curvas, fórmulas y animaciones, y consolidé
el nombre *CAMPUS EN JUEGO*. Añadí arte para las menciones,
demostraciones de estudio y ajustes del grafo curricular.
Estos cambios se apoyaron en los nuevos módulos
`mention_art.gd` y `study_demo.gd`.

También incorporé un perfil de logros globales, transiciones de menú y
una opción de bajo consumo. Esta opción reduce detalles visuales y
limita las animaciones a 30 FPS. Los logros se conservan entre partidas.

El primer commit de esta fecha se registró a las 00:18. Mantengo la fecha
de Git como referencia, sin convertir ese horario en una estimación
de duración de la sesión.

## 25 de octubre: motor individual e interfaz del campus
**Commits:** `f2e23de`, `0d5b259`.

Separé la simulación del controlador principal. En
`student_simulation.gd` reuní inscripción, cursado, resultados,
historial, cambios de plan, auxiliatura y graduación.
Añadí módulos específicos para definiciones de trámites, comandos
opcionales y guardado.

El recorrido quedó centrado en un estudiante. La auxiliatura pasó a ser
una actividad dentro de su carrera y las autoridades se representaron
mediante oficinas y procesos simulados. El modo de equipo de las
versiones anteriores dejó de ofrecerse como recorrido jugable.
Conservé compatibilidad de lectura para el historial individual antiguo.

En la interfaz incorporé una navegación común entre materias, malla,
trámites, historial, auxiliatura y graduación. Añadí formularios para
solicitudes y separé las demostraciones de estudio de la evaluación
que registra notas. La vista utiliza el estado del motor y ejecuta
sus operaciones; no modifica directamente el avance de un trámite.

Añadí pruebas de simulación, guardado, integración e interfaz.
La separación permitió comprobar reglas académicas sin recorrer
manualmente todas las pantallas.

## 26 de octubre: identidad del jugador y catálogo de logros
**Commits:** `fd84010`.

Corregí el flujo de creación para exigir un nombre no vacío y conservarlo
al volver entre la selección de carrera y mención. Ajusté también
la asignación de materias de ingreso para el primer semestre.

Organicé los logros en un catálogo con identificadores estables.
La interfaz muestra los públicos como pendientes o desbloqueados y
revela los ocultos cuando se consiguen. Mantuve la migración de
registros históricos y añadí pruebas de las reglas del jugador.

Los archivos principales de esta entrega fueron
`game.gd`, `student_simulation.gd` y el nuevo
`achievement_catalog.gd`.

## 28 de octubre: identidad visual y malla interactiva
**Commits:** `fa203e7`, `23b5dd0`.

Centralicé las paletas y primitivas visuales en
`neon_visuals.gd`. Apliqué una identidad azul para Sistemas,
roja para Informática y motivos de fondo para las cinco menciones.
Extendí esa identidad a controles, estudio y pantallas del campus.

Amplié la malla a todo el ancho disponible y trasladé la ficha de la
materia debajo del grafo. Añadí arrastre de nodos, desplazamiento,
zoom, restablecimiento y conservación de la distribución durante
la sesión. Las posiciones son de presentación y no cambian los
prerrequisitos ni los resultados académicos.

En `graph_routing.gd` añadí validación de las polilíneas que
se dibujan. El validador evita cruces, contacto entre aristas y paso
por esferas ajenas a la conexión. Un arrastre que incumple esas
condiciones se rechaza antes de actualizar el dibujo. La separación
mínima entre aristas está definida en 24 unidades del lienzo.

Incorporé pruebas de separación e interacción. La prueba de separación
incluye una comprobación geométrica independiente del validador
utilizado por el grafo, para contrastar sus resultados.

## 29 de octubre: navegación por botones y ambiente de menciones

**Commits:** `32d6a59`, `e486e77`.

Sustituí la dependencia de la rueda y los deslizadores por controles explícitos,
páginas y selectores. Añadí `paged_view.gd` y `choice_picker.gd`, revisé opciones
y vistas del campus y mantuve la identidad de la partida en su cabecera.

Separé el ambiente de cada mención en `mention_ambient.gd`. Los fondos son
animados, desenfocados y de baja presencia visual; las tarjetas permanecen
opacas. Registré las reglas de presentación y el material institucional que
falta confirmar en los documentos de coordinación.

Después incorporé la historia demostrativa con `career_story.gd` y
`career_story_ui.gd`. El generador recorre una carrera mediante el motor del
estudiante con perfiles aislados, semillas y parámetros ficticios. La
demostración no ocupa espacios ni escribe partidas o logros. Amplié el grafo
para mover ramas y girarlas dentro de la protección geométrica.

Añadí pruebas de navegación compacta, ambiente, historia y navegación de la
historia. Su existencia y sus casos se comprueban en el historial; esta entrada
no presenta una nueva ejecución de esas pruebas.

## 30 de octubre: guías del repositorio y procedimiento de documentación

**Commit:** `78cc2f2`.

Actualicé el README para presentar Godot como producto principal y distinguir
la API Django y la interfaz Next.js. Incorporé el índice de documentación,
la guía de arquitectura y las instrucciones de desarrollo y compilación local.
Amplié `AGENTS.md` con la revisión de reglas al cerrar y el uso de Markdown
para la documentación técnica.

La estructura permite encontrar los contratos y responsables sin confundir
la memoria histórica con las guías del estado actual.

### Cambios de documentación todavía sin commit

**Fecha de preparación:** 30 de octubre de 2026.

Incorporé las reglas acumulativas sobre documentación, código libre y título
del summary. Añadí esta bitácora, una guía de mantenimiento de documentos y
la política de licencia; enlacé esos documentos desde los índices.

Adopté `GPL-3.0-or-later` para el código original y la documentación propia
y añadí el texto oficial completo a `LICENSE`. Conservé las licencias de
terceros y registré las revisiones de procedencia, dependencias y distribución
pendientes en [Código libre y licencia](LICENCIA_CODIGO_LIBRE.md).

Las comprobaciones de cierre se registran en el resumen de esta entrega.
No se atribuye un identificador de commit a cambios que todavía no lo tienen.
