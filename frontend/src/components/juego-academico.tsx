"use client";

import { useEffect, useMemo, useState } from "react";
import {
  careers,
  campusEvents,
  roleCases,
  roleNames,
  roleOrder,
  roleTitles,
  roleUnlocks,
  teacherProfiles,
  type Career,
  type RoleId,
  type SimulationCase,
  type Stats,
} from "@/lib/juego-data";

type Phase = "evento" | "pregunta" | "resultado" | "final";

type Achievement = {
  id: string;
  title: string;
  detail: string;
  earnedAt: string;
};

type ActiveGame = {
  role: RoleId;
  careerId: string | null;
  routeId: string | null;
  stageIndex: number;
  phase: Phase;
  stats: Stats;
  grades: number[];
  attempt: number;
  currentGrade: number | null;
  selectedAnswer: number | null;
  eventFeedback: string | null;
  eventOrder: number[];
  teacher: { name: string; style: string; modifier: number };
};

type GameSave = {
  version: 1;
  playerName: string;
  unlockedRoles: RoleId[];
  completedRoles: RoleId[];
  completedCareers: string[];
  achievements: Achievement[];
  activeGame: ActiveGame | null;
};

const SAVE_KEY = "cuaderno-universitario-save-v1";
const startingStats: Stats = { energia: 72, enfoque: 58, recursos: 62, confianza: 54 };
const routeStartingEffects: Record<string, Partial<Stats>> = {
  "gestion-empresarial": { confianza: 6 },
  optimizacion: { enfoque: 6, recursos: -2 },
  comunitaria: { confianza: 7, energia: 2 },
  clinica: { enfoque: 6 },
  publico: { enfoque: 4, confianza: 3 },
  social: { confianza: 6, recursos: 2 },
  desarrollo: { enfoque: 4, recursos: 4 },
  finanzas: { enfoque: 4, recursos: 4 },
  organizaciones: { confianza: 5 },
  emprendimiento: { recursos: 6, energia: -2 },
  auditoria: { enfoque: 6 },
  tributaria: { recursos: 5, enfoque: 3 },
};

function freshSave(): GameSave {
  return {
    version: 1,
    playerName: "",
    unlockedRoles: ["estudiante"],
    completedRoles: [],
    completedCareers: [],
    achievements: [],
    activeGame: null,
  };
}

function clamp(value: number) {
  return Math.max(0, Math.min(100, value));
}

function applyEffects(stats: Stats, effects: Partial<Stats>): Stats {
  return {
    energia: clamp(stats.energia + (effects.energia ?? 0)),
    enfoque: clamp(stats.enfoque + (effects.enfoque ?? 0)),
    recursos: clamp(stats.recursos + (effects.recursos ?? 0)),
    confianza: clamp(stats.confianza + (effects.confianza ?? 0)),
  };
}

function shuffle(values: number[]) {
  const result = [...values];
  for (let index = result.length - 1; index > 0; index -= 1) {
    const swapIndex = Math.floor(Math.random() * (index + 1));
    [result[index], result[swapIndex]] = [result[swapIndex], result[index]];
  }
  return result;
}

function randomTeacher() {
  return teacherProfiles[Math.floor(Math.random() * teacherProfiles.length)];
}

function getActiveCase(activeGame: ActiveGame): SimulationCase {
  const caseIndex = activeGame.eventOrder[activeGame.stageIndex] ?? activeGame.stageIndex;
  if (activeGame.role === "estudiante") return campusEvents[caseIndex % campusEvents.length];
  return roleCases[activeGame.role][caseIndex % roleCases[activeGame.role].length];
}

function getCareer(activeGame: ActiveGame | null): Career | undefined {
  return careers.find((career) => career.id === activeGame?.careerId);
}

function getRoute(career: Career | undefined, routeId: string | null) {
  return career?.routes.find((route) => route.id === routeId);
}

function StatBar({ label, value }: { label: string; value: number }) {
  return (
    <div className="game-stat">
      <div className="game-stat-label"><span>{label}</span><strong>{value}</strong></div>
      <div className="game-stat-track"><span style={{ width: `${value}%` }} /></div>
    </div>
  );
}

export function JuegoAcademico() {
  const [save, setSave] = useState<GameSave | null>(null);
  const [nombre, setNombre] = useState("");
  const [carreraElegida, setCarreraElegida] = useState(careers[0].id);
  const [enfoqueElegido, setEnfoqueElegido] = useState(careers[0].routes[0].id);
  const [respuestaElegida, setRespuestaElegida] = useState<number | null>(null);
  const [tableroAbierto, setTableroAbierto] = useState(false);

  useEffect(() => {
    try {
      const stored = window.localStorage.getItem(SAVE_KEY);
      if (stored) {
        const parsed = JSON.parse(stored) as GameSave;
        if (parsed.version === 1 && Array.isArray(parsed.unlockedRoles)) {
          setSave(parsed);
          setNombre(parsed.playerName);
          return;
        }
      }
    } catch {
      window.localStorage.removeItem(SAVE_KEY);
    }
    const initial = freshSave();
    setSave(initial);
  }, []);

  const carreraActual = useMemo(
    () => careers.find((career) => career.id === carreraElegida) ?? careers[0],
    [carreraElegida],
  );

  function persist(next: GameSave) {
    setSave(next);
    window.localStorage.setItem(SAVE_KEY, JSON.stringify(next));
  }

  function startGame(role: RoleId, career?: Career, routeId?: string) {
    if (!save) return;
    const playerName = nombre.trim() || save.playerName || "Estudiante";
    const next: GameSave = {
      ...save,
      playerName,
      activeGame: {
        role,
        careerId: role === "estudiante" ? career?.id ?? null : null,
        routeId: role === "estudiante" ? routeId ?? null : null,
        stageIndex: 0,
        phase: "evento",
        stats: applyEffects(startingStats, routeStartingEffects[routeId ?? ""] ?? {}),
        grades: [],
        attempt: 0,
        currentGrade: null,
        selectedAnswer: null,
        eventFeedback: null,
        eventOrder: shuffle([0, 1, 2, 3]),
        teacher: randomTeacher(),
      },
    };
    setRespuestaElegida(null);
    persist(next);
  }

  function chooseEvent(index: number) {
    if (!save?.activeGame) return;
    const active = save.activeGame;
    const activeCase = getActiveCase(active);
    const choice = activeCase.choices[index];
    if (!choice) return;
    const stats = applyEffects(active.stats, choice.effects);
    if (active.role === "estudiante") {
      persist({
        ...save,
        activeGame: {
          ...active,
          stats,
          phase: "pregunta",
          eventFeedback: choice.outcome,
        },
      });
      return;
    }

    const grade = clamp(
      (choice.score ?? 55) + Math.floor((stats.enfoque - 50) / 12) + Math.floor((stats.confianza - 50) / 20),
    );
    persist({
      ...save,
      activeGame: {
        ...active,
        stats,
        phase: "resultado",
        currentGrade: grade,
        selectedAnswer: index,
        eventFeedback: choice.outcome,
      },
    });
  }

  function submitAnswer() {
    if (!save?.activeGame || respuestaElegida === null) return;
    const active = save.activeGame;
    const career = getCareer(active);
    const challenge = career?.stages[active.stageIndex];
    if (!challenge) return;
    const correct = respuestaElegida === challenge.answer;
    const score = clamp(
      (correct ? 74 : 42) +
        (active.attempt > 0 ? 12 : 0) +
        Math.floor((active.stats.enfoque - 50) / 10) +
        Math.floor((active.stats.energia - 50) / 20) +
        active.teacher.modifier -
        (challenge.difficulty - 1) * 5,
    );
    persist({
      ...save,
      activeGame: {
        ...active,
        phase: "resultado",
        selectedAnswer: respuestaElegida,
        currentGrade: score,
      },
    });
    setRespuestaElegida(null);
  }

  function retryChallenge() {
    if (!save?.activeGame) return;
    persist({
      ...save,
      activeGame: {
        ...save.activeGame,
        phase: "pregunta",
        attempt: save.activeGame.attempt + 1,
        stats: applyEffects(save.activeGame.stats, { energia: -8, enfoque: 5 }),
        selectedAnswer: null,
        currentGrade: null,
      },
    });
    setRespuestaElegida(null);
  }

  function finishCampaign(active: ActiveGame, grade: number) {
    if (!save) return;
    const completedRoles = save.completedRoles.includes(active.role)
      ? save.completedRoles
      : [...save.completedRoles, active.role];
    const unlockedRoles = [...save.unlockedRoles];
    const nextRole = roleOrder[roleOrder.indexOf(active.role) + 1];
    if (nextRole && !unlockedRoles.includes(nextRole)) unlockedRoles.push(nextRole);

    let awardTitle = roleTitles[active.role];
    let awardDetail = `Ruta de ${roleNames[active.role]} · promedio final ${grade}`;
    let completedCareers = save.completedCareers;
    if (active.role === "estudiante") {
      const career = getCareer(active);
      const route = getRoute(career, active.routeId);
      if (career) {
        awardTitle = career.title;
        awardDetail = `${career.name} · ${route?.name ?? "recorrido general"} · promedio final ${grade}`;
        const program = `${career.id}:${active.routeId ?? "general"}`;
        if (!completedCareers.includes(program)) completedCareers = [...completedCareers, program];
      }
    }

    const award: Achievement = {
      id: `${active.role}-${Date.now()}-${Math.random().toString(16).slice(2, 6)}`,
      title: awardTitle,
      detail: awardDetail,
      earnedAt: new Date().toISOString(),
    };
    const activeGame: ActiveGame = {
      ...active,
      phase: "final",
      grades: [...active.grades, grade],
      currentGrade: grade,
    };
    persist({
      ...save,
      completedRoles,
      completedCareers,
      unlockedRoles,
      achievements: [award, ...save.achievements],
      activeGame,
    });
  }

  function advanceStage() {
    const active = save?.activeGame;
    if (!active || active.currentGrade === null) return;
    const currentGrade = active.currentGrade;
    const career = getCareer(active);
    const stageCount = active.role === "estudiante" ? career?.stages.length ?? 0 : roleCases[active.role].length;
    const grades = [...active.grades, currentGrade];
    if (active.stageIndex + 1 >= stageCount) {
      const average = Math.round(grades.reduce((sum, value) => sum + value, 0) / grades.length);
      finishCampaign(active, average);
      return;
    }
    persist({
      ...save,
      activeGame: {
        ...active,
        stageIndex: active.stageIndex + 1,
        phase: "evento",
        grades,
        attempt: 0,
        currentGrade: null,
        selectedAnswer: null,
        eventFeedback: null,
        teacher: randomTeacher(),
      },
    });
  }

  function returnToBoard() {
    if (!save) return;
    persist({ ...save, activeGame: null });
  }

  function abandonCampaign() {
    if (!save) return;
    if (!window.confirm("¿Quieres salir de esta partida? El avance de esta ruta no contará como título.")) return;
    persist({ ...save, activeGame: null });
  }

  if (!save) {
    return <main className="game-loading"><span className="loading-mark">CU</span><p>Abriendo el cuaderno…</p></main>;
  }

  const active = save.activeGame;
  const career = getCareer(active);
  const route = getRoute(career, active?.routeId ?? null);
  const ongoing = active !== null && active.phase !== "final";
  const currentCase = active ? getActiveCase(active) : null;
  const challenge = active && active.role === "estudiante" ? career?.stages[active.stageIndex] : undefined;
  const stageCount = active ? active.role === "estudiante" ? career?.stages.length ?? 4 : roleCases[active.role].length : 4;
  const stageNumber = active ? active.stageIndex + 1 : 1;
  const correctAnswer = challenge ? active?.selectedAnswer === challenge.answer : false;
  const topTitle = active?.role === "estudiante" ? career?.name ?? "Carrera" : roleNames[active?.role ?? "estudiante"];

  if (active?.phase === "final") {
    const average = Math.round(active.grades.reduce((sum, value) => sum + value, 0) / active.grades.length);
    const finalAward = save.achievements[0];
    const nextRole = roleOrder[roleOrder.indexOf(active.role) + 1];
    return (
      <main className="game-page">
        <div className="game-sheet game-finish-sheet">
          <header className="game-header"><a className="game-brand" href="/"><span className="game-brand-mark">CU</span><span>CUADERNO<br />UNIVERSITARIO</span></a><a className="game-system-link" href="/sistema">Sistema académico ↗</a></header>
          <section className="finish-content">
            <p className="game-eyebrow">RUTA COMPLETADA <span>·</span> PARTIDA GUARDADA</p>
            <div className="finish-medal" aria-hidden="true">✳</div>
            <h1>Un capítulo<br />queda escrito.</h1>
            <p className="finish-copy">{save.playerName}, terminaste {active.role === "estudiante" ? `${career?.name ?? "tu carrera"}${route ? ` con enfoque en ${route.name}` : ""}` : `la ruta de ${roleNames[active.role].toLowerCase()}`}.</p>
            <div className="earned-title"><span>TÍTULO OBTENIDO</span><strong>{finalAward?.title ?? "Compañero de generación"}</strong><small>{finalAward?.detail}</small></div>
            <div className="finish-stats"><div><strong>{average}</strong><span>PROMEDIO<br />DE RUTA</span></div><div><strong>{save.achievements.length}</strong><span>TÍTULOS<br />ACUMULADOS</span></div><div><strong>{save.unlockedRoles.length}</strong><span>ROLES<br />DISPONIBLES</span></div></div>
            {nextRole && save.unlockedRoles.includes(nextRole) && !save.completedRoles.includes(nextRole) && <p className="unlock-note"><span>✦</span> Se habilitó el rol de <strong>{roleNames[nextRole]}</strong>.</p>}
            <button className="game-button game-button-primary" onClick={returnToBoard}>Volver al tablero <span>→</span></button>
          </section>
          <footer className="game-footer"><span>CUADERNO DE PARTIDA</span><span>EL APRENDIZAJE SIGUE</span><span>✳</span></footer>
        </div>
      </main>
    );
  }

  if (active && currentCase && !tableroAbierto) {
    const score = active.currentGrade ?? 0;
    const isStudent = active.role === "estudiante";
    return (
      <main className="game-page">
        <div className="game-sheet game-session-sheet">
          <header className="game-header"><a className="game-brand" href="/"><span className="game-brand-mark">CU</span><span>CUADERNO<br />UNIVERSITARIO</span></a><div className="session-heading"><span>PARTIDA EN CURSO</span><strong>{topTitle}</strong></div><button className="game-quiet-button" onClick={() => setTableroAbierto(true)}>Pausar partida</button></header>
          <section className="session-content">
            <div className="session-progress-row"><div><p className="game-eyebrow">CAPÍTULO {String(stageNumber).padStart(2, "0")} <span>·</span> {isStudent ? route?.name ?? "RECORRIDO" : "SIMULACIÓN DE ROL"}</p><h1>{isStudent ? challenge?.subject : currentCase.title}</h1><p className="session-subtitle">{isStudent ? `${challenge?.topic} · dificultad ${challenge?.difficulty}/3` : `${roleNames[active.role]} · decisión ${stageNumber} de ${stageCount}`}</p></div><span className="chapter-fraction">{String(stageNumber).padStart(2, "0")}<i>/</i>{String(stageCount).padStart(2, "0")}</span></div>
            <div className="chapter-progress" aria-label={`Capítulo ${stageNumber} de ${stageCount}`}><span style={{ width: `${(stageNumber / stageCount) * 100}%` }} /></div>

            <div className="session-grid">
              <section className="session-main">
                {active.phase === "evento" && (
                  <>
                    <div className="scenario-card">
                      <div className="scenario-kicker"><span className="paper-icon">✎</span><span>{isStudent ? "SITUACIÓN DEL CAMPUS" : "CASO DE GESTIÓN"}</span><span className="difficulty-stamp">RETO {currentCase.difficulty}</span></div>
                      <h2>{currentCase.title}</h2><p>{currentCase.context}</p>
                    </div>
                    <div className="choice-block"><p className="game-eyebrow">¿QUÉ HARÍAS?</p><div className="choice-list">{currentCase.choices.map((choice, index) => <button className="choice-option" key={choice.label} onClick={() => chooseEvent(index)}><span className="choice-letter">{String.fromCharCode(65 + index)}</span><span><strong>{choice.label}</strong><small>{choice.outcome}</small></span><span className="choice-arrow">↗</span></button>)}</div></div>
                  </>
                )}

                {active.phase === "pregunta" && challenge && (
                  <>
                    {active.eventFeedback && <div className="feedback-note"><span>✦</span><p>{active.eventFeedback}</p></div>}
                    <div className="scenario-card quiz-card"><div className="scenario-kicker"><span className="paper-icon">?</span><span>APUNTE DE MATERIA</span><span className="difficulty-stamp">{challenge.topic.toUpperCase()}</span></div><h2>{challenge.question}</h2></div>
                    <div className="answer-list">{challenge.options.map((option, index) => <button aria-pressed={respuestaElegida === index} className={`answer-option${respuestaElegida === index ? " answer-option-selected" : ""}`} key={option} onClick={() => setRespuestaElegida(index)}><span className="choice-letter">{String.fromCharCode(65 + index)}</span><span>{option}</span></button>)}</div>
                    <button className="game-button game-button-primary" disabled={respuestaElegida === null} onClick={submitAnswer}>Revisar respuesta <span>→</span></button>
                  </>
                )}

                {active.phase === "resultado" && (
                  <>
                    <div className={`result-card ${score >= 60 ? "result-card-pass" : "result-card-retry"}`}><span className="result-icon">{score >= 60 ? "✓" : "↻"}</span><div><p className="game-eyebrow">{isStudent ? correctAnswer ? "RESPUESTA REVISADA" : "HAY OTRA OPORTUNIDAD" : "DECISIÓN REGISTRADA"}</p><h2>{isStudent ? correctAnswer ? "Buen razonamiento." : "Un error también enseña." : score >= 75 ? "Decisión bien encaminada." : "Revisa el efecto de esa decisión."}</h2><p>{isStudent ? challenge?.explanation : currentCase.explanation}</p><small>CALIFICACIÓN DE ESTA ETAPA <strong>{score}/100</strong></small></div></div>
                    {active.eventFeedback && <div className="feedback-note"><span>✦</span><p>{active.eventFeedback}</p></div>}
                    {score < 60 && isStudent ? <button className="game-button game-button-primary" onClick={retryChallenge}>Repasar y volver a intentar <span>↻</span></button> : <button className="game-button game-button-primary" onClick={advanceStage}>{stageNumber === stageCount ? "Cerrar este capítulo" : "Continuar al siguiente capítulo"} <span>→</span></button>}
                  </>
                )}
              </section>

              <aside className="session-sidebar">
                <div className="student-card"><span className="card-stamp">FICHA DE PARTIDA</span><span className="student-avatar">{save.playerName.slice(0, 1).toUpperCase() || "E"}</span><strong>{save.playerName || "Estudiante"}</strong><small>{roleNames[active.role]}{route ? ` · ${route.name}` : ""}</small></div>
                <div className="teacher-note"><span>DOCENTE DEL DÍA</span><strong>{active.teacher.name}</strong><small>{active.teacher.style}</small><p>La dificultad del reto y el acompañamiento cambian de una partida a otra.</p></div>
                <div className="stat-sheet"><p className="game-eyebrow">ESTADO DE LA SEMANA</p><StatBar label="Energía" value={active.stats.energia} /><StatBar label="Enfoque" value={active.stats.enfoque} /><StatBar label="Recursos" value={active.stats.recursos} /><StatBar label="Confianza" value={active.stats.confianza} /></div>
                <div className="grade-sheet"><span>NOTAS DE LA RUTA</span><div>{active.grades.length ? active.grades.map((grade, index) => <span key={`${grade}-${index}`} title={`Etapa ${index + 1}: ${grade}`}>{grade}</span>) : <small>Las primeras notas aparecerán al cerrar una etapa.</small>}</div></div>
              </aside>
            </div>
          </section>
          <footer className="game-footer"><span>CUADERNO DE PARTIDA</span><span>GUARDADO EN ESTE DISPOSITIVO</span><span>{String(stageNumber).padStart(2, "0")}</span></footer>
        </div>
      </main>
    );
  }

  const selectedRoute = carreraActual.routes.find((candidate) => candidate.id === enfoqueElegido) ?? carreraActual.routes[0];
  const nextLockedRole = roleOrder.find((role) => !save.unlockedRoles.includes(role));

  return (
    <main className="game-page">
      <div className="game-sheet">
        <header className="game-header"><a className="game-brand" href="/"><span className="game-brand-mark">CU</span><span>CUADERNO<br />UNIVERSITARIO</span></a><nav className="game-nav" aria-label="Secciones del juego"><a href="#carreras">Carreras</a><a href="#roles">Roles</a><a href="#logros">Logros</a></nav><a className="game-system-link" href="/sistema">Sistema académico ↗</a></header>

        <section className="game-hero">
          <div className="game-hero-copy"><p className="game-eyebrow"><span className="game-eyebrow-line" /> SIMULADOR UNIVERSITARIO</p><h1>Tu historia<br />empieza en el aula.</h1><p>Elige una carrera, toma decisiones, resuelve retos de materias y gana tu lugar en la comunidad universitaria.</p><a className="game-text-link" href="#carreras">Abrir el cuaderno <span>↘</span></a><div className="game-mode-note"><span>◉</span><p>Partida individual guardada en este dispositivo. Cada recorrido mezcla situaciones, docentes y resultados.</p></div></div>
          <aside className="game-hero-card"><div className="hero-card-top"><span>CUADERNO DE CAMPO</span><span>01 / 04</span></div><div className="hero-doodle" aria-hidden="true"><div className="doodle-ring" /><span>✳</span><i /><b /></div><p className="hero-card-caption">“Lo que decides hoy<br />cambia el próximo capítulo.”</p><div className="hero-card-bottom"><span>UNA PARTIDA A LA VEZ</span><span>✎</span></div></aside>
        </section>

        <section className="game-quick-stats" aria-label="Progreso de la partida"><div><span>ROLES ABIERTOS</span><strong>{save.unlockedRoles.length}<small>/4</small></strong></div><div><span>PROGRAMAS COMPLETADOS</span><strong>{save.completedCareers.length}</strong></div><div><span>TÍTULOS GANADOS</span><strong>{save.achievements.length}</strong></div><div className="quick-progress"><span>PRÓXIMO DESBLOQUEO</span><strong>{nextLockedRole ? roleNames[nextLockedRole] : "Todas las rutas abiertas"}</strong></div></section>

        {ongoing && <section className="resume-card"><div><p className="game-eyebrow">HAY UNA PARTIDA ABIERTA</p><h2>{active.role === "estudiante" ? `${career?.name} · capítulo ${stageNumber}` : `${roleNames[active.role]} · decisión ${stageNumber}`}</h2><p>El progreso quedó guardado en este dispositivo.</p></div><div className="resume-actions"><button className="game-button game-button-primary" onClick={() => setTableroAbierto(false)}>Continuar partida <span>→</span></button><button className="game-quiet-button" onClick={abandonCampaign}>Abandonar</button></div></section>}

        <section className="career-section" id="carreras">
          <div className="game-section-heading"><div><p className="game-eyebrow">01 <span>·</span> ELIGE TU RECORRIDO</p><h2>¿Qué quieres llegar a ser?</h2><p>Cuatro capítulos jugables por carrera, con preguntas, situaciones y niveles de reto distintos.</p></div><span className="game-section-count">{careers.length} CARRERAS DISPONIBLES</span></div>
          <label className="player-name-field"><span>NOMBRE PARA TU CUADERNO</span><input maxLength={28} onChange={(event) => setNombre(event.target.value)} placeholder="¿Cómo te llamas?" value={nombre} /></label>
          <div className="career-grid">{careers.map((candidate, index) => <article className={`career-card${carreraElegida === candidate.id ? " career-card-active" : ""}`} key={candidate.id}><div className="career-card-top"><span className="career-index">{String(index + 1).padStart(2, "0")}</span><span>{candidate.faculty}</span></div><h3>{candidate.name}</h3><p>{candidate.summary}</p><div className="career-subjects"><span>EN ESTE RECORRIDO</span><small>{candidate.stages.slice(0, 2).map((stage) => stage.subject).join(" · ")}</small></div><button aria-pressed={carreraElegida === candidate.id} className="career-select" disabled={ongoing} onClick={() => { setCarreraElegida(candidate.id); setEnfoqueElegido(candidate.routes[0].id); }}>{carreraElegida === candidate.id ? "Seleccionada" : "Elegir carrera"}<span>↗</span></button></article>)}</div>

          <div className="route-picker"><div><p className="game-eyebrow">ENFOQUE DE JUEGO</p><h3>{carreraActual.name}</h3><p>Estos recorridos cambian los casos y el título que recibes al completar la carrera.</p></div><div className="route-choice-list">{carreraActual.routes.map((candidate) => <button aria-pressed={enfoqueElegido === candidate.id} className={`route-choice${enfoqueElegido === candidate.id ? " route-choice-active" : ""}`} disabled={ongoing} key={candidate.id} onClick={() => setEnfoqueElegido(candidate.id)}><span className="route-choice-mark">{enfoqueElegido === candidate.id ? "●" : "○"}</span><span><strong>{candidate.name}</strong><small>{candidate.description}</small></span></button>)}</div><button className="game-button game-button-primary career-start-button" disabled={ongoing} onClick={() => startGame("estudiante", carreraActual, selectedRoute.id)}>Iniciar carrera <span>→</span></button></div>
          <p className="curriculum-note">Las materias y recorridos son una selección para jugar y aprender. Ingeniería de Sistemas toma como referencia asignaturas y menciones publicadas por la UTO; los demás énfasis son rutas de simulación.</p>
        </section>

        <section className="role-section" id="roles"><div className="game-section-heading"><div><p className="game-eyebrow">02 <span>·</span> LA UNIVERSIDAD POR DENTRO</p><h2>Una comunidad, cuatro miradas.</h2><p>Completa cada ruta para desbloquear un nuevo personaje y conocer otra parte del sistema.</p></div><span className="game-section-count">{save.unlockedRoles.length} DE 4 ROLES ABIERTOS</span></div><div className="role-grid">{roleOrder.map((role, index) => { const unlocked = save.unlockedRoles.includes(role); const complete = save.completedRoles.includes(role); return <article className={`role-card${unlocked ? " role-card-open" : " role-card-locked"}`} key={role}><div className="role-card-top"><span>0{index + 1}</span><span>{unlocked ? complete ? "RUTA COMPLETADA" : "DISPONIBLE" : "CERRADO"}</span></div><h3>{roleNames[role]}</h3><p>{roleUnlocks[role]}</p>{unlocked && <button disabled={ongoing} onClick={() => role === "estudiante" ? document.getElementById("carreras")?.scrollIntoView({ behavior: "smooth" }) : startGame(role)}>{complete ? "Volver a jugar" : role === "estudiante" ? "Elegir carrera" : "Comenzar ruta"}<span>↗</span></button>}{!unlocked && <div className="role-lock-hint"><span>▧</span><small>Gana el título de la ruta anterior para abrir este personaje.</small></div>}</article>; })}</div><div className="multiplayer-note"><span className="multiplayer-mark">⇄</span><div><strong>Una partida compartida, más adelante</strong><p>El modo actual es individual. El tablero ya organiza las carreras, roles y logros como partidas separadas; el modo en línea necesitará salas, cuentas y guardado sincronizado.</p></div><span className="multiplayer-status">POR CONSTRUIR</span></div></section>

        <section className="achievement-section" id="logros"><div className="game-section-heading"><div><p className="game-eyebrow">03 <span>·</span> RECONOCIMIENTOS</p><h2>Lo que ya dejaste escrito.</h2><p>Cada carrera y cada rol completado suma un título a tu historial.</p></div><span className="game-section-count">{save.achievements.length} TÍTULOS</span></div>{save.achievements.length ? <div className="achievement-list">{save.achievements.map((achievement) => <article className="achievement-item" key={achievement.id}><span className="achievement-star">✳</span><div><strong>{achievement.title}</strong><p>{achievement.detail}</p></div><time dateTime={achievement.earnedAt}>{new Date(achievement.earnedAt).toLocaleDateString("es-BO")}</time></article>)}</div> : <div className="empty-achievements"><span>✎</span><p>Todavía no hay títulos. Completa tu primera carrera para ganar el primero.</p></div>}</section>

        <footer className="game-footer"><span>CUADERNO UNIVERSITARIO</span><span>APRENDER · DECIDIR · AVANZAR</span><a href="/sistema">Volver al sistema académico ↗</a></footer>
      </div>
    </main>
  );
}
