# Integración gráfica de CAMPUS EN JUEGO

Actualizado: 25 de octubre de 2026. Las tareas temporales del contrato original se consumieron e implementaron. Este archivo conserva el punto de coordinación con la sesión del motor.

## Estado implementado

| Área | Interfaz disponible |
|---|---|
| Inicio | Continuar la partida más reciente, crear carrera directamente en un espacio libre y administrar partidas. |
| Creación | Nombre y elección de Sistemas/Informática juntos; mención y consulta del plan antes de iniciar. El nombre se conserva al retroceder. |
| Campus | Resumen contextual, próximos pasos y siete accesos comunes: campus, materias, malla, trámites, historial, auxiliatura y graduación. |
| Materias | Búsqueda por nombre/sigla, filtros, estados personales, inscripción, retiro, paquete de regulares, estudio y repaso sin registrar resultados. |
| Malla | Grafo a todo el ancho, esferas con volumen y aristas protegidas contra cruces y contactos, con puertos separados por esfera. Arrastre validado, desplazamiento, zoom, restablecimiento y distribución conservada durante la sesión. Ficha bajo el grafo, estados personales y lista equivalente de materias. Flechas/Enter y ratón; respeta reducción de movimiento y escala de texto. |
| Trámites | Expedientes por oficina, pasos cumplidos y pendientes, observaciones, documentos, comprobantes simulados y cancelación. Incluye formularios de carta, materia externa, K-02 y K-03. |
| Historial | Intentos y resultados por semestre cursado, con el plan de origen. Se conservan las reprobaciones y las materias de otros planes. |
| Auxiliatura | Elegibilidad explicada, postulación, expediente, competencia, puesto y resultado, asignación de docente/paralelo y trabajo con plan firmado, aula, apoyo e informe. |
| Graduación | Egreso separado de modalidad, defensa, diploma y título. Excelencia usa la elegibilidad del motor; tesis y proyecto mantienen la evaluación de defensa. |
| Estudio | Columnas adaptables, respuestas con ajuste de líneas, deslizador visible y modelos que responden al parámetro. Repasar no altera notas ni historial. |
| Accesibilidad | Contenido con desplazamiento, navegación y Atrás fuera del área desplazable, foco de navegación, texto 80–120%, fuente legible y malla sin movimiento cuando se reduce la animación. |
| Exploración | F10 queda como consola opcional. `/desbloquear todo` conserva su funcionamiento sin aprobar ni borrar resultados. Las gestiones ordinarias ya tienen acceso gráfico. |

## Límite entre presentación y motor

- `game/scripts/student_campus.gd` construye las vistas y conserva búsquedas, selección, borradores de formulario y contexto de navegación. Su referencia al controlador es débil para evitar un ciclo de propiedad.
- `game/scripts/game.gd` conserva el controlador, guardado, preguntas y entrada del juego. Proporciona la plantilla desplazable, la navegación y las rejillas que recalculan columnas según el ancho real.
- `game/scripts/student_simulation.gd` sigue siendo la fuente de las reglas. No se modificaron sus algoritmos de inscripción, calificación, historial, auxiliatura, defensa o titulación para construir la interfaz.
- El frontend usa `snapshot()` y ejecuta los métodos existentes del motor. Cada acción persiste el perfil, incluso una observación documental con `ok=false`, y reconstruye la pantalla desde un snapshot nuevo.
- Los IDs completos `carrera/mencion/SIGLA` viajan como datos de los selectores. Las pantallas no inventan IDs de trámite ni marcan un paso como completado directamente.
- La inscripción de una correlativa muestra las regulares adicionales antes de enviar el paquete al motor. La capacidad y la protección de regulares se validan en el motor.
- Los indicadores de documentos son presentación; la autorización para avanzar sigue en `advance_procedure`. Las respuestas de examen y defensa se envían mediante los métodos existentes.
- La interfaz muestra errores de guardado y conserva la partida abierta si falla al guardar y salir o al cambiar de partida.

La API Django y el frontend Next.js siguen separados y no se modificaron en esta integración.

## Recorridos disponibles sin comandos

1. **Matrícula:** Campus → Matrícula del semestre → registrar comprobante → presentar en Caja, Kardex y Cómputo. Volver al campus e iniciar el semestre.
2. **Cursado:** Materias → estudiar una inscrita → responder sus parciales. Repetir con las demás y cerrar el semestre desde el campus, previa confirmación de resultados y vencimiento de actividades del periodo.
3. **Planificación:** Materias → cambiar filtro → consultar requisitos → inscribir o retirar antes del inicio. El motor explica cualquier rechazo del paquete o de la retirada.
4. **Solicitudes:** Trámites → Nueva solicitud académica → tipo → carrera/mención/materia, según corresponda → justificación → presentar. El expediente conserva los requisitos faltantes y la oficina siguiente.
5. **Auxiliatura:** Auxiliatura → postular a una materia aprobada habilitada → completar expediente y competencia → consultar docente/paralelo → preparar plan → firma → aula → apoyo → informe → cierre.
6. **Graduación:** Graduación → elegir modalidad habilitada → preparar documentos y completar oficinas. Tesis/proyecto requieren aprobar las actividades de defensa; avanzar el expediente por sí solo no las aprueba.

Se conserva el alcance de simulación definido en `SIMULACION_ESTUDIANTE.md`. Los documentos y pagos son simulados y no realizan transacciones reales.

## Verificación reproducible

Desde la raíz del proyecto:

```powershell
.\game\.tools\Godot_v4.7.2-stable_win64_console.exe --headless --path game --script res://tests/test_frontend_campus.gd
.\game\.tools\Godot_v4.7.2-stable_win64_console.exe --headless --path game --script res://tests/test_game_integration.gd
.\game\.tools\Godot_v4.7.2-stable_win64_console.exe --headless --path game --script res://tests/test_student_simulation.gd
.\game\.tools\Godot_v4.7.2-stable_win64_console.exe --headless --path game --script res://tests/test_simulation_storage.gd
```

La prueba del frontend cubre los recorridos gráficos completos de matrícula, auxiliatura y las tres modalidades de graduación; formularios académicos, persistencia de observaciones, búsqueda, repaso sin notas y conservación de partida ante un error de guardado. También comprueba geometría en áreas lógicas de 900×640 y 1152×720, con texto al 100% y 120%. Esas áreas lógicas no se confunden con el tamaño físico de una ventana bajo escalado del sistema.

Resultado de esta entrega: **1.826 comprobaciones, cero fallos** (1.609 motor, 18 guardado, 21 integración y 178 frontend). Se exportó `game/build/CAMPUS EN JUEGO.exe` con su `.pck` y se verificó su arranque aislado en modo headless. El entorno restringido emitió un aviso de lectura del almacén de certificados de Windows en ese arranque; no hubo errores de scripts y el proceso terminó con código 0.

`game/tests/capture_frontend.gd` renderiza doce vistas con el motor gráfico en `game/.test-artifacts/frontend/`, usando datos ficticios y sin cargar ni guardar partidas personales. Las capturas permiten revisar composición, legibilidad y acceso a controles además de las medidas automáticas. La prueba gráfica requiere pantalla; el resto funciona en headless.

## Límites que conserva la versión

- Los temarios detallados del catálogo todavía requieren revisión de contenido. La interfaz conserva el aviso de los planes publicados en 2011.
- Las actividades académicas calificadas mantienen el modelo de tres respuestas del motor. El frontend añade repaso y demostraciones, pero no cambia esa regla.
- Los documentos y comprobantes son registros de simulación, no PDFs institucionales emitidos ni pagos reales.
- La revisión de diseño y los recorridos automatizados no sustituyen una sesión de usabilidad con estudiantes.
