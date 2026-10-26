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

- **Estudiante:** nombre obligatorio, primer semestre con materias asignadas automáticamente y planificación desde el segundo; resultados mixtos, reprobadas obligatorias, correlativas con sus regulares e historial de intentos.
- **Logros globales:** catálogo completo de logros públicos pendientes/desbloqueados y logros ocultos que se revelan al conseguirlos. Se conservan entre recorridos.
- **Trámites:** matrícula, carta, materia externa, cambio de carrera K-03 y cambio de mención K-02.
- **Auxiliatura:** postulación durante la carrera, competencia con rivales simulados, asignación de paralelo y trabajo con el docente.
- **Graduación:** excelencia sin reprobaciones y promedio mayor que 65, o tesis/proyecto con defensa. Concluir materias no entrega automáticamente el título.
- **Campus gráfico:** navegación común entre materias, malla, trámites, historial, auxiliatura y graduación. La matrícula, los documentos, las solicitudes y las defensas se realizan con botones y formularios.
- **Exploración:** F10 conserva una consola opcional; `/desbloquear todo` habilita las materias sin aprobarlas automáticamente. No hace falta utilizar comandos para el recorrido normal.
- **Guardado:** tres espacios individuales, archivo temporal y respaldo `.bak`; se migran las materias conocidas de partidas antiguas sin inventar sus notas. Los archivos multijugador anteriores se conservan sin cargarlos como modo jugable.
- **Interfaz:** contenido desplazable con navegación y regreso visibles, columnas adaptables, texto 80–120%, repaso libre, malla con estados y teclado, y modelos interactivos de estudio.
- **Sin audio.** Solo local.

## Estructura

```text
game/
  project.godot
  scenes/main.tscn
  scripts/game.gd
  scripts/student_campus.gd
  scripts/study_demo.gd
  scripts/study_model.gd
  scripts/catalog.gd
  scripts/student_simulation.gd
  scripts/simulation_procedures.gd
  scripts/simulation_commands.gd
  scripts/simulation_save_store.gd
  scripts/achievement_catalog.gd
  tests/
  assets/campus_vector.svg
  build/           (ejecutable/exportado)
```

## Base de datos

**No es necesaria para este juego.** Usa archivos JSON en `user://partidas/`. El PostgreSQL/Django solo aplica al sistema académico (`backend/`), que se mantiene intacto.

Las reglas están en `docs/SIMULACION_ESTUDIANTE.md`. La integración gráfica y sus verificaciones se documentan en `docs/PENDIENTES_FRONTEND_SIMULACION.md`.

## Verificar la interfaz

```powershell
game\.tools\Godot_v4.7.2-stable_win64_console.exe --headless --path game --script res://tests/test_frontend_campus.gd
```

La prueba usa partidas ficticias y no lee ni escribe las partidas del jugador. `tests/capture_frontend.gd` genera capturas con el renderizador real, también con datos aislados, en `game/.test-artifacts/frontend/`. Necesita un entorno gráfico; no se ejecuta con `--headless`.
