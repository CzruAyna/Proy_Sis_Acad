# Integración pendiente de la interfaz del juego

<!-- FRONTEND_TEMP: leer este contrato, aplicar las tareas y eliminar cada comentario temporal junto con el pendiente que ya esté resuelto. -->

El motor ya está conectado al juego de escritorio. Esta sesión implementa lógica y persistencia; la otra sesión puede construir la experiencia gráfica sin duplicar las reglas. La auditoría existente `AUDITORIA_FRONTEND_CAMPUS.md` se conserva como trabajo independiente.

## Contrato

- Motor: `game/scripts/student_simulation.gd`. Recibe el diccionario de perfil y mantiene el estado serializable en `profile.simulation`.
- Catálogo de trámites: `game/scripts/simulation_procedures.gd`.
- Guardado: `game/scripts/simulation_save_store.gd`.
- Adaptador temporal de comandos: `game/scripts/simulation_commands.gd`.
- `snapshot()` devuelve una copia de los datos para presentar. Evitar modificar el estado interno desde componentes gráficos.
- Los comandos del motor devuelven `{ok, message, ...}`. Después de una acción, persistir el perfil y refrescar el snapshot. Una observación documental puede cambiar el expediente aunque `ok` sea falso; también debe guardarse.
- El identificador estable de materia es `carrera/mencion/SIGLA`. La sigla abreviada se resuelve dentro del plan actual. Una materia externa debe conservar el identificador completo.

## Acciones de presentación

<!-- FRONTEND_TEMP: reemplazar la consola de F10 por formularios y oficinas gráficas; eliminar este comentario al completar la integración. -->

La consola permite revisar todas las acciones mientras se desarrolla la interfaz. F10 la abre o cierra dentro de una partida; `/ayuda` documenta su uso. No es el diseño final de la experiencia. El botón de inicio/cierre del semestre y las tarjetas actuales solo conectan el controlador con el motor nuevo.

<!-- FRONTEND_TEMP: mostrar planificación por materia y paquete de regulares, no por primer semestre incompleto; eliminar al aplicar. -->

`snapshot.subjects[]` contiene `id`, `sigla`, `name`, `semester`, `approved`, `eligibility` y `enrollment`. `eligibility.regulars` enumera todas las regulares pendientes obligatorias. `enroll(id)` incorpora el paquete completo si cabe; `withdraw(id)` protege las regulares requeridas y reprobadas obligatorias. Las materias inscritas se estudian solo en fase `CURSANDO`; las de resultado final se consolidan al cerrar.

<!-- FRONTEND_TEMP: incorporar estados personales a la malla e historial de intentos; eliminar al aplicar. -->

El grafo existente sigue dibujando el catálogo. Debe consumir el snapshot para distinguir aprobada, inscrita, correlativa, pendiente, reprobada y bloqueada, y presentar el motivo devuelto por el motor. La posición curricular de una materia no es el semestre efectivamente cursado. `snapshot.history` conserva cada intento y los resultados de materias externas o planes anteriores.

<!-- FRONTEND_TEMP: representar pasos de trámite, oficinas, requisitos y observaciones; eliminar al aplicar. -->

`snapshot.procedures[]` incluye identificador, tipo, nombre, estado, semestre, `steps`, índice `step`, `payload` y `events`. Cada paso expone oficina, etiqueta, documentos, comprobante u otra condición. `SimulationProcedures.current_step(request)` devuelve el paso accionable. Utilizar `open_procedure`, `advance_procedure`, `cancel_procedure`, `pay` e `issue_document`; no marcar un trámite como completado desde la interfaz.

<!-- FRONTEND_TEMP: mostrar auxiliares como actividad del estudiante y diferenciar aprobar examen de conseguir plaza; eliminar al aplicar. -->

`apply_assistant(id)` abre la postulación. Tras habilitar documentos, `assistant_answer(application_id, partial_index, correct)` registra tres respuestas. La selección depende de la competencia y las plazas. `snapshot.assignments` publica materia, paralelo, docente, semestre y trabajo asociado. `support_session(request_id, expected_session, successful)` exige plan firmado y permiso de aula. La vista debe explicar el expediente de trabajo y sus actividades pendientes.

<!-- FRONTEND_TEMP: distinguir egreso, modalidad, defensa, diploma y título; eliminar al aplicar. -->

`studies_complete` no equivale a `graduated`. `snapshot.excellence` explica si puede acceder a excelencia. El umbral es **promedio > 65**, además de ninguna materia reprobada. `open_procedure("excelencia" | "tesis" | "proyecto")` inicia la ruta. `defense_answer` conserva intentos y nunca permite que un simple botón de avance apruebe una defensa.

<!-- FRONTEND_TEMP: conservar acceso al comando de exploración dentro del juego; eliminar al integrar la consola definitiva. -->

`/desbloquear todo` llama a `unlock_all()`. No aprueba materias ni elimina reprobaciones; la inscripción sigue respetando su carga. El modo se conserva en la partida. Puede quedar en una consola discreta separada del recorrido normal.

## Recorridos manuales rápidos

1. Crear partida y abrir F10. Ejecutar `/pagar matricula`, consultar `/tramites` y ejecutar tres veces `/paso TR-001` para la matrícula inicial. Cerrar F10 e iniciar semestre.
2. Responder tres parciales por materia y cerrar semestre. Revisar `/historial`; las aprobadas desbloquean materias y las reprobadas quedan en la inscripción siguiente.
3. Antes de iniciar, `/materias`, `/retirar SIGLA` para liberar un espacio opcional y `/inscribir SIGLA` para añadir una correlativa con sus regulares. El motor rechaza retirar una regular necesaria.
4. Tras aprobar una materia y matricular el nuevo semestre: `/pagar historial`, `/documento historial`, `/auxiliar SIGLA`. El resultado indica los IDs de expediente y postulación; pagar su derecho, avanzar el trámite y usar `/examen AUX-...`.
5. Si gana, preparar `/documento plan_aux TR-...`, avanzar las firmas, usar `/apoyo TR-...` tres veces y completar el expediente. Los IDs se consultan en `/tramites`.

Los IDs posteriores dependen de las acciones realizadas; no codificarlos en pantallas ni asumir que siempre coinciden con el ejemplo inicial.
