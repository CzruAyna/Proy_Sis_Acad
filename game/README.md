# SIS-INF

Juego de escritorio para Windows hecho con Godot 4.7.2 (GDScript). Simula el recorrido individual de un estudiante por la carrera: materias, trámites, auxiliatura y graduación.

El sistema académico Django/Next.js de este repositorio queda separado y no se modifica por este juego.

## Ejecutar

Desde la raíz del repositorio:

```powershell
godot --path game
```

Versión exportada: `game/build/SIS-INF.exe`.

## Exportar

También desde la raíz del repositorio:

```powershell
godot --headless --path game --export-release "Windows Desktop" "build/SIS-INF.exe"
```

Requisitos y pasos completos en [`../docs/DESARROLLO_LOCAL.md`](../docs/DESARROLLO_LOCAL.md).

## Estado

- **Estudiante:** nombre obligatorio, primer semestre con materias asignadas automáticamente y planificación desde el segundo; resultados mixtos, reprobadas obligatorias, correlativas con sus regulares e historial de intentos.
- **Logros globales:** catálogo completo de logros públicos pendientes/desbloqueados y logros ocultos que se revelan al conseguirlos. Se conservan entre recorridos.
- **Trámites:** matrícula, carta, materia externa, cambio de carrera K-03 y cambio de mención K-02.
- **Auxiliatura:** postulación durante la carrera, competencia con rivales simulados, asignación de paralelo y trabajo con el docente.
- **Graduación:** excelencia sin reprobaciones y promedio mayor que 65, o tesis/proyecto con defensa. Concluir materias no entrega automáticamente el título.
- **Campus gráfico:** navegación común entre materias, malla, trámites, historial, auxiliatura y graduación. La matrícula, los documentos, las solicitudes y las defensas se realizan con botones y formularios.
- **Exploración:** F10 conserva una consola opcional; `/desbloquear todo` habilita las materias sin aprobarlas automáticamente. No hace falta utilizar comandos para el recorrido normal.
- **Guardado:** tres espacios individuales, archivo temporal y respaldo `.bak`; se migran las materias conocidas de partidas antiguas sin inventar sus notas. Los archivos multijugador anteriores se conservan sin cargarlos como modo jugable.
- **Interfaz:** contenido paginado con botones de navegación y regreso, sin rueda, barras de desplazamiento ni deslizadores; incluye columnas adaptables, texto 80–120%, repaso libre, malla con estados y teclado, y modelos interactivos de estudio.
- **Identidad visual:** Sistemas azul e Informática roja; fondos oscuros temáticos para las cinco menciones, grafos, ecuaciones y controles con resplandor neón. Detalle en `docs/DISENO_VISUAL_CAMPUS.md`.
- **Sin audio.** Solo local.

## Exploración espacial

**Explorar la facultad** abre el campus pixel art con nombre obligatorio.
WASD o flechas mueven al personaje; Shift permite correr; E interactúa con
puertas y tableros. P abre progreso y M el mapa. Desde una partida también
se accede con **Explorar FNI** y **Caminar por la FNI**; posición y visitas
se guardan junto con el perfil. La visita libre dura la sesión.

El plano y el logo fueron aportados por el usuario. Los interiores son
recreaciones y quedan pendientes de referencias reales. Los controles,
recordatorios de decoración, fuentes y pendientes se detallan en
[Exploración FNI](../docs/EXPLORACION_FNI.md).

## Historia demostrativa

En el menú, **Historia de una carrera** permite generar un recorrido ficticio
con nombre, carrera, mención y enfoque. Incluye resultados aleatorios,
recuperación de materias, auxiliatura y titulación, con capítulos, grafos y
modelos didácticos. No cambia partidas ni logros. El nombre personaliza el
relato y no predice rendimiento. Detalles y análisis de mejoras en
`docs/MODULO_HISTORIA_CARRERA.md`.

Los grafos permiten **Mover: esfera/rama**, giro de rama con **↻**, cámara,
zoom y encuadre de toda la distribución, conservando la protección de aristas.

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

Desde la raíz y con Godot disponible en `PATH`:

```powershell
godot --headless --path game --script res://tests/test_frontend_campus.gd
```

La prueba usa partidas ficticias y no lee ni escribe las partidas del jugador. `tests/capture_frontend.gd` genera capturas con el renderizador real, también con datos aislados, en `game/.test-artifacts/frontend/`. Necesita un entorno gráfico; no se ejecuta con `--headless`.
