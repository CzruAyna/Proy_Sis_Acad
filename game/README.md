# CAMPUS EN JUEGO

Juego de escritorio para Windows hecho con Godot 4.7 (GDScript). Simula el recorrido individual de un estudiante por la carrera: materias, trámites, auxiliatura y graduación.

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

- **Estudiante:** semestres con resultados mixtos, reprobadas obligatorias, correlativas con sus regulares y conservación del historial de intentos.
- **Trámites:** matrícula, carta, materia externa, cambio de carrera K-03 y cambio de mención K-02.
- **Auxiliatura:** postulación durante la carrera, competencia con rivales simulados, asignación de paralelo y trabajo con el docente.
- **Graduación:** excelencia sin reprobaciones y promedio mayor que 65, o tesis/proyecto con defensa. Concluir materias no entrega automáticamente el título.
- **Gestiones temporales:** F10 abre la consola del motor; `/ayuda` enumera las acciones y `/desbloquear todo` habilita explorar las materias sin aprobarlas automáticamente.
- **Guardado:** tres espacios individuales, archivo temporal y respaldo `.bak`; se migran las materias conocidas de partidas antiguas sin inventar sus notas. Los archivos multijugador anteriores se conservan sin cargarlos como modo jugable.
- **Interfaz:** estilo cuaderno, iconos, animaciones, ajuste de texto, antialiasing opcional, mejor legibilidad.
- **Sin audio.** Solo local.

## Estructura

```text
game/
  project.godot
  scenes/main.tscn
  scripts/game.gd
  scripts/catalog.gd
  scripts/student_simulation.gd
  scripts/simulation_procedures.gd
  scripts/simulation_commands.gd
  scripts/simulation_save_store.gd
  tests/
  assets/campus_vector.svg
  build/           (ejecutable/exportado)
```

## Base de datos

**No es necesaria para este juego.** Usa archivos JSON en `user://partidas/`. El PostgreSQL/Django solo aplica al sistema académico (`backend/`), que se mantiene intacto.

Las reglas están en `docs/SIMULACION_ESTUDIANTE.md`. El contrato para sustituir la consola temporal por oficinas y formularios gráficos está en `docs/PENDIENTES_FRONTEND_SIMULACION.md`.
