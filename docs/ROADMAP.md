# Roadmap y trabajo pendiente

Revisado: 2 de noviembre de 2026. Referencia: `b122e96`.

La planificación inicial era la del sistema académico web. El proyecto pasó a
priorizar SIS-INF en Godot. Esta revisión separa ambos recorridos para no
presentar una función del juego como una implementación de la API.

## Juego de escritorio

| Área | Estado en el código | Siguiente revisión |
|---|---|---|
| Motor del estudiante | Inscripción, resultados, historial, trámites, auxiliatura y titulación. | Revisar los datos y las reglas con fuentes originales. |
| Presentación | Pixel art, navegación explícita, malla interactiva y terminal interior del inicio. | Usabilidad y rendimiento en otros equipos. |
| Historia demostrativa | Generador aislado y reproducible por semilla. | Decisiones narrativas y actividades adicionales, si se solicitan. |
| Exploración | Campus, interiores y vínculos al expediente; posición y visitas guardadas. | Validar distribución e interiores y recibir el plano de la sede del centro. |
| Minijuegos | Cuatro mesas jugables con motores y rivales propios. | Pruebas con jugadores y alcance adicional del ajedrez. |
| Distribución | Preset y procedimiento de exportación de Windows. | Paquete accesible para terceros y validación por plataforma. |

## Sistema académico web

| Fase original | Implementación identificada | Alcance todavía pendiente |
|---|---|---|
| Base | Configuración local de Django y Next.js, usuario y autenticación. | Preparación y validación de un despliegue público. |
| Núcleo académico | Carreras, planes, materias, requisitos, periodos, admin y consultas. | Datos institucionales y versiones revisados. |
| Oferta | Aulas, docentes habilitados, paralelos y sesiones. | Verificación de casos de capacidad y horario con datos de referencia. |
| Inscripción y horarios | Cupos transaccionales, retiro, requisitos y carga de seis/siete materias en el servicio desde `122d1d3`; consulta de elegibilidad y horario. | Prioridades completas, generación automática de horarios y pruebas de casos límite. |
| Notas | Actas, carga, cierre y corrección auditada. | Revisión de permisos y concurrencia con una batería ejecutada de backend. |
| Auxiliaturas y permisos | Carpetas previstas; la simulación de Godot tiene su propio flujo. | Implementación de los módulos de la API. |
| Documentos | Directorio inicial para plantillas institucionales. | Plantillas y generación de documentos del sistema web. |

La antigua tabla marcaba requisitos y carga como pendientes aunque el servicio
ya los incorporaba. Esta corrección documenta su presencia, no certifica todas
sus condiciones. La elección del periodo anterior, las notas cerradas,
la carga y las solicitudes concurrentes necesitan pruebas de backend antes
de considerar cerrada toda la fase.

La memoria LaTeX externa es un informe del desarrollo, no el generador de PDF
institucional pendiente en la API. Fuentes, responsables y criterios de cierre
están en [Estado actual](ESTADO_ACTUAL.md) y [Datos y fuentes](PARA_BACKEND_DATOS_Y_FUENTES.txt).
