# Reglas de negocio

Este documento es la referencia inicial para las reglas funcionales. Cada implementación deberá conservar el identificador de la regla para facilitar su revisión.

| ID | Regla |
|---|---|
| R1 | El límite predeterminado es de seis materias por estudiante. |
| R2 | Se habilita una séptima materia cuando el promedio ponderado del periodo ordinario anterior es igual o superior a 65. |
| R3 | Verano, invierno y mesa pueden habilitar prerrequisitos, pero no se consideran para el promedio ordinario. |
| R4 | El cupo de cada paralelo respeta la capacidad física del aula. Si se llena, se intenta el siguiente paralelo; no hay lista de espera. |
| R5 | Solo el personal administrativo abre paralelos. |
| R6 | Quien no obtuvo cupo en una materia que tenía habilitada recibe prioridad máxima en la siguiente oportunidad. |
| R7 | Reprobar una materia cursada suspende la prioridad en esa materia por un semestre completo. |
| R8 | El estudiante puede editar su horario aunque genere cruces; el sistema debe advertirlos sin bloquear la edición. |
| R9 | Un acta cerrada es inmutable. Una corrección requiere un trámite autorizado y auditado. |
| R10 | Cada estudiante puede mantener hasta tres postulaciones activas a auxiliatura. |
| R11 | La selección de auxiliares ordena postulantes por promedio; los mejores ocupan primero los paralelos disponibles. |
| R12 | La carta de postulación incluye materias ordinarias aprobadas y excluye verano, invierno y mesa. |
| R13 | El Encargado de Horarios puede conceder un permiso temporal y específico para una materia y periodo. |

## Criterios transversales

- El promedio es ponderado por créditos y usa las materias ordinarias del semestre ordinario inmediato anterior con nota registrada.
- Las materias de verano, invierno y mesa pueden contar para prerrequisitos, pero nunca para dicho promedio.
- Los choques del horario se muestran como advertencias visibles.
- Al cerrar un acta, todas las notas de inscripciones cursando deben estar registradas; el acta y sus notas quedan bloqueadas. La corrección requiere Dirección o Administración, motivo y referencia de trámite, y conserva una auditoría inmutable.
- Los detalles operativos y los desempates están descritos en el enunciado funcional entregado para el proyecto; se irán incorporando aquí al implementar cada regla.
