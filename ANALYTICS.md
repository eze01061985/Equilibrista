# Analítica mínima

**Estado (26/09/2026):** proyecto Firebase **Equilibrista** (`equilibrista-58746`) y app **Equilibrista Android** configurados en **Spark**, sin vincular facturación, tarjeta ni Blaze. Ubicación Analytics: Argentina; Gemini, programa de desarrolladores y uso compartido opcional desactivados. Inicialización nativa y recepción real en DebugView confirmadas en Android. El preset **Android** sigue sin SDK/red. **Android Analytics** usa Gradle, Firebase Core 22.0.1 y Analytics 23.0.0 mediante [Godotx Firebase 2.4.1](https://github.com/godot-x/firebase/tree/2.4.1), versión publicada para Godot 4.6. No instalar la última versión sin verificar compatibilidad.

Validación de exportación: **Android Analytics 0.2.3 (5)** compilado y firmado en debug; instalado en Samsung SM-S921B. `prepare_analytics.ps1` valida el JSON real y termina correctamente. El APK final usa `com.ezequielflores.equilibrista`, no incluye permisos AD_ID/AdServices y conserva los seis flags de privacidad. La exportación en OneDrive falló al limpiar temporales bloqueados; compilación exitosa desde una copia fuera de OneDrive, en `%LOCALAPPDATA%/EquilibristaTools/firebase-build-20260926`, sin cambiar gameplay. Advertencias de plantilla/manifest y librerías sin strip no impiden compilar. Las pruebas de Analytics pasan sin errores de scripts.

## Verificación real (26/09/2026)

- App **Equilibrista Android**, paquete **com.ezequielflores.equilibrista**, proyecto `equilibrista-58746`; plan **Spark** verificado en consola. No se vinculó billing ni tarjeta ni se habilitó Blaze u otros productos.
- Archivo local: `C:/Users/damer/OneDrive/Escritorio/Equilibrista/google-services.json`. Se descargó de Firebase sin editarlo; está ignorado por Git, igual que su copia de Gradle.
- `tools/prepare_analytics.ps1`: **Configuración lista. Exportá con el preset Android Analytics.**
- APK debug 0.2.3 (5), firma v2 verificada e instalación correcta en Samsung SM-S921B. Firebase Core y Analytics inicializaron correctamente.
- DebugView observó **3 game_started, 3 game_over y 2 retry**, correspondientes a tres partidas y dos reintentos físicos del usuario; sin duplicados evidentes. `retry` incluye `attempt_number` (primer reintento: 1). Se observaron también los eventos automáticos `first_open` y `session_start`, una vez cada uno.
- En DebugView: `non_personalized_ads = 1`. Manifiesto final sin AD_ID ni permisos AdServices; no se agregó tracking publicitario.
- No se detectaron errores GDScript, errores de Firebase ni cierres fatales en el proceso del juego. Google Play Services emitió una advertencia interna de FlagStore/certificados; no impidió inicializar ni recibir los eventos reales.
- Al terminar, se desactivó el modo DebugView del teléfono (`debug.firebase.analytics.app = .none.`) y se restauró logging FA/FA-SVC a INFO. Cerrar y volver a abrir la app para las siguientes pruebas normales.
- Ningún archivo de gameplay, balance, UI, récord o controles fue cambiado por esta configuración.
## Eventos

| Evento | Momento confirmado | Parámetros numéricos |
|---|---|---|
| game_started | Escena lista o reinicio terminado | attempt_number (1, 2…) |
| game_over | Transición a derrota, después de actualizar el juego | survival_seconds (decimal), is_new_record (0/1), attempt_number |
| retry | Reinicio realizado después de perder, antes del nuevo game_started | attempt_number de la partida perdida |

No hay eventos por tap/frame/color. No duplicamos aperturas, first_open ni session_start del SDK. No enviamos new_record separado: game_over contiene la información. Récord estrictamente mayor, guardado en user://analytics_record.cfg; empate no cuenta. No existía un récord previo. Es local por instalación, empieza en cero y se evalúa al terminar la partida. No agrega UI.

AnalyticsService contiene deduplicación, contador, récord y proveedor. Game solo llama después de confirmar cambios. PC/sin plugin: logging en debug y no-op en release. Inicialización nativa diferida; cola de arranque acotada a 128 eventos, descartable ante fallos; el SDK maneja envío offline. Nunca esperamos a la red para jugar. Eventos sin entrega no se reintentan desde GDScript.

## Activar Firebase real

1. Crear/seleccionar proyecto Firebase con Google Analytics habilitado y registrar Android: **com.ezequielflores.equilibrista**.
2. Descargar **google-services.json** y colocarlo en la raíz del proyecto (ignorado por Git). No usar credenciales de cuenta de servicio.
3. Ejecutar **tools/prepare_analytics.ps1**. La plantilla Android 4.6.1 ya está instalada localmente; si se reinstala, ejecutar el script otra vez.
4. Exportar con **Android Analytics**. Solo Core y Analytics habilitados; no Crashlytics, Messaging, anuncios ni login.
5. Instalar en un teléfono, comprobar conexión y abrir Firebase → Analytics → DebugView.

Con adb del SDK:

```text
adb shell setprop debug.firebase.analytics.app com.ezequielflores.equilibrista
adb shell setprop debug.firebase.analytics.app .none.
```

La primera línea activa DebugView y la segunda lo desactiva. Abrir → perder → tocar → perder: comprobar la secuencia y attempt_number creciente. Para validar récord: una partida corta, otra más larga y otra más corta. Los eventos debug no deben usarse para cifras de producción.

En PC, F5 muestra [Analytics] solamente en debug. Prueba automatizada:
```text
Godot_v4.6.1-stable_win64_console.exe --path . --script tests/analytics_test.gd --quit-after 300
```
Comprueba orden, duplicados, tres derrotas/reintentos, récord persistido, empate y fallo/ausencia de proveedor. Usa un archivo de prueba separado.

## Consultas

Firebase/GA4 → Events para partidas/derrotas/retries; Realtime y DebugView para comprobación; informes estándar para usuarios, sesiones y retención. Registrar survival_seconds como métrica personalizada y is_new_record/attempt_number como dimensiones si se necesitan en exploraciones. Ratio simple: retry / game_over × 100 (ventanas iguales; los límites temporales y eventos perdidos pueden afectar el cociente). Récords: game_over filtrado por is_new_record=1.

## Privacidad / Google Play

Los eventos propios solo contienen esos números: no nombre, email, texto libre, user_id ni identificadores creados por el juego. **Firebase no es anonimato absoluto:** genera app-instance ID y puede recolectar información de dispositivo/aplicación, actividad y ubicación aproximada derivada de IP. No pedimos ubicación precisa ni contactos.

El plugin local analytics_privacy agrega flags para desactivar Advertising ID, SSAID, personalización publicitaria, ad storage/ad user data y pantallas automáticas; elimina AD_ID y permisos AdServices del manifiesto. Mantener Google Signals, enlaces a Google Ads y personalización desactivados en la consola. Verificar el manifiesto final antes de publicar.

Para el preset con SDK, revisar/declarar actividad de la app, identificadores de dispositivo/instalación y ubicación aproximada según el SDK/configuración final, finalidad analítica, transmisión cifrada, retención y eliminación. Revisar política de privacidad y consentimiento para los mercados de distribución; esta tarea no añade una pantalla de consentimiento. No declarar simplemente “no recolecta datos”.

Fuentes oficiales: [datos recolectados](https://support.google.com/analytics/answer/11582702), [configuración](https://firebase.google.com/docs/analytics/android/configure-data-collection), [DebugView](https://firebase.google.com/docs/analytics/debugview).
