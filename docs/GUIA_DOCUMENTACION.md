# Guía de documentación del proyecto

Actualizada: 30 de octubre de 2026.

## Para qué se mantiene esta documentación

CAMPUS EN JUEGO comenzó como un sistema académico web y evolucionó hacia una
simulación de escritorio. Conviven Godot, Django y Next.js, con modelos y formas
de persistencia diferentes. La documentación permite identificar qué componente
debe revisarse y evita cambiar el backend para corregir una pantalla o tratar
los datos del juego como información institucional verificada.

El historial de Git muestra versiones y archivos, pero un mensaje de commit
breve no explica por sí solo una decisión. La bitácora relaciona ese registro
con el propósito y el resultado de cada avance. Las guías vigentes explican
cómo trabajar con la versión actual; los documentos de coordinación conservan
lo que todavía falta resolver.

Esto permite revisar cambios técnicamente, reproducir comprobaciones, preservar
decisiones y dar continuidad al trabajo sin depender de conversaciones previas.

## Reglas de trabajo

1. Leer completos `AGENTS.md` y `REGLAS_USUARIO.txt` antes de analizar, editar,
   probar o compilar.
2. Consultar el índice `docs/README.md` y los documentos del área afectada.
3. Para datos o reglas institucionales, leer
   `PARA_BACKEND_DATOS_Y_FUENTES.txt` y registrar el material faltante.
4. Escribir la documentación técnica del repositorio en Markdown. Enlazar los
   documentos nuevos desde el índice o el README principal.
5. Conservar las reglas anteriores al incorporar una instrucción expresa nueva.
   Identificar las decisiones técnicas como tales; no atribuirlas al usuario.
6. Antes de cerrar una modificación, releer completo `REGLAS_USUARIO.txt` y
   revisar el diff contra sus reglas.

La memoria académica en LaTeX se conserva en la carpeta externa solicitada por
el autor. Es una entrega separada y fechada; no reemplaza las guías Markdown
del repositorio ni se debe confundir con el estado actual del producto.

## Dónde documentar cada asunto

| Asunto | Documento |
|---|---|
| Reglas expresas acumuladas del usuario | `../REGLAS_USUARIO.txt` |
| Procedimiento obligatorio para agentes | `../AGENTS.md` |
| Componentes y separación de responsabilidades | `ARQUITECTURA.md` |
| Requisitos, ejecución, compilación y pruebas locales | `DESARROLLO_LOCAL.md` |
| Reglas del recorrido individual | `SIMULACION_ESTUDIANTE.md` |
| Navegación, identidad y comportamiento del grafo | `DISENO_VISUAL_CAMPUS.md` |
| Generador de historia demostrativa | `MODULO_HISTORIA_CARRERA.md` |
| Historial por fecha y commits | `BITACORA_DESARROLLO.md` |
| Material institucional y verificaciones de datos | `PARA_BACKEND_DATOS_Y_FUENTES.txt` |
| Coordinación entre interfaz y motor | `PENDIENTES_FRONTEND_SIMULACION.md` |
| Licencia, alcance y revisiones de terceros | `LICENCIA_CODIGO_LIBRE.md` |

## Qué debe contener una entrada de avance

La entrada debe permitir localizar el cambio y entender su efecto:

- Fecha del registro y commit, cuando exista. Si todavía no hay commit,
  indicarlo sin inventar un identificador.
- Problema u objetivo concreto.
- Cambio realizado y área afectada.
- Decisión y motivo, cuando estén confirmados por el autor o por el contrato
  técnico. Las motivaciones personales no se deducen del código.
- Comprobaciones realizadas, resultado y alcance.
- Pendientes, responsable y evidencia que falta.

La fecha de commit no mide horas de dedicación. Una jornada sin commits no
demuestra ausencia de trabajo. Los cambios de madrugada pueden pertenecer a una
sesión iniciada el día anterior; cualquier agrupación diferente debe explicarse.

## Redacción y evidencia

Usar lenguaje sencillo y técnico, nombres reales de archivos y ejemplos breves.
Explicar primero el comportamiento y después el mecanismo que lo produce.
Evitar repetir el mensaje del commit sin describir el cambio.

En las guías operativas describir el estado actual. En la bitácora se puede
redactar en primera persona para la memoria del autor, conservando trazabilidad
con el historial y las explicaciones recibidas.

No incluir horas, fallos, pruebas superadas, decisiones ni conversaciones que no
estén respaldados. Una comprobación sugerida no es una prueba ejecutada. Si solo
se inspeccionó código, indicarlo.

Los comandos y diagramas deben corresponder a archivos y contratos existentes.
No incorporar credenciales, partidas personales, firmas o documentos
institucionales con datos privados.

## Estado actual e historial

Un diagnóstico fechado conserva el valor de la revisión original aunque una
entrega posterior lo resuelva. Añadir una referencia al documento vigente o una
actualización fechada; no presentar el hallazgo antiguo como un defecto actual.

El roadmap describe planificación. Si contradice el código, registrar la
diferencia y el área que debe revisarla. No marcar una fase como completada por
la existencia de una carpeta, un modelo o un método aislado.

## Registro de pendientes

Cada pendiente debe tener área responsable, evidencia disponible, material
necesario y criterio de cierre:

| Campo | Contenido esperado |
|---|---|
| Área responsable | Documentación, frontend, motor, backend/datos o empaquetado. |
| Evidencia | Archivo, contrato, commit, prueba o documento que motiva la duda. |
| Material faltante | Pregunta concreta, original institucional o registro de ejecución. |
| Estado | Pendiente, verificado, resuelto o sustituido, con fecha. |
| Cierre | Comprobación que permitirá considerarlo resuelto. |

Los datos institucionales se coordinan mediante
`PARA_BACKEND_DATOS_Y_FUENTES.txt`. Las revisiones de licencias y distribución
están registradas en `LICENCIA_CODIGO_LIBRE.md`.

### Pendiente identificado en esta revisión

| Área responsable | Evidencia | Revisión necesaria | Criterio de cierre |
|---|---|---|---|
| Backend y documentación de API | `ROADMAP.md` mantiene como pendientes límites de carga y prerrequisitos; el commit `122d1d3` los incorpora en el servicio de inscripción. | Contrastar los casos cubiertos y actualizar el estado del roadmap sin declarar completa toda la fase. | Planificación y comportamiento del servicio descritos de forma consistente, con las limitaciones restantes identificadas. |

## Cierre de una entrega

La primera línea de la respuesta final debe ser el título breve del summary,
con el formato obligatorio `tipo: descripción breve` o
`tipo(ámbito): descripción breve`. Elegir el prefijo que corresponda al trabajo:
`feat`, `fix`, `build`, `chore`, `ci`, `docs`, `style`, `refactor`, `perf`,
`test`, `revert` u otro pertinente. No concatenar todos los tipos.
Esto se aplica a cada entrega, también si solo cambia documentación o
configuración. Por ejemplo: `docs: precisar el formato de los summaries`.
Después debe explicar:

1. Qué se modificó y para qué.
2. Qué comprobaciones se ejecutaron y qué permiten concluir.
3. Qué quedó sin verificar y qué responsable o material requiere.

El título y el detalle se entregan por el chat. Los archivos del proyecto no
deben contener instrucciones para subir, publicar o empujar cambios a GitHub
o GitHub Desktop.
