# Equilibrista: reglas de desarrollo

- Mantener el alcance del MVP: equilibrio, entrada, tiempo, derrota y reintento.
- Usar Godot 4.6.1 existente y GDScript. El usuario autorizó de forma persistente instalar y configurar los componentes necesarios para este proyecto (13/09/2026); continuar sin pedir nuevamente esa autorización. Mantener los cambios acotados al proyecto y sus herramientas. No interpretar esta autorización como permiso para borrar archivos ajenos.
- Priorizar KISS, legibilidad, funciones enfocadas y nombres expresivos. Aplicar SOLID y DRY solo cuando simplifiquen cambios reales; sin patrones ni abstracciones prematuras.
- Separar razonablemente simulación, entrada, presentación y parámetros de balance.
- Centralizar parámetros editables en un recurso expuesto al Inspector; evitar números mágicos de gameplay.
- Comentar el porqué, no repetir el código. Usar primitivas; no incorporar assets externos.
- Mantener touch como entrada principal y mouse/espacio para pruebas en Windows. UI adaptable.
- Probar importación, ejecución, caída en ambos sentidos, correcciones y reinicio. Corregir errores y warnings de scripts.
- Inicializar Git y realizar commits pequeños por hitos. No versionar caché, builds, claves ni credenciales.
- Documentar cómo ejecutar y las limitaciones Android reales. No presentar pruebas automatizadas como pruebas en un dispositivo físico.
