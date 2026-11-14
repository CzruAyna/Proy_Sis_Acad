# Desarrollo y compilación local

## Juego de escritorio Godot

### Requisitos

- Godot 4.7.2 para editar o ejecutar el proyecto desde el código fuente.
- Para exportar Windows: plantillas de exportación de Godot 4.7.2 y el preset
  `Windows Desktop` que ya está en `game/export_presets.cfg`.

### Ejecutar desde el proyecto

Desde la raíz del repositorio:

```powershell
godot --version
godot --path game
```

El primer comando permite comprobar que la versión del editor coincide. Si
Godot no está en `PATH`, reemplazar `godot` por la ruta al ejecutable local de
Godot 4.7.2.

### Exportar un ejecutable de Windows

En Godot, instalar las plantillas correspondientes a la versión 4.7.2 desde el
administrador de plantillas de exportación. Luego, desde la raíz:

```powershell
godot --headless --path game --export-release "Windows Desktop" "build/SIS-INF.exe"
```

El resultado consta de `SIS-INF.exe` y `SIS-INF.pck` dentro de
`game/build/`. Mantener ambos archivos juntos. La carpeta de exportación está
ignorada por Git y no sustituye al código fuente del proyecto.

Para obtener el instalador, los paquetes de Linux y macOS y las sumas SHA-256
de la beta, consulta [Instaladores de la beta](INSTALADORES_BETA.md).

### Partidas y preferencias

El juego guarda las partidas, preferencias y logros en el directorio local de
usuario de Godot (`user://`). Las
partidas personales no están dentro del repositorio.

El nombre visible actual es SIS-INF. En Windows se mantiene la ruta de datos
anterior mediante la configuración explícita del proyecto, para conservar
partidas y preferencias. Detalle en [Exploración FNI](EXPLORACION_FNI.md).

## Pruebas y diagnósticos

Los resultados de cada revisión están en [Verificaciones](VERIFICACIONES.md).
GitHub Actions ejecuta todos los scripts de prueba. [Automatización](AUTOMATIZACION.md)

Las pruebas de Godot son scripts independientes dentro de `game/tests/` y se
ejecutan con el mismo motor:

```powershell
godot --headless --path game --script res://tests/test_student_simulation.gd
godot --headless --path game --script res://tests/test_game_integration.gd
godot --headless --path game --script res://tests/test_simulation_storage.gd
```

Las comprobaciones de grafo, navegación, interfaz e identidad visual también
están separadas por archivo en `game/tests/`. Las capturas gráficas requieren
un entorno de escritorio y no se ejecutan en modo `--headless`. Los documentos
de [diseño visual](DISENO_VISUAL_CAMPUS.md) y [simulación](SIMULACION_ESTUDIANTE.md)
incluyen los comandos y límites conocidos de sus áreas.

Para los motores recreativos y su integración:

```powershell
godot --headless --path game --script res://tests/test_recreation_models.gd
godot --headless --path game --script res://tests/test_recreation_ui.gd
godot --headless --path game --script res://tests/test_games_room.gd
```
