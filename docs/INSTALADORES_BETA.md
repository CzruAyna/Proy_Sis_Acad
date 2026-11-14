# Instalar y verificar SIS-INF

Los paquetes incluyen el motor Godot. Elige el archivo de tu sistema y
descarga también el manifiesto `*-SHA256SUMS.txt` de la misma publicación.
[Publicaciones de SIS-INF](https://github.com/CzruAyna/Proy_Sis_Acad/releases)

Si tienes GitHub CLI, puedes descargar los archivos desde la terminal.
Este ejemplo obtiene el instalador de Windows y su manifiesto de la primera beta.
Para Linux usa el patrón `*-Linux-x86_64.tar.gz`, y para macOS,
`*-macOS-Universal.zip`. Cambia la etiqueta para usar otra publicación.

```sh
gh release download v0.1.0-beta.1 --repo CzruAyna/Proy_Sis_Acad --pattern '*-Windows-x64-Setup.exe' --pattern '*-SHA256SUMS.txt'
```

Calcula la suma del archivo descargado y compárala con la línea del mismo
nombre en el manifiesto. Si difiere, vuelve a descargarlo antes de instalar.

| Sistema | Comando para calcular SHA-256 |
|---|---|
| Windows, PowerShell | `Get-FileHash .\SIS-INF-0.1.0-beta.1-Windows-x64-Setup.exe -Algorithm SHA256` |
| Linux | `sha256sum SIS-INF-0.1.0-beta.1-Linux-x86_64.tar.gz` |
| macOS | `shasum -a 256 SIS-INF-0.1.0-beta.1-macOS-Universal.zip` |

| Sistema | Archivo | Uso |
|---|---|---|
| Windows x64 | `*-Windows-x64-Setup.exe` | Abre el instalador y busca SIS-INF en Inicio. Se instala por usuario en `%LOCALAPPDATA%\Programs\SIS-INF`. Puedes retirarlo desde Aplicaciones instaladas. |
| Linux x86_64 | `*-Linux-x86_64.tar.gz` | Extrae todo y ejecuta `sh install.sh` dentro de la carpeta. Verifica sistema y arquitectura y añade SIS-INF al menú. Ejecuta `sh install.sh --uninstall` para retirarlo. |
| macOS Intel y Apple Silicon | `*-macOS-Universal.zip` | Extrae el ZIP y arrastra `SIS-INF.app` a Aplicaciones. El paquete de prueba lleva firma ad hoc. Quedan pendientes la notarización y una prueba en un Mac. |

Windows y Linux instalan sin privilegios de administrador. El desinstalador
retira los archivos del juego y el acceso directo. Godot guarda las partidas
por separado en `user://` y conserva la ruta de perfiles de SIS-INF.
El instalador de Windows carece de firma Authenticode. En Linux, la
extracción y la instalación usan `tar`, `sh` y utilidades GNU básicas.

## Construcción local

Usa Python 3.11 o posterior y Godot 4.7.2 estable con sus plantillas de
exportación. Para Windows, el empaquetador usa NSIS. Busca su licencia en
`COPYING` junto al compilador o en la ruta indicada mediante `--nsis-license`.
Las plantillas deben corresponder a la versión exacta
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

La configuración de compilación y pruebas en GitHub Actions está en
[Automatización](AUTOMATIZACION.md).
