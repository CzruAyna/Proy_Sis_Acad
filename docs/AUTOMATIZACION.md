# Pruebas y empaquetado automatizados

| Workflow | Cuándo se ejecuta | Resultado esperado |
|---|---|---|
| [Pruebas de SIS-INF](../.github/workflows/ci.yml) | Pull requests a `main`, ejecución manual y llamada desde el workflow de publicación. | Importa los recursos con Godot 4.7.2 y ejecuta cada `game/tests/test_*.gd` sin interfaz. |
| [Publicación de SIS-INF](../.github/workflows/beta.yml) | Cada push a una rama, o una etiqueta `vX.Y.Z` o `vX.Y.Z-beta.N`. | Ejecuta las pruebas y empaqueta Windows x64, Linux x86_64 y macOS universal. Ante un fallo, la publicación queda detenida en la etapa que reportó el error. |

Las publicaciones de rama usan el nombre **SIS-INF 0.2.0-beta.N** y la
etiqueta `v0.2.0-beta.N`. El número corresponde a la ejecución del flujo.
Reintentar una ejecución conserva su número.
Las etiquetas `vX.Y.Z` mantienen su versión y las `vX.Y.Z-beta.N` se
publican como preliminares. [Publicaciones](https://github.com/CzruAyna/Proy_Sis_Acad/releases)

El empaquetado reutiliza `game/packaging/build_beta.py`. Los avisos de licencia
acompañan a los paquetes. Cada compilación verifica sus sumas y la última etapa
verifica que estén los cuatro archivos antes de crear la publicación. Solo esa
etapa tiene permiso de escritura y usa el token del propio workflow.
La página de Actions muestra el resultado
por etapa y conserva los archivos de cada compilación durante siete días.

Para comprobar la instalación de un paquete, sigue la
[guía de la beta](INSTALADORES_BETA.md). La compilación de macOS usa firma ad
hoc. La notarización y la prueba gráfica en Linux y macOS siguen pendientes.

Los resultados por commit están en [Verificaciones](VERIFICACIONES.md) y
[GitHub Actions](https://github.com/CzruAyna/Proy_Sis_Acad/actions).
