# Equilibrista — Release Candidate 1

Versión de prueba: **0.2.4-rc1 (6)**. Esta RC está dedicada a presentación; no cambia el balance.

## Presentación

- Inicio con Equilibrista, Mantén el equilibrio y JUGAR. La escena de partida se carga únicamente al jugar; la pantalla inicial no emite eventos propios.
- Durante la partida: tiempo y récord. Game Over: Perdiste el equilibrio, Tiempo, Récord, ¡NUEVO RÉCORD! cuando corresponde y Toca para reintentar.
- El panel de resultados permite seguir leyendo aunque el personaje caiga detrás. No consume los toques de reintento.
- Tipografía, contenedores y botón mínimo de 76 unidades lógicas; ajuste al viewport expandido y márgenes adicionales según el área segura de Android. Validado visualmente a 360×640, 360×800 y 768×1024.
- Audio propio sintetizado a 22.050 Hz: inicio (170 ms), derrota (240 ms) y resultado con nuevo récord (360 ms), volumen -18 dB. El nuevo récord sustituye el tono de derrota para no superponer sonidos. Sin alerta crítica repetitiva, assets externos ni dependencias nuevas.

## Datos y gameplay intactos

El récord sigue siendo responsabilidad de AnalyticsService, con ConfigFile en `user://analytics_record.cfg`: un tiempo estrictamente mayor reemplaza el récord; empatar no lo cambia. La UI consume `best_seconds` y `is_new_record` del evento existente, sin otro guardado ni cálculo de récord.

`game_started`, `game_over` y `retry` conservan nombres, parámetros, orden y deduplicación. `game_started` ocurre al entrar en la escena de partida tras JUGAR, nunca por esperar en la pantalla inicial. No hay eventos nuevos.

Sin cambios en `balance_model.gd`, `balance_settings.gd`, `player_input.gd`, `game_view.gd` ni `analytics_service.gd`. Se mantienen fuerza, damping, inercia, caída de 14 grados, taps por tiempo y umbrales/colores.

## Verificación

- Pruebas existentes: smoke, balance_v02, tap_input y analytics: PASS, sin errores ni warnings de scripts.
- `tests/rc1_test.gd`: ejecución gráfica real en Godot 4.6.1; JUGAR mediante eventos mouse/touch, tres proporciones de pantalla, seis derrotas/reintentos, récord nuevo/no nuevo, guardado persistente y orden de eventos: PASS.
- Capturas examinadas después de la animación de caída; textos y botones dentro de pantalla. Las simulaciones de input y tamaños en PC no sustituyen la prueba física Android.
- APK Android Analytics compilado correctamente fuera de OneDrive, firmado en debug (v2), versión 0.2.4-rc1 (6), instalado como actualización en Samsung SM-S921B. Conservó el récord anterior (7,0 s); el usuario probó seis partidas y cinco reintentos y logró 11,6 s, persistidos en el archivo local. Sin errores GDScript ni cierres fatales en logcat.
- SDK nativo inicializado: 6 game_started, 6 game_over y 5 retry, sin duplicados; primera apertura en menú sin game_started. La última consulta disponible de DebugView aún no mostraba la sesión RC1; la conexión de control del navegador dejó de estar disponible al intentar la comprobación final. La recepción cloud de esta RC queda pendiente, aunque los eventos nativos y su secuencia están verificados; no se modificó Analytics para intentar resolver esta demora.
- El usuario confirmó en el teléfono: interfaz y textos completos, sonidos correctos y control igual que antes. Se desactivó el modo de depuración de Firebase al cerrar la prueba.
- Manifiesto final: sin permisos AD_ID/AdServices; los seis flags de privacidad permanecen desactivados. La plantilla Gradle mantiene advertencias no bloqueantes (overridePathCheck y reglas de manifiesto), ajenas al gameplay.

## Archivos de la RC

- `scenes/start.tscn`, `scripts/start_screen.gd`: pantalla inicial.
- `scripts/presentation.gd`: estilos mínimos compartidos y márgenes seguros.
- `scripts/game_ui.gd`: HUD y resultados.
- `scripts/game_audio.gd`: tonos propios.
- `scripts/game.gd`: escucha de resultados existentes para UI/audio; simulación sin cambios.
- `project.godot`: escena inicial; se conserva el formato previo del editor.
- `export_presets.cfg`: identificación de versión RC1.
- `tests/rc1_test.gd` y los UID de scripts nuevos: comprobaciones del flujo y layout.
- `RC1.md`: esta documentación.

## Antes de publicar en Google Play

Esta entrega de presentación no incluye publicación ni alta de servicios. Falta preparar firma de lanzamiento y AAB final, política de privacidad y Seguridad de los datos acordes a Analytics, ficha/capturas y pruebas de distribución en Play. El APK de esta sesión se firma con clave debug para pruebas locales. Firebase permanece en Spark; no se modificó su configuración ni se vinculó facturación.

Área segura: implementación basada en [DisplayServer de Godot 4.6](https://docs.godotengine.org/en/4.6/classes/class_displayserver.html#class-displayserver-method-get-display-safe-area).
