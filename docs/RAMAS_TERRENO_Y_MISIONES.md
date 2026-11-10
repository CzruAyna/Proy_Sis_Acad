# Ramas, terreno y misiones

Avance local del 9 de noviembre de 2026 sobre `4cd9fdc`.

## Mapa y malla

La rueda acerca o aleja el mapa y la malla donde apunta el cursor, con
ajuste en los bordes del mapa. Más y menos ofrecen la misma función desde
el teclado y la tecla Inicio recupera el encuadre. Las listas y menús
mantienen sus controles explícitos. Se retiró la botonera de zoom.

| En la malla | Acción |
|---|---|
| Clic derecho o Espacio | Mostrar los sucesores directos y sus requisitos |
| N | Saltar entre ramas principales |
| Inicio | Encuadrar todas las ramas abiertas |
| F | Abrir el plan completo, con sus conexiones |
| Clic izquierdo o Enter | Abrir la ficha seleccionada |
| Flechas | Seleccionar |
| Arrastre o WASD | Desplazar el lienzo |

Por ejemplo, abrir `SIS 1110` incorpora `SIS 2210` al mismo lienzo.
Cambiar de rama o abrir una ficha conserva las relaciones ya abiertas.
El trazado usa columnas y bandas separadas. Cuando una materia tiene
varias correlativas, las referencias con asterisco permiten dibujar todos
los vínculos con separación. Son referencias al mismo ID. La vista de
plan completo da prioridad al trazado. Las etiquetas reaparecen al acercarse.

La ficha muestra una descripción breve y un dibujo animado ilustrativo,
con acciones académicas solo donde corresponde. Sistemas usa azules con
acentos menta. Informática usa rojo con rosa y acentos cálidos. Los estados
del grafo continúan diferenciándose con símbolos y texto.

## Arte y recorrido

Los caminos tienen bordes con relieve, grano y juntas. Los jardines
combinan tonos, matas y flores procedurales. El pasto se mueve cuando están
activas las animaciones. Las manchas de pasto nuevas son decisiones de
ambientación. Las huellas de edificios y las coordenadas de la cartografía
se conservan. El protagonista usa una silueta propia, un ciclo de marcha
de cuatro cuadros y mochila. Los NPC exteriores son más grandes y los estudiantes
tienen detalles de mochila. La colisión sigue anclada a los pies.

Empezar o continuar una partida abre la exploración. La franja de misión
indica el siguiente paso del expediente. La matrícula dirige a la
ventanilla simulada. Después, J abre la acción disponible para iniciar el
semestre, consultar materias, rendir el siguiente parcial o cerrar el
periodo. La confirmación académica la devuelve el motor existente.
El aviso de recompensa prevista es una maqueta. No modifica un saldo.

## Pendientes para motor y backend

| Área | Información o contrato pendiente |
|---|---|
| Rótulos del mapa | Recibir del usuario el nombre que debe corregirse, el nombre correcto y la ubicación. Una captura marcada o una referencia de la matriz 8×8 ayuda a identificar el edificio. Mantener su ID de partida. |
| Misiones | Proveer un identificador estable por objetivo y estado disponible, completado o bloqueado. Los requisitos y resultados pertenecen al motor. Separar los datos de una partida de la ambientación de la visita libre. |
| Recompensas | Acordar si se conceden créditos virtuales, puntos de aprendizaje u otros. Registrar una concesión por partida y por hito con un ID estable para evitar duplicarla al recargar. Frontend muestra el resultado confirmado por el motor. |
| Ramas | Conservar IDs, relación de origen y destino y estados por plan. Acordar si el jugador necesita guardar las ramas abiertas entre ejecuciones. En esta entrega se mantienen durante la sesión. |

Las notas de campo sobre nombres de sectores siguen pendientes. El material
original se consulta externamente según la regla 26.
