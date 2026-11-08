# Menús, mapa jugable y perímetro FNI

Avance local del 8 de noviembre de 2026 sobre `f79e107`. El menú y la
exploración pertenecen a Godot.

## Menús y controles

El inicio mantiene sus cuatro acciones en un panel centrado de ruptura negra,
con separación de 12 unidades y acciones de 194 × 46 unidades. Jugar agrupa
las acciones y el título dentro de un panel compacto. Las menciones se
eligen por pestañas, y Opciones se divide en Pantalla, Accesibilidad y
Rendimiento. Las vistas largas que requieren navegación adicional muestran
el nombre del contenido visible, con acciones anterior y siguiente.

El azul frío se usa para las superficies del inicio y el ámbar para señalar
el puntero. La acción enfocada por teclado tiene marcas claras en las
esquinas. El estado pulsado invierte el relieve del botón. La paleta de
texto claro sobre los rellenos opacos de Jugar tiene un contraste calculado
de al menos 8,08:1. Los botones translúcidos del inicio tienen un respaldo
oscuro bajo la etiqueta para mantenerla legible con la terminal. Se usó
[la guía de contraste cromático de Adobe](https://www.adobe.com/uk/creativecloud/design/discover/color-contrast.html)
para diferenciar el acento cálido de la superficie fría. Los estados de
interacción toman como referencia las guías de Xbox de
[contraste](https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/102),
[navegación](https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/112)
y [foco](https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/113).

## Mapa de exploración

`M` abre el mapa desde la exploración. La flecha amarilla usa la última
dirección exterior del personaje. El mapa tiene cuatro niveles de
ampliación además de la vista general. Se controla con `+` y `−`, con
arrastre o flechas para desplazar la vista ampliada y con `M` o `Esc`
para volver. Vista general recupera el encuadre completo.

Los rótulos de Sistemas e Informática, Mecánica, Metalurgia y los demás
sectores se sitúan sobre sus huellas. Al acercarse se ven más edificios e
hitos según el espacio disponible. Se mantienen la orientación cardinal,
la escala aproximada y los créditos. La matriz 8×8 queda en el atlas técnico
descrito en [Cartografía y escala FNI](CARTOGRAFIA_FNI_Y_ESCALA.md).

## Perímetro y carretera

El límite parte del [contorno de la UTO en OpenStreetMap](https://www.openstreetmap.org/way/721056391)
y la carretera del [tramo de la RN12 junto al ingreso](https://www.openstreetmap.org/way/377934502).
La cartografía identifica el límite como barrera. La distribución entre
malla y mampostería es una interpretación jugable. Se abrió el tramo del
ingreso y se añadieron arco, postes y caseta tomando como referencia la
[fotografía pública del acceso sur](https://de.bolivia.bo/lugar/facultad-nacional-de-ingenieria-sud/).
La fotografía ayuda a reconocer el acceso. La altura y material de los
muros posteriores, los tramos exactos del cerco y otros portones requieren
fotos fechadas o un croquis confirmado por la FNI.

La malla y los muros participan en la colisión del campus. Camiones y
minibuses pixel art recorren los carriles como ambientación y quedan
estáticos con movimiento reducido o bajo consumo. Sus modelos, frecuencia
y colores son de diseño. La circulación real y las paradas siguen
pendientes de verificar. El atlas y el juego usan datos derivados ODbL y
dibujos propios, con las referencias fotográficas fuera del repositorio.

## Verificación

Ver el [registro de comprobaciones](VERIFICACIONES.md) para los tamaños de
ventana, navegación, entradas, colisiones y alcance de la exportación.
