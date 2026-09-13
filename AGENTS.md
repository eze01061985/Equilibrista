# Equilibrista: reglas de desarrollo

- Mantener el alcance del MVP: equilibrio, entrada, tiempo, derrota y reintento.
- Usar Godot 4.6.1 existente y GDScript. No instalar software, borrar archivos ajenos ni cambiar configuración global sin autorización.
- Priorizar KISS, legibilidad, funciones enfocadas y nombres expresivos. Aplicar SOLID y DRY solo cuando simplifiquen cambios reales; sin patrones ni abstracciones prematuras.
- Separar razonablemente simulación, entrada, presentación y parámetros de balance.
- Centralizar parámetros editables en un recurso expuesto al Inspector; evitar números mágicos de gameplay.
- Comentar el porqué, no repetir el código. Usar primitivas; no incorporar assets externos.
- Mantener touch como entrada principal y mouse/espacio para pruebas en Windows. UI adaptable.
- Probar importación, ejecución, caída en ambos sentidos, correcciones y reinicio. Corregir errores y warnings de scripts.
- Inicializar Git y realizar commits pequeños por hitos. No versionar caché, builds, claves ni credenciales.
- Documentar cómo ejecutar y las limitaciones Android reales. No presentar pruebas automatizadas como pruebas en un dispositivo físico.
