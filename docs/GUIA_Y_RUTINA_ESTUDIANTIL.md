# Guía y rutina estudiantil

## Cómo jugar

- En el campus, pulsa **G** para abrir la guía. Al marcar un destino se
  resalta su ubicación en el mapa. La marca sigue visible al llegar al
  exterior del edificio o puesto.
- Entra a **Decanato**, acércate al mostrador y pulsa **E** para iniciar o
  continuar trámites. Cada expediente muestra el paso actual, sus documentos
  y las acciones de esa ventanilla. Caja, Kardex y las demás etapas son parte
  del recorrido simulado del expediente.
- En **Dirección de Carrera**, en el edificio de Administración de Sistemas,
  consulta Auxiliaturas, postula y abre las carpetas de la convocatoria o del
  trabajo asignado.
- Pulsa **H** en el recorrido para abrir el horario o consulta una pizarra de **Ciclo Básico**.
  El horario de tus inscripciones indica el día, la franja, el aula y el piso.
  En la pizarra pulsa **E**. Si la clase todavía no comenzó, puedes esperar en
  el aula. El reloj y las necesidades avanzan durante esa espera. Al terminar
  de escribirse la pizarra se guarda el apunte en la mochila. Los parciales
  se habilitan al iniciar el semestre.
- Acércate a un puesto y pulsa **E** para comprar. Con **Tab** abres o cierras la mochila. Puedes
  cambiar entre **Alimentos**, **Carpetas** y **Apuntes** con **1–3** o **←/→**.
  Selecciona alimentos con **↑/↓** y consúmelos con **Enter**.
  El comedor y el kiosco están dentro del campus. Encuentra el pollo, el café
  espumoso, la tienda con licor y el camión de milanesas por el ingreso exterior.

## Teclas según la pantalla

| Pantalla | Teclas |
|---|---|
| Recorrido | WASD o flechas para moverte, Shift para correr, E para interactuar, J para la misión actual, M para el mapa y F1 para los controles. |
| Mochila | Tab para abrir desde el mundo, la pausa, el mapa o un puesto. Tab o Esc devuelve a la pantalla desde la que entraste. |
| Pausa y pantallas académicas | Esc pausa o regresa. F2–F5 abre los accesos anunciados en el campus. En las listas, ↑/↓ permite seleccionar, Enter confirma y Re Pág/Av Pág recorre el contenido extenso. |
| Formularios | Tab y Mayús+Tab recorren campos. Los atajos de juego ceden mientras escribes. |
| Mapas y grafos | Flechas y teclas indicadas en el lienzo. +/− y la rueda ajustan el zoom. |

## Reglas del juego

El saldo inicial y la asignación por semana simulada son de 100 créditos.
La mochila tiene 12 espacios para consumibles y conserva aparte documentos
y apuntes. Hay agua sin costo. El hambre y la sed crecen con el tiempo
jugable y reducen un poco la velocidad al alcanzar un nivel alto. El licor
es un producto recreado sin efecto de hidratación. Los precios, horarios,
contenidos de pizarra y ubicaciones de puestos son valores del juego.

El reloj, la mochila y las necesidades se guardan con la exploración de cada
partida. Una partida antigua inicializa estos datos al retomar el recorrido.
Las visitas libres conservan su estado durante la sesión.

## Pendientes de frontend

- Dibujar las carpetas según el trámite real del juego. La portada muestra
  número y tipo de expediente, estado y organismo responsable del paso.
  Separadores de materiales, comprobantes y observaciones deben apuntar a
  los datos existentes. En menú y mostrador, dejar visible una sola acción
  principal de avance con las casillas de requisitos encima.
- Señalizar Decanato, Dirección de Carrera y Ciclo Básico con nombres,
  símbolos y contraste legible. Hacer coincidir carteles y mapa. Conservar
  navegación por teclado, foco visible y diseño adaptable con texto ampliado.
- Componer la pizarra, docente y escritorios alrededor de las líneas de clase.
  En movimiento reducido, mantener legibles el contenido y el progreso sin
  efectos de escritura por carácter. Ilustrar cada puesto y el camión con
  puestos y productos reconocibles. Conservar los nombres, precios y efectos
  en texto. Dar iconos distintos al hambre y la sed y conservar sus valores.
- Revisar el balance en una sesión larga. Hace falta medir con jugadores
  cuánto rinde el saldo y con qué frecuencia necesitan abrir la mochila.

## Fuentes pendientes

Para sustituir la recreación hacen falta horarios o listados de aulas por
materia y paralelo, temarios o apuntes autorizados, formularios y orden de
oficinas vigentes, y un croquis o fotos propias de los puestos con permiso
de uso. Consultar el [registro de fuentes](PARA_BACKEND_DATOS_Y_FUENTES.txt).

## Capturas de comprobación

Godot 4.7.2 en Windows. Partida ficticia de Sistemas, vista lógica de
1200 × 780. Las parejas muestran el mismo aula y los apuntes de Física I
antes y después de aplicar los atajos contextuales.

| Pantalla | Antes | Después |
|---|---|---|
| Aula en Ciclo Básico | [Botonera del recorrido](evidencia/teclado/aula-antes.png) | [Indicaciones de interacción, misión y pausa](evidencia/teclado/aula-despues.png) |
| Mochila | [Inventario, carpetas y apuntes en una vista](evidencia/teclado/mochila-antes.png) | [Apuntes en su bolsillo, seleccionable mediante 3 o flechas](evidencia/teclado/mochila-despues.png) |
