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

| Consulta | Endpoint |
|---|---|
| Estado de la API | `GET /api/health/` |
| Carreras | `GET /api/carreras/` |
| Mallas y planes | `GET /api/mallas/` |
| Materias | `GET /api/materias/` |
| Materias por plan | `GET /api/materias/?plan=<id>` |
| Materias por semestre | `GET /api/materias/?semestre=<n>` |
| Periodos académicos | `GET /api/periodos/` |

## Decisiones de dominio

- Las materias son nodos curriculares y sus prerrequisitos forman un grafo dirigido.
- Las materias extracurriculares aparecen en el horario e historial, sin modificar el avance del plan ni el promedio.
- Los tipos de periodo previstos son `S1`, `S2`, `ANUAL`, `VERANO`, `INVIERNO` y `MESA`.
- El usuario personalizado de Django está definido desde su migración inicial, antes de crear las tablas de autenticación.
