# Modelo de datos previsto

Este mapa describe las entidades del dominio antes de su implementación. Las relaciones y restricciones detalladas se precisarán junto a cada fase.

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

## Decisiones de dominio

- Las materias son nodos curriculares y sus prerrequisitos forman un grafo dirigido.
- Las materias extracurriculares aparecen en el horario e historial, sin modificar el avance del plan ni el promedio.
- Los tipos de periodo previstos son `S1`, `S2`, `ANUAL`, `VERANO`, `INVIERNO` y `MESA`.
- El usuario personalizado de Django se definirá antes de generar la primera migración, para evitar cambiar el modelo de autenticación más adelante.
