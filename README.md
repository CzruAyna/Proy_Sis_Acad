# SIS-INF

Juego de escritorio educativo desarrollado con Godot. La experiencia principal
permite explorar carreras de Ingeniería, cursar materias, resolver actividades,
gestionar trámites simulados y avanzar por auxiliatura y graduación. El progreso
de las partidas y los logros se guardan localmente en el equipo.

En **Jugar** puedes continuar una partida o visitar el campus pixel art con
sus aulas, pisos transitables y cuatro minijuegos locales en el bloque E.
**Simular** reúne la historia de una carrera y una terminal automática que
presenta las dos carreras y sus cinco menciones.

Este repositorio también conserva una API académica en Django y una interfaz
web en Next.js. Son componentes separados del juego Godot: la partida de
escritorio no necesita PostgreSQL ni se conecta a la API.

## Descargar y probar la beta

La beta pública incluye paquetes para Windows x64, Linux x86_64 y macOS
(Intel y Apple Silicon). Descarga el de tu equipo y compara su hash SHA-256
con el del archivo `SIS-INF-0.1.0-beta.1-SHA256SUMS.txt` antes de instalar.
[Descargas de SIS-INF 0.1.0-beta.1](https://github.com/CzruAyna/Proy_Sis_Acad/releases/tag/v0.1.0-beta.1)

Después de instalar, abre SIS-INF, crea una partida y entra al campus.
Abre el mapa, guarda la partida, cierra el juego y comprueba que puedes
continuarla desde **Jugar**. [Guía de instalación y prueba](docs/INSTALADORES_BETA.md)

## Ejecutar desde el código fuente

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

- [Estado actual de SIS-INF](docs/ESTADO_ACTUAL.md)
- [Índice de documentación](docs/README.md)
- [Arquitectura y componentes](docs/ARQUITECTURA.md)
- [Desarrollo y compilación local](docs/DESARROLLO_LOCAL.md)
- [Reglas de la simulación individual](docs/SIMULACION_ESTUDIANTE.md)
- [Identidad visual y navegación](docs/DISENO_VISUAL_CAMPUS.md)
- [Exploración FNI: personaje, mapa y aulas](docs/EXPLORACION_FNI.md)
- [Información institucional y fuentes pendientes](docs/PARA_BACKEND_DATOS_Y_FUENTES.txt)
- [Guía de documentación](docs/GUIA_DOCUMENTACION.md)
- [Bitácora de desarrollo](docs/BITACORA_DESARROLLO.md)
- [Historial de pushes](docs/HISTORIAL_PUSHES.md)
- [Detalle técnico por commit](docs/HISTORIAL_COMMITS.md)
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
