"use client";

import { useEffect, useState, type FormEvent } from "react";

interface RegistroActa {
  id: number;
  estudiante_id: number;
  estudiante: string;
  estado: string;
  puntaje: string | null;
}

interface Acta {
  id: number;
  paralelo_codigo: string;
  paralelo_materia: string;
  paralelo_identificador: string;
  periodo: string;
  docente: string;
  cerrada: boolean;
  cerrada_en: string | null;
  cerrada_por_nombre: string | null;
  inscripciones: RegistroActa[];
}

const apiUrl = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8000";

async function errorDe(response: Response) {
  try {
    const cuerpo = (await response.json()) as Record<string, unknown>;
    return Object.values(cuerpo).flat().join(" ");
  } catch {
    return `La operación no pudo completarse (${response.status}).`;
  }
}

async function solicitarConToken(
  access: string,
  refresh: string,
  path: string,
  options: RequestInit,
  renovar: (access: string) => void,
  expirar: () => void,
) {
  const headers = new Headers(options.headers);
  headers.set("Authorization", `Bearer ${access}`);
  let response = await fetch(`${apiUrl}${path}`, { ...options, headers });
  if (response.status !== 401 || !refresh) return response;

  const refreshResponse = await fetch(`${apiUrl}/api/token/refresh/`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ refresh }),
  });
  if (!refreshResponse.ok) {
    expirar();
    return response;
  }

  const tokens = (await refreshResponse.json()) as { access: string };
  renovar(tokens.access);
  headers.set("Authorization", `Bearer ${tokens.access}`);
  response = await fetch(`${apiUrl}${path}`, { ...options, headers });
  return response;
}

export function ActasDocente() {
  const [usuario, setUsuario] = useState("");
  const [contrasena, setContrasena] = useState("");
  const [access, setAccess] = useState("");
  const [refresh, setRefresh] = useState("");
  const [actas, setActas] = useState<Acta[]>([]);
  const [actaId, setActaId] = useState("");
  const [puntajes, setPuntajes] = useState<Record<number, string>>({});
  const [cargando, setCargando] = useState(false);
  const [mensaje, setMensaje] = useState("");

  const actaSeleccionada = actas.find((acta) => String(acta.id) === actaId);

  useEffect(() => {
    if (!access) return;
    let vigente = true;

    async function cargarActas() {
      setCargando(true);
      try {
        const response = await solicitarConToken(
          access,
          refresh,
          "/api/actas/",
          {},
          setAccess,
          () => {
            setAccess("");
            setRefresh("");
          },
        );
        if (!response.ok) throw new Error(await errorDe(response));
        const data = (await response.json()) as Acta[];
        if (vigente) {
          setActas(data);
          setActaId((actual) => data.some((acta) => String(acta.id) === actual) ? actual : String(data[0]?.id ?? ""));
          setMensaje(data.length ? "" : "No tienes actas asignadas para calificar.");
        }
      } catch (error) {
        if (vigente) setMensaje(error instanceof Error ? error.message : "No se pudieron consultar las actas.");
      } finally {
        if (vigente) setCargando(false);
      }
    }

    void cargarActas();
    return () => { vigente = false; };
  }, [access, refresh]);

  useEffect(() => {
    if (!actaSeleccionada) {
      setPuntajes({});
      return;
    }
    setPuntajes(Object.fromEntries(
      actaSeleccionada.inscripciones.map((registro) => [
        registro.id,
        registro.puntaje ?? "",
      ]),
    ));
  }, [actaSeleccionada]);

  async function ingresar(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setCargando(true);
    setMensaje("");
    try {
      const response = await fetch(`${apiUrl}/api/token/`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username: usuario, password: contrasena }),
      });
      if (!response.ok) throw new Error("No se pudo iniciar sesión con esos datos.");
      const tokens = (await response.json()) as { access: string; refresh: string };
      setAccess(tokens.access);
      setRefresh(tokens.refresh);
      setContrasena("");
    } catch (error) {
      setMensaje(error instanceof Error ? error.message : "No se pudo iniciar sesión.");
    } finally {
      setCargando(false);
    }
  }

  function cambiarActa(acta: Acta) {
    setActas((actuales) => actuales.map((actual) => actual.id === acta.id ? acta : actual));
  }

  async function guardarNotas() {
    if (!actaSeleccionada) return;
    setCargando(true);
    setMensaje("");
    try {
      const notas = actaSeleccionada.inscripciones
        .filter((registro) => puntajes[registro.id] !== "")
        .map((registro) => ({ inscripcion_id: registro.id, puntaje: puntajes[registro.id] }));
      const response = await solicitarConToken(
        access,
        refresh,
        `/api/actas/${actaSeleccionada.id}/notas/`,
        { method: "PUT", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ notas }) },
        setAccess,
        () => { setAccess(""); setRefresh(""); },
      );
      if (!response.ok) throw new Error(await errorDe(response));
      const data = (await response.json()) as { guardadas: number; acta: Acta };
      cambiarActa(data.acta);
      setMensaje(`Se guardaron ${data.guardadas} calificaciones.`);
    } catch (error) {
      setMensaje(error instanceof Error ? error.message : "No se pudieron guardar las calificaciones.");
    } finally {
      setCargando(false);
    }
  }

  async function cerrarActa() {
    if (!actaSeleccionada || !window.confirm("Al cerrar el acta, las notas quedarán bloqueadas. ¿Continuar?")) return;
    setCargando(true);
    setMensaje("");
    try {
      const response = await solicitarConToken(
        access,
        refresh,
        `/api/actas/${actaSeleccionada.id}/cerrar/`,
        { method: "POST" },
        setAccess,
        () => { setAccess(""); setRefresh(""); },
      );
      if (!response.ok) throw new Error(await errorDe(response));
      cambiarActa((await response.json()) as Acta);
      setMensaje("Acta cerrada. Las calificaciones están en modo de solo lectura.");
    } catch (error) {
      setMensaje(error instanceof Error ? error.message : "No se pudo cerrar el acta.");
    } finally {
      setCargando(false);
    }
  }

  return (
    <section aria-labelledby="actas-title" className="enrollment-section" id="actas-docente">
      <div className="catalog-heading">
        <div>
          <p className="eyebrow">DOCENCIA <span className="index-dash">/</span> CALIFICACIONES</p>
          <h2 id="actas-title">Actas de notas.</h2>
          <p className="catalog-intro">Carga calificaciones y cierra el acta cuando el registro esté completo.</p>
        </div>
        {access && <button className="enrollment-logout" onClick={() => { setAccess(""); setRefresh(""); setActas([]); setActaId(""); }}>Cerrar sesión</button>}
      </div>

      {!access ? (
        <form className="student-login" onSubmit={ingresar}>
          <label><span>USUARIO DOCENTE</span><input autoComplete="username" onChange={(event) => setUsuario(event.target.value)} required value={usuario} /></label>
          <label><span>CONTRASEÑA</span><input autoComplete="current-password" onChange={(event) => setContrasena(event.target.value)} required type="password" value={contrasena} /></label>
          <button disabled={cargando} type="submit">{cargando ? "Ingresando…" : "Ingresar"}</button>
        </form>
      ) : (
        <>
          {actas.length > 0 && (
            <label className="offer-period-picker acta-picker">
              <span>PARALELO ASIGNADO</span>
              <select aria-label="Seleccionar acta" onChange={(event) => setActaId(event.target.value)} value={actaId}>
                {actas.map((acta) => <option key={acta.id} value={acta.id}>{acta.paralelo_codigo} · {acta.paralelo_identificador} · {acta.periodo}</option>)}
              </select>
            </label>
          )}
          {actaSeleccionada && (
            <div className="acta-sheet">
              <div className="acta-sheet-heading">
                <div><span>{actaSeleccionada.paralelo_codigo} · {actaSeleccionada.paralelo_identificador}</span><h3>{actaSeleccionada.paralelo_materia}</h3><p>{actaSeleccionada.periodo} · {actaSeleccionada.docente}</p></div>
                <span className={`acta-state${actaSeleccionada.cerrada ? " acta-state-closed" : ""}`}>{actaSeleccionada.cerrada ? "CERRADA · BLOQUEADA" : "ABIERTA"}</span>
              </div>
              <div className="grade-table-head"><span>ESTUDIANTE</span><span>NOTA / 100</span></div>
              {actaSeleccionada.inscripciones.length === 0 ? <p className="acta-empty">Este paralelo no tiene estudiantes inscritos.</p> : actaSeleccionada.inscripciones.map((registro) => (
                <div className="grade-row" key={registro.id}>
                  <div><strong>{registro.estudiante}</strong><span>{registro.estado}</span></div>
                  <input
                    aria-label={`Nota de ${registro.estudiante}`}
                    disabled={actaSeleccionada.cerrada || cargando}
                    max="100"
                    min="0"
                    onChange={(event) => setPuntajes((actuales) => ({ ...actuales, [registro.id]: event.target.value }))}
                    step="0.01"
                    type="number"
                    value={puntajes[registro.id] ?? ""}
                  />
                </div>
              ))}
              {!actaSeleccionada.cerrada && (
                <div className="acta-actions">
                  <button disabled={cargando} onClick={() => void guardarNotas()}>Guardar calificaciones</button>
                  <button disabled={cargando} onClick={() => void cerrarActa()}>Cerrar acta</button>
                </div>
              )}
              {actaSeleccionada.cerrada && actaSeleccionada.cerrada_en && <p className="acta-closed-note">Cerrada el {new Date(actaSeleccionada.cerrada_en).toLocaleString("es-CL")}{actaSeleccionada.cerrada_por_nombre ? ` por ${actaSeleccionada.cerrada_por_nombre}` : ""}.</p>}
            </div>
          )}
        </>
      )}
      {mensaje && <p aria-live="polite" className="enrollment-message">{mensaje}</p>}
    </section>
  );
}
