# SIS-INF: exploración de la FNI

Actualizado: 31 de octubre de 2026. Estado: implementación local, sin commit
creado por esta entrega. El nombre anterior del juego era CAMPUS EN JUEGO.

## Uso actual

En el inicio, **Explorar la facultad** abre una visita libre con nombre o apodo
obligatorio. En una partida, **Explorar FNI** y **Caminar por la FNI** abren el
mismo campus y conservan su relación con el progreso académico.

El mapa jugable adapta el plano `AULAS-FNI.jpg` entregado por el usuario.
Incluye bloques de Sistemas, administración, Decanatura, Matemáticas,
Geología, Química, Física, Minas, Mecánica, Civil, Metalurgia, laboratorios,
comedor, canchas, caminos y áreas abiertas. Todas las entradas del catálogo
son accesibles desde el ingreso. Las puertas iluminadas permiten pasar a un
interior. Los bloques con varios ambientes abren un pasillo transitable:
acercarse a cada puerta y pulsar E permite elegir aula. El umbral del aula
devuelve a su puerta en el pasillo; la salida del corredor lleva al campus.
Los bloques de un solo ambiente conservan la entrada directa. El tablero del
interior abre sus actividades y el directorio del bloque.

Sistemas A incorpora LSIA-1 y LSIA-4; Sistemas B, LSIB-1, LSIB-2 y LSIB-4.
Los nombres aparecen en el sitio de la carrera; su agrupación A/B se infiere
de la nomenclatura y debe validarse, al igual que las plantas y los accesos.
Los laboratorios se distinguen con monitores, teclados, canaletas y un armario;
las aulas mantienen pupitres y las otras salas de prácticas tienen mesones.
La cantidad de puestos dibujados no representa un inventario real.
Las fuentes, contradicciones y material pendiente están en
[Referencias de interiores](REFERENCIAS_INTERIORES_FNI.md).

El inicio ofrece todas sus acciones en un único menú de altura contenida,
sin paginación, con fondo negro y borde irregular de píxeles rotos. Conserva
el cosmos; el emblema del fondo se dibuja con funciones geométricas en pixel
art, con bloques grandes y letras verdes ocasionales en los menús. Se retiró
el recuadro separado de citas. La exploración dispone
de un lienzo ancho y barra propia, sin repetir las pestañas académicas.

La geometría es una adaptación para jugar, sin escala topográfica. Las
entradas se sitúan en el frente inferior de los bloques como decisión de
diseño; no se afirma que sean sus puertas físicas reales. El recuadro de
Aulas Básicas del plano se incorpora como una zona del esquema: su conexión
espacial exacta queda pendiente de confirmación. No se ha añadido la sede del
centro, cuyo plano todavía no se recibió.

### Controles

| Control | Acción |
|---|---|
| WASD o flechas | Caminar; las diagonales mantienen la velocidad. |
| Shift | Correr. |
| E o Enter | Entrar cerca de una puerta, salir desde el umbral interior o consultar el tablero. |
| P o Tab | Pausar y consultar progreso. |
| M | Consultar el mapa y señalar un destino. |
| Escape | Volver desde la vista actual. En el mundo, regresar al campus académico o al inicio de la visita libre. |
| Botones visibles | Abrir progreso, mapa, ayuda o interacción sin recordar sus atajos. |

La cámara sigue al personaje. No se usa rueda, barras ni deslizadores. Las
paredes, los edificios y las mesas impiden atravesarlos; los árboles exteriores
son decoración y no bloquean accesos. Se liberan las teclas al perder el foco.
Cambiar de menú retira el mundo activo y detiene el movimiento.

## Progreso y actividades

**Pausa y progreso** presenta visitas, periodo, aprobaciones y promedio. Desde
una partida permite abrir Materias, Malla, Historial, Trámites, Auxiliatura y
Graduación. El acceso **Explorar FNI** permite volver al personaje desde esas
pantallas. Las actividades académicas mantienen las validaciones del motor;
una visita no aprueba materias ni completa trámites.

En aulas y laboratorios, el tablero abre estudiar/repasar. En los edificios
administrativos abre Trámites. Son enlaces generales a las funciones existentes:
todavía no hay una asignación institucional verificada entre materia, paralelo,
horario y aula, ni entre cada oficina real y un paso del expediente.

El mapa muestra edificios visitados en verde, la posición exterior en dorado y
el destino señalado con borde azul. El directorio enumera bloques y aulas.
Señalar un destino no teletransporta al personaje. **Ver plano aportado** muestra
la referencia original, preservando la distinción con el esquema jugable.

## Guardado y cambio de nombre

En una partida se añade `campus_exploration` al perfil, separado de `simulation`:

```json
{
  "version": 1,
  "map_id": "fni_ciudad_v1",
  "position": [1280, 1536],
  "room_id": "",
  "room_name": "",
  "visited": []
}
```

Se actualiza en memoria al caminar y se guarda mediante el almacén existente
al consultar progreso, actividades, salir o guardar el perfil. Se conservan
posición exterior, aula y visitas. Al recargar un aula se usa un punto seguro
interior. Coordenadas inválidas, identificadores desconocidos y visitas ajenas
al catálogo se descartan. Una partida antigua sin este campo empieza en el
ingreso. La visita libre se conserva solo durante la sesión y no concede logros.
Cerrar la ventana también ejecuta el guardado del perfil; si falla, la partida
permanece abierta y se muestra el error.

El formato espacial sigue en versión 1. Un `room_id` válido con `room_name`
vacío identifica ahora el pasillo de un bloque con varias aulas. Se recupera
en su entrada segura. Las antiguas salas genéricas `sis_a/SIS A` y
`sis_b/SIS B` se retoman en ese pasillo y conservan sus visitas históricas.

El título de ventana, portada, icono y exportación ahora usan SIS-INF. En
Windows se conserva explícitamente la ruta anterior de datos de Godot,
`Godot/app_userdata/CAMPUS EN JUEGO`, dentro de AppData. El nombre visible no
obliga a mover, borrar ni sobrescribir partidas. No se ha comprobado esta ruta
en otros sistemas operativos.

## Componentes

| Archivo | Responsabilidad |
|---|---|
| `game/scripts/campus_map.gd` | Bloques, aulas, caminos, coordenadas y mobiliario de colisión. Datos de presentación, no catálogo académico. |
| `game/scripts/campus_world.gd` | Movimiento, colisiones, cámara, entradas, visitas y dibujo pixel art del mundo/personaje/interiores. |
| `game/scripts/campus_exploration_ui.gd` | Visita libre, menús, enlaces con la partida y conservación del estado espacial. |
| `game/scripts/campus_overview.gd` | Esquema general del campus y marcas de posición, visitas y destino. |
| `game/scripts/game.gd` | Entradas del menú, logo, integración con guardado y navegación existente. |
| `game/tools/prepare_brand_assets.gd` | Conversión reproducible del JPEG aportado a PNG, sin redibujar el logo. |

Los dibujos de terreno, árboles, edificios, mobiliario y personaje son código
original del proyecto, con píxeles y escala entera. No se incorporaron paquetes
gráficos externos ni se modificaron Django, Next.js o las reglas académicas.

## Recordatorios de ambientación

Los interiores actuales distinguen aula, laboratorio informático, sala de
prácticas y espacio administrativo, pero son recreaciones. Estos recordatorios corresponden a frontend y
arte; no implican que se recibieron fotografías o se verificó el mobiliario.

| Espacio | Decoración prevista | Material para completar |
|---|---|---|
| Aulas de Sistemas y ciencias | Pizarrón, pupitres, mesa docente, ventanas, luminarias, señal de aula y material de la materia. | Fotografías autorizadas por aula, orientación y ubicación de puerta/pizarra. |
| Laboratorios de informática | Estaciones, monitores, cables, proyector, armario y motivos de la mención. | Inventario y fotos. Confirmar qué ambientes del plano son laboratorios informáticos. |
| Química, Física y otros laboratorios | Mesones y equipamiento propio de cada disciplina. | Fotos, distribución y señalética real; no representar el equipamiento genérico de computadoras como dato real. |
| Administración / Decanatura | Mostrador, escritorios, archivo y señalización comprensible. | Ubicación confirmada de Caja, Kardex, DTIC, dirección y demás oficinas de los trámites. |
| Biblioteca / comedor / posta | Estanterías, mesas de lectura, atención y mobiliario específico. | Referencias para distinguir usos; evitar atribuir funciones vigentes a aulas solo por el rótulo del plano. |
| Exterior | Árboles, bancos, jardines, luminarias, accesibilidad, fuentes y señales en cruces. | Fotos y recorrido confirmado. Los árboles actuales son decorativos. |
| Canchas y espacios comunes | Líneas, redes, gradas, cercos y accesos. | Referencias de cada cancha y de sus entradas transitables. |
| Personaje y vida del campus | Variantes de ropa/mochila, animaciones por dirección y personajes ambientales. | Diseño original y pruebas de lectura. Evitar personas reales identificables sin autorización. |

Los recordatorios se mantienen aquí para poder actualizarlos o cerrarlos al
aplicarlos, sin dejar comentarios temporales dispersos en el código.

## Fuentes aportadas y licencia

El usuario pidió usar estos dos archivos el 30/10/2026. Ese encargo respalda su
uso en la implementación local; no demuestra autoría institucional, vigencia ni
licencia de redistribución pública. Se conservan los derechos de terceros y no
se atribuye GPL al emblema o al plano. El código y los dibujos originales
mantienen `GPL-3.0-or-later`.

| ID | Original / recurso local | Preparación y estado |
|---|---|---|
| FNI-PLANO-01 | `AULAS-FNI.jpg` → `game/assets/reference/fni_plan.jpg` | Copia sin cambios. Entidad emisora, fecha, vigencia y condiciones de reproducción pendientes. |
| SIS-INF-LOGO-01 | `images (3).jfif` → `game/assets/branding/sis_inf_logo.png` | JPEG decodificado y guardado como PNG de 554×554, sin redibujar ni cambiar dimensiones. Autor y condiciones de reproducción pendientes. |

SHA-256:

```text
AULAS-FNI.jpg
C01E70FE9E04DE81C0F1DD89721D549811B39ACB6081E170FFED9CD35C70DE34
images (3).jfif
8A6FE52A5709CBED398D2BAF6C9A7F62948240F337249D1A5FCE0B7802725EE9
sis_inf_logo.png
7235ABF2211EFCE694626D4B8BF068126EA24049BA967481C8286B0B8296612C
```

## Pendientes y responsables

| Área | Evidencia / pendiente | Material y criterio de cierre |
|---|---|---|
| Usuario y backend/datos | Plano aportado sin fecha ni versión confirmadas. | Original fechado, entidad emisora y revisión de rótulos, ubicación y accesos. Cerrar con un mapa validado y versionado. |
| Usuario y documentación/licencias | Logo y plano de terceros. | Autor, fuente y permiso/licencia de reproducción. Confirmarlos antes de redistribuir públicamente esos recursos. |
| Frontend y arte | Interiores genéricos y ubicación adaptada del bloque de Básicas. | Fotos autorizadas, plano de plantas y accesos. Cerrar con comparación contra referencias recibidas. |
| Backend/datos | No existe asignación verificada aula–materia–paralelo–horario en el juego local. | Oferta académica y contrato de datos. Conectar actividades contextualizadas sin cambiar notas por navegar. |
| Usuario | Sede del centro todavía no aportada. | Plano de esa sede y relación entre accesos; añadir otro mapa con ID propio. |
| Frontend / empaquetado | Usabilidad y otros equipos. | Sesión de juego y pruebas en otras GPU, resoluciones, distribuciones de teclado y sistemas. |

## Verificación reproducible

Desde la raíz, con Godot 4.7.2:

```powershell
godot --headless --path game --script res://tests/test_exploration.gd
godot --headless --path game --script res://tests/test_exploration_navigation.gd
godot --headless --path game --script res://tests/test_building_interiors.gd
```

La primera prueba verifica movimiento, paredes, acceso desde el ingreso a
todas las puertas mediante recorrido de una rejilla, interiores, visitas sin
duplicados, recarga, saneamiento de datos y conservación del estado académico.
La segunda comprueba acceso al módulo, nombre obligatorio, menús paginados,
ausencia de rueda/deslizadores, superficies pequeñas, texto al 120% y retorno
a la partida. Los perfiles son ficticios.

`game/tests/capture_exploration.gd` genera vistas reales del inicio, campus,
bloques de Sistemas, aula, mapa y progreso en
`game/.test-artifacts/exploration/`. Requiere renderizador gráfico. Los
resultados ejecutados de esta entrega se registran en la bitácora; estos
comandos no constituyen por sí solos evidencia de ejecución.

### Revisión del 31/10/2026

Se ejecutaron **4.497 comprobaciones sin fallos**: 518 de exploración,
470 de edificios/menú único, 900 de navegación de exploración, 2.335 de
navegación compacta, 59 de composición/ambientes, 194 del frontend académico
y 21 de integración. Los registros locales son
`game/.test-artifacts/building-test_*.log`.

La prueba de edificios recorre la superficie de colisión desde el pasillo
hasta cada puerta, comprueba entrada y retorno a esa puerta, paredes, armario,
recarga del corredor y conservación de visitas antiguas. El menú se verifica
en 900×640, 1152×720 y 1600×900 con texto al 80%, 100% y 120%, una partida
reciente y nombre largo: un contenedor, sin páginas y acciones visibles.

`capture_building_details.gd` generó ocho capturas reales, inspeccionadas en
`game/.test-artifacts/building-details/`: menú, versión compacta, exterior,
pasillos A/B, laboratorio LSIA-1 y bloque con varias aulas. El renderizador
utilizó ANGLE. Se exportó `game/build/SIS-INF.exe` con su `.pck` y el arranque
aislado headless terminó con salida 0, sin errores de scripts.

Quedan sin verificar las plantas reales, accesos, usos actuales de cada sala,
fotografías autorizadas y pruebas con jugadores u otras configuraciones
gráficas; los responsables y criterios están en la guía de referencias.
