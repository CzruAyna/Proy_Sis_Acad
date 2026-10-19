"use client";

import { useEffect, useState } from "react";

interface PeriodoAcademico {
  id: number;
  tipo_display: string;
  anio: number;
  activo: boolean;
}

interface SesionClase {
  id: number;
  tipo_display: string;
  grupo_lab: number;
  aula: string;
  dia_display: string;
  hora_inicio: string;
  hora_fin: string;
}

interface Paralelo {
  id: number;
  materia_codigo: string;
  materia_nombre: string;
  identificador: string;
  docente_nombre: string;
  cupo_maximo: number;
  inscriptos_actuales: number;
  cupos_disponibles: number;
  sesiones: SesionClase[];
}

type Estado = "cargando" | "listo" | "error";

const apiUrl = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8000";

export function OfertaAcademica() {
  const [periodos, setPeriodos] = useState<PeriodoAcademico[]>([]);
  const [periodoId, setPeriodoId] = useState("");
  const [paralelos, setParalelos] = useState<Paralelo[]>([]);
  const [estado, setEstado] = useState<Estado>("cargando");

  useEffect(() => {
    const controller = new AbortController();

    async function cargarPeriodos() {
      try {
        const response = await fetch(`${apiUrl}/api/periodos/`, { signal: controller.signal });
        if (!response.ok) throw new Error();
        const data = (await response.json()) as PeriodoAcademico[];
        setPeriodos(data);
        const seleccionado = data.find((periodo) => periodo.activo) ?? data[0];
        if (seleccionado) setPeriodoId(String(seleccionado.id));
        else setEstado("listo");
      } catch {
        if (!controller.signal.aborted) setEstado("error");
      }
    }

    void cargarPeriodos();
    return () => controller.abort();
  }, []);

  useEffect(() => {
    if (!periodoId) return;
    const controller = new AbortController();

    async function cargarOferta() {
      setEstado("cargando");
      try {
        const response = await fetch(`${apiUrl}/api/paralelos/?periodo=${periodoId}`, {
          signal: controller.signal,
        });
        if (!response.ok) throw new Error();
        setParalelos((await response.json()) as Paralelo[]);
        setEstado("listo");
      } catch {
        if (!controller.signal.aborted) setEstado("error");
      }
    }

    void cargarOferta();
    return () => controller.abort();
  }, [periodoId]);

  const periodoSeleccionado = periodos.find((periodo) => String(periodo.id) === periodoId);

  return (
    <section aria-labelledby="oferta-title" className="offer-section" id="oferta">
      <div className="catalog-heading">
        <div>
          <p className="eyebrow">OFERTA <span className="index-dash">/</span> PROGRAMACIÓN SEMANAL</p>
          <h2 id="oferta-title">Paralelos y horarios.</h2>
          <p className="catalog-intro">Aulas, docentes y sesiones de los paralelos habilitados.</p>
        </div>
        <span className="catalog-index">CONSULTA PÚBLICA <span aria-hidden="true">↗</span></span>
      </div>

      {periodos.length > 0 && (
        <label className="offer-period-picker">
          <span>PERIODO ACADÉMICO</span>
          <select aria-label="Seleccionar periodo académico" value={periodoId} onChange={(event) => setPeriodoId(event.target.value)}>
            {periodos.map((periodo) => (
              <option key={periodo.id} value={periodo.id}>
                {periodo.tipo_display} {periodo.anio}{periodo.activo ? " · Activo" : ""}
              </option>
            ))}
          </select>
        </label>
      )}

      {estado === "cargando" && <p aria-live="polite" className="catalog-message">Consultando paralelos…</p>}
      {estado === "error" && <p aria-live="polite" className="catalog-message">No se pudo consultar la oferta académica.</p>}
      {estado === "listo" && periodos.length === 0 && <p className="catalog-message">Todavía no hay periodos académicos registrados.</p>}
      {estado === "listo" && periodos.length > 0 && paralelos.length === 0 && (
        <p className="catalog-message">No hay paralelos abiertos para {periodoSeleccionado?.tipo_display} {periodoSeleccionado?.anio}.</p>
      )}
      {estado === "listo" && paralelos.length > 0 && (
        <div className="offer-grid">
          {paralelos.map((paralelo) => (
            <article className="offer-card" key={paralelo.id}>
              <div className="offer-card-heading">
                <span className="subject-code">{paralelo.materia_codigo}</span>
                <span className="offer-parallel">PARALELO {paralelo.identificador}</span>
              </div>
              <h3>{paralelo.materia_nombre}</h3>
              <p className="offer-teacher">Docente · {paralelo.docente_nombre}</p>
              <div className="offer-capacity">
                <span>DISPONIBLES / CUPO MÁXIMO</span>
                <strong>{paralelo.cupos_disponibles} / {paralelo.cupo_maximo}</strong>
              </div>
              {paralelo.sesiones.length > 0 ? (
                <ul className="offer-sessions">
                  {paralelo.sesiones.map((sesion) => (
                    <li key={sesion.id}>
                      <span>{sesion.dia_display}</span>
                      <span>{sesion.hora_inicio.slice(0, 5)}–{sesion.hora_fin.slice(0, 5)}</span>
                      <span>{sesion.tipo_display}{sesion.tipo_display === "Laboratorio" ? ` ${sesion.grupo_lab}` : ""}</span>
                      <span>{sesion.aula}</span>
                    </li>
                  ))}
                </ul>
              ) : <p className="offer-no-sessions">Horario pendiente de publicación.</p>}
            </article>
          ))}
        </div>
      )}
    </section>
  );
}
