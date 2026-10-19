"use client";

import { useEffect, useState, type FormEvent } from "react";

interface Periodo {
  id: number;
  tipo_display: string;
  anio: number;
  activo: boolean;
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
}

interface Inscripcion {
  id: number;
  paralelo_info: Paralelo;
  estado_display: string;
  creado_en: string;
}

const apiUrl = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8000";

async function leerError(response: Response) {
  try {
    const data = (await response.json()) as Record<string, unknown>;
    return Object.values(data).flat().join(" ");
  } catch {
    return `No se pudo completar la operación (${response.status}).`;
  }
}

export function InscripcionesPanel() {
  const [periodos, setPeriodos] = useState<Periodo[]>([]);
  const [periodoId, setPeriodoId] = useState("");
  const [paralelos, setParalelos] = useState<Paralelo[]>([]);
  const [inscripciones, setInscripciones] = useState<Inscripcion[]>([]);
  const [token, setToken] = useState("");
  const [refreshToken, setRefreshToken] = useState("");
  const [usuario, setUsuario] = useState("");
  const [contrasena, setContrasena] = useState("");
  const [cargando, setCargando] = useState(false);
  const [mensaje, setMensaje] = useState("");

  useEffect(() => {
    const controller = new AbortController();
    fetch(`${apiUrl}/api/periodos/`, { signal: controller.signal })
      .then((response) => {
        if (!response.ok) throw new Error("No se pudieron cargar los periodos.");
        return response.json() as Promise<Periodo[]>;
      })
      .then((data) => {
        setPeriodos(data);
        const actual = data.find((periodo) => periodo.activo) ?? data[0];
        if (actual) setPeriodoId(String(actual.id));
      })
      .catch(() => {
        if (!controller.signal.aborted) setMensaje("No se pudo conectar con el sistema académico.");
      });
    return () => controller.abort();
  }, []);

  useEffect(() => {
    if (!token) return;
    const controller = new AbortController();

    async function cargarDatos() {
      setCargando(true);
      try {
        const headers = { Authorization: `Bearer ${token}` };
        const [inscripcionesResponse, paralelosResponse] = await Promise.all([
          fetch(`${apiUrl}/api/inscripciones/`, { headers, signal: controller.signal }),
          periodoId
            ? fetch(`${apiUrl}/api/paralelos/?periodo=${periodoId}`, { signal: controller.signal })
            : Promise.resolve(null),
        ]);
        if (inscripcionesResponse.status === 401 && refreshToken) {
          const refreshResponse = await fetch(`${apiUrl}/api/token/refresh/`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ refresh: refreshToken }),
            signal: controller.signal,
          });
          if (refreshResponse.ok) {
            const tokens = (await refreshResponse.json()) as { access: string };
            setToken(tokens.access);
            return;
          }
          setToken("");
          setRefreshToken("");
          throw new Error("La sesión venció. Inicia sesión otra vez.");
        }
        if (!inscripcionesResponse.ok) {
          if (inscripcionesResponse.status === 401) {
            setToken("");
            setRefreshToken("");
            setInscripciones([]);
          }
          throw new Error(await leerError(inscripcionesResponse));
        }
        setInscripciones((await inscripcionesResponse.json()) as Inscripcion[]);
        if (paralelosResponse) {
          if (!paralelosResponse.ok) throw new Error("No se pudo cargar la oferta del periodo.");
          setParalelos((await paralelosResponse.json()) as Paralelo[]);
        } else {
          setParalelos([]);
        }
        setMensaje("");
      } catch (error) {
        if (!controller.signal.aborted) {
          setMensaje(error instanceof Error ? error.message : "No se pudieron cargar tus datos.");
        }
      } finally {
        if (!controller.signal.aborted) setCargando(false);
      }
    }

    void cargarDatos();
    return () => controller.abort();
  }, [periodoId, token, refreshToken]);

  async function iniciarSesion(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setCargando(true);
    setMensaje("");
    try {
      const response = await fetch(`${apiUrl}/api/token/`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username: usuario, password: contrasena }),
      });
      if (!response.ok) throw new Error("Usuario o contraseña incorrectos.");
      const data = (await response.json()) as { access: string; refresh: string };
      setToken(data.access);
      setRefreshToken(data.refresh);
      setContrasena("");
    } catch (error) {
      setMensaje(error instanceof Error ? error.message : "No se pudo iniciar sesión.");
    } finally {
      setCargando(false);
    }
  }

  async function inscribirse(paraleloId: number) {
    setCargando(true);
    setMensaje("");
    try {
      const response = await fetch(`${apiUrl}/api/inscripciones/`, {
        method: "POST",
        headers: { Authorization: `Bearer ${token}`, "Content-Type": "application/json" },
        body: JSON.stringify({ paralelo_id: paraleloId }),
      });
      if (!response.ok) throw new Error(await leerError(response));
      setMensaje("Inscripción registrada.");
      await recargar();
    } catch (error) {
      setMensaje(error instanceof Error ? error.message : "No se pudo completar la inscripción.");
    } finally {
      setCargando(false);
    }
  }

  async function retirar(inscripcionId: number) {
    setCargando(true);
    setMensaje("");
    try {
      const response = await fetch(`${apiUrl}/api/inscripciones/${inscripcionId}/`, {
        method: "DELETE",
        headers: { Authorization: `Bearer ${token}` },
      });
      if (!response.ok) throw new Error(await leerError(response));
      setMensaje("Inscripción retirada; el cupo quedó disponible.");
      await recargar();
    } catch (error) {
      setMensaje(error instanceof Error ? error.message : "No se pudo retirar la inscripción.");
    } finally {
      setCargando(false);
    }
  }

  async function recargar() {
    const [misResponse, paralelosResponse] = await Promise.all([
      fetch(`${apiUrl}/api/inscripciones/`, { headers: { Authorization: `Bearer ${token}` } }),
      periodoId ? fetch(`${apiUrl}/api/paralelos/?periodo=${periodoId}`) : Promise.resolve(null),
    ]);
    if (misResponse.ok) setInscripciones((await misResponse.json()) as Inscripcion[]);
    if (paralelosResponse?.ok) setParalelos((await paralelosResponse.json()) as Paralelo[]);
  }

  const activas = inscripciones.filter((inscripcion) => inscripcion.estado_display === "Cursando");
  const inscritoEnMateria = new Set(
    activas.map((inscripcion) => inscripcion.paralelo_info.materia_codigo),
  );

  return (
    <section aria-labelledby="enrollment-title" className="enrollment-section" id="inscripciones">
      <div className="catalog-heading">
        <div>
          <p className="eyebrow">ESTUDIANTE <span className="index-dash">/</span> INSCRIPCIONES</p>
          <h2 id="enrollment-title">Organiza tu periodo.</h2>
          <p className="catalog-intro">Consulta tus materias y encuentra un paralelo con cupos disponibles.</p>
        </div>
        {token && <button className="enrollment-logout" onClick={() => { setToken(""); setRefreshToken(""); setInscripciones([]); setParalelos([]); }}>Cerrar sesión</button>}
      </div>

      {!token ? (
        <form className="student-login" onSubmit={iniciarSesion}>
          <label>
            <span>USUARIO</span>
            <input autoComplete="username" onChange={(event) => setUsuario(event.target.value)} required value={usuario} />
          </label>
          <label>
            <span>CONTRASEÑA</span>
            <input autoComplete="current-password" onChange={(event) => setContrasena(event.target.value)} required type="password" value={contrasena} />
          </label>
          <button disabled={cargando} type="submit">{cargando ? "Ingresando…" : "Ingresar"}</button>
        </form>
      ) : (
        <>
          <div className="enrollment-toolbar">
            <label className="offer-period-picker">
              <span>PERIODO ACADÉMICO</span>
              <select aria-label="Periodo para consultar paralelos" onChange={(event) => setPeriodoId(event.target.value)} value={periodoId}>
                {periodos.map((periodo) => <option key={periodo.id} value={periodo.id}>{periodo.tipo_display} {periodo.anio}</option>)}
              </select>
            </label>
            <span className="enrollment-total">{activas.length} MATERIA{activas.length === 1 ? "" : "S"} EN CURSO</span>
          </div>

          <div className="my-enrollments">
            <h3>Mis inscripciones</h3>
            {activas.length === 0 ? <p>Aún no tienes materias inscritas en tu historial.</p> : activas.map((inscripcion) => (
              <article className="my-enrollment-row" key={inscripcion.id}>
                <div><span>{inscripcion.paralelo_info.materia_codigo} · {inscripcion.paralelo_info.identificador}</span><strong>{inscripcion.paralelo_info.materia_nombre}</strong></div>
                <button disabled={cargando} onClick={() => void retirar(inscripcion.id)}>Retirar</button>
              </article>
            ))}
          </div>

          <div className="enrollment-offers">
            <h3>Paralelos disponibles</h3>
            {paralelos.filter((paralelo) => paralelo.cupos_disponibles > 0 && !inscritoEnMateria.has(paralelo.materia_codigo)).length === 0 ? (
              <p>No hay paralelos con cupos para este periodo.</p>
            ) : paralelos.filter((paralelo) => paralelo.cupos_disponibles > 0 && !inscritoEnMateria.has(paralelo.materia_codigo)).map((paralelo) => (
              <article className="enrollment-offer-row" key={paralelo.id}>
                <div><span>{paralelo.materia_codigo} · PARALELO {paralelo.identificador}</span><strong>{paralelo.materia_nombre}</strong><small>{paralelo.docente_nombre} · {paralelo.cupos_disponibles} cupo{paralelo.cupos_disponibles === 1 ? "" : "s"}</small></div>
                <button disabled={cargando} onClick={() => void inscribirse(paralelo.id)}>Inscribirme</button>
              </article>
            ))}
          </div>
        </>
      )}
      {mensaje && <p aria-live="polite" className="enrollment-message">{mensaje}</p>}
    </section>
  );
}
