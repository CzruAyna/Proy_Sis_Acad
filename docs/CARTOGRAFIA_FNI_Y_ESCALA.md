# Cartografía y escala FNI

Estado del 8 de noviembre de 2026. La exploración usa el mapa `fni_ciudad_v3`
de Ciudad Universitaria. El trazado se recrea en pixel art a partir de una
selección del [mapa de OpenStreetMap](https://www.openstreetmap.org/#map=17/-17.990505/-67.139089).

La cuadrícula 8×8 se usa en el atlas técnico. La vista del jugador usa
rótulos de sectores, una flecha de orientación y zoom. El perímetro y la
carretera exterior se describen en [Menús, mapa jugable y perímetro](MENUS_MAPA_Y_PERIMETRO.md).

## Datos y cobertura

El [recorte de la API de OpenStreetMap](https://api.openstreetmap.org/api/0.6/map?bbox=-67.1434,-17.9945,-67.1354,-17.9860)
aporta 36 huellas asociadas a edificios del juego, 10 vías de servicio, 149
tramos peatonales, 56 jardines, seis canchas, dos estacionamientos, dos
fuentes y el monumento al Chivato. La selección abarca el área jugable y
cada geometría derivada guarda el identificador de su vía o nodo.

Entre los puntos de control figuran [Sistemas e Informática](https://www.openstreetmap.org/way/548885224),
[Ciclo Básico](https://www.openstreetmap.org/way/587273320),
[la cancha sintética](https://www.openstreetmap.org/way/277946021) y
[el Chivato](https://www.openstreetmap.org/node/4682413170). El ingreso se
ubica en la vía [96620810](https://www.openstreetmap.org/way/96620810). Entre
el ingreso y el Chivato hay unos 292 m cartográficos en línea recta.

La relación entre las huellas y los nombres del juego es provisional
donde OpenStreetMap carece de rótulo. Sistemas C y E, el edificio de Eléctrica
y el quirquincho de Matemáticas todavía usan huellas recreadas. Se conservaron
el bosque, la laguna de Civil, Piedritas y otros hitos del diseño anterior
como referencias aproximadas. La posición de las puertas y el ancho de los
caminos se ajustaron para que se puedan recorrer en el juego. En Metalurgia 2,
el acceso de juego quedó al oeste para evitar el área de colisión del Comedor.

## Escala y ritmo

El rectángulo jugable mide **7.040 × 3.904 unidades**, unos **880 × 488 m**.
La proyección local toma latitud −17,99427 y longitud −67,13950 como origen.
El eje X aumenta hacia el norte y el eje Y hacia el este. Cada celda mide
880 × 488 unidades o unos **110 × 61 m**. Las filas A–H avanzan hacia el
este y las columnas 1–8 hacia el norte. El ingreso se encuentra en H5.

| Parámetro exterior | Valor |
|---|---:|
| Escala cartográfica | 8 unidades/m |
| Sprite humano | 12 × 16 unidades |
| Radio de colisión humano | 6 unidades |
| Sprite canino | 10 × 12 unidades |
| Radio de colisión canino | 4 unidades |
| Velocidad base del jugador | 156,8 unidades/s |
| Velocidad con Shift | 282,24 unidades/s |
| Velocidad de NPC humanos | 58 % de la base |
| Velocidad de perros | 34 % de la base |

La referencia de marcha es 1,4 m/s con un factor de 14 para el tiempo de
desplazamiento del jugador. En el juego equivale a avanzar 19,6 m de mapa por
segundo real a velocidad base. Los interiores conservan sus unidades y su
velocidad local. El reloj académico tiene su propio avance.

| Destino desde el ingreso | Caminata v3 | Mínimo teórico v2 en línea recta |
|---|---:|---:|
| Física | 6,31 s | 8,85 s |
| Sistemas A | 14,67 s | 19,88 s |
| Básicas | 14,03 s | 18,92 s |

`test_exploration` recorrió los tres trayectos con el movimiento y las
colisiones del juego, sin Shift ni pausas. Para v2 se calculó la distancia
directa dividida por la velocidad base anterior. Los recorridos reales de
esa versión podían requerir rodeos. Los tiempos de la tabla se miden en el juego.

## Reproducir y revisar

1. Consultar el recorte indicado y guardar el XML en una ubicación externa al
   proyecto. Para actualizaciones, anotar fecha, límites e IDs que cambiaron.
2. Ejecutar el conversor desde la raíz y revisar el diff del JSON y las
   correspondencias de cada edificio cuya geometría cambie.

   ```powershell
   python game/tools/prepare_campus_osm.py "C:/ruta-externa/fni.osm" game/assets/cartography/fni_osm.json
   ```

3. Correr `test_exploration`, `test_campus_life` y `test_natural_campus`.
   Comprobar las entradas, el paso por los cruces y los tiempos de referencia.
4. Con Godot y su renderizador gráfico, ejecutar
   `--path game --script res://tools/export_campus_quadrants.gd`. El atlas
   queda en `game/.test-artifacts/mapa-8x8-v3/` con un índice, un plano
   completo, 64 láminas y un JSON de referencias. Para señalar una corrección,
   indicar la celda y el código impreso junto al elemento.

El juego empaqueta [el JSON derivado](../game/assets/cartography/fni_osm.json).
Se atribuye a [OpenStreetMap y sus colaboradores](https://www.openstreetmap.org/copyright)
bajo la [ODbL 1.0](https://opendatacommons.org/licenses/odbl/1-0/). El código
propio de proyección y dibujo sigue bajo GPL-3.0-or-later. Las fotos, planos
aportados y el XML original se consultan externamente.

## Coordinación con motor y backend

- Conservar los IDs de edificios y aulas al cambiar su geometría. Versionar
  `map_id` si cambian las coordenadas. La carga actual reubica posiciones
  exteriores de v1 y v2 en v3, ancla las cercanas a una entrada conocida y
  busca suelo transitable si el punto convertido queda dentro de un obstáculo.
- Mantener los pisos, visitas y el estado de la vida del campus ligados al
  guardado. La migración probada de v2 conserva las visitas y el encuentro
  de Piedritas. El encuentro raro mantiene su evaluación una vez por recorrido.
- Pedir un plano o croquis institucional fechado con los bloques Sistemas A–E,
  Eléctrica y el quirquincho de Matemáticas señalados. Confirmar las puertas,
  niveles y conexiones peatonales con fotos de campo autorizadas.
- Medir sobre el terreno los tres trayectos de la tabla. Registrar el ingreso
  y la puerta usados, el camino recorrido y el método. Confirmar los límites
  del bosque, la laguna de Civil y la ubicación de Piedritas. Contrastar los
  resultados con las celdas del atlas antes de actualizar las geometrías.
