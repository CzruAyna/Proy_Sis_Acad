# Modo demostrativo automático

Actualizado: 3 de noviembre de 2026. Implementación local sin commit nuevo.

## Estado actual

El inicio incluye **Demostración automática**, separado de **Historia de una
carrera** y del recorrido interactivo. Al entrar se escribe el comando virtual
`sis-inf demo --loop` y comienza una presentación que vuelve al inicio al
terminar. No abre una consola del sistema ni ejecuta órdenes externas.

El resumen recorre ambas carreras, las cinco menciones, ejemplos de aplicación,
inscripción, resultados, trámites, auxiliatura y titulación. El botón
**Resumen / completo** activa el recorrido por semestres, cada materia,
descripciones, temas y requisitos del catálogo existente. Son 32 tarjetas de
resumen y 738 tarjetas completas en esta versión; los textos se dividen en
fragmentos de hasta 190 caracteres para conservar la lectura sin desplazamiento.

Los controles permiten pausar, continuar, retroceder, avanzar, cambiar velocidad
entre 1x/2x y reiniciar. El cierre de ventana sigue siendo el del juego. Salir
de la presentación destruye su vista y reloj; no quedan ciclos ejecutándose.
Cambiar de ventana pausa la presentación. Volver a ella requiere Continuar.
Movimiento reducido y bajo consumo muestran texto por bloques en vez de animar
cada letra; el avance automático se conserva.

La terminal y un panel lateral explicativo ya funcionan. **Las animaciones
ilustradas laterales quedan pendientes de frontend**; los esquemas actuales
permiten leer el ejemplo mientras se prepara ese trabajo. La demostración no
modifica perfil académico, notas, matrícula, logros ni partidas recreativas.
No necesita nombre porque presenta información general, no crea un recorrido.

## Separación técnica

| Archivo | Responsabilidad |
|---|---|
| `game/scripts/career_presentation.gd` | Guion desde `catalog.gd`, secuencia, escritura, pausa, velocidad y repetición. Sin nodos, archivos ni acceso al expediente. |
| `game/scripts/career_presentation_view.gd` | Terminal, controles y adaptación del capítulo a la columna lateral. |
| `game/scripts/game.gd` | Acceso desde inicio y retorno al modo interactivo. |
| `game/tests/test_career_presentation.gd` | Cobertura del catálogo, dos vueltas completas, límites, controles, disposición y aislamiento del perfil. |

El guion se prepara una vez al abrir. Los capítulos se consultan por índice y
la vista conserva sólo el texto del capítulo actual. La repetición no concatena
historiales, crea nodos ni agrega capítulos; no aumenta la memoria por vuelta.
El reloj acota delta a 0,25 s para evitar saltos largos tras una suspensión.

## Contrato para frontend: animaciones laterales

La vista emite `animation_cue(cue: Dictionary)` cuando cambia el capítulo.
Sus claves son:

| Campo | Uso |
|---|---|
| `id` | Identificador estable de capítulo y fragmento. Reiniciar o repetir vuelve a emitirlo. |
| `program_id`, `mention_id` | Contexto del catálogo; pueden estar vacíos en introducción y cierre. |
| `scene` | Tipo de ilustración de la tabla siguiente. |
| `title`, `text`, `command` | Contenido visible; el comando es exclusivamente una representación. |
| `subject`, `semester`, `topics`, `prereq` | Contexto opcional de una materia en recorrido completo. |

Usar `view.model.progress()` (0–1), `phase` (`COMMAND`, `EXPLANATION`, `HOLD`),
`paused`, `speed` y `view.reduced_motion` para sincronizar. Al recibir la señal,
cancelar la animación anterior y reutilizar una escena de la columna
`DemoAnimationStage`. No abrir ventanas, overlays sobre la terminal ni añadir
historiales crecientes. Una conexión nueva puede inicializarse con
`view.model.current()`; la primera señal ocurre durante `build()`.

| `scene` | Animación que debe preparar frontend |
|---|---|
| `overview` | Problema, análisis y solución; distinguir Sistemas azul e Informática rojo. |
| `systems_flow` | Flujo de una organización con cola y cuello de botella; comparar una mejora. |
| `information` | Datos que se limpian y organizan antes de alimentar una decisión. |
| `optimization` | Recursos limitados que se asignan entre alternativas; mostrar restricciones. |
| `software` | Requisitos, componentes, código y prueba que valida una solución. |
| `network` | Mensaje entre equipos, router y servicio; diagnóstico de una interrupción. |
| `curriculum` | Nodos de materias y enlaces de requisitos, resaltando `subject` cuando exista. |
| `procedure` | Documentos y pasos de oficina; mantener visible que el proceso es simulado. |
| `graduation` | Materias, evaluación de modalidad y etapas de titulación sin prometer elegibilidad real. |

Respetar pixel art, tarjetas opacas, ausencia de rueda/deslizadores y texto
80/100/120 %. No fabricar sellos, firmas, formularios o distribuciones reales.
Con movimiento reducido usar un diagrama estático; con pausa detener también
la animación. Limitar partículas/nodos y liberar tweens al salir. El comentario
`FRONTEND TEMPORAL` de la vista se elimina cuando se integre y compruebe esta
parte, conservando aquí el contrato vigente.

## Personaje al pausar: contrato preparado, arte pendiente

Ampliación del 03/11/2026: el motor prepara un personaje aleatorio en cada
pausa nueva. `model.set_paused(true)` elige uno de los seis arquetipos, detiene
el reloj y emite `pause_changed`. La vista reenvía el evento como
`pause_scene_requested(cue)`. **No se dibujó todavía el personaje ni la rotura
de aparición**: el usuario pidió dejar este diseño a frontend. Se conserva el
botón Pausa/Continuar que ya funciona.

Una segunda notificación de foco perdido no cambia de personaje ni incrementa
su secuencia. La siguiente pausa elige otro arquetipo; no repite el anterior.
No se usan el nombre, notas ni perfil del estudiante para esta elección. Para
una conexión tardía se puede consultar `model.pause_cue()`.

```json
{
  "version": 1,
  "paused": true,
  "sequence": 1,
  "actor": {
    "id": "systems_engineer",
    "name": "Ingeniería de Sistemas",
    "theme": "sistemas",
    "prop": "diagrama de procesos"
  },
  "facing": "viewer",
  "action": "idle_wait",
  "opening": "screen_fracture"
}
```

| ID estable | Referencia para el diseño original |
|---|---|
| `systems_engineer` | Ingeniería de Sistemas; diagrama de procesos, acento azul. |
| `informatics_engineer` | Ingeniería Informática; terminal y código, acento rojo. |
| `arch_linux` | Entusiasta de Arch Linux con portátil; personaje propio, sin suponer que un logo ajeno tenga permiso de uso. |
| `cybersecurity` | Especialista en seguridad defensiva con escudo geométrico y registros. |
| `network_engineer` | Especialista en redes con equipos y conexiones. |
| `data_analyst` | Analista con gráficos y libreta. |

Frontend debe preparar una abertura negra irregular que rompa una parte del
panel, reutilizando el lenguaje geométrico del inicio. Desde ella aparece el
personaje pixel art, de frente, mirando al espectador, y queda esperando.
Puede respirar o parpadear lentamente si las animaciones están habilitadas.
Su zona de dibujo debe reservar espacio sin tapar la explicación, la identidad,
Pausa/Continuar, navegación o salida. La aparición no debe capturar las teclas
ni bloquear el botón para continuar.

Al recibir `paused: false`, retirar personaje y abertura, cancelar los tweens
de espera y reanudar desde el mismo punto de la explicación. Con movimiento
reducido o bajo consumo, usar aparición estática y silueta quieta; no ejecutar
partículas ni bucles de tweens invisibles. Al salir o reiniciar, liberar la
escena. Cambiar de capítulo durante una pausa no debe crear otro personaje.
No añadir un tiempo de espera que reanude automáticamente: continúa el usuario.

El comentario temporal de `_pause_scene()` se elimina al integrar el arte.
La prueba de cierre debe cubrir las seis identidades con recursos originales,
pausas repetidas, pérdida de foco, reanudación, salida y texto 80/100/120 %.
El alcance no incluye voz ni retratos generados ni insignias oficiales.

## Contenido y verificación institucional

Se reutilizan `Catalog.PROGRAMS`, menciones y `Catalog.semesters_for()`, cuyo
plan de referencia procede de 2011; no se incorporó una fuente institucional
nueva. Las descripciones son explicaciones didácticas del catálogo, algunas
genéricas, y no programas analíticos confirmados. Las reglas académicas
mencionadas son las reglas de la simulación acordadas con el usuario.

Backend/datos debe verificar los planes por cohorte, programas analíticos,
requisitos, trámites, auxiliatura y titulación con originales vigentes. El
material solicitado sigue en [Datos y fuentes](PARA_BACKEND_DATOS_Y_FUENTES.txt).
El aviso de orientación y vigencia pendiente permanece visible en la pantalla.

## Comprobación y pendientes

La prueba `test_career_presentation.gd` recorre el guion en tiempo simulado y
verifica su repetición sin crecimiento; no equivale a dejar abierta la ventana
durante horas. `capture_exploration_presentation.gd` genera capturas reales a
900×640 y 120 %. Los resultados ejecutados se registran en la bitácora.

| Responsable | Pendiente | Cierre |
|---|---|---|
| Frontend/arte | Sustituir los esquemas por las nueve familias de animación. | Señales y reloj sincronizados, pausa/reducción de movimiento y capturas en tamaños admitidos. |
| Backend/datos | Contrastar contenidos con documentos originales vigentes. | Fuentes, páginas, cohorte y permisos registrados; catálogo revisado sin alterar partidas silenciosamente. |
| Autor/QA | Evaluar duración, ritmo y claridad en una exhibición prolongada. | Recorrido supervisado en el equipo de presentación. |
