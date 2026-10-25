# Simulación individual de la carrera

Este documento describe las reglas del juego de escritorio acordadas con el usuario el 25 de octubre de 2026. El motor está en `game/scripts/student_simulation.gd`. Django y el juego web siguen siendo componentes separados; estas reglas no sustituyen automáticamente la normativa ni los modelos del sistema académico real.

## Recorrido académico

| Regla | Comportamiento |
|---|---|
| SIM-01 | Una persona juega como estudiante. La auxiliatura es una actividad del estudiante; las autoridades son oficinas y personajes simulados. No hay modo equipo ni ascenso a administrativo o decano. |
| SIM-02 | El semestre tiene inscripción, cursado y cierre. El plan inicial incluye las materias de ingreso. Los siguientes planes priorizan reprobadas pendientes y agregan materias habilitadas por aprobaciones anteriores. |
| SIM-03 | Una correlativa puede cursarse junto con todas sus regulares pendientes, que se incorporan obligatoriamente a la inscripción. El paquete completo respeta el límite de carga y se registra íntegramente o se rechaza. No se retira una regular mientras otra inscripción dependa de ella. |
| SIM-04 | Los resultados de regular y correlativa son independientes. La correlativa aprobada se conserva aunque se repruebe la regular. Los nuevos desbloqueos académicos se consolidan al cerrar el semestre. |
| SIM-05 | Tres parciales aportan cada uno 0 o 100; la nota final es su media. Se aprueba desde 51. Un resultado final no se repite en el mismo semestre. Reprobar un parcial no equivale a reprobar la materia. |
| SIM-06 | El historial conserva todos los intentos. Aprobar después, cambiar de plan o usar el truco de desbloqueo no borra una reprobación. |
| SIM-07 | La carga es de seis materias, o siete si el promedio del semestre anterior alcanza 65. Si quedan más reprobadas que espacios, las restantes conservan su obligación de recursado. Esta regla de carga es distinta de la excelencia. |
| SIM-08 | La excelencia exige concluir el plan, no haber reprobado materias y promedio estrictamente mayor que 65. El 65 exacto no habilita esta vía. La excelencia no requiere defensa. |
| SIM-09 | Con una reprobación histórica se requiere tesis o proyecto de grado. También se puede elegir una de estas modalidades voluntariamente. Egreso, defensa, diploma y título son estados diferentes. |
| SIM-10 | La auxiliatura requiere materia aprobada, al menos una aprobación en el semestre anterior, matrícula vigente, documentación y derecho de postulación. Hay hasta tres postulaciones activas. |
| SIM-11 | El examen compite con postulantes simulados; resultados y rivales se conservan al guardar. Ganar asigna materia, paralelo, docente y periodo. Luego se requiere plan firmado, permiso de aula, tres actividades de apoyo e informe firmado. El beneficio se registra al cumplir el trabajo. |
| SIM-12 | Los permisos por carta o materia externa son específicos para una materia y un semestre. Cambiar de carrera o mención conserva el historial; se reconocen como comunes únicamente materias con igual sigla y nombre. |

El promedio usa créditos cuando el catálogo los proporciona; las mallas actuales no los incluyen y cada materia tiene peso uno. Las materias externas permanecen en el historial, pero no completan por sí mismas una materia distinta del plan. El nodo `SIS 5100 · GRADUACIÓN` se representa mediante el proceso de graduación y no exige un examen de materia antes de la vía de excelencia.

## Documentos y oficinas

El expediente conserva formularios, comprobantes, documentos y eventos por trámite. Sus estados son pendiente, observado, completado, cancelado y vencido. Un documento faltante produce una observación subsanable. Los pagos son simulados y no contienen aranceles oficiales ni una integración de cobro.

- **Matrícula:** Caja → Kardex → Cómputo. La habilitación corresponde al semestre actual.
- **Materia por carta:** Dirección → Vicedecanato → Cómputo. Requiere motivo, matrícula e historial.
- **Materia externa:** Dirección de origen → Dirección de destino → Vicedecanato → Cómputo.
- **Cambio de mención, K-02:** Dirección → Vicedecanato → Kardex → DTIC.
- **Cambio interno de carrera, K-03:** Dirección de origen → Dirección de destino → Vicedecanato → Kardex → DTIC.
- **Postulación a auxiliatura:** comprobante de Caja y revisión de solicitud, identidad, matrícula e historial por Dirección; después, examen.
- **Trabajo de auxiliatura:** firma del docente en el plan → autorización de aula → actividades de apoyo → informe docente → cierre en Dirección y registro del beneficio.
- **Excelencia:** verificación en Dirección → aprobación en Decanato → derecho de titulación → diploma → título.
- **Tesis/proyecto:** perfil y tutor → borrador → habilitación documental y pago → defensa → derecho de titulación → diploma → título. Una defensa fallida conserva su intento y admite nueva presentación.

Las rutas de carta, autorización externa y tareas concretas de auxiliatura son reglas de simulación revisables. No se presentan como un procedimiento oficial completo verificado. El catálogo inicial de competencia utiliza dos plazas A/B y dos rivales simulados por convocatoria; la asignación por puesto es una regla del juego configurable, no una norma universal de la UTO. Los rivales varían por materia y semestre, con un resultado estable dentro de la convocatoria.

Referencias institucionales consultadas durante el análisis:

- [K-02 y procedimiento de cambio de mención](https://www.fni.uto.edu.bo/index.php/cambio-mencion/item/download/54_9d3ec891ca17b15abfb78341736f86ed).
- [K-03 y procedimiento de cambio interno de carrera](https://www.fni.uto.edu.bo/index.php/cambio-carrera/item/download/55_4feb2f4c995300e3c581a7232545ec5a).
- [Reglamento de auxiliatura UTO, resolución HCU 146/13](https://www.ft.uto.edu.bo/wp-content/uploads/2025/10/reglamentoauxiliaresdocencia.pdf).
- [Defensa de proyecto de grado en la FNI](https://www.fni.uto.edu.bo/index.php/publicaciones/tramites/item/129-defensa-de-proyecto-de-grado).

Los documentos publicados tienen distintas fechas y no equivalen a un reglamento consolidado vigente. Los calendarios, importes y particularidades de cada convocatoria deben configurarse al ampliar el catálogo.

## Guardado y compatibilidad

Las partidas continúan en `user://partidas/solo_partida_N.json`, con tres espacios. El guardado escribe primero un archivo temporal y conserva la última versión legible en `.bak`. La carga intenta recuperar ese respaldo si el principal está incompleto. Al borrar una partida se eliminan también sus temporales y respaldo. Los archivos multijugador antiguos se conservan sin ofrecerlos como modo jugable.

Las partidas antiguas conservan sus materias conocidas, pero no se inventan notas que nunca fueron guardadas. Se identifican como historial incompleto y no acreditan excelencia automáticamente. Los títulos globales históricos no se eliminan, pero el motor nuevo distingue estudios concluidos de título emitido.

## Verificación

Ejecutar desde la raíz del repositorio:

```powershell
.\game\.tools\Godot_v4.7.2-stable_win64_console.exe --headless --path game --script res://tests/test_student_simulation.gd
.\game\.tools\Godot_v4.7.2-stable_win64_console.exe --headless --path game --script res://tests/test_game_integration.gd
.\game\.tools\Godot_v4.7.2-stable_win64_console.exe --headless --path game --script res://tests/test_simulation_storage.gd
```

Las pruebas incluyen resultados mixtos, todas aprobadas/reprobadas, regular y correlativa independientes, carga, doble respuesta, expedientes, autorización temporal, cambios de plan, auxiliatura, límites, competencia fallida, actividades, ambas defensas, umbral exacto de excelencia, migración, JSON y recuperación del guardado. También recorren completas las cinco mallas disponibles.
