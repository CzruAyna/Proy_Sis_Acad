"use client";

import { useEffect, useState } from "react";

interface PlanEstudio {
  id: number;
  carrera: number;
  carrera_codigo: string;
  carrera_nombre: string;
  nombre: string;
  vigente: boolean;
  cantidad_materias: number;
}

interface Prerrequisito {
  id: number;
  codigo: string;
  nombre: string;
  es_corequisito: boolean;
}

interface Materia {
  id: number;
  codigo: string;
  nombre: string;
  creditos: string;
  semestre_sugerido: number;
  es_extracurricular: boolean;
  lleva_auxiliatura: boolean;
  prerrequisitos: Prerrequisito[];
}

interface PeriodoAcademico {
  id: number;
  tipo_display: string;
  anio: number;
  orden: number;
  activo: boolean;
}

type EstadoCatalogo = "cargando" | "listo" | "error";

const apiUrl = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8000";

export function CatalogoAcademico() {
  const [planes, setPlanes] = useState<PlanEstudio[]>([]);
  const [periodos, setPeriodos] = useState<PeriodoAcademico[]>([]);
  const [materias, setMaterias] = useState<Materia[]>([]);
  const [planSeleccionado, setPlanSeleccionado] = useState("");
  const [estado, setEstado] = useState<EstadoCatalogo>("cargando");
  const [estadoMaterias, setEstadoMaterias] = useState<EstadoCatalogo>("listo");

  useEffect(() => {
    const controller = new AbortController();

    async function cargarCatalogo() {
      try {
        const [planesResponse, periodosResponse] = await Promise.all([
          fetch(`${apiUrl}/api/mallas/`, { signal: controller.signal }),
          fetch(`${apiUrl}/api/periodos/`, { signal: controller.signal }),
        ]);

        if (!planesResponse.ok || !periodosResponse.ok) {
          throw new Error("No fue posible consultar el catálogo académico.");
        }

        const [planesData, periodosData] = await Promise.all([
          planesResponse.json() as Promise<PlanEstudio[]>,
          periodosResponse.json() as Promise<PeriodoAcademico[]>,
        ]);

        setPlanes(planesData);
        setPeriodos(periodosData);
        setPlanSeleccionado(planesData[0] ? String(planesData[0].id) : "");
        setEstado("listo");
      } catch {
        if (!controller.signal.aborted) {
          setEstado("error");
        }
      }
    }

    void cargarCatalogo();
    return () => controller.abort();
  }, []);

  useEffect(() => {
    if (!planSeleccionado) {
      setMaterias([]);
      return;
    }

    const controller = new AbortController();

    async function cargarMaterias() {
      setEstadoMaterias("cargando");
      try {
        const response = await fetch(
          `${apiUrl}/api/materias/?plan=${planSeleccionado}`,
          { signal: controller.signal },
        );

        if (!response.ok) {
          throw new Error("No fue posible consultar las materias.");
        }

        const data = (await response.json()) as Materia[];
        setMaterias(data);
        setEstadoMaterias("listo");
      } catch {
        if (!controller.signal.aborted) {
          setEstadoMaterias("error");
        }
      }
    }

    void cargarMaterias();
    return () => controller.abort();
  }, [planSeleccionado]);

  const planActual = planes.find(
    (plan) => String(plan.id) === planSeleccionado,
  );
  const semestres = Array.from(new Set(materias.map((materia) => materia.semestre_sugerido))).sort(
    (a, b) => a - b,
  );
  const periodosOrdenados = [...periodos].sort(
    (a, b) => b.anio - a.anio || a.orden - b.orden,
  );

  return (
    <section aria-labelledby="catalog-title" className="catalog-section" id="catalogo">
      <div className="catalog-heading">
        <div>
          <p className="eyebrow">MALLA <span className="index-dash">/</span> REGISTRO ACADÉMICO</p>
          <h2 id="catalog-title">El catálogo académico.</h2>
          <p className="catalog-intro">
            Planes de estudio y materias consultados directamente desde el sistema.
          </p>
        </div>
        <span className="catalog-index">CONSULTA EN VIVO <span aria-hidden="true">↗</span></span>
      </div>

      {estado === "cargando" && (
        <p aria-live="polite" className="catalog-message">Consultando el catálogo…</p>
      )}

      {estado === "error" && (
        <p aria-live="polite" className="catalog-message">
          El catálogo aparecerá aquí cuando la API académica esté disponible.
        </p>
      )}

      {estado === "listo" && (
        <>
          <div className="catalog-toolbar">
            {planes.length > 0 ? (
              <label className="plan-picker">
                <span>PLAN DE ESTUDIO</span>
                <select
                  aria-label="Seleccionar plan de estudio"
                  onChange={(event) => setPlanSeleccionado(event.target.value)}
                  value={planSeleccionado}
                >
                  {planes.map((plan) => (
                    <option key={plan.id} value={plan.id}>
                      {plan.carrera_codigo} — {plan.nombre}
                    </option>
                  ))}
                </select>
              </label>
            ) : (
              <p className="catalog-message catalog-message-inline">
                Todavía no se han registrado planes de estudio.
              </p>
            )}
            <div aria-label="Periodos académicos" className="period-strip">
              <span className="period-strip-label">PERIODOS</span>
              {periodosOrdenados.length > 0 ? (
                periodosOrdenados.slice(0, 3).map((periodo) => (
                  <span
                    className={`period-chip${periodo.activo ? " period-chip-active" : ""}`}
                    key={periodo.id}
                  >
                    {periodo.tipo_display} {periodo.anio}
                    {periodo.activo && <span className="period-dot" />}
                  </span>
                ))
              ) : (
                <span className="period-empty">Sin periodos</span>
              )}
            </div>
          </div>

          {planActual && (
            <div className="plan-summary">
              <div>
                <span className="plan-code">{planActual.carrera_codigo}</span>
                <h3>{planActual.carrera_nombre}</h3>
                <p>{planActual.nombre}{planActual.vigente ? " · Vigente" : " · No vigente"}</p>
              </div>
              <span className="subject-count">
                <strong>{planActual.cantidad_materias}</strong>
                <span>materias<br />registradas</span>
              </span>
            </div>
          )}

          {estadoMaterias === "cargando" && (
            <p aria-live="polite" className="catalog-message">Cargando materias…</p>
          )}

          {estadoMaterias === "error" && (
            <p aria-live="polite" className="catalog-message">
              No se pudieron cargar las materias de este plan.
            </p>
          )}

          {estadoMaterias === "listo" && materias.length === 0 && planActual && (
            <p className="catalog-message">Este plan todavía no tiene materias registradas.</p>
          )}

          {estadoMaterias === "listo" && materias.length > 0 && (
            <div className="semester-list">
              {semestres.map((semestre) => (
                <section aria-labelledby={`semestre-${semestre}`} className="semester-group" key={semestre}>
                  <div className="semester-heading">
                    <h4 id={`semestre-${semestre}`}>Semestre {semestre}</h4>
                    <span>{materias.filter((materia) => materia.semestre_sugerido === semestre).length} MATERIAS</span>
                  </div>
                  <div className="subject-list">
                    {materias
                      .filter((materia) => materia.semestre_sugerido === semestre)
                      .map((materia) => (
                        <article className="subject-row" key={materia.id}>
                          <span className="subject-code">{materia.codigo}</span>
                          <div className="subject-main">
                            <h5>{materia.nombre}</h5>
                            {materia.prerrequisitos.length > 0 && (
                              <p className="prerequisite-list">
                                {materia.prerrequisitos.map((requisito) => (
                                  <span key={requisito.id}>
                                    {requisito.es_corequisito ? "Corequisito" : "Requiere"}: {requisito.codigo}
                                  </span>
                                ))}
                              </p>
                            )}
                          </div>
                          <div className="subject-meta">
                            <span>{materia.creditos} CR</span>
                            {materia.es_extracurricular && <span>EXTRACURRICULAR</span>}
                            {materia.lleva_auxiliatura && <span>CON AUXILIATURA</span>}
                          </div>
                        </article>
                      ))}
                  </div>
                </section>
              ))}
            </div>
          )}
        </>
      )}
    </section>
  );
}
