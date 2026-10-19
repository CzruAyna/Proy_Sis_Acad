# Sistema de Gestión Académica

Monorepo para un sistema de gestión académica universitaria. El proyecto prioriza la libertad del estudiante para organizar su horario, el control de cupos, las reglas de avance curricular y la generación de documentos institucionales.

El desarrollo se realiza de forma local, sin Docker. El núcleo académico ya cuenta con modelos para carreras, planes de estudio, materias, prerrequisitos y periodos; estos datos se administran desde Django y se consultan desde la interfaz mediante la API.

## Tecnologías previstas

| Componente | Tecnología |
|---|---|
| API | Django 5, Django REST Framework y SimpleJWT |
| Base de datos | PostgreSQL 16 |
| Interfaz | Next.js 14, React y TypeScript |
| Estilos | Tailwind CSS |
| Documentos | LaTeX con `latexmk` (fase posterior) |

## Estructura

```text
backend/          API Django y módulos de dominio
frontend/         Aplicación Next.js
docs/             Especificación, reglas y modelo de datos
latex-templates/  Plantillas institucionales (fase posterior)
```

## Núcleo académico

El catálogo conecta carreras con sus planes de estudio y materias. Las materias pueden declarar prerrequisitos o corequisitos; el sistema evita relaciones duplicadas, autorreferencias y ciclos en la malla. Los periodos académicos incluyen semestres ordinarios, anuales, verano, invierno y mesas. La oferta académica permite administrar aulas, docentes habilitados, paralelos y sesiones semanales, y publica los paralelos abiertos desde la API.

La API publica las consultas de carreras, mallas, materias, periodos y paralelos abiertos. La portada consume estos endpoints y presenta planes, materias agrupadas por semestre, requisitos y oferta semanal de paralelos, con cupos actuales. Las inscripciones autenticadas permiten que cada estudiante reserve un asiento, pase al siguiente paralelo cuando el elegido se llena y retire su propia inscripción.

## Documentación del proyecto

La especificación funcional está en [`docs/ESPECIFICACION_FUNCIONAL.md`](docs/ESPECIFICACION_FUNCIONAL.md). Las reglas están resumidas en [`docs/REGLAS_NEGOCIO.md`](docs/REGLAS_NEGOCIO.md), las entidades en [`docs/MODELO_DATOS.md`](docs/MODELO_DATOS.md) y las fases previstas en [`docs/ROADMAP.md`](docs/ROADMAP.md).

## Licencia

Este proyecto se distribuye bajo la licencia MIT. Consulta [`LICENSE`](LICENSE).
