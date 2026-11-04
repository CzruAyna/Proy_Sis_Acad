# Código libre y licencia

Actualización del 04/11/2026: se retiraron los JPG de planos y el PNG original
aportados, junto con su conversor y metadatos. Se conservan el código y arte
procedural propios, el icono pixel art y la procedencia histórica documentada.
Las futuras referencias se consultan externamente; no se empaquetaron fotos
ni imágenes de Google Maps. Detalle en
[Matriz 8×8 y personajes](MAPA_8X8_Y_PERSONAJES.md).

Actualizado: 30 de octubre de 2026.

## Licencia del proyecto

El código original y la documentación técnica propia de SIS-INF se
ofrecen bajo la **GNU General Public License, versión 3 o cualquier versión
posterior**, con identificador SPDX `GPL-3.0-or-later`.

Copyright (C) 2026 José Gabriel Cruz Choque.

La instrucción del autor es conservar las libertades del código y no introducir
licencias privativas. La elección de GPLv3 o posterior es la decisión técnica
aplicada para expresar esa instrucción mediante una licencia libre con copyleft.
El texto completo y sin modificaciones está en [`../LICENSE`](../LICENSE).

## Libertades y copyleft

La licencia permite ejecutar, estudiar, copiar, modificar y redistribuir el
programa. Cuando se distribuyen versiones derivadas cubiertas por GPL, se
deben conservar sus condiciones de copyleft y proporcionar el código fuente
correspondiente según las modalidades previstas por la licencia.

La libertad de uso incluye el uso comercial. No se agregan condiciones de
«solo uso educativo», «sin uso comercial» o «sin modificaciones». El software
se ofrece sin garantía en los términos del texto de GPL.

El copyleft protege las libertades de quienes reciben una copia. No significa
que toda modificación privada deba publicarse. La mera ejecución de un servidor
sin distribuir copias tampoco equivale, por sí sola, a una obligación general de
publicar todas sus modificaciones bajo GPLv3.

Este documento explica el alcance adoptado; no cambia ni sustituye los términos
de `LICENSE`. La declaración describe la versión actual y no reescribe los
archivos ni las declaraciones de licencia conservados en el historial.

## Componentes de terceros

La licencia del proyecto no reemplaza los avisos de Godot, bibliotecas,
dependencias, fuentes tipográficas ni recursos ajenos. Deben conservarse
sus atribuciones y condiciones originales.

Godot es software libre bajo licencia MIT. Su licencia no obliga a aplicar MIT
al juego creado con él. La documentación del motor solicita conservar su aviso
y licencia al redistribuir el motor; su página de licencia explica el uso de
un enlace a ese aviso en la documentación o los créditos.

Esta referencia es el aviso documental del motor:
[licencia y atribución de Godot](https://godotengine.org/license/).

No se han eliminado avisos de terceros ni se ha declarado una auditoría completa
de compatibilidad de todas las dependencias. Antes de preparar una distribución
debe revisarse el inventario exacto del paquete que vaya a entregarse.

## Documentos e imágenes institucionales

Las mallas, formularios, logotipos, fotografías y reglamentos de terceros no se
convierten en materiales propios por estar citados en el proyecto. Su
procedencia y condiciones de reproducción deben constar antes de incorporarlos
o redistribuirlos.

El material solicitado y los campos de revisión se mantienen en
[`PARA_BACKEND_DATOS_Y_FUENTES.txt`](PARA_BACKEND_DATOS_Y_FUENTES.txt).
La licencia libre del código no confirma vigencia institucional ni concede
derechos que el autor no tenga sobre ese material.

## Revisiones pendientes

La ampliación de las mesas del 03/11/2026 incluye siluetas de ajedrez y dibujos
de bolas/tableros creados por código original; no incorpora sprites ni código
de 8 Ball Pool o de una edición comercial de Monopolio. Las referencias de
controles de Miniclip están enlazadas en [Sala E](JUEGOS_BLOQUE_E.md). El arte de
los personajes de pausa todavía no existe: frontend debe aportar recursos
originales o con condiciones compatibles y registrar su procedencia.

El 03/11/2026 se añadió un icono geométrico simplificado de 32 píxeles, con PNG
y archivo ICO multirresolución generados por `game/tools/prepare_pixel_icon.gd`.
Su código de dibujo es original y conserva GPL-3.0-or-later. La interpretación
del emblema aportado no resuelve los derechos pendientes de la identidad
institucional que representa; no se incorporaron fuentes, imágenes o paquetes
externos nuevos para este icono.

El 30/10/2026 se incorporaron el logo `images (3).jfif` (convertido a PNG)
y el plano `AULAS-FNI.jpg` por encargo expreso del usuario para SIS-INF.
Su procedencia inmediata, hashes, preparación y derechos pendientes se
registran en [Exploración FNI](EXPLORACION_FNI.md). Son recursos de terceros:
no se atribuyen al autor del código ni se relicencian bajo GPL. Falta confirmar
autor, entidad emisora y condiciones de redistribución pública.

| Área responsable | Pendiente | Evidencia o material necesario | Criterio de cierre |
|---|---|---|---|
| Documentación y autor | Completar la procedencia de recursos originales y aportados. | Identificación del autor y del origen de cada recurso que se incorpore. | Recursos clasificados como propios o de terceros con condiciones registradas. |
| Backend y datos | Verificar reproducción de mallas, formularios e imágenes institucionales. | Originales, entidad emisora, versión, permiso o licencia y páginas utilizadas. | Datos trazables y condiciones de reproducción documentadas. |
| Empaquetado | Inventariar las licencias de dependencias incluidas en cada distribución. | Versiones exactas, archivos de licencia y avisos del motor y bibliotecas. | Paquete revisado con sus avisos y condiciones correspondientes. |
| Empaquetado y autor | Comprobar la entrega del código fuente correspondiente junto con el binario o por una modalidad admitida por GPL. | Contenido del paquete, fuentes de esa versión y método de entrega. | Distribución concreta revisada; no basta con la existencia de un repositorio. |

## Material del campus ampliado

La ampliación del campus del 03/11/2026 añade arte procedural original de
estatuas y personajes, sin copiar las fotografías al juego. El plano marcado
aportado por el usuario sí se conserva como referencia de terceros. Su hash,
procedencia y derechos pendientes están en
[Campus ampliado](CAMPUS_AMPLIADO_Y_VIDA_DEL_CAMPUS.md); no se relicencia bajo GPL
ni se atribuye al autor del código la propiedad de esculturas o identidad FNI.

## Referencias oficiales

- [Texto oficial de GPLv3](https://www.gnu.org/licenses/gpl-3.0.html).
- [Cómo aplicar las licencias GNU](https://www.gnu.org/licenses/gpl-howto.html).
- [Qué es copyleft](https://www.gnu.org/licenses/copyleft.html).
- [Preguntas frecuentes sobre las licencias GNU](https://www.gnu.org/licenses/gpl-faq.html).
- [Licencia del motor Godot](https://godotengine.org/license/).
