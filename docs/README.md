# Documentación

Para descargar o comprobar una instalación, consulta la [guía de instaladores](INSTALADORES_BETA.md).
Para preparar un cambio, consulta [Contribuir a SIS-INF](../CONTRIBUTING.md).

Este índice reúne guías de uso y documentos de coordinación. Los análisis con
fecha describen el estado observado durante esa revisión; para reglas vigentes
del juego, consultar [Simulación individual](SIMULACION_ESTUDIANTE.md).

## Uso y componentes

| Documento | Contenido |
|---|---|
| [Estado actual](ESTADO_ACTUAL.md) | Funciones, persistencia y límites al corte `2868d19`. |
| [Arquitectura](ARQUITECTURA.md) | Organización del repositorio, separación de componentes y responsabilidades principales del código. |
| [Desarrollo local](DESARROLLO_LOCAL.md) | Requisitos, ejecución, exportación y pruebas de Godot. |
| [Automatización](AUTOMATIZACION.md) | Suites, empaquetado por plataforma y comprobación de los archivos. |
| [Instaladores de la beta](INSTALADORES_BETA.md) | Paquetes por sistema, compilación, pruebas y pendientes. |
| [Simulación individual](SIMULACION_ESTUDIANTE.md) | Reglas y estados del recorrido individual en Godot. |
| [Diseño visual](DISENO_VISUAL_CAMPUS.md) | Identidad, grafos, navegación y comportamiento visual acordados. |
| [Ruptura y emblema geométrico](DISENO_RUPTURA_Y_EMBLEMA.md) | Terminal interior, botones translúcidos, erosión progresiva, emblema animado y verificaciones. |
| [Tareas de frontend](ALCANCE_FRONTEND.md) | Qué puede asumir interfaz, ejemplos de encargos y coordinación con motor/backend. |
| [Historia demostrativa](MODULO_HISTORIA_CARRERA.md) | Funcionamiento y límites de la historia simulada de una carrera. |
| [Demostración automática](MODO_DEMOSTRATIVO.md) | Terminal explicativa en bucle, resumen y recorrido por materias; contrato de animaciones para frontend. |
| [Exploración FNI](EXPLORACION_FNI.md) | Campus pixel art de SIS-INF, personaje, controles, aulas, guardado y recordatorios de ambientación. |
| [Campus ampliado y personajes](CAMPUS_AMPLIADO_Y_VIDA_DEL_CAMPUS.md) | Antecedente del mapa ampliado, las estatuas, los primeros planos de pisos y el elenco. |
| [Matriz 8×8 y personajes](MAPA_8X8_Y_PERSONAJES.md) | Primera versión del atlas, cambios de escala, retirada de originales y paseos ambientales del 4 de noviembre. |
| [Cartografía y escala FNI](CARTOGRAFIA_FNI_Y_ESCALA.md) | Mapa vigente, geometría de OpenStreetMap, escala, tiempos de recorrido y coordinación con motor/backend. |
| [Menús, mapa jugable y perímetro](MENUS_MAPA_Y_PERIMETRO.md) | Navegación centrada, opciones por categoría, zoom, sectores y referencias para el cerco y el tránsito exterior. |
| [Exploración contextual y malla](EXPLORACION_CONTEXTUAL_Y_MALLA.md) | Ventanilla de la partida, ciclo visual, navegación de materias y contrato para motor/backend. |
| [Ramas, terreno y misiones](RAMAS_TERRENO_Y_MISIONES.md) | Malla acumulativa, controles del mapa, arte del campus, objetivos y contrato de recompensas. |
| [Caminos, inicio y ambientes](CAMINOS_MENU_Y_AMBIENTES.md) | Empalmes continuos, rosa orientada, inicio con cuatro acciones, interiores variados y contrato para motor/backend. |
| [Vida del campus y rendimiento](VIDA_CAMPUS_Y_RENDIMIENTO.md) | Pisos transitables, rutinas persistentes, caricias, Piedritas 1/100, logros y optimizaciones medidas; pendientes para frontend y datos. |
| [Guía y rutina estudiantil](GUIA_Y_RUTINA_ESTUDIANTIL.md) | Misiones, minimapa, celular, rasgos, proyectos, exámenes y tiendas. |
| [Mapa en cuatro cuadrantes, histórico](MAPA_PARA_CORRECCIONES.md) | Exportación del 03/11/2026, sustituida por la matriz 8×8. |
| [Referencias de interiores FNI](REFERENCIAS_INTERIORES_FNI.md) | Fuentes consultadas, ambientación recreada y planos/fotos que faltan verificar. |
| [Sala de juegos del bloque E](JUEGOS_BLOQUE_E.md) | Cuatro minijuegos jugables contra rivales, variantes, controles, guardado, optimizaciones y pendientes. |

## Historial y comprobaciones

| Documento | Contenido |
|---|---|
| [Historial de pushes](HISTORIAL_PUSHES.md) | Envíos de la etapa Godot registrados en `origin/main`. |
| [Historial técnico por commit](HISTORIAL_COMMITS.md) | Cambios del juego por commit, con títulos originales y archivos de referencia. |
| [Bitácora de desarrollo](BITACORA_DESARROLLO.md) | Avances y decisiones de la etapa Godot, por jornada. |
| [Verificaciones](VERIFICACIONES.md) | Ejecuciones registradas por versión y alcance de la revisión documental. |

## Especificación y coordinación

| Documento | Contenido |
|---|---|
| [Auditoría del frontend del juego](AUDITORIA_FRONTEND_CAMPUS.md) | Diagnóstico fechado; sus hallazgos deben contrastarse con el código actual. |
| [Pendientes de frontend y simulación](PENDIENTES_FRONTEND_SIMULACION.md) | Coordinación y asuntos pendientes para el responsable de interfaz y motor. |
| [Datos y fuentes para backend](PARA_BACKEND_DATOS_Y_FUENTES.txt) | Fuentes originales que faltan y aspectos institucionales por verificar. |
| [Roadmap](ROADMAP.md) | Fases previstas en el documento de planificación. |
| [Guía de documentación](GUIA_DOCUMENTACION.md) | Criterios para documentar decisiones, cambios, comprobaciones y pendientes. |
| [Código libre y licencia](LICENCIA_CODIGO_LIBRE.md) | GPLv3 o posterior para el código original, derechos de terceros y revisiones pendientes. |
