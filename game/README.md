# CAMPUS EN JUEGO

Juego de escritorio para Windows hecho con Godot 4.7 (GDScript). Es una partida corta en modo cuaderno: carrera universitaria en solitario o partida local por turnos entre 1 y 4 jugadores.

El sistema académico Django/Next.js de este repositorio queda separado y no se modifica por este juego.

## Ejecutar

```powershell
game\.tools\Godot_v4.7.2-stable_win64_console.exe --path game
```

Versión exportada: `game/build/CAMPUS EN JUEGO.exe`.

## Exportar

```powershell
$env:APPDATA = "game\.tools\editor-profile\Roaming"
$env:LOCALAPPDATA = "game\.tools\editor-profile\Local"
game\.tools\Godot_v4.7.2-stable_win64_console.exe --headless --path game --export-release "Windows Desktop" "build/CAMPUS EN JUEGO.exe"
```

## Estado

- **Solo:** nombre, facultad/carrera/enfoque, 3 materias con 3 parciales, examen de competencia y títulos.
- **Equipo local:** 1-4 jugadores con nombres, turno rotativo, marcador individual (puntos/confianza), CV, entrevista, votación a decano y casos por rol.
- **Guardado:** `solo_partida_N.json` y `multi_partida_N.json` en 3 espacios cada uno. Se lee formato antiguo `partida_N.json`.
- **Interfaz:** estilo cuaderno, iconos, animaciones, ajuste de texto, antialiasing opcional, mejor legibilidad.
- **Sin audio.** Solo local.

## Estructura

```text
game/
  project.godot
  scenes/main.tscn
  scripts/game.gd
  scripts/catalog.gd
  assets/campus_vector.svg
  build/           (ejecutable/exportado)
```

## Base de datos

**No es necesaria para este juego.** Usa archivos JSON en `user://partidas/`. El PostgreSQL/Django solo aplica al sistema académico (`backend/`), que se mantiene intacto.
