# Mapa del campus para correcciones por cuadrantes

Generado: 3 de noviembre de 2026. Mapa `fni_ciudad_v2`, 12288 × 8704 unidades
de juego. Las láminas muestran el estado dibujado por el juego y sirven para
revisar posiciones, formas, distancias y contenido. No son planos institucionales
verificados ni una nueva propuesta de distribución.

## Archivos disponibles

Los PNG se generan localmente en `game/.test-artifacts/mapa-cuadrantes/`, fuera
del control de versiones. En una copia nueva del proyecto se regeneran mediante
el script indicado debajo.

| Lámina | Mitad del mapa en pantalla | Resolución | Referencias visibles |
|---|---|---|---:|
| [Índice general](../game/.test-artifacts/mapa-cuadrantes/00-indice.png) | Ubicación de Q1, Q2, Q3 y Q4. | 1632 × 1272 | Vista de conjunto |
| [Q1](../game/.test-artifacts/mapa-cuadrantes/Q1.png) | Superior izquierda; X 0–50 %, Y 0–50 %. | 3200 × 2760 | 15 |
| [Q2](../game/.test-artifacts/mapa-cuadrantes/Q2.png) | Superior derecha; X 50–100 %, Y 0–50 %. | 3200 × 2760 | 15 |
| [Q3](../game/.test-artifacts/mapa-cuadrantes/Q3.png) | Inferior izquierda; X 0–50 %, Y 50–100 %. | 3200 × 2760 | 19 |
| [Q4](../game/.test-artifacts/mapa-cuadrantes/Q4.png) | Inferior derecha; X 50–100 %, Y 50–100 %. | 3200 × 2760 | 25 |
| [Mapa completo](../game/.test-artifacts/mapa-cuadrantes/mapa-completo.png) | Unión de las cuatro regiones, con códigos y rejilla. | 6144 × 4352 | Todas |
| [Referencias](../game/.test-artifacts/mapa-cuadrantes/referencias.json) | IDs del código, nombres y porcentajes de cada marcador. | JSON | Por cuadrante |

Se conserva la orientación del plano en pantalla. **Superior/inferior e
izquierda/derecha no equivalen a norte/sur geográfico.** X crece a la derecha;
Y crece hacia abajo. Los porcentajes siempre se refieren al mapa completo.

Los cortes pasan por X 50 % e Y 50 %. Los edificios o zonas que cruzan un corte
aparecen en ambas láminas con el mismo código y la indicación «continúa».
El marcador se coloca en la parte visible de ese elemento. Su posición de
anotación no sustituye la geometría o la puerta real del juego.

## Cómo señalar una corrección

Indicar cuadrante, código y cambio. Por ejemplo: «Q4, B33: el bloque 100 tiene
esta forma», «Q2, M02: la cabra está más cerca del camino» o «Q4, en X 65 %,
Y 80 %: aquí falta un sendero». Se pueden aportar croquis, fotografías o
una lámina marcada. Antes de convertir una corrección en dato institucional,
conservar su procedencia y confirmar qué parte es observación o distribución
provisional, como establece [Campus ampliado](CAMPUS_AMPLIADO_Y_VIDA_DEL_CAMPUS.md).

| Código | Tipo de referencia |
|---|---|
| `B01`…`B40` | Edificios; el pie de cada lámina indica el nombre. |
| `C01`…`C09` | Canchas. |
| `G01`…`G07` | Jardines y zonas de pasto. |
| `P01`, `P02` | Estacionamientos. |
| `V01` | Bosque del ingreso, Q4. |
| `V02` | Asientos FNI, Q2. |
| `A01` | Laguna de Civil, Q4. |
| `M01` | Piedritas, Q4. |
| `M02` | Chivato, Q2. |
| `F01`…`F03` | Fuentes de agua. |
| `I01` | Aparición del jugador junto al ingreso, Q4. |

Los códigos de revisión corresponden a esta exportación. Los IDs persistentes
del juego están en el JSON: por ejemplo, `B33` corresponde a `fis_mat` y `B34`
a `basicas`. Si cambia el catálogo, regenerar las láminas y sus referencias.

## Generación y comprobaciones

`game/tools/export_campus_quadrants.gd` reutiliza `campus_world.gd`, el paisaje,
los edificios, las canchas, los árboles y el arte procedural vigentes. Añade
rótulos, rejilla, leyenda e índice en una superficie de captura independiente;
no cambia posiciones, guardados, reglas académicas ni interfaces del juego.

Desde la raíz, con Godot y renderizador gráfico disponibles:

```powershell
.\game\.tools\Godot_v4.7.2-stable_win64_console.exe --path game --script res://tools/export_campus_quadrants.gd --rendering-method gl_compatibility --log-file .test-artifacts/quadrants-export.log
```

Se ejecutaron la comprobación sintáctica del script y la generación gráfica
de los seis PNG y del JSON, con perfil aislado. La revisión visual comprueba
composición, correspondencia de cuadrantes, códigos y leyendas; las posiciones
institucionales siguen pendientes de las correcciones del usuario. Los
registros son `game/.test-artifacts/quadrants-check.log` y
`quadrants-export.log`, más la salida de `quadrants-session/`. La GPU utilizó
ANGLE, como en las capturas anteriores.

## Avances paralelos que deben conservarse

El summary combinado incluye los minijuegos y el campus ampliado. Las
verificaciones registradas son 14.422 aserciones para minijuegos y 3.664 para
campus, ambas sin fallos; son ejecuciones anteriores documentadas en
[Verificaciones](VERIFICACIONES.md), no pruebas repetidas al exportar las láminas.
El ejecutable previamente exportado incluye el estado compartido de esos cambios.

Al integrar los cambios compartidos, conservar la navegación y la ampliación
de tableros en `game.gd`, el dibujo y controles de `minigame_board.gd`, y las
señales y reloj de `career_presentation_view.gd`. El diseño y animación del
personaje de pausa continúan pendientes de frontend; su contrato está en
[Modo demostrativo](MODO_DEMOSTRATIVO.md). Los profesionales, estudiantes y
perros del campus son otro catálogo, con tareas de motor registradas en
[Campus ampliado](CAMPUS_AMPLIADO_Y_VIDA_DEL_CAMPUS.md).
