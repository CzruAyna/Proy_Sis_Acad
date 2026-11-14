# Contribuir a SIS-INF

## Reportar un fallo

Indica la versión o el commit, tu sistema operativo, los pasos para
reproducirlo y qué esperabas que ocurriera. Si el fallo depende de una
partida, usa una partida de prueba y evita adjuntar datos personales.
[Issues de SIS-INF](https://github.com/CzruAyna/Proy_Sis_Acad/issues)

## Preparar un cambio

1. Consulta las [reglas del proyecto](REGLAS_USUARIO.txt) y la guía del área
   que vas a modificar. [Índice de documentación](docs/README.md)
2. Ejecuta las pruebas relacionadas con Godot 4.7.2. Para cambios de
   interfaz, comprueba también el recorrido con teclado. [Desarrollo local](docs/DESARROLLO_LOCAL.md)
3. Describe el propósito, el comportamiento que cambió y las pruebas que
   ejecutaste. Si cambia un control, requisito o procedimiento, actualiza
   su guía de uso. [Guía de documentación](docs/GUIA_DOCUMENTACION.md)

Las reglas académicas del juego son parte de la simulación. Si aportas un
dato institucional, registra su procedencia y vigencia. [Datos y fuentes](docs/PARA_BACKEND_DATOS_Y_FUENTES.txt)

## Capturas para revisión

Cada pull request incluye al menos una captura del resultado. En interfaz,
muestra el juego y añade una comparación antes/después cuando puedas
reproducir la vista anterior. Para cambios de motor, documentación o CI,
captura la prueba ejecutada, la guía renderizada o el resultado de la
ejecución. Indica qué se comprueba y enlaza el resultado de CI cuando exista.
Usa datos de prueba y oculta cualquier información sensible.

Mientras falte la captura, conserva el pull request en borrador.
[Plantilla de pull request](.github/pull_request_template.md)
