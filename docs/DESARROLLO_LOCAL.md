# Desarrollo y compilación local

Los pasos son para desarrollo en Windows y PowerShell. El repositorio no
requiere Docker. La experiencia Godot se puede ejecutar sin el backend, el
frontend web ni PostgreSQL.

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
godot --headless --path game --export-release "Windows Desktop" "game/build/CAMPUS EN JUEGO.exe"
```

El resultado consta de `CAMPUS EN JUEGO.exe` y `CAMPUS EN JUEGO.pck` dentro de
`game/build/`. Mantener ambos archivos juntos. La carpeta de exportación está
ignorada por Git y no sustituye al código fuente del proyecto.

### Partidas y preferencias

El juego guarda las partidas, preferencias y logros en el directorio local de
usuario de Godot (`user://`). No almacena estos datos en PostgreSQL. Las
partidas personales no están dentro del repositorio.

## API Django y PostgreSQL

Este componente es independiente del juego. Requiere Python, PostgreSQL y las
dependencias indicadas en `backend/requirements.txt`.

Desde la raíz del repositorio, preparar el entorno en PowerShell:

```powershell
Set-Location backend
py -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
if (-not (Test-Path ..\.env)) { Copy-Item ..\.env.example ..\.env }
```

Si ya existe `.env`, conservarlo y editar solo los valores que correspondan.
El archivo de ejemplo contiene valores de desarrollo. Iniciar PostgreSQL con
una base y usuario que coincidan con el archivo antes de continuar.

Desde `backend/`, ejecutar las migraciones y arrancar el servidor:

```powershell
python manage.py migrate
python manage.py runserver
```

El servidor local queda en `http://localhost:8000/`; el estado de salud está
en `/api/health/`. Para administrar usuarios localmente, se puede crear un
superusuario con `python manage.py createsuperuser`.

No copiar ni publicar el `.env`; `.gitignore` excluye ese archivo. Los valores
de desarrollo no son configuración de producción.

## Interfaz Next.js

Este componente consume la API local y puede ejecutarse por separado. Requiere
Node.js y npm compatibles con la versión fijada en `frontend/package.json`.
Desde una terminal nueva situada en la raíz del repositorio:

```powershell
Set-Location frontend
npm ci
npm run dev
```

La página se sirve por defecto en `http://localhost:3000`. La API usada por
`frontend/src/lib/api.ts` puede cambiarse con `NEXT_PUBLIC_API_URL`; si no se
define, usa `http://localhost:8000`.

Para crear la compilación web de producción, ejecutar `npm run build` desde
`frontend/`:

```powershell
npm run build
```

## Pruebas y diagnósticos

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
