# Pruebas y empaquetado automatizados

| Workflow | Cuándo se ejecuta | Resultado esperado |
|---|---|---|
| [Pruebas de SIS-INF](../.github/workflows/ci.yml) | Pull requests a `main`, cambios en `main` y ejecución manual. | Importa los recursos con Godot 4.7.2 y ejecuta cada `game/tests/test_*.gd` sin interfaz. |
| [Publicación de SIS-INF](../.github/workflows/release.yml) | Etiqueta de versión con formato `vX.Y.Z` o `vX.Y.Z-beta.N`. | Repite las pruebas, empaqueta Windows x64, Linux x86_64 y macOS universal, y reúne los binarios, las fuentes y las sumas SHA-256. Las etiquetas beta generan una publicación preliminar. |

El empaquetado reutiliza `game/packaging/build_beta.py`. Los avisos de licencia
acompañan a los paquetes. Cada compilación verifica sus sumas y la última etapa
verifica que estén los cuatro archivos antes de crear la publicación. Solo esa
etapa tiene permiso de escritura. La página de Actions muestra el resultado
por etapa y conserva los archivos de cada compilación durante siete días.

Para comprobar la instalación de un paquete, sigue la
[guía de la beta](INSTALADORES_BETA.md). La compilación de macOS usa firma ad
hoc. La notarización y la prueba gráfica en Linux y macOS siguen pendientes.

El primer resultado en GitHub queda pendiente de ejecutar en ese servicio.
Los resultados anteriores están en [Verificaciones](VERIFICACIONES.md).
