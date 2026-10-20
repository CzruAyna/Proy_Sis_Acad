# Modelo de datos

El núcleo académico implementa carreras, planes de estudio, materias, prerrequisitos y periodos. Las demás áreas representan entidades previstas para las siguientes fases.

| Área | Entidades | Relación principal |
|---|---|---|
| Identidad | Usuario | Usuario con rol institucional. |
| Currículo | Carrera, PlanEstudio, Materia, Prerrequisito | Un plan agrupa materias; los prerrequisitos conectan materias del plan. |
| Periodos | PeriodoAcademico | Agrupa oferta, inscripciones y resultados por periodo. |
| Oferta | Aula, DocenteMateria, Paralelo, SesionClase | Paralelos pertenecen a una materia y periodo, y tienen sesiones. |
| Inscripción | Inscripcion, PrioridadEstudiante | Relaciona estudiantes con paralelos y registra prioridad. |
| Evaluación | Acta, Nota | Actas agrupan notas y tienen un ciclo de apertura y cierre. |
| Auxiliaturas | PostulacionAuxiliatura | Registra la postulación de estudiantes a paralelos elegibles. |
| Excepciones | PermisoEspecial | Autoriza una materia durante un periodo hasta su expiración. |
| Documentos | DocumentoGenerado | Registra documentos institucionales generados. |

## Núcleo académico implementado

| Entidad | Campos principales | Restricciones |
|---|---|---|
| Carrera | nombre, codigo | Código único. |
| PlanEstudio | carrera, nombre, vigente | Nombre único dentro de su carrera. |
| Materia | plan, codigo, nombre, creditos, semestre_sugerido, es_extracurricular, lleva_auxiliatura | Código único; créditos no negativos; semestre sugerido positivo. |
| Prerrequisito | materia, requisito, es_corequisito | Una relación única por par; sin autorreferencias ni ciclos; ambas materias deben pertenecer al mismo plan. |
| PeriodoAcademico | tipo, anio, orden, activo | Tipos S1, S2, ANUAL, VERANO, INVIERNO y MESA; orden único dentro del año. |

Los catálogos de carreras, planes, materias y periodos se exponen en modo de solo lectura mediante la API. La carga y edición del catálogo se realiza desde el admin de Django.

## Oferta académica implementada

| Entidad | Campos principales | Restricciones |
|---|---|---|
| Aula | nombre, capacidad, es_laboratorio | Nombre único; capacidad positiva. |
| DocenteMateria | docente, materia | Par único; solo usuarios con rol docente. |
| Paralelo | materia, periodo, identificador, docente, cupo_maximo, abierto | Identificador único por materia y periodo; docente habilitado para la materia; cupo positivo. |
| SesionClase | paralelo, tipo, grupo_lab, aula, dia, hora_inicio, hora_fin | Fin posterior al inicio; el cupo no supera la capacidad del aula; laboratorio requiere aula laboratorio; un aula no puede tener sesiones cruzadas. |

La gestión se realiza en el admin de Django. La API pública solo muestra paralelos abiertos y permite filtrarlos por periodo o materia. La oferta aparece en la interfaz con docente, cupo, aula y sesiones semanales.

## Inscripciones implementadas

| Entidad | Campos principales | Restricciones |
|---|---|---|
| Inscripcion | estudiante, paralelo, estado, origen, creado_en, actualizado_en | Un registro por estudiante y paralelo; no se sobrepasa el cupo ni se cursa dos veces la misma materia en el periodo. |

La inscripción requiere JWT y rol de estudiante. La operación bloquea los paralelos de la misma materia y periodo mientras asigna el asiento; si el seleccionado está lleno, intenta los paralelos siguientes. Retirar una inscripción cambia su estado a `RETIRADA` y libera el asiento. La API devuelve inscriptos actuales y cupos disponibles.

## Actas y calificaciones implementadas

| Entidad | Campos principales | Restricciones |
|---|---|---|
| Acta | paralelo, cerrada, creada_en, cerrada_en, cerrada_por | Una por paralelo; se cierra solo con todas las notas de estudiantes cursando; cerrada es inmutable. |
| Nota | acta, inscripcion, puntaje, actualizada_en | Una por inscripción; puntaje entre 0 y 100; la inscripción debe pertenecer al paralelo del acta. |
| CorreccionNota | nota, puntaje_anterior, puntaje_nuevo, motivo, referencia_tramite, corregida_por, creada_en | Auditoría de solo lectura, no modificable ni eliminable. |

Los docentes solo gestionan actas de paralelos que tienen asignados. El cierre clasifica las inscripciones con la nota mínima aprobatoria (51). Dirección y Administración pueden corregir una nota cerrada mediante un motivo y referencia de trámite, que queda auditada.

| Consulta | Endpoint |
|---|---|
| Estado de la API | `GET /api/health/` |
| Carreras | `GET /api/carreras/` |
| Mallas y planes | `GET /api/mallas/` |
| Materias | `GET /api/materias/` |
| Materias por plan | `GET /api/materias/?plan=<id>` |
| Materias por semestre | `GET /api/materias/?semestre=<n>` |
| Periodos académicos | `GET /api/periodos/` |
| Paralelos abiertos | `GET /api/paralelos/` |
| Paralelos de un periodo | `GET /api/paralelos/?periodo=<id>` |
| Paralelos de una materia | `GET /api/paralelos/?materia=<id>` |
| Inscripciones propias | `GET /api/inscripciones/` (JWT estudiante) |
| Crear inscripción | `POST /api/inscripciones/` con `{"paralelo_id": <id>}` (JWT estudiante) |
| Retirar inscripción propia | `DELETE /api/inscripciones/<id>/` (JWT estudiante) |
| Actas asignadas o administrables | `GET /api/actas/` (JWT docente/Dirección/Administración) |
| Guardar notas de acta | `PUT /api/actas/<id>/notas/` con `{ "notas": [{"inscripcion_id": <id>, "puntaje": <0–100>}] }` |
| Cerrar acta | `POST /api/actas/<id>/cerrar/` (JWT docente asignado) |
| Corregir nota cerrada | `POST /api/actas/<id>/correcciones/` (JWT Dirección/Administración, motivo y referencia de trámite) |

## Decisiones de dominio

- Las materias son nodos curriculares y sus prerrequisitos forman un grafo dirigido.
- Las materias extracurriculares aparecen en el horario e historial, sin modificar el avance del plan ni el promedio.
- Los tipos de periodo previstos son `S1`, `S2`, `ANUAL`, `VERANO`, `INVIERNO` y `MESA`.
- El usuario personalizado de Django está definido desde su migración inicial, antes de crear las tablas de autenticación.
