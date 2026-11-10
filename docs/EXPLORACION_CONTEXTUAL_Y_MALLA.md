# Exploración contextual y malla

Avance del 9 de noviembre de 2026 sobre `286f86a`.

## Diseño disponible

- El botón translúcido del inicio usa un solo relleno. Se retiró el rectángulo
  independiente bajo su etiqueta. Las páginas académicas muestran cuatro
  accesos comunes y Materias agrupa sus filtros y el Historial en una fila.
- En exploración quedan Mapa y Pausa. El texto de contexto indica qué hace E
  cerca de cada elemento. El catálogo de personajes queda bajo Controles.
- La partida usa una ventanilla simulada al fondo de Administración de
  Sistemas. Se abre con E y conserva los expedientes que valida el motor
  actual. Una consulta fuera de la ventanilla puede mostrar el expediente,
  con las acciones de trámite reservadas a la visita. Desde el resumen se
  anuncia graduación cuando el motor devuelve `studies_complete`. La
  modalidad se consulta y se inicia desde la ventanilla.
- El reloj visual empieza a las 09:00. Avanza cuatro minutos de juego por
  segundo real, o seis minutos reales por día. Se detiene en los menús y
  continúa al volver a la misma sesión. De 05:00 a 07:15 y de 17:30 a 20:00
  cambia gradualmente el tono exterior. Movimiento reducido y bajo consumo
  mantienen la iluminación fija y conservan el texto del reloj.

La interfaz usa orden de foco predecible, estado visible y teclas para
seleccionar antes de activar. Los rótulos y el progreso acompañan al color.
Se tomaron como referencia las guías de Xbox de
[navegación](https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/112)
y [manejo del foco](https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/113).

## Malla y fichas

| Tecla | Acción |
|---|---|
| Flechas y Enter | Elegir una materia y abrir su ficha |
| Q y E | Cambiar de semestre curricular |
| WASD o arrastre del fondo | Desplazar la vista |
| Más y menos | Cambiar el zoom |
| Inicio | Encuadrar los nodos |
| 0 | Volver al nivel inicial o al del periodo |
| B y T | Alternar arrastre de esfera o rama y girar la rama seleccionada |
| R | Restaurar distribución |
| Esc o clic fuera | Recoger la ficha y devolver el foco al grafo o a Materias |

La malla abre ajustada al espacio. Sistemas combina azul con celeste e
Informática combina rojo con rosa. En ambos planes el ámbar señala el
cursado y las materias por recursar, con marcas de avance o texto para
distinguir esos casos. Las aprobadas se dibujan atenuadas en el fondo.
El resumen conserva siglas aprobadas de niveles anteriores.

Al volver a la malla tras un cierre de periodo que consolidó aprobaciones,
las esferas de las materias recién aprobadas se retraen. Los sucesores
habilitados toman su tonalidad de primer plano. Se usan las relaciones que
ya entrega el plan y el resultado consolidado del motor. La animación
preserva los puertos y el radio usados para validar cruces y colisiones.
Los resultados provisionales se muestran como tales en la ficha.

## Pendientes para motor y backend

| Área | Contrato propuesto y evidencia necesaria |
|---|---|
| Oficinas y trámites | Confirmar el punto de atención de Caja, Kardex, Cómputo, Dirección y demás oficinas. Vincular `office_id`, edificio, ambiente, punto de interacción, horario y paso de expediente. El motor valida lugar, apertura, documentos y resultado. Pedir croquis, señalética y horarios vigentes. |
| Reloj | Definir un valor de tiempo de campus persistente por partida y su avance en interiores, menús y pausas. Mantenerlo separado del calendario académico. El reloj visual actual no cambia trámites, rutinas de NPC, fechas ni colisiones. |
| Graduación | Usar la elegibilidad consolidada que ya informa el motor. Si se requiere aviso de una sola vez, emitir y guardar un identificador cuando el estado cambie. Confirmar las modalidades y etapas con las fuentes institucionales. |
| Malla | Proporcionar estado final, parciales y elegibilidad por ID de curso y plan. Para disparar la transición desde otra pantalla o al recargar, registrar el cambio consolidado y su revisión de snapshot. La interfaz conserva el orden y la validez de las relaciones. |

Para comprobar la implementación, consultar
[el registro de verificaciones](VERIFICACIONES.md). Los planos y horarios
originales se consultan fuera del repositorio.
