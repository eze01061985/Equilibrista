# Publicación de la política de privacidad

## Estado — 28/09/2026

Borrador preparado en `docs/privacy/index.html`; contacto público y soporte: `ezequielflores.dev@gmail.com`. No publicado todavía: esta copia Git no tiene remoto y el conector de GitHub no devuelve repositorios accesibles. Se solicitó al propietario la URL del repositorio actual. No se inventó una URL ni se agregó un enlace inoperante al juego.

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

## Comprobaciones del borrador

Página abierta en Chrome por servidor local. Diseño de escritorio y viewport móvil 360 × 800 revisados; sin desbordamiento horizontal, sin scripts ni formularios. CSS y fuentes del sistema, sin dependencias externas. Android no conectado por ADB al revisar.

## Pendiente al disponer del repositorio

1. Confirmar remoto, visibilidad, rama y configuración Pages existente. No hacer público un repositorio privado sin autorización.
2. Publicar `/docs` en la rama apropiada, sin servicios pagos ni dominio propio.
3. Verificar HTTPS sin autenticación y diseño desktop/móvil en la URL definitiva.
4. Agregar esa URL comprobada en un enlace discreto de la pantalla inicial mediante `OS.shell_open`, con mouse y touch, sin evento Analytics.
5. Ejecutar las pruebas de PC y Android si está disponible; documentar la URL para Play Console en RELEASE.md.
6. Generar un nuevo artefacto de distribución cuando el enlace esté integrado: el AAB firmado anterior no contiene este cambio.

La política no sustituye las declaraciones de Data Safety, la definición de público objetivo ni la revisión de consentimiento para los mercados de distribución. No se modifican esas decisiones en esta tarea.
