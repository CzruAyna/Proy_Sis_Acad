# SIS-INF

Juego de escritorio educativo desarrollado con Godot. La experiencia principal
permite explorar carreras de Ingeniería, cursar materias, resolver actividades,
gestionar trámites simulados y avanzar por auxiliatura y graduación. El progreso
de las partidas y los logros se guardan localmente en el equipo.

Incluye campus pixel art, historia demostrativa y cuatro minijuegos locales.
El alcance revisado y lo que falta están en
[Estado actual](docs/ESTADO_ACTUAL.md).

Este repositorio también conserva una API académica en Django y una interfaz
web en Next.js. Son componentes separados del juego Godot: la partida de
escritorio no necesita PostgreSQL ni se conecta a la API.

## Inicio rápido

Para ejecutar el juego desde el proyecto se necesita Godot 4.7.2:

```powershell
godot --path game
```

Para generar la versión de Windows, hay que tener instaladas las plantillas de
exportación de la misma versión de Godot y usar el preset `Windows Desktop`:

```powershell
godot --headless --path game --export-release "Windows Desktop" "build/SIS-INF.exe"
```

La exportación crea el ejecutable y su archivo `.pck`. Ambos deben permanecer
juntos para iniciar el juego. `game/build/` es una carpeta local ignorada por
Git, por lo que los binarios generados no forman parte del código fuente.

Los requisitos detallados para el juego, Django y Next.js están en
[`docs/DESARROLLO_LOCAL.md`](docs/DESARROLLO_LOCAL.md).

## Estructura del repositorio

```text
AGENTS.md             Instrucciones permanentes para agentes del proyecto
REGLAS_USUARIO.txt    Reglas acumuladas expresadas por el usuario
backend/              API académica Django y PostgreSQL
frontend/             Interfaz web Next.js
game/                 Juego de escritorio Godot, sus datos y pruebas
docs/                 Arquitectura, reglas, diseño y coordinación
.env.example          Plantilla local de configuración
```

El código de Godot es el producto principal. La API y el sitio web mantienen
sus propios modelos y flujos; no se deben tratar como dependencias del juego.

## Documentación

- [Índice de documentación](docs/README.md)
- [Arquitectura y componentes](docs/ARQUITECTURA.md)
- [Desarrollo y compilación local](docs/DESARROLLO_LOCAL.md)
- [Reglas de la simulación individual](docs/SIMULACION_ESTUDIANTE.md)
- [Identidad visual y navegación](docs/DISENO_VISUAL_CAMPUS.md)
- [Exploración FNI: personaje, mapa y aulas](docs/EXPLORACION_FNI.md)
- [Información institucional y fuentes pendientes](docs/PARA_BACKEND_DATOS_Y_FUENTES.txt)
- [Guía de documentación](docs/GUIA_DOCUMENTACION.md)
- [Bitácora de desarrollo](docs/BITACORA_DESARROLLO.md)
- [Detalle técnico de los 32 commits revisados](docs/HISTORIAL_COMMITS.md)
- [Resultados y límites de verificación](docs/VERIFICACIONES.md)
- [Licencia y libertades del código](docs/LICENCIA_CODIGO_LIBRE.md)

Antes de modificar el proyecto, cualquier agente debe leer `AGENTS.md` y el
registro completo `REGLAS_USUARIO.txt`. La información institucional pendiente
de verificación no debe presentarse como normativa oficial.

## Licencia

Copyright (C) 2026 José Gabriel Cruz Choque.

El código original y la documentación técnica propia de SIS-INF se
distribuyen bajo la **GNU General Public License, versión 3 o cualquier versión
posterior** (`GPL-3.0-or-later`). Se permite usar, estudiar, modificar y
redistribuir el proyecto. Al redistribuir versiones derivadas deben conservarse
las condiciones de copyleft aplicables y facilitarse el código fuente
correspondiente según la licencia. El software se ofrece sin garantía.

El texto completo está en [LICENSE](LICENSE). Las dependencias, el motor y
los recursos de terceros conservan sus licencias y avisos. El alcance, las
fuentes oficiales y las verificaciones pendientes están en la
[guía de licencia](docs/LICENCIA_CODIGO_LIBRE.md).
