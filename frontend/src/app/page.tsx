const modules = [
  {
    number: "01",
    title: "Malla curricular",
    description:
      "Planes de estudio conectados por prerrequisitos y avance académico.",
    label: "CURRÍCULO",
  },
  {
    number: "02",
    title: "Inscripciones",
    description:
      "Oferta académica y cupos organizados para cada periodo.",
    label: "OFERTA",
  },
  {
    number: "03",
    title: "Horarios",
    description:
      "Una vista clara del horario, con libertad para organizarlo.",
    label: "PLANIFICACIÓN",
  },
  {
    number: "04",
    title: "Documentos",
    description:
      "Documentación académica preparada para cada etapa del recorrido.",
    label: "REGISTROS",
  },
];

export default function Home() {
  return (
    <main className="paper-page">
      <div className="paper-sheet">
        <header className="sheet-header">
          <a aria-label="Sistema de Gestión Académica, inicio" className="brand" href="#inicio">
            <span className="brand-mark">SGA</span>
            <span className="brand-name">
              Sistema de Gestión
              <br />
              Académica
            </span>
          </a>
          <nav aria-label="Navegación principal" className="sheet-nav">
            <a href="#sistema">El sistema</a>
            <a href="#modulos">Módulos</a>
            <a href="#principios">Principios</a>
          </nav>
          <span className="edition-label">CUADERNO 01 <span>·</span> EDICIÓN INICIAL</span>
        </header>

        <section aria-labelledby="page-title" className="hero" id="inicio">
          <div className="hero-copy" id="sistema">
            <p className="eyebrow"><span className="eyebrow-line" /> ORGANIZACIÓN ACADÉMICA, EN CLARO</p>
            <h1 id="page-title">Cada materia,<br />en su lugar.</h1>
            <p className="hero-description">
              Una plataforma para ordenar planes de estudio, inscripciones y
              horarios con una idea simple: que la información académica se
              entienda de un vistazo.
            </p>
            <a className="text-link" href="#modulos">
              Explorar el sistema <span aria-hidden="true">↘</span>
            </a>
          </div>

          <aside aria-label="Nota sobre el proyecto" className="margin-note" id="principios">
            <div className="note-holes" aria-hidden="true"><i /><i /><i /></div>
            <p className="note-kicker">APUNTE AL MARGEN</p>
            <h2>Un sistema que respeta el proceso de aprender.</h2>
            <div className="note-rule" />
            <p className="note-detail">
              Currículo claro. Cupos visibles. Horarios que cada estudiante
              puede organizar según su realidad.
            </p>
            <span className="note-stamp">BASE DEL PROYECTO</span>
          </aside>
        </section>

        <section aria-labelledby="modules-title" className="modules-section" id="modulos">
          <div className="section-heading">
            <div>
              <p className="eyebrow">ÍNDICE <span className="index-dash">/</span> CONTENIDOS</p>
              <h2 id="modules-title">Lo esencial, bien ordenado.</h2>
            </div>
            <span className="section-count">4 ÁREAS PRINCIPALES</span>
          </div>

          <div className="module-grid">
            {modules.map((module) => (
              <article className="module-card" key={module.number}>
                <div className="module-topline">
                  <span className="module-number">{module.number}</span>
                  <span className="module-label">{module.label}</span>
                </div>
                <h3>{module.title}</h3>
                <p>{module.description}</p>
                <span aria-hidden="true" className="module-arrow">↗</span>
              </article>
            ))}
          </div>
        </section>

        <footer className="sheet-footer">
          <span>SISTEMA DE GESTIÓN ACADÉMICA</span>
          <span>UNA BASE PARA APRENDER Y AVANZAR</span>
          <span className="page-number">01</span>
        </footer>
      </div>
    </main>
  );
}
