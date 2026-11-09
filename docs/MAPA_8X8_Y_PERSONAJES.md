# Matriz 8×8, escala de personajes y referencias externas

Para la matriz vigente y sus medidas aproximadas en metros, consultar
[Cartografía y escala FNI](CARTOGRAFIA_FNI_Y_ESCALA.md). Las dimensiones y
coordenadas descritas debajo corresponden a las versiones del 4 y 6 de noviembre.

Actualización del 06/11/2026: se regeneran las 64 láminas con caminos conectados
y rosa de los vientos. El usuario precisó norte a la derecha, sur a la izquierda,
este abajo y oeste arriba. Esa orientación sustituye la falta de referencia
cardinal del avance del 04/11 descrito debajo; siguen sin equivaler a metros.
Detalles en [Caminos, inicio y ambientes](CAMINOS_MENU_Y_AMBIENTES.md).

Entrega del 4 de noviembre de 2026, incorporada en `c0bd256`. Este avance
actualiza [Campus ampliado](CAMPUS_AMPLIADO_Y_VIDA_DEL_CAMPUS.md) y sustituye
la revisión en cuatro cuadrantes por una matriz de 64 celdas.

## Archivos de referencia fuera del juego

Se retiraron del proyecto los dos JPG de planos, el PNG del logo original y
sus metadatos de importación. También se retiró el conversor que volvía a
copiar el logo original al directorio de recursos. Los archivos del usuario
en Descargas no se borraron. Las referencias históricas, hashes y procedencia
documentados se conservan como trazabilidad, no como archivos empaquetados.

El mapa y los retratos del juego siguen dibujados mediante código propio.
El icono pixel art sintetizado también se conserva. El mapa de orientación
ahora ofrece **Cuadrícula y coordenadas**, sin mostrar originales ni cargar
fotografías externas. Las futuras fotos o planos se consultan fuera del
repositorio y del ejecutable, según la regla 26.

## Matriz para corregir y dimensionar

Las filas **A–H** avanzan de arriba abajo; las columnas **1–8**, de izquierda
a derecha, siguiendo la orientación del esquema. No representan norte/sur
geográfico. El mapa conserva 12288 × 8704 unidades de juego.

- Cada celda abarca **1536 × 1088 unidades**, un octavo del ancho y alto.
- La celda `A1` comienza en X 0, Y 0; `A2`, en X 1536, Y 0; `B1`, en X 0,
  Y 1088. El ingreso del jugador queda en `H5`.
- Cada lámina mide 1600 × 1520 píxeles. El área del mapa empieza en (32, 100)
  y mide 1536 × 1088: dentro de esa área, un píxel representa una unidad.
- Cabecera, leyenda y márgenes quedan fuera de esa relación. Los cortes
  internos de la rejilla equivalen a 384 unidades en X y 272 en Y.
- **Todavía no se puede convertir a metros.** Para hacerlo hace falta una
  escala o distancia real confirmada y contrastar la geometría del esquema.

El exportador `game/tools/export_campus_quadrants.gd` reutiliza el renderizador
vigente y `campus_grid.gd`. Genera en `game/.test-artifacts/mapa-8x8/`:

| Archivo | Contenido |
|---|---|
| `00-indice.png` | Mapa completo con las 64 celdas. |
| `A1.png`…`H8.png` | Una lámina detallada por celda, con códigos de elementos y leyenda. |
| `mapa-completo.png` | Unión de las regiones a 6144 × 4352 píxeles. |
| `referencias.json` | Intervalos X/Y de cada celda, IDs del juego y marcadores. |

Los códigos `B`, `C`, `G`, `P`, `M`, `F`, `V`, `A` e `I` conservan los tipos
de [la guía anterior](MAPA_PARA_CORRECCIONES.md). Un objeto que cruza un corte
figura en ambas celdas con el mismo código y «continúa». Para corregirlo,
indicar celda y código, o coordenadas del juego: forma, tamaño, distancia y
qué elemento falta. Las exportaciones son artefactos locales regenerables.

## Personajes más visibles y avance más rápido

`campus_scale.gd` concentra el contrato visual y de espacio:

| Elemento | Antes | Ahora |
|---|---|---|
| Jugador | 12 × 16 | 24 × 32 unidades. |
| Personas ambientales | 16 × 22 | 24 × 32 unidades. |
| Perros | 12 × 16 | 24 × 28 unidades. |
| Radio de pies del jugador | 7 | 12 unidades. |
| Avance exterior | 112 | 224 unidades/segundo. |
| Avance interior | 112 | 160 unidades/segundo. |
| Carrera | ×1,65 | ×1,8. |

Se amplió la puerta exterior dibujada para mantener su proporción con el
jugador. El desplazamiento conserva sus pasos de colisión para no atravesar
paredes a mayor velocidad. Si una posición guardada con el radio anterior
queda demasiado cerca de una pared, se busca una posición segura a un máximo
de 64 unidades antes de recurrir al ingreso. Las visitas se conservan.

### Notas obligatorias para frontend y motor

- Cambiar tamaño, anclaje de pies, radio, sombra, puertas y distancia de
  interacción conjuntamente. No ampliar solo la textura.
- El círculo del jugador tiene diámetro 24; se aplica a edificios, interiores,
  mesones, agua y bases. Personas ambientales usan radio 12 y perros 10.
- Los NPC evitan geometría, al jugador y a otros NPC durante su paseo. Sus
  sprites son ambientales: todavía no son obstáculos sólidos para el jugador.
- Antes de incorporar choques sólidos o rutas entre pisos, validar huecos de
  puertas, corredores y descansos con esos diámetros, sin bloquear guardados.
- La vista de espalda y el reflejo lateral deben mantener el mismo anclaje.
  Los ensayos de entrada a mesas siguen comprobando E, Enter y botón visible.

## Variedad y paseos ambientales

Hay **14 profesionales, 24 estudiantes distintos, 8 diseños de personal y
visitantes, y 6 perros**, incluida la variante de recuerdo de Piedritas. La
población normal contiene 51 personajes: 46 personas y cinco perros. La
variante rara sigue solo en el catálogo y no se introduce con probabilidad
inventada. El personal incluye docencia, biblioteca, laboratorio, mantenimiento,
jardinería, seguridad, administración y visitas; son personajes ficticios.

`campus_ambient_cast.gd` producía, en el corte del 04/11, paseos locales alrededor de
las zonas de origen. Comprueba trayectos y huellas, alterna poses de paso y
evita penetrar edificios, bases o agua. Se detiene al pausar, entrar en un
interior, desactivar animaciones o activar bajo consumo. La lógica usa semilla
fija para poder comprobarla y no altera el estado académico.

Es un estado visual temporal: al reconstruir el mundo, los paseos comienzan
de nuevo. **Motor/backend** debe resolver recorridos por toda la facultad,
horarios, asistencia a clases, entrada y salida de aulas, continuidad entre
menús, caricias, rareza y logros. Debe publicar IDs de instancia separados
del diseño. La presentación ambiental se sustituirá por esa proyección al
integrarla; no se deben ejecutar dos poblaciones a la vez.

## Referencias consultadas el 04/11/2026

| Fuente | Qué se pudo observar | Límite |
|---|---|---|
| [Google Maps, Ciudad Universitaria FNI en satélite](https://www.google.com/maps/@-17.9894528,-67.1382524,817m/data=!3m1!1e3) | Se pudo abrir la capa satelital, distinguir la sede universitaria de la sede de San Felipe, observar cubiertas metálicas arqueadas, sectores con cubiertas ocres/grises, canchas cubiertas azules y caminos con curvas. | Es observación visual; el copyright 2026 no confirma la fecha de captura. No se obtuvieron planos ni alturas o plantas verificadas. |
| [UTO: Informe de gestión 2025, publicado en 2026](https://www.uto.edu.bo/wp-content/uploads/2026/05/informe-2025-reducido.pdf), pp. 28–29 impresas. | Documenta infraestructura de Ciencias Básicas, acceso vial norte y remodelación de la cancha de Civil. | Es evidencia de intervenciones; no permite extraer por sí sola su geometría actual ni reasignar edificios del esquema. |
| [Ingeniería Química: Aulas](https://quimica.fni.uto.edu.bo/index.php/es/aulas) | Página institucional identificada con acreditación ARCU-SUR 2025 y descripción de aulas. | La imagen enlazada no pudo abrirse mediante la herramienta web; no se usa como fotografía visualmente verificada. |
| [Galería del sitio FNI](https://www.fni.uto.edu.bo/) | Se localizó una referencia a una portada con arco que puede corresponder a la sede histórica. | No se utilizó para dibujar la Ciudad Universitaria ni se verificó la fecha de esa toma. |

Los ajustes gráficos adoptan tonos ocres/grises, mayor lectura de volumen y
bandas en cubiertas arqueadas; Civil incorpora una cubierta azul. Son
interpretaciones de las referencias observadas. Las posiciones generales del
esquema y la distribución provisional de plantas se mantienen hasta recibir
correcciones. No se descargaron ni incorporaron fotos o teselas de Google Maps.

### Material que todavía ayudaría a confirmar el diseño

| Responsable | Material necesario | Criterio de cierre |
|---|---|---|
| Usuario y backend/datos | Fotos propias fechadas de frente y lateral de Sistemas A–E, bloque 100, bloque en cruz, los tres quirquinchos y cubiertas de canchas. | Nombre de edificio, fecha, lado de la toma y correspondencia clara con una celda del esquema. |
| Usuario y backend/datos | Croquis por planta, aulas, escaleras y baños de los bloques altos. | Disposición confirmada sin inferir plantas desde la cubierta satelital. |
| Usuario y frontend | Captura satelital de conjunto con norte, escala y fecha de imagen, si se dispone, y acercamientos de los sectores que se quieran corregir. | Poder orientar y contrastar las formas; sirve como referencia externa y no se añade al juego. |
| Backend/datos | Dos puntos de control con una distancia real fiable o un plano acotado. | Definir una conversión y comprobarla en varios tramos antes de mostrar metros. |

Las comprobaciones ejecutadas de esta entrega y sus límites se registran en
[Verificaciones](VERIFICACIONES.md). Las fuentes históricas y tareas de
monumentos siguen en [Campus ampliado](CAMPUS_AMPLIADO_Y_VIDA_DEL_CAMPUS.md).
