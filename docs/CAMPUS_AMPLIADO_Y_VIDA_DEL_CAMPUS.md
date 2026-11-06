# Campus ampliado: paisaje, memoria y personajes

Actualización de motor del 06/11/2026: los contratos CAMPUS-NPC-01,
CAMPUS-DOG-01/02/03, CAMPUS-FLOOR-01 y CAMPUS-MEMORY-01 tienen implementación
de simulación y pruebas. Piedritas usa 1/100 por recorrido según el usuario.
El detalle vigente, pendientes de arte y fuentes están en
[Vida del campus y rendimiento](VIDA_CAMPUS_Y_RENDIMIENTO.md). La tabla de
contratos inferior se conserva como antecedente del encargo, no como lista
de funciones todavía ausentes. Horarios y plantas reales siguen sin verificar.

Actualización del 04/11/2026: los originales de referencia se retiraron del
proyecto; la matriz actual es 8×8. Los personajes tienen mayor tamaño y huella,
con 51 paseantes ambientales. Las descripciones de muestras estáticas,
seis estudiantes y cuatro perros que aparecen debajo corresponden al avance
del 03/11/2026; el estado vigente y sus límites están en
[Matriz 8×8 y personajes](MAPA_8X8_Y_PERSONAJES.md).

Estado: 3 de noviembre de 2026, cambios de trabajo sin commit propio. Área:
frontend Godot. Este documento complementa [Exploración FNI](EXPLORACION_FNI.md)
y concentra el contrato pendiente para motor/backend y datos institucionales.

Para revisar formas y posiciones, están disponibles las
[láminas por cuadrantes](MAPA_PARA_CORRECCIONES.md), generadas desde el mapa
actual con códigos de edificios, jardines y puntos de interés.

## Lo que se puede ver y usar

El campus pasa de 2304 × 1664 a **12288 × 8704 unidades de juego**, unas 27,9
veces su superficie anterior. Es una decisión de presentación para separar
edificios y aumentar los recorridos; las unidades no representan metros ni
coordenadas geográficas. El ingreso sigue en el borde inferior y las puertas
conservan sus identificadores. El mapa permite señalar destinos, sin teletransporte.

La referencia nueva es `MAPA DETECTADO.jpg`, marcada por el usuario. Los caminos
siguen sus trazos negros; hay siete zonas de pasto, un bosque denso a la derecha
del ingreso, dos estacionamientos, tres fuentes decorativas y la laguna de Civil
con borde e islotes. Los árboles son decorativos; la laguna y las bases de
fuentes y estatuas bloquean el paso. Los asientos de hormigón forman FNI por
encima del Chivato en el esquema. Los tres quirquinchos tienen silueta, cubierta y motivo diferentes.
Física incorpora péndulos y medición; Química, matraces y soluciones; Física
virtual, estaciones informáticas. El mobiliario es ilustrativo, sin inventario
de equipos ni capacidades reales.

Piedritas está junto al ingreso y el Chivato más al norte, en las X del plano.
Acercarse y pulsar **E** abre una ficha central con ruptura negra, retrato pixel
art procedural, texto y páginas explícitas. Al cerrar se conserva la misma
instancia del mundo, su posición y visitas. No se usan rueda, barras ni
deslizadores. El foco de teclado se mantiene dentro de la ficha y vuelve al
personaje al cerrarla. El efecto respeta animaciones desactivadas y bajo consumo.

**Personajes** abre un catálogo visual. También hay muestras estáticas en el
exterior, consultables con E. Son diseños preparados para integrar movimiento;
no son NPC autónomos ni personas reales. Hay 14 variantes profesionales, seis
estudiantes y cuatro perros, con fotogramas de paso. Los personajes humanos
incluyen vista de espalda. Sistemas usa azul e Informática rojo.

La variante de Piedritas se muestra únicamente en el catálogo. No se ha elegido
una probabilidad ni se simula que un encuentro raro ya esté funcionando.
**Acariciar · en preparación** es una acción deshabilitada, sin premio asociado.

## Edificios de varios niveles

| ID conservado | Diseño disponible | Límite actual |
|---|---|---|
| `fis_mat` | Bloque 100: dos niveles; PB con tres aulas y Física virtual; primer piso con tres aulas. Fachada azul/amarillo y escalera con descanso. | La escalera abre un plano por nivel; todavía no desplaza entre pisos. |
| `basicas` | Bloque en cruz: PB y cuatro pisos, cuatro alas ilustrativas, escalera central en U con dos tramos y descanso. | Aulas y dimensiones provisionales; no son una planta institucional. |
| `basicas`, PB/2/4 | Baños separados de mujeres y varones. | PB/2/4 es la interpretación de «cada dos pisos», pendiente de confirmar. |

Los pasillos y aulas transitables existentes se conservan. Las escaleras abren
el directorio de planos; la navegación por esos planos **no cambia un piso del
motor ni concede visitas nuevas**. Se mantiene el identificador `fis_mat` para
no romper partidas. `CU-100` a `CU-106` siguen siendo los nombres heredados del
plano. La asociación visual de `CU-106` con Física virtual es provisional:
backend/datos debe confirmar el código real y su distribución por planta.

El recuadro separado de Aulas Básicas del plano se conserva como adaptación del
esquema. Su conexión exacta con el resto del campus todavía necesita validación.

## Contrato que ya emite frontend

En `campus_world.gd`, las señales siguientes se conectan de forma diferida para
terminar el despacho de entrada antes de abrir una superficie:

| Señal | Argumento | Presentación actual |
|---|---|---|
| `landmark_requested(id)` | `piedritas` o `chivato` | Ficha paginada con arte y fuentes. |
| `actor_requested(id)` | ID del diseño | Página del catálogo que contiene ese diseño. |
| `stairs_requested(id)` | `fis_mat` o `basicas` | Planos de los niveles del edificio. |

El mundo se pausa y libera las teclas al emitir estas intenciones. La ficha
restaura la acción Volver anterior y el foco al cerrarse. Los textos y el arte
están separados del estado académico. No se modificaron motores académicos,
servicios Django, Next.js ni reglas de los minijuegos del bloque E.

### IDs del catálogo

- Profesionales: `minas`, `civil`, `electrica`, `electronica`, `mecanica`,
  `electromecanica`, `mecatronica`, `metalurgia`, `materiales`, `quimica`,
  `geologia`, `industrial`, `sistemas`, `informatica`.
- Estudiantes: `estudiante_0` a `estudiante_5`.
- Perros: `perro_arena`, `perro_negro`, `perro_manchado`, `piedritas_recuerdo`.

Es un catálogo de vestuario, herramientas y color; no afirma la oferta vigente
de carreras. Mecatrónica y Materiales se identifican como diseños ilustrativos.
Cada futuro NPC debe tener un **ID de instancia propio**, separado de su diseño,
para no confundir varios estudiantes o perros que compartan apariencia.

### Trabajo pendiente para motor/backend

| ID | Entrega requerida | Criterio de cierre |
|---|---|---|
| CAMPUS-NPC-01 | Recorridos por caminos, evitación de edificios/agua, horarios, entrada y salida de aulas para profesionales y estudiantes. Proyectar `instance_id`, `design_id`, posición, orientación, estado y aula/piso. | NPC caminando y asistiendo a clases sin atravesar obstáculos ni cambiar el expediente del jugador. |
| CAMPUS-DOG-01 | Paseo, espera y reacción a caricia de perros; resolver una intención futura de caricia por ID de instancia. | E abre una acción disponible solo a distancia válida y reproduce su respuesta visual. |
| CAMPUS-DOG-02 | Definir con el usuario la probabilidad mínima de Piedritas, frecuencia de evaluación, semilla y persistencia del encuentro. | Una aparición rara reproducible y probada, sin regenerarse al abrir/cerrar menús. No fijar una probabilidad inventada como requisito del usuario. |
| CAMPUS-DOG-03 | Diseñar logros, IDs, condiciones, repetición y persistencia separados de las notas académicas. | Premios otorgados por el motor tras validar una interacción real; pruebas de duplicados y recarga. |
| CAMPUS-FLOOR-01 | Estado de planta, puntos de entrada/salida de escaleras, colisiones, descansos y vínculo aula/planta. Propuesta: `building_id`, `floor_id` (`pb`, `p1`…`p4`), `room_id`, posición y destino. | Subir y bajar los dos edificios conservando ubicación válida, guardado y baños por nivel. La propuesta no modifica el formato actual. |
| CAMPUS-MEMORY-01 | Si se desean visitas/logros de monumentos, definir registro y condiciones. | Inspeccionar una ficha no otorga un logro antes de contar con reglas acordadas. |

Los puntos y retratos están en `campus_landscape.gd` y `campus_landmark_art.gd`;
el catálogo, en `campus_cast.gd`; los planos, en `campus_floor_plan.gd`.
La interfaz es `campus_inspection_overlay.gd`. Son módulos de presentación,
reutilizables cuando motor publique el estado de las nuevas entidades.

Se leyeron los contratos de `animation_cue` y `pause_scene_requested` de
[Modo demostrativo](MODO_DEMOSTRATIVO.md). Sus animaciones laterales y personaje
de pausa siguen como trabajo de frontend separado; este avance no los sustituye.

## Fuentes y material que necesita aportar el usuario

| Fuente | Uso y estado | Material pendiente para backend/datos |
|---|---|---|
| Plano original y `MAPA DETECTADO.jpg`, aportados por el usuario el 03/11/2026. | Ubicación aproximada, colores, caminos y elementos señalados. No es un levantamiento topográfico. | Fecha, autor/entidad emisora, versión vigente y permiso o condiciones de reproducción. |
| Foto del Chivato, archivo adjunto `codex-clipboard-ba4f0413-2259-4e8c-8d84-68d66ee07489.png`. | Referencia visual de cabra de piedra sobre rocas. El juego dibuja su interpretación mediante código, sin incluir la fotografía. | Autor de foto y escultura, fecha de instalación y texto original de la placa, si existe. |
| Foto de Piedritas, archivo adjunto `codex-clipboard-9c445205-8d90-415c-871d-e73c3084bb42.png`. | Referencia visual del perro sentado de bronce y su pedestal; no se reproduce a la persona que aparece junto a él. | Foto autorizada de la placa, nombre exacto y fechas de la mascota y del monumento. |
| [FNI-UTO: Nosotros / Misión y Visión](https://www.fni.uto.edu.bo/index.php/nosotros/mision-vision). Consulta 03/11/2026. | La fuente institucional sitúa la creación de la Escuela de Minas el **3 de julio de 1906**. La ficha calcula 120 años en 2026. | Confirmar la redacción histórica final con material institucional. No se atribuye esa fecha a la instalación del Chivato. |
| [Bolivisión: Piedrita, la perrita que marcó el corazón de una universidad](https://redbolivision.tv.bo/noticia/piedrita-la-perrita-que-marco-el-corazon-de-una-universidad), resultado fechado 28/05/2026. | Solo se pudo leer el extracto del buscador; la página completa no abrió. Usa «Piedrita», mientras el usuario dice «Piedritas». | Artículo completo u original institucional que resuelva nombre, biografía y fechas. No se extraen datos de una página que no se pudo consultar. |
| Relato del usuario sobre una organización en su nombre. | Se presenta como relato atribuido, con datos pendientes; no como registro institucional verificado. | Nombre oficial, fecha de creación, responsables, actividad actual y documento/página original que lo respalde. |
| Relato del usuario sobre pisos y baños. | Plantas provisionales dibujadas, con aviso visible. | Croquis/fotos por piso de ambos bloques, códigos de aulas, ubicación de laboratorio, accesos y baños; confirmar PB/2/4. |

«¡Salud!» es una frase de celebración pedida por el usuario; no se presenta como
lema oficial. No se inventan fechas de esculturas ni de fundación de la
organización. La [Guía académica UTO de 2018](https://www.uto.edu.bo/assets/pdf/Guia%20Academica%202018%20Noviembre.pdf)
sirve solo como antecedente histórico para variantes profesionales, sin validar
la oferta actual.

### Procedencia y licencia del material

El código y los dibujos procedurales originales mantienen `GPL-3.0-or-later`.
Las esculturas y la identidad institucional representadas tienen derechos
propios que no se atribuyen al autor del código. No se añadieron paquetes ni
sprites de terceros. Las dos fotos se usan como referencia y no se empaquetan.

El plano marcado se conserva en `game/assets/reference/fni_plan_annotated.jpg`;
SHA-256: `319c09becebccaa4e04fba897788805d5f0ab7ae393d9ff9fdfd9d363e2b8a53`.
Es material aportado por el usuario, con autoría y condiciones de reproducción
pendientes, igual que el plano original. No se relicencia bajo GPL.

## Compatibilidad y coste de dibujo

El mapa nuevo se identifica como `fni_ciudad_v2`. Los guardados espaciales siguen
en versión 1: al cargar `fni_ciudad_v1` se escala la posición exterior de forma
proporcional; si cae en un obstáculo, se usa el ingreso seguro. Se conservan las
visitas y los IDs de aulas; un interior se retoma en su punto seguro. Se mantiene
el directorio personal anterior de partidas. No se migraron ni editaron partidas
personales durante las pruebas.

Los árboles se generan una vez con semilla fija y se consultan mediante celdas
espaciales de 128 unidades. Solo se dibujan árboles, cubiertas y detalles de la
región visible. Los retratos y sprites se generan una vez y se reutilizan. El
agua se actualiza a intervalos cuando está cerca; se detiene con animaciones
desactivadas. Estas medidas evitan crear una textura del tamaño de todo el mapa;
no equivalen a una medición comparada de FPS.

Las comprobaciones de esta entrega se registran en
[Verificaciones](VERIFICACIONES.md). Siguen pendientes el recorrido humano
completo, la fidelidad institucional de las plantas, sesiones prolongadas y
rendimiento en otros equipos.
