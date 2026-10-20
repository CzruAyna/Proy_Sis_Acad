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
  periodo: number;
  materia_codigo: string;
  materia_nombre: string;
  identificador: string;
  docente_nombre: string;
  cupo_maximo: number;
  inscriptos_actuales: number;
  cupos_disponibles: number;
  sesiones: SesionClase[];
  elegibilidad?: {
    habilitada: boolean;
    motivos: string[];
    carga_actual: number;
    limite_materias: number;
    promedio_ordinario_anterior: number | null;
  };
}

interface SesionClase {
  id: number;
  dia: number;
  dia_display: string;
  hora_inicio: string;
  hora_fin: string;
  tipo_display: string;
  grupo_lab: number;
  aula: string;
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

function minutos(hora: string) {
  const [horas, minutos] = hora.split(":").map(Number);
  return horas * 60 + minutos;
}

function seCruzan(a: SesionClase, b: SesionClase) {
  return a.dia === b.dia && minutos(a.hora_inicio) < minutos(b.hora_fin) && minutos(a.hora_fin) > minutos(b.hora_inicio);
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
            ? fetch(`${apiUrl}/api/inscripciones/elegibilidad/?periodo=${periodoId}`, { headers, signal: controller.signal })
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
      periodoId ? fetch(`${apiUrl}/api/inscripciones/elegibilidad/?periodo=${periodoId}`, { headers: { Authorization: `Bearer ${token}` } }) : Promise.resolve(null),
    ]);
    if (misResponse.ok) setInscripciones((await misResponse.json()) as Inscripcion[]);
    if (paralelosResponse?.ok) setParalelos((await paralelosResponse.json()) as Paralelo[]);
  }

  const activas = inscripciones.filter((inscripcion) => inscripcion.estado_display === "Cursando");
  const activasPeriodo = activas.filter((inscripcion) => String(inscripcion.paralelo_info.periodo) === periodoId);
  const resumenElegibilidad = paralelos[0]?.elegibilidad;
  const inscritoEnMateria = new Set(
    activasPeriodo.map((inscripcion) => inscripcion.paralelo_info.materia_codigo),
  );
  const sesionesActuales = activasPeriodo.flatMap((inscripcion) =>
    inscripcion.paralelo_info.sesiones.map((sesion) => ({
      ...sesion,
      materia: inscripcion.paralelo_info.materia_nombre,
      codigo: inscripcion.paralelo_info.materia_codigo,
      paralelo: inscripcion.paralelo_info.identificador,
    })),
  );
  const dias = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"];

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
            <span className="enrollment-total">{activasPeriodo.length} MATERIA{activasPeriodo.length === 1 ? "" : "S"} EN ESTE PERIODO</span>
          </div>
          {resumenElegibilidad && <p className="eligibility-summary">
            Llevas {resumenElegibilidad.carga_actual} de {resumenElegibilidad.limite_materias} materias permitidas.
            {resumenElegibilidad.promedio_ordinario_anterior === null
              ? " La séptima requiere un promedio ponderado de al menos 65 en el periodo ordinario anterior."
              : ` Promedio ponderado anterior: ${resumenElegibilidad.promedio_ordinario_anterior.toFixed(2)}${resumenElegibilidad.limite_materias === 7 ? ", habilita la séptima materia." : ", no alcanza el umbral de 65 para la séptima."}`}
          </p>}

          <div className="weekly-schedule" id="horario">
            <div className="schedule-heading">
              <div><span>CUADERNO DE HORARIO</span><h3>Mi semana en clases</h3></div>
              <div className="schedule-tools">
                <span>{sesionesActuales.length} SESIÓN{sesionesActuales.length === 1 ? "" : "ES"}</span>
                {sesionesActuales.length > 0 && <button className="schedule-print-button" onClick={() => window.print()} type="button">Imprimir horario</button>}
              </div>
            </div>
            {sesionesActuales.length === 0 ? <p className="schedule-empty">Tus clases aparecerán aquí cuando tus paralelos tengan horarios publicados.</p> : (
              <div className="schedule-days">
                {dias.map((dia, index) => {
                  const sesionesDia = sesionesActuales.filter((sesion) => sesion.dia === index + 1).sort((a, b) => minutos(a.hora_inicio) - minutos(b.hora_inicio));
                  if (sesionesDia.length === 0) return null;
                  return <section className="schedule-day" key={dia} aria-label={`Clases del ${dia}`}>
                    <h4>{dia}</h4>
                    <div>{sesionesDia.map((sesion, sesionIndex) => {
                      const hayCruce = sesionesDia.slice(0, sesionIndex).some((anterior) => seCruzan(anterior, sesion));
                      return <article className={`schedule-class${hayCruce ? " schedule-class-conflict" : ""}`} key={`${sesion.codigo}-${sesion.id}`}>
                        <time>{sesion.hora_inicio.slice(0, 5)}–{sesion.hora_fin.slice(0, 5)}</time>
                        <strong>{sesion.codigo} · {sesion.materia}</strong>
                        <span>{sesion.tipo_display}{sesion.tipo_display === "Laboratorio" ? ` ${sesion.grupo_lab}` : ""} · {sesion.aula} · Paralelo {sesion.paralelo}</span>
                        {hayCruce && <small>Se cruza con otra clase</small>}
                      </article>;
                    })}</div>
                  </section>;
                })}
              </div>
            )}
          </div>

          <div className="my-enrollments">
            <h3>Mis inscripciones</h3>
            {activasPeriodo.length === 0 ? <p>No tienes materias inscritas en este periodo.</p> : activasPeriodo.map((inscripcion) => (
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
            ) : paralelos.filter((paralelo) => paralelo.cupos_disponibles > 0 && !inscritoEnMateria.has(paralelo.materia_codigo)).map((paralelo) => {
              const cruces = paralelo.sesiones.filter((sesion) => sesionesActuales.some((actual) => seCruzan(sesion, actual)));
              return (
              <article className="enrollment-offer-row" key={paralelo.id}>
                <div><span>{paralelo.materia_codigo} · PARALELO {paralelo.identificador}</span><strong>{paralelo.materia_nombre}</strong><small>{paralelo.docente_nombre} · {paralelo.cupos_disponibles} cupo{paralelo.cupos_disponibles === 1 ? "" : "s"}</small>{cruces.length > 0 && <small className="schedule-warning">Advertencia: {cruces.length} sesión{cruces.length === 1 ? "" : "es"} coincide{cruces.length === 1 ? "" : "n"} con tu horario.</small>}</div>
                <button disabled={cargando || !paralelo.elegibilidad?.habilitada} onClick={() => void inscribirse(paralelo.id)}>Inscribirme</button>
                {paralelo.elegibilidad?.motivos.map((motivo) => <small className="enrollment-block-reason" key={motivo}>{motivo}</small>)}
              </article>
            );})}
          </div>
        </>
      )}
      {mensaje && <p aria-live="polite" className="enrollment-message">{mensaje}</p>}
    </section>
  );
}
