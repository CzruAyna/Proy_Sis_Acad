# Historia demostrativa de una carrera

## Acceso y alcance

Menú principal → **Historia de una carrera**. Escribir nombre o apodo, escoger carrera, mención y enfoque. **Crear historia** genera un recorrido; **Capítulo anterior/siguiente** permite leerlo por periodos. **Desenlace** muestra el resultado completo y permite generar otra historia.

Cada capítulo presenta resultados, circunstancias, trámites, documentos y comprobantes simulados. **Grafo de este capítulo** muestra el estado acumulado de ese momento, sin adelantar aprobaciones futuras. **Qué se exploró** abre los temas orientativos y los modelos didácticos de las materias.

La demostración vive en memoria: no ocupa los tres espacios, no modifica partidas, no concede logros y se pierde al cerrar el juego. No es un pronóstico del rendimiento de la persona ni utiliza el nombre para calcular capacidad. No incluye compras, premios aleatorios ni mecánicas de monetización.

## Motor y variación

`career_story.gd` genera perfiles independientes y llama a la API de `student_simulation.gd`: matrícula, inscripción, parciales, cierre, solicitudes, auxiliatura y graduación. No escribe aprobaciones directamente ni utiliza el desbloqueo de exploración.

- Tres enfoques: constancia mejora la probabilidad base; colaboración favorece postulaciones de auxiliatura; exploración intenta correlativas y muestra una solicitud por carta en el tercer periodo.
- Circunstancias por periodo: grupos de repaso, consultas, entregas e imprevistos modifican la probabilidad.
- Los reintentos reciben una mejora acotada. Las reprobaciones permanecen en el historial y las aprobaciones de correlativas se conservan según el motor.
- Un 18% de las historias comienza en un régimen especialmente favorable, sin garantizar aprobar. Se permiten recorridos de excelencia; el desenlace sigue exigiendo todas las materias, cero reprobaciones y promedio estrictamente mayor que 65.
- En el régimen normal la probabilidad por materia parte de 0,83, suma el enfoque, el suceso y la mejora por reintento. En ambos regímenes se limita a 0,65–0,997. Son parámetros de ficción, no estadísticas universitarias.
- El resultado sorteado se traduce a tres respuestas compatibles con el motor: dos o tres aciertos aprueban, cero o uno reprueban. Se mezclan sus posiciones. No se fabrican notas distintas de las posibles en el juego.
- Las competencias usan los rivales, puestos y designaciones del motor. Una designación continúa con firma del plan, permiso de aula, tres apoyos, informe y cierre.
- La graduación abre y completa un expediente real del motor. Tesis/proyecto incluyen defensa aleatoria y posibles nuevas presentaciones. Solo un expediente completado emite el título.
- Se limita a 60 periodos y cinco presentaciones de defensa. Si se alcanza un límite o una validación falla, se comunica un recorrido incompleto; no se inventa el título.

La semilla y la versión del generador figuran en el desenlace. `generate(nombre, carrera, mencion, enfoque, semilla)` reproduce una historia con la misma versión de código y catálogo. Cambiar únicamente el nombre no cambia sus resultados.

## Grafos

Se conserva la protección geométrica: separación de nodos, distancia entre aristas y ausencia de cruces. El trazado ahora admite orientación variable. El botón **Mover: esfera/rama** alterna un nodo individual o su componente conectado completo; **↻** gira la rama seleccionada 30 grados. Arrastrar el fondo y los botones de flechas desplazan la cámara. **Ver todo** encuadra también ramas trasladadas fuera del lienzo inicial. **Restablecer** recupera la distribución original.

Las posiciones manuales son presentación; no cambian requisitos ni estados académicos. Se restauran conjuntamente y se validan de nuevo. Los movimientos incompatibles se rechazan. La interfaz utiliza botones y páginas, sin rueda ni deslizadores.

## Análisis y próximas mejoras

| Prioridad | Hallazgo en el código | Mejora propuesta |
|---|---|---|
| Alta | Las mallas se identifican como históricas y las gestiones no tienen todavía todos sus originales confirmados. | Versionar planes, cohortes y fuentes verificadas. Material requerido en `PARA_BACKEND_DATOS_Y_FUENTES.txt`. |
| Alta | `game.gd` concentra menú, guardado, presentación y evaluaciones en más de 2.000 líneas. | Seguir extrayendo pantallas a módulos, manteniendo las transacciones en el motor. Esta entrega separa generador y presentación de historias. |
| Alta | Las evaluaciones usan tres preguntas binarias; las notas posibles tienen poca variedad. | Diseñar actividades por disciplina y rúbricas antes de ampliar calificaciones. Requiere acuerdo con el responsable de reglas y revisión docente. |
| Media | El grafo trabaja por semestre curricular; un recorrido puede cursar varios niveles a la vez. | Añadir una vista general de ruta crítica y comparación entre periodos sin ocultar relaciones ni sobrecargar el dibujo. |
| Media | La historia muestra matrícula, carta, correlativas, auxiliatura y titulación; no fuerza todos los trámites opcionales en una misma carrera. | Añadir decisiones narrativas para materia externa, K-02 y K-03, con conservación de estados de cada plan. No confundir demostración con requisito obligatorio. |
| Media | La explicación de aprendizaje proviene de temas orientativos del catálogo. | Reemplazar generalidades por objetivos, ejemplos y ejercicios revisados y trazables. Aprobar en una historia no acredita dominio real. |
| Media | Los parámetros probabilísticos son deliberadamente ficticios. | Ajustarlos mediante pruebas de diversión y duración; permitir comparar historias con las mismas condiciones. No publicarlos como tasas reales. |

Django y Next.js son componentes separados y no se modifican. Este análisis prioriza el producto Godot solicitado; no constituye una auditoría nueva de seguridad o rendimiento de la API.

## Verificación

`game/tests/test_career_story.gd` cubre todas las menciones, distintos enfoques y semillas, las tres modalidades de titulación, reintentos, auxiliares, cartas, correlativas, coherencia temporal del grafo, reproducción e independencia del nombre. También comprueba el acceso al módulo, validación, modelos didácticos y ausencia de escrituras de partidas/logros. Los tests de grafos existentes verifican la separación geométrica con arrastres y tamaños distintos.

Las fuentes pendientes siguen en `PARA_BACKEND_DATOS_Y_FUENTES.txt`: originales de planes y correlatividades, reglamentos de evaluación, formularios e instructivos de oficinas, convocatorias de auxiliatura, modalidades de titulación y programas analíticos. Esta entrega no incorpora nuevos datos institucionales ni imágenes oficiales.
