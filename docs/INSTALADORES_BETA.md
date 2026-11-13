# Instaladores de SIS-INF

La beta pública `0.1.0-beta.1` incluye el motor Godot en los paquetes de
escritorio. Cada descarga corresponde a un sistema y una arquitectura.
[Archivos de la beta](https://github.com/CzruAyna/Proy_Sis_Acad/releases/tag/v0.1.0-beta.1)

| Sistema | Archivo | Uso |
|---|---|---|
| Windows x64 | `*-Windows-x64-Setup.exe` | Abre el instalador y busca SIS-INF en Inicio. Se instala por usuario en `%LOCALAPPDATA%\Programs\SIS-INF`. Puedes retirarlo desde Aplicaciones instaladas. |
| Linux x86_64 | `*-Linux-x86_64.tar.gz` | Extrae todo y ejecuta `sh install.sh` dentro de la carpeta. Verifica sistema y arquitectura y añade SIS-INF al menú. Ejecuta `sh install.sh --uninstall` para retirarlo. |
| macOS Intel y Apple Silicon | `*-macOS-Universal.zip` | Extrae el ZIP y arrastra `SIS-INF.app` a Aplicaciones. El paquete de prueba lleva firma ad hoc. Quedan pendientes la notarización y una prueba en un Mac. |

Windows y Linux instalan sin privilegios de administrador. El desinstalador
retira los archivos del juego y el acceso directo. Godot guarda las partidas
por separado en `user://` y conserva la ruta de perfiles de SIS-INF.
El instalador de Windows carece de firma Authenticode.

## Construcción local

Usa Python 3.11 o posterior, Godot 4.7.2 estable con sus plantillas de
exportación y NSIS 3.12 para Windows. El compilador NSIS debe tener cerca su
archivo `COPYING`. Las plantillas deben corresponder a la versión exacta
de Godot. [Plantillas oficiales](https://github.com/godotengine/godot-builds/releases/tag/4.7.2-stable).

Desde la raíz del proyecto, con Godot y MakeNSIS en `PATH`:

~~~powershell
python game/packaging/build_beta.py --target all --version 0.1.0-beta.1
~~~

Usa `--godot RUTA` o `--nsis RUTA` si las herramientas están en otra
ubicación. `--target auto` elige el preset según el sistema donde se ejecuta
el empaquetador. También acepta `windows`, `linux` y `macos` de manera
independiente. El resultado queda en `game/build/beta/` junto al ZIP de
fuentes y al manifiesto SHA-256 de los archivos generados en esa ejecución.
Los paquetes incluyen los avisos de Godot, la GPL y el JSON derivado de
OpenStreetMap con su atribución y enlace a la ODbL. El instalador de Windows
incluye el aviso de NSIS.

## Comprobar la instalación

1. Instala en la plataforma correspondiente y abre SIS-INF desde su acceso.
2. Crea una partida, entra al campus, abre mapa y malla y prueba una mesa
   de minijuego. Guarda y verifica que puedes continuar.
3. Reinstala y comprueba que continúa la misma partida. Desinstala y vuelve
   a instalar para comprobar que se conserva el perfil.

Los rótulos y oficinas pendientes de confirmación, el reloj persistente y
la concesión de recompensas quedan registrados en las notas de
[exploración contextual](EXPLORACION_CONTEXTUAL_Y_MALLA.md) y
[ramas y misiones](RAMAS_TERRENO_Y_MISIONES.md).
