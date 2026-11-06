# Integración gráfica de SIS-INF

Actualización de motor del 06/11/2026: implementados los contratos de pisos,
rutinas de NPC, caricias, rareza persistente 1/100 y logros de exploración.
Estado, límites, campos para frontend y verificaciones en
[Vida del campus y rendimiento](VIDA_CAMPUS_Y_RENDIMIENTO.md).
El arte del personaje de pausa y las animaciones laterales siguen pendientes.

Actualización del 06/11/2026: inicio de cuatro acciones, caminos continuos,
rosa orientada e interiores de dimensiones diferentes. Motor/backend debe
consultar aparición, salida y colisiones de cada perfil, sin fijar aulas a
480×320; ocupación, uso de equipos y planos reales siguen pendientes.
[Contrato y material necesario](CAMINOS_MENU_Y_AMBIENTES.md).

Actualización del 04/11/2026: referencias originales fuera del juego, matriz
8×8, personajes mayores y paseos ambientales. Frontend debe respetar el
contrato de `campus_scale.gd`: sprite, huella, anclajes y accesos crecen juntos.
Motor/backend debe sustituir la población ambiental por sus estados de
recorridos y clases, sin duplicarla. Tamaños, límites y fuentes pendientes en
[Matriz 8×8 y personajes](MAPA_8X8_Y_PERSONAJES.md).

Ampliación de exploración del 03/11/2026: hay paisaje ampliado, estatuas con
fichas, diseños de personajes y planos por piso. **Motor/backend** debe conectar
recorridos, clases, caricias, rareza de Piedritas, logros y cambio de planta.
Los IDs, señales, criterios de cierre y fuentes pendientes están en
[Campus ampliado y vida del campus](CAMPUS_AMPLIADO_Y_VIDA_DEL_CAMPUS.md).
Los diseños estáticos y los planos no se presentan como esas funciones ya activas.

Ampliación del 03/11/2026: se preparó `pause_scene_requested` para la rotura y
el personaje aleatorio que espera al pausar la terminal. **Frontend debe hacer
su diseño y animación**, según el apartado Personaje al pausar de
[Modo demostrativo](MODO_DEMOSTRATIVO.md). Los comentarios temporales de esa
integración se eliminan después de aplicarlos. Los tableros jugables ahora
incluyen piezas sin letras, billar de ocho bolas y controles dentro del lienzo;
su funcionamiento se detalla en [Sala E](JUEGOS_BLOQUE_E.md).

Actualización del 03/11/2026: disponible el modo de terminal automática con
resumen y recorrido completo, independiente de partidas. Frontend debe integrar
las animaciones laterales mediante `animation_cue` y el reloj del modelo.
El contrato, nueve tipos de escena, accesibilidad, fuentes pendientes y criterio
para retirar el comentario temporal están en
[Modo demostrativo](MODO_DEMOSTRATIVO.md). Los esquemas laterales actuales son
una presentación de referencia, no las animaciones finales.

Revisión documental: 2 de noviembre de 2026. Las mesas son jugables desde
`b122e96`. Los contratos de las actualizaciones antiguas se conservan debajo
como antecedentes. El resumen vigente está en [Estado actual](ESTADO_ACTUAL.md)
y los resultados de cada versión en [Verificaciones](VERIFICACIONES.md).

Actualización del 02/11/2026: los cuatro minijuegos de E tienen motores locales
y rivales automáticos, con pausa, reinicio y guardado independiente. El encargo
del usuario habilitó completar el funcionamiento antes pendiente. El estado
actual, variantes elegidas, optimizaciones y pendientes están en
[Sala de juegos del bloque E](JUEGOS_BLOQUE_E.md). El texto siguiente conserva
el antecedente de presentación; ya no describe el estado actual de las mesas.

Actualización del 31/10/2026: se preparó la presentación de billar, ping-pong,
ajedrez y Monopolio en Sistemas E. **Motor/backend debe implementar su
funcionamiento**; el botón de partida sigue deshabilitado. Consultar
[Sala de juegos del bloque E](JUEGOS_BLOQUE_E.md) para IDs, alcance, contrato
propuesto, reglas pendientes y material que el usuario necesita aportar.
La sala fue indicada por el usuario; no hay plano interior confirmado.

Actualización del 30/10/2026: el nombre actual es **SIS-INF** y se añadió
[Exploración FNI](EXPLORACION_FNI.md). El estado espacial se mantiene separado
de la simulación académica. Frontend/arte debe completar interiores con fotos
autorizadas; backend/datos debe verificar aulas, accesos y la relación entre
oficinas o aulas y actividades. El mapa de la sede del centro no se recibió.
La guía enlazada registra la procedencia y los derechos pendientes del plano
y del logo, las decisiones de adaptación y los criterios para cerrar tareas.

Actualizado: 29 de octubre de 2026. Las tareas temporales del contrato original se consumieron e implementaron. Este archivo conserva el punto de coordinación con la sesión del motor. Leer primero `REGLAS_USUARIO.txt` y, para datos institucionales, `docs/PARA_BACKEND_DATOS_Y_FUENTES.txt`.

## Registro de integración de octubre de 2026

Las secciones restantes describen la integración original y sus verificaciones.
Las menciones a una plantilla desplazable, ficha bajo el grafo o exportación con
el nombre anterior son históricas. Para navegación vigente se aplica
`REGLAS_USUARIO.txt` y [Diseño visual](DISENO_VISUAL_CAMPUS.md).

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
| Estudio | Columnas adaptables, respuestas con ajuste de líneas y modelos controlados con botones Disminuir/Aumentar. Repasar no altera notas ni historial. |
| Accesibilidad | Páginas completas mediante botones, sin rueda, deslizadores ni barras. Selectores con búsqueda y páginas. Contenedores acotados, identidad de partida, texto 80–120% con botones y malla con encuadre legible. |
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
