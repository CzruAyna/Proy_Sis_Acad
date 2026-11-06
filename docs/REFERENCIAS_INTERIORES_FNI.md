# Referencias para los edificios e interiores de la FNI

Actualización del 06/11/2026: se observaron dos fotografías de RTvU–UTO sobre
mobiliario del ciclo básico (publicación del 22/05/2026). Se incorporaron
proporciones variadas y detalles recreados, sin atribuir a una foto un ID de aula
no identificado. Fuentes, límites y croquis pendientes en
[Caminos, inicio y ambientes](CAMINOS_MENU_Y_AMBIENTES.md).

Estado del 04/11/2026: las referencias se consultan externamente y las copias
de los originales fueron retiradas del proyecto. La revisión satelital, límites
de actualidad y fotos de fachadas pendientes están en
[Matriz 8×8 y personajes](MAPA_8X8_Y_PERSONAJES.md). Las rutas locales antiguas
del inventario siguiente documentan su incorporación histórica.

Consulta: 31 de octubre de 2026. Área: frontend y datos de ambientación.

Ampliación del 03/11/2026: el plano marcado, las fotos de Piedritas y el
Chivato, la fecha institucional y las plantas provisionales se registran en
[Campus ampliado y vida del campus](CAMPUS_AMPLIADO_Y_VIDA_DEL_CAMPUS.md).
La ampliación no convierte las plantas recreadas en planos verificados.

## Evidencia utilizada

| ID | Fuente | Qué permite representar | Límites |
|---|---|---|---|
| FNI-PLANO-01 | `game/assets/reference/fni_plan.jpg`, copia del `AULAS-FNI.jpg` aportado por el usuario. | Bloques Sistemas A–E y administración, agrupación de edificios y rótulos de aulas de otras áreas. | No muestra plantas interiores, mobiliario ni puertas exactas. Fecha, entidad emisora y reproducción siguen pendientes. |
| FNI-COMPUTACION-01 | [Computación, sitio de Sistemas e Informática](https://www.sisinf.fni.uto.edu.bo/computacion/). | Publica los nombres LSIA-1, LSIA-4, LSIB-1, LSIB-2 y LSIB-4. Describe puestos informáticos con monitores, asientos y conexión de red. | La introducción habla de cuatro instalaciones y el listado nombra cinco; no se adopta ese total como inventario vigente. No demuestra la planta ni la posición de cada sala. |
| FNI-REDES-01 | [Redes Informáticas, sitio de la carrera](https://www.sisinf.fni.uto.edu.bo/redes-informaticas/). | Sirve como referencia temática para equipos y prácticas de conectividad. | No se asigna ese laboratorio a un aula concreta del mapa. Algunas descripciones mezclan tipos de dispositivos y requieren revisión antes de usarlas como contenido didáctico. |
| FNI-DATACENTER-01 | [Data Center, sitio de la carrera](https://www.sisinf.fni.uto.edu.bo/data-center/). | Describe armarios de red, servidores, canalizaciones y acondicionamiento. Inspira detalles originales de equipamiento. | No prueba su ubicación dentro de A o B ni acceso libre del alumnado. No se representan niveles de certificación, inventario vigente o temperaturas como datos confirmados. |
| FNI-MAPS-01 | [Galería de Ciudad Universitaria en Google Maps](https://www.google.com/maps/place/?q=place_id:ChIJD-l6vvmw4pMR6quM_wi-_DY), revisada visualmente el 31/10/2026. | Paseo adoquinado con árboles altos y copas diferentes; construcciones bajas con columnas y ladrillo; cancha con cubierta curva, estructura metálica, aro y graderías. | Galería con fotografías antiguas, algunas fechadas en 2017 y 2018. No confirma inventario, acceso ni distribución actual. No es un levantamiento topográfico. |
| FNI-E-USUARIO-01 | Indicación expresa del usuario del 31/10/2026: sala de juegos en el bloque E. | Identificar E como destino recreativo y preparar billar, ping-pong, ajedrez y Monopolio. | Mesas e interior recreados; falta croquis, fotos autorizadas y confirmación del inventario actual. |

En la primera revisión, las imágenes de las páginas institucionales no se
pudieron visualizar. En este avance se abrió la ficha de Ciudad Universitaria
en Google Maps, distinguida de la sede de calle San Felipe, y se inspeccionó
su galería exterior. Se observaron la foto del paseo de octubre de 2018 y
la cancha cubierta, además de fachadas visibles en las miniaturas. No se
afirma haber inspeccionado interiores de aulas ni imágenes satelitales.
La sesión muestra una vista limitada de Maps. No se descargaron ni incorporaron
fotografías, mapas o teselas de Google al juego; los dibujos nuevos son propios.

## Aplicación al juego

Los nombres LSIA y LSIB se agrupan en Sistemas A y B por su nomenclatura y el
encargo del usuario. Esa correspondencia necesita confirmación institucional.
Los pasillos, posición de puertas, dimensiones, orden de salas y mobiliario
son una **recreación jugable**, no un levantamiento arquitectónico.

El exterior incorpora siluetas escalonadas distintas para Sistemas A,
Geología, Decanatura, Básicas, Minas, Civil y otros bloques según el plano.
El dibujo, la colisión y el mapa de orientación usan el mismo contorno.
Los detalles de cubiertas, equipos, ventanas y entrada diferencian bloques;
las especies concretas de árboles no se identifican como verificadas. El
paseo adoquinado y las copas variadas toman rasgos de la galería exterior,
sin atribuirles medidas ni ubicación exacta. Fútbol sintético/tierra,
voleibol, tenis y canchas polifuncionales tienen marcas y elementos diferentes.
Los cortes de cubierta permiten ver las canchas que el plano llama techadas.

El bloque A tiene dos ambientes identificados por esos nombres; el B tiene
tres. No se inventan LSIA-2/3 ni LSIB-3 para llenar una numeración. Los otros
bloques con varias aulas conservan los rótulos del plano y reciben un corredor.
Los puestos, pizarras, luminarias y armarios dibujados son ilustraciones
originales; su cantidad no representa capacidad o inventario real.

Las páginas se consultan como referencias públicas, sin fecha de actualización
confirmada. Su presencia en el juego no demuestra vigencia ni aporta una
licencia de reproducción de fotografías. El código y los dibujos propios
conservan `GPL-3.0-or-later`; no cambia la titularidad de recursos de terceros.

## Pendientes para el usuario y backend/datos

| Responsable | Material necesario | Criterio de cierre |
|---|---|---|
| Usuario y backend/datos | Planta de Sistemas A/B, número de niveles, listado de aulas y laboratorios, accesos y fecha de referencia. | Validación de correspondencia entre bloque, nombre, planta y puerta. |
| Usuario y frontend/arte | Fotos propias o autorizadas de fachadas, pasillos, ventanas, aulas y equipos, identificadas por lugar y fecha. | Comparación de las recreaciones con material que pueda utilizarse. |
| Backend/datos | Revisión de la diferencia entre el total de instalaciones y el listado de Computación, y de las descripciones de Redes. | Inventario versionado y contenido técnico revisado. |
| Backend/datos | Aula, materia, paralelo y horario con sus fuentes. | Contrato que permita contextualizar actividades sin deducir notas ni inscripciones por entrar a una sala. |
| Usuario + backend/datos | Croquis/fotos propias o autorizadas de la sala E, fecha, mesas reales y acceso. | Interior y usos contrastados; ver [nota de minijuegos](JUEGOS_BLOQUE_E.md). |

La solicitud general de originales y permisos continúa en
[Datos y fuentes para backend](PARA_BACKEND_DATOS_Y_FUENTES.txt).
