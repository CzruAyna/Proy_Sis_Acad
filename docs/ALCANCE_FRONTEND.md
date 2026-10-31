# Tareas de frontend del juego

Actualizado: 30 de octubre de 2026.

El frontend de SIS-INF comprende lo que el jugador ve, entiende y
controla en Godot. Las reglas permanentes están en
[`REGLAS_USUARIO.txt`](../REGLAS_USUARIO.txt) y la presentación vigente en
[Diseño visual](DISENO_VISUAL_CAMPUS.md).

## Trabajo que puede asumir frontend

| Área | Tareas y ejemplos de pedidos |
|---|---|
| Diseño visual | Estilo pixel art, paletas, marcos, tipografía, iconos, estados de botones y fondos por mención. «Distingue mejor las acciones principales de las secundarias». |
| Organización de pantallas | Jerarquía, proporciones, agrupación de acciones y adaptación a diferentes tamaños de ventana. «Simplifica Trámites y separa lo urgente de lo opcional». |
| Navegación y comprensión | Recorridos, pasos, pestañas, páginas, indicaciones, mensajes y ayuda contextual. «Que se entienda cómo matricularse sin conocer los comandos». |
| Interacción | Ratón, teclado, foco, selección, arrastre, zoom por botones, formularios y confirmaciones. «Permite completar este recorrido solo con teclado». |
| Grafos y demostraciones | Representar materias, requisitos y estados recibidos del motor; diseñar herramientas para explorar y estudiar. «Distingue una pendiente de una bloqueada con algo más que color». |
| Accesibilidad | Legibilidad, contraste, tamaño de texto, movimiento reducido y controles accesibles sin rueda ni deslizadores. «Revisa todas las vistas con letras al 120%». |
| Integración con el motor | Conectar botones a operaciones existentes; mostrar resultados, errores y estados de guardado. «Explica en pantalla por qué fue rechazada la inscripción». |
| Calidad y rendimiento gráfico | Revisar recortes, superposiciones, rutas completas, animaciones, consumo y capturas; probar y exportar la versión de escritorio. «Revisa el juego en una ventana de 900×640». |
| Recursos audiovisuales | Preparar e integrar sprites, animaciones y sonidos de interacción cuando se soliciten, registrando autoría/licencia. «Añade una animación breve al aprobar una materia». |

## Trabajo compartido con otras áreas

Frontend puede detectar que falta información, proponer el contrato para
mostrarla y conectar la interfaz cuando esté disponible. No determina por sí
solo los requisitos académicos, las calificaciones, los pagos, la elegibilidad
ni la vigencia de documentos institucionales.

El responsable del motor/backend valida esas reglas y suministra datos y estados.
El usuario y el responsable de datos aportan o verifican los originales. Los
pendientes se coordinan en [Integración gráfica](PENDIENTES_FRONTEND_SIMULACION.md)
y [Datos y fuentes](PARA_BACKEND_DATOS_Y_FUENTES.txt).

## Cómo formular un encargo

Indicar la pantalla o recorrido, el problema observado y el resultado esperado.
Una captura ayuda a identificar el detalle, pero no es indispensable. Ejemplo:
«En Materias, quiero identificar qué puedo cursar ahora y qué requisito me
falta, sin abrir cada ficha». Frontend puede revisar el recorrido y proponer
la presentación usando los datos existentes.

Esta lista describe responsabilidades y posibilidades; no declara esas tareas
como funcionalidades ya implementadas. Las pruebas automáticas y capturas
tampoco sustituyen la evaluación de usabilidad con jugadores.
