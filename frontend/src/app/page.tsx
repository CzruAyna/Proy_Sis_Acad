const modules = [
  "Malla curricular y prerrequisitos",
  "Inscripciones con control de cupos",
  "Horarios flexibles para estudiantes",
  "Documentos institucionales",
];

export default function Home() {
  return (
    <main className="mx-auto flex min-h-screen max-w-5xl flex-col justify-center px-6 py-20">
      <p className="text-sm font-semibold uppercase tracking-widest text-sky-700">
        Proyecto en preparación
      </p>
      <h1 className="mt-4 text-4xl font-bold tracking-tight md:text-6xl">
        Sistema de Gestión Académica
      </h1>
      <p className="mt-6 max-w-2xl text-lg leading-8 text-slate-600">
        Una base abierta para organizar planes de estudio, oferta académica,
        inscripciones y procesos universitarios.
      </p>
      <ul className="mt-10 grid gap-3 sm:grid-cols-2">
        {modules.map((module) => (
          <li
            className="rounded-lg border border-slate-200 bg-white p-4 text-slate-700"
            key={module}
          >
            {module}
          </li>
        ))}
      </ul>
      <p className="mt-10 text-sm text-slate-500">
        Interfaz inicial · API local prevista en http://localhost:8000
      </p>
    </main>
  );
}
