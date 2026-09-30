# Publicación de la política de privacidad

## Estado — 29/09/2026

Política publicada: https://eze01061985.github.io/Equilibrista/privacy/

Repositorio público: https://github.com/eze01061985/Equilibrista. Rama principal: `master`. GitHub Pages publica `/docs` desde esa rama, con HTTPS. Se conservó todo el historial Git local. Contacto público y soporte: `ezequielflores.dev@gmail.com`.

Pantalla inicial: enlace secundario «Política de privacidad», abre el navegador externo mediante `OS.shell_open`. Sin WebView ni eventos nuevos. La posición y comportamiento de JUGAR permanecen iguales.

## Revisión de datos

Se revisaron `scripts/analytics_service.gd`, sus llamadas en `scripts/game.gd`, `addons/analytics_privacy/plugin.gd`, `export_presets.cfg` y `ANALYTICS.md`. Coinciden con la descripción del juego:

- Firebase Core 22.0.1 y Analytics 23.0.0 en Android Analytics / Android Release; preset Android sin SDK.
- `game_started`: `attempt_number`.
- `game_over`: `survival_seconds`, `attempt_number`, `is_new_record`.
- `retry`: `attempt_number` de la partida perdida.
- Parámetros numéricos; sin user_id, texto libre ni datos personales ingresados por jugadores.
- Sin cuentas, login, compras, AdMob, anuncios, backend propio, ubicación precisa ni contactos.
- Récord local en `user://analytics_record.cfg`.
- Flags publicitarios desactivados y permisos AD_ID/AdServices eliminados por el plugin de exportación.
- Firebase puede procesar identificadores de instalación y datos técnicos; no se describe como totalmente anónimo.

Fuentes consultadas:
- https://support.google.com/analytics/answer/11582702
- https://support.google.com/analytics/answer/9268042
- https://firebase.google.com/docs/analytics/android/configure-data-collection
- https://firebase.google.com/support/privacy

No se cambiaron eventos ni configuración de Analytics. La revisión de código no reemplaza revisar retención, Google Signals y vínculos publicitarios de la consola antes de completar Data Safety.

## Comprobaciones realizadas

- HTTP 200 por HTTPS sin cookies ni autenticación, contenido idéntico al HTML local.
- Página pública revisada en Chrome en escritorio y viewport 360 × 800: sin desbordamiento horizontal. HTML publicado sin scripts, formularios ni dependencias externas.
- Godot ejecutado con renderizado en PC. Click y touch simulados desde `tests/privacy_link_test.gd -- --open-browser` abrieron dos pestañas externas con la URL correcta; cada entrada abrió una sola vez y mantuvo el menú.
- Prueba del retorno al menú, JUGAR, derrota por simulación física y reintento. Test RC1 aprobado en tres relaciones de aspecto con seis derrotas/reintentos. Test de Analytics aprobado, sin cambios en sus eventos ni parámetros. Sin errores o warnings GDScript en estas pruebas.
- Android físico: APK debug con Firebase instalado mediante `adb install -r`, sin borrar datos. Récord de 11,6 s conservado. El usuario confirmó apertura de la política en navegador, vuelta al juego, partida y dos reintentos correctos, con presentación y control intactos. Exportación sin errores de scripts. Al revisar posteriormente los logs, el proceso del juego ya no estaba disponible; no se afirma una revisión completa del log de esa sesión ni una nueva comprobación en Firebase DebugView.
- Revisión del historial completo antes del push: sin archivos de credenciales/keystore/APK/AAB ni coincidencias con los patrones de secretos comprobados. Exclusiones de APK y .env reforzadas. `project.godot` conserva un cambio local previo de formato, no incluido en los commits de esta tarea.

Para volver a probar la apertura real del navegador en PC:

```text
Godot --path . --script tests/privacy_link_test.gd -- --open-browser
```

Sin `--open-browser`, el test comprueba el despacho de input sin lanzar navegadores. El test RC1 existente comprueba además los estados y eventos de partidas consecutivas.

## Para Google Play

Pegar https://eze01061985.github.io/Equilibrista/privacy/ en el campo Política de privacidad. No se cambió Play Console en esta tarea.

El AAB firmado anterior no contiene el enlace: compilar y firmar un nuevo artefacto antes de publicar el juego actualizado. Completar Data Safety y público objetivo conforme a la configuración real; revisar conservación y consentimiento para los mercados elegidos. Esta tarea no cambia esas decisiones.
