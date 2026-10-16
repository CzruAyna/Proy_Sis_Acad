# Sistema de Gestión Académica

Monorepo para un sistema de gestión académica universitaria. El proyecto prioriza la libertad del estudiante para organizar su horario, el control de cupos, las reglas de avance curricular y la generación de documentos institucionales.

El desarrollo inicial se realiza de forma local, sin Docker. El repositorio está en etapa de inicio: la estructura y la documentación establecen la base para implementar los módulos por fases.

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

## Documentación del proyecto

La especificación funcional está en [`docs/ESPECIFICACION_FUNCIONAL.md`](docs/ESPECIFICACION_FUNCIONAL.md). Las reglas están resumidas en [`docs/REGLAS_NEGOCIO.md`](docs/REGLAS_NEGOCIO.md), las entidades en [`docs/MODELO_DATOS.md`](docs/MODELO_DATOS.md) y las fases previstas en [`docs/ROADMAP.md`](docs/ROADMAP.md).

## Licencia

Este proyecto se distribuye bajo la licencia MIT. Consulta [`LICENSE`](LICENSE).
