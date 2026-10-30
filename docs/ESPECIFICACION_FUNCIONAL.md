# ENUNCIADO MAESTRO v2.0 — Sistema de Gestión Académica Open Source

> **Alcance histórico — revisión del 30/10/2026.** Este enunciado conserva la
> especificación de la etapa del sistema académico web. Las instrucciones
> vigentes para trabajar en el repositorio son [AGENTS.md](../AGENTS.md) y
> [REGLAS_USUARIO.txt](../REGLAS_USUARIO.txt). El producto principal es el
> juego Godot; sus reglas se describen en
> [SIMULACION_ESTUDIANTE.md](SIMULACION_ESTUDIANTE.md). La denominación
> «fuente única» del texto original corresponde a aquella etapa y no
> sustituye las reglas permanentes actuales.

> Documento de especificación funcional y técnica. Es la fuente única de verdad del proyecto.
> El desarrollo es 100% LOCAL, SIN Docker. El código no lleva comentarios.
> Los tests referencian los IDs de reglas de negocio (R1–R13) documentados en docs/REGLAS_NEGOCIO.md.

---

## 1. Visión General

Sistema de gestión académica universitaria open source que prioriza:

- La libertad de cátedra y del estudiante (el estudiante puede armar su horario incluso con choques, bajo su responsabilidad).
- Automatización inteligente de horarios basada en rendimiento académico.
- Generación de documentos institucionales en LaTeX compilados a PDF.
- Control estricto de cupos físicos y de prerrequisitos en forma de nodos.

## 2. Stack Tecnológico (decisiones fijadas, no re-discutir)

| Capa | Tecnología |
|---|---|
| Backend | Django 5 + Django REST Framework, Python 3.12 |
| Base de datos | PostgreSQL 16 |
| Frontend | Next.js 14 (App Router) + TypeScript + TailwindCSS |
| Autenticación | djangorestframework-simplejwt (JWT) |
| Documentos | LaTeX compilado con latexmk → PDF (MiKTeX en Windows, MacTeX en macOS, TeX Live en Linux) |
| Tests | pytest + pytest-django |
| Infraestructura | Desarrollo local directo (sin contenedores). Servidores: `python manage.py runserver` y `npm run dev` |

Notas técnicas fijadas:

- NO se usa Celery ni Redis en las fases iniciales. La compilación de PDF se ejecuta de forma síncrona (subprocess). Celery podrá introducirse en fases avanzadas si el volumen lo justifica.
- Producción futura (fuera del alcance inicial): gunicorn + nginx.
- El admin de Django se usa como herramienta operativa interna (cargar mallas, aulas, docentes, abrir paralelos).
- Configuración por variables de entorno con python-dotenv, archivo `.env` en la raíz del repo (nunca versionado), plantilla `.env.example` versionada.
- Settings divididos: `config/settings/base.py`, `dev.py`, `prod.py`.
- `AUTH_USER_MODEL = "usuarios.Usuario"` con Usuario custom (AbstractUser) y campo `rol`.

## 3. Estructura del Repositorio (monorepo)

    sistema-academico/
    ├── .vscode/extensions.json
    ├── .vscode/settings.json
    ├── backend/
    │   ├── manage.py
    │   ├── requirements.txt
    │   ├── requirements-dev.txt
    │   ├── config/
    │   │   ├── __init__.py
    │   │   ├── urls.py
    │   │   ├── wsgi.py
    │   │   ├── asgi.py
    │   │   └── settings/
    │   │       ├── __init__.py
    │   │       ├── base.py
    │   │       ├── dev.py
    │   │       └── prod.py
    │   └── apps/
    │       ├── usuarios/
    │       ├── academico/
    │       ├── oferta/
    │       ├── inscripciones/
    │       ├── horarios/
    │       ├── notas/
    │       ├── auxiliaturas/
    │       ├── permisos/
    │       └── documentos/
    ├── frontend/
    │   ├── package.json
    │   ├── next.config.mjs
    │   ├── tsconfig.json
    │   ├── tailwind.config.ts
    │   ├── postcss.config.mjs
    │   └── src/
    │       ├── app/
    │       │   ├── globals.css
    │       │   ├── layout.tsx
    │       │   └── page.tsx
    │       └── lib/api.ts
    ├── docs/
    │   ├── REGLAS_NEGOCIO.md
    │   └── MODELO_DATOS.md
    ├── latex-templates/
    │   ├── historial_academico.tex
    │   ├── carta_postulacion_auxiliatura.tex
    │   ├── acta_notas.tex
    │   └── carta_correccion.tex
    ├── .editorconfig
    ├── .env.example
    ├── .gitignore
    ├── LICENSE
    └── README.md

Responsabilidad de cada app backend:

| App | Contenido |
|---|---|
| usuarios | Usuario custom, roles, auth JWT |
| academico | Carrera, PlanEstudio, Materia, Prerrequisito, PeriodoAcademico |
| oferta | Aula, DocenteMateria, Paralelo, SesionClase, cupos |
| inscripciones | Motor de inscripción, prioridades, reglas R1–R8 |
| horarios | Generador automático de horarios y validaciones |
| notas | Acta, Nota, cierre bloqueante (R9) |
| auxiliaturas | Postulaciones, selección por notas (R10–R12) |
| permisos | PermisoEspecial temporal (R13) |
| documentos | Motor LaTeX → PDF y reportes |

## 4. Estructura Académica

### 4.1 Malla curricular como grafo

- Las materias son nodos; los prerrequisitos son aristas dirigidas (materia → requisito aprobado).
- Algunas materias son terminales: fin de un nodo, no desbloquean nada.
- El modelo `Prerrequisito` (M:N sobre sí misma) incluye flag `es_corequisito` para cursado simultáneo si se necesita.
- Una materia se considera DISPONIBLE solo cuando TODOS sus prerrequisitos están APROBADOS.

### 4.2 Materias extracurriculares

- Se vinculan opcionalmente a la malla del estudiante (`es_extracurricular=True`).
- NO afectan el avance de la malla, la obligatoriedad del plan ni el promedio.
- Aparecen en el horario e historial del estudiante pero marcadas como extracurriculares.

### 4.3 Temporalidad

- Periodos: `S1`, `S2` (semestrales), `ANUAL`, `VERANO`, `INVIERNO`, `MESA`.
- Cada periodo tiene `anio` y `orden` para calcular secuencias.
- "Semestre ordinario inmediato anterior" = último periodo S1/S2/ANUAL cerrado antes del actual. VERANO/INVIERNO/MESA nunca cuentan como "semestre anterior" para promedios.

### 4.4 Parámetros globales configurables

| Parámetro | Valor por defecto |
|---|---|
| NOTA_APROBACION | 51 (escala 0–100) |
| UMBRAL_PROMEDIO_7MA | 65 |
| MATERIAS_BASE | 6 |
| MAX_POSTULACIONES_AUXILIATURA | 3 |
| SEMESTRES_PERDIDA_PRIORIDAD | 1 |

### 4.5 Promedio ponderado (definición formal)

- promedio = Σ(nota_final × créditos) / Σ(créditos), sobre materias ORDINARIAS (S1/S2/ANUAL) del semestre ordinario inmediato anterior con nota registrada.
- Verano/Invierno/Mesa JAMÁS entran al promedio (cuentan solo como aprobadas para habilitar prerrequisitos y la 7ma materia).

## 5. Reglas de Negocio

| ID | Regla |
|---|---|
| R1 | 6 materias por defecto por estudiante |
| R2 | 7ma materia automática si promedio ponderado del semestre ordinario inmediato anterior ≥ 65 |
| R3 | Verano/Invierno/Mesa habilitan prerrequisitos y la 7ma, pero no modifican el promedio |
| R4 | Cupo físico estricto por paralelo; si se llena salta al siguiente paralelo; NO existen colas de espera |
| R5 | Apertura de paralelos es tarea exclusivamente administrativa |
| R6 | Máxima prioridad a estudiantes que tenían la materia desbloqueada y no obtuvieron cupo (retrasados) |
| R7 | Si el estudiante se inscribe y reprueba, pierde prioridad por 1 semestre completo en esa materia |
| R8 | El estudiante edita su horario libremente; los choques se permiten con advertencia visible, sin bloqueo |
| R9 | Acta cerrada = inmutable a nivel de modelo, API y admin; corrección solo por trámite formal o rol administrativo |
| R10 | Máximo 3 postulaciones a auxiliatura por estudiante |
| R11 | Selección de auxiliares por notas: mejor promedio → Paralelo A, segundo → Paralelo B, etc. |
| R12 | La carta de postulación a auxiliatura lista solo materias aprobadas ORDINARIAS (excluye verano/invierno/mesa) |
| R13 | El Encargado de Horarios otorga un permiso temporal específico (materia + periodo + fecha de expiración) para cursar materias adelantadas o cruzadas de otras carreras |

Desarrollo de reglas críticas:

- R2 (ejemplo): estudiante cursó 6 materias en S1-2024 con promedio ponderado 68 → en S2-2024 el sistema le agrega automáticamente una 7ma correlativa disponible. Con promedio 64 → solo 6.
- R3 (ejemplo): aprobó Cálculo I en VERANO con nota 90 → habilita Cálculo II, pero el 90 no entra al promedio del semestre ordinario.
- R4: el cupo máximo del paralelo se define dentro de la capacidad física del aula asignada. La inscripción usa `select_for_update` sobre el paralelo para que dos estudiantes nunca tomen el último cupo simultáneamente. Sin cupo en ningún paralelo → el estudiante queda marcado como RETRASADO (alimenta R6) y espera al siguiente semestre.
- R6 (ejemplo): la materia X estaba desbloqueada en S1-2024 pero todos los paralelos se llenaron → en S2-2024 ese estudiante tiene prioridad máxima sobre quienes recién desbloquean X.
- R7 (ejemplo): se inscribió en X en S1-2024 y reprobó → en S2-2024 no puede usar prioridad en X; recupera prioridad en S1-2025.
- R11 (desempate): ordena por promedio ponderado ordinario; desempate por nota en la materia objetivo si la aprobó; segundo desempate por fecha de postulación.
- R13: el permiso NO modifica la malla ni el historial; solo habilita visualización e inscripción en ESA materia durante ese periodo. Expira automáticamente.

## 6. Horarios

- Generación automática inicial: cruza materias disponibles + correlativas + preferencias de docente. Estrategia MVP: greedy con backtracking sobre combinaciones de paralelos sin solapamiento. Si no existe combinación perfecta → asignación estándar sin preferencias. Fase avanzada: Google OR-Tools (CP-SAT).
- Teoría: horarios fijos por paralelo.
- Laboratorios: en aulas con `es_laboratorio=True`, cupo estricto, NO pueden chocar con la teoría de su propio paralelo. Si inscriptos > capacidad del laboratorio → se divide en `grupo_lab` 1..N con sesiones distintas.
- Un administrativo define qué materias puede dictar cada docente (modelo `DocenteMateria`); a partir de ahí el sistema sugiere horario óptimo de laboratorio.
- Una vez generado, el estudiante modifica libremente (R8). El motor nunca genera choques, pero la edición manual solo advierte, no bloquea.
- Retiro de inscripción existe como estado `RETIRADA` con gestión administrativa.

## 7. Calificaciones y Actas

- El docente carga notas completando campos directamente en el sistema, formato limpio, sin archivos externos, sin modificaciones libres fuera del periodo de carga.
- Estados del Acta: ABIERTA → CERRADA. El cierre la bloquea por completo (modelo, API y admin).
- Corrección de acta cerrada: trámite formal con carta LaTeX, examen de mesa según corresponda, o intervención directa de un rol administrativo autorizado. Toda corrección queda auditada.

## 8. Roles y Permisos

| Acción | Estudiante | Docente | Auxiliar | Encargado Horarios | Admin/Director |
|---|---|---|---|---|---|
| Ver malla propia | Sí | — | — | — | Sí (cualquiera) |
| Editar horario propio (con choques) | Sí | — | — | — | — |
| Cargar notas (periodo abierto) | — | Sí | — | — | — |
| Cerrar acta | — | Sí | — | — | — |
| Reabrir/corregir acta cerrada | — | — | — | — | Sí |
| Abrir paralelos / gestionar cupos | — | — | — | — | Sí |
| Definir materias que dicta cada docente | — | — | — | — | Sí |
| Otorgar permiso especial temporal | — | — | — | Sí | — |
| Postular a auxiliatura (máx 3) | Sí | — | — | — | — |
| Subir plan de estudio | — | — | — | — | Sí |

Implementación: grupos y permisos de Django + validaciones a nivel de servicio.

## 9. Auxiliares de Cátedra

- Existe un auxiliar por paralelo SOLO en materias con `lleva_auxiliatura=True` (ej: Auxiliar para Mat 1 Paralelo A, otro para Paralelo B).
- Máximo 3 postulaciones activas por estudiante (R10).
- Selección automática al cerrar la convocatoria: mejor promedio → Paralelo A, segundo → Paralelo B (R11).
- El sistema genera la carta de postulación formal en LaTeX/PDF con todas las materias aprobadas ordinarias del postulante (R12).
- Los auxiliares eligen libremente sus horarios de ayudantía, coordinando aulas/laboratorios SIN control estricto de cupos institucionales (sesiones tipo AYUDANTIA).
- La nota de auxiliatura se registra en el sistema y alimenta la calificación final que consolida y cierra el docente titular; el titular define el peso antes del cierre de notas.

## 10. Modelo de Datos (entidades y campos clave)

- **Usuario** (AbstractUser): ci (unique), rol (ESTUDIANTE | DOCENTE | AUXILIAR | ENCARGADO_HORARIOS | DIRECTOR | ADMIN)
- **Carrera**: nombre, codigo
- **PlanEstudio**: carrera (FK), nombre, vigente (bool)
- **Materia**: plan (FK), codigo (unique), nombre, creditos, semestre_sugerido, es_extracurricular (bool), lleva_auxiliatura (bool)
- **Prerrequisito**: materia (FK), requisito (FK), es_corequisito (bool)
- **PeriodoAcademico**: tipo (S1|S2|ANUAL|VERANO|INVIERNO|MESA), anio, orden, activo
- **Aula**: nombre, capacidad, es_laboratorio (bool)
- **DocenteMateria**: docente (FK), materia (FK)
- **Paralelo**: materia (FK), periodo (FK), identificador (A, B, C…), docente (FK null), auxiliar (FK a Usuario, null), cupo_maximo, inscriptos, abierto (bool)
- **SesionClase**: paralelo (FK), tipo (TEORIA|LABORATORIO|AYUDANTIA), grupo_lab (int, default 1), aula (FK), dia (1–7), hora_inicio, hora_fin
- **Inscripcion**: estudiante (FK), paralelo (FK), estado (CURSANDO|APROBADA|REPROBADA|RETIRADA), origen (ORDINARIA|VERANO|INVIERNO|MESA|PERMISO_ESPECIAL|AUTO_7MA)
- **PrioridadEstudiante**: estudiante (FK), materia (FK), retrasado_desde (FK Periodo), suspendido_hasta (FK Periodo, null)
- **Acta**: paralelo (OneToOne), cerrada (bool), cerrada_en (datetime null)
- **Nota**: acta (FK), inscripcion (OneToOne), puntaje (decimal 0–100)
- **PostulacionAuxiliatura**: estudiante (FK), paralelo (FK), estado (POSTULADO|SELECCIONADO|RECHAZADO), fecha
- **PermisoEspecial**: estudiante (FK), materia (FK), periodo (FK), otorgado_por (FK Usuario), fecha_expiracion, motivo
- **DocumentoGenerado**: tipo, estudiante (FK null), archivo_pdf (path), creado_en

## 11. API REST (esbozo)

- POST /api/token/ y /api/token/refresh/ (JWT)
- GET /api/health/
- GET /api/mallas/, /api/materias/?plan=, /api/periodos/
- GET /api/paralelos/?periodo=
- GET /api/inscripciones/ | POST /api/inscripciones/ | DELETE /api/inscripciones/{id}/
- POST /api/inscripciones/horario-sugerido/
- GET /api/mis-materias-disponibles/
- GET/PUT /api/notas/?paralelo= | POST /api/actas/{id}/cerrar/
- GET/POST /api/auxiliaturas/postulaciones/ | GET /api/auxiliaturas/postulaciones/{id}/carta/
- GET /api/documentos/historial/{estudiante}/ | /api/documentos/seguimiento/{estudiante}/
- GET/POST /api/permisos-especiales/

## 12. Diseño UI/UX

- Paleta: blanco, negro y grises de papel e impresión; textura sutil de hoja, líneas de cuaderno y margen editorial.
- Tipografía: serif editorial para títulos y sans-serif legible para datos e interfaz.
- Pantallas principales:
  1. Login: formulario centrado, autenticación JWT contra la API.
  2. Dashboard estudiante: tarjeta de promedio ponderado, materias en curso, % de avance de malla, acciones rápidas.
  3. Malla curricular: tarjetas agrupadas por semestre con estados coloreados (aprobada verde, reprobada rojo, disponible azul, bloqueada gris, extracurricular violeta).
  4. Horario semanal: grilla Lunes–Domingo × horas, bloques de color por materia; badge amarillo de advertencia cuando hay choque (sin bloqueo).
  5. Inscripción: lista de materias disponibles con paralelos, docente y cupo (x/y); al llenarse muestra "Sin cupo" y el motor salta al siguiente paralelo.
  6. Panel docente: sus paralelos, acta con inputs de nota, botón "Cerrar acta" con modal de confirmación; tras cerrar, vista solo lectura con ícono de candado.
  7. Auxiliaturas: convocatorias abiertas, contador de postulaciones usadas (n/3), descarga de carta PDF.
  8. Admin Django: registrado y customizado para operación interna.

## 13. Roadmap por Fases

| Fase | Contenido | Entregable |
|---|---|---|
| F0 | Entorno local, repo GitHub, auth JWT, roles, Usuario custom, frontend base | Login funcional end-to-end |
| F1 | academico: Carrera, Plan, Materia, Prerrequisitos (grafo), Periodos | Admin carga malla completa |
| F2 | oferta: Aulas, Paralelos, SesionClase, cupos, validador de solapamientos | Oferta académica de un periodo |
| F3 | inscripciones + horarios: R1–R8, motor de prioridades, horario sugerido, edición libre | Estudiante recibe y edita horario |
| F4 | notas: carga, cierre bloqueante R9, corrección formal | Actas operativas |
| F5 | auxiliaturas + LaTeX: R10–R12, carta PDF | Flujo completo de auxiliatura |
| F6 | permisos: R13, solicitud y otorgamiento temporal | Flujo de excepciones |
| F7 | reportes LaTeX (historial, seguimiento), pulido UI, docs | v1.0 |

Cada fase termina con tests pytest de las reglas incluidas, nombrados con el ID (ej: test_r2_septima_materia_con_promedio_65).

## 14. Convenciones del Proyecto

- Código SIN comentarios.
- Identificadores de código en inglés; labels y textos de UI en español.
- Commits convencionales: feat | fix | docs | chore | refactor | test.
- Flujo Git: rama main protegida, trabajo en feature/nombre, Pull Requests.
- `.env` nunca versionado; `.env.example` siempre actualizado.
- Toda regla de negocio se documenta en docs/REGLAS_NEGOCIO.md con su ID antes de implementarse.

## 15. Criterios de Aceptación v1.0

- Un estudiante nuevo recibe un horario de 6 materias automáticamente sin choques.
- Con promedio ≥ 65 recibe 7ma materia automáticamente; con < 65 no.
- Aprobar en verano habilita la correlativa pero no sube el promedio.
- Dos estudiantes que se inscriben al último cupo al mismo tiempo nunca generan sobre-cupo.
- Un retrasado del semestre anterior aparece primero en la cola de prioridad.
- Un reprobado pierde prioridad exactamente 1 semestre.
- El estudiante puede crear choques en su horario y el sistema solo advierte.
- Un acta cerrada no puede editarse por ningún medio salvo trámite autorizado y auditado.
- La carta de auxiliatura se descarga en PDF y lista solo materias ordinarias aprobadas.
- El permiso especial permite inscribirse solo en la materia autorizada y expira solo.
