# Release Android — Equilibrista 0.2.4

## Configuración

- Package: `com.ezequielflores.equilibrista`.
- Preset: **Android Release** (no cambia Android ni Android Analytics).
- versionName: **0.2.4**; versionCode: **7** (superior a la RC1 local, código 6).
- Godot y plantilla: **4.6.1**; Java **17.0.20.1**; Gradle **8.11.1**.
- Android Gradle Plugin **8.9.1**, compile/target SDK **36**, min SDK **24**, Build Tools **35.0.1**.
- ARM64 y ARMv7. Firebase Core/Analytics conservados, sin servicios adicionales.

SDK 36 y AGP 8.9.1 fueron autorizados el 27/09/2026. AGP/compileSdk se ajustan en una copia de build fuera de OneDrive; los presets y la plantilla de desarrollo no se alteran. No se actualiza Godot, Gradle ni Java.

## Compilar y firmar

Desde la raíz del proyecto, en PowerShell:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\build_release.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\sign_release.ps1
```

El primer script comprueba herramientas, copia el proyecto a `%LOCALAPPDATA%/EquilibristaTools/release-<id>`, excluye assets generados de exportaciones previas (evita duplicados entre base y asset pack), aplica los ajustes autorizados y exporta con `--export-release`. La copia usa firma interna desactivada: genera `builds/Equilibrista-0.2.4-unsigned.aab`, que NO debe subirse a Play. El preset versionado conserva firma habilitada; el flujo reproducible soportado son estos scripts, porque aplican AGP/SDK en la copia temporal y separan la firma. No guardar contraseñas en Godot.

El segundo script firma con `jarsigner` y deja **releases/Equilibrista-0.2.4-release.aab**. No pasa contraseñas a Godot ni Gradle. La contraseña se ingresa oculta en la terminal local, se entrega a keytool/jarsigner mediante una variable de entorno temporal y se elimina de ese proceso al finalizar. No ejecutar con transcripción ni herramientas de diagnóstico que vuelquen variables de entorno.

Por defecto busca el keystore de carga en:

```text
C:/Users/damer/.android/keystores/Equilibrista/equilibrista-upload.jks
```

Alias: **equilibrista-upload**. Si existe, lo reutiliza. Si falta, pide contraseña y confirmación antes de crear RSA de 3072 bits y certificado de 10000 días, identificado como `Equilibrista Upload`. La misma contraseña protege almacén y clave. La identidad del certificado es una etiqueta técnica, no una verificación de identidad comercial.

**Guardar la contraseña en un gestor y respaldar el keystore en un lugar seguro fuera del repositorio.** No generar una nueva clave para cada release. El `.pem` generado en releases es solo el certificado público; no reemplaza el respaldo del keystore.

Esta clave local sirve como clave de carga para Play App Signing. No se gestionó ni creó una clave de firma de Google Play y no se ingresó en Play Console.

## Versiones futuras

Incrementar `version/code` del preset Android Release a un entero superior a la última versión subida a Play (siguiente tras esta: **8**, si no se usó antes). Cambiar `version/name` solo al cambiar la versión visible. Actualizar también los nombres de salida en ambos scripts al pasar de 0.2.4 a otra versión. No cambiar el package. Los scripts no sobrescriben un AAB final existente.

## Verificación

Usar bundletool oficial 1.18.3 para `validate`, `dump manifest` y `dump config`, y `jarsigner -verify` para la firma. Confirmar package, código 7, nombre 0.2.4, target 36, min 24, debuggable ausente/false, arquitecturas, Firebase y compatibilidad de bibliotecas nativas con páginas de 16 KB. Verificar también que el certificado corresponda al keystore de carga y no al debug.

Verificado el 27/09/2026: exportación release completa y reproducible, bundletool validate correcto, package/version/SDK correctos, sin debuggable, ARMv7 y ARM64, configuración Firebase coincidente y restricciones de privacidad conservadas. Bundle con PAGE_ALIGNMENT_16K y todas las bibliotecas ARM64 con segmentos PT_LOAD alineados a 16384. Test automatizado RC1 aprobado (JUGAR mouse/touch, tres relaciones de aspecto, récord, seis derrotas/reintentos y eventos sin duplicados). Sin cambios en scripts, escenas ni addons respecto de RC1. No se realizó una prueba física de este AAB aún.

Build unsigned: 53218141 bytes; SHA256 `7f313a05fd72c96a72014893bb73092f43bdff87a1772cafb2e9da6628ddcc5e`. El unsigned es únicamente intermedio; no subirlo a Play.

AAB final firmado: `releases/Equilibrista-0.2.4-release.aab`, 53241101 bytes. SHA256: `97ca69914b183665e354ace5bafdbd5af188f69d5ea260949d880f34ceb27e1c`. Firma y bundletool validate aprobados; todos los contenidos originales coinciden byte a byte con el unsigned validado. Certificado de carga nuevo, CN=Equilibrista Upload, RSA 3072, válido hasta 12/02/2054. Huella SHA256: `55:28:41:B9:44:D6:7F:92:AF:34:03:A5:1B:F8:64:7D:7A:B5:CA:F9:CF:09:5F:50:DC:B1:BD:C2:8E:A1:83:29`. Coincide con el certificado público exportado. Contraseña elegida e ingresada localmente por el usuario.

Los avisos de jarsigner sobre certificado autofirmado/cadena no confiable y ausencia de timestamp son esperables para esta clave de carga; la firma criptográfica se verificó. El aviso de keytool sobre formato JKS no requiere regenerar ni migrar la clave. Respaldo del keystore a cargo del usuario.

Warnings no bloqueantes del toolchain: android.overridePathCheck experimental, lector SDK XML v3 frente a metadatos v4, directivas de merge del manifest sin otra declaración y bibliotecas nativas empaquetadas sin stripping adicional. No hay errores de exportación ni de scripts. No se instalaron componentes extra para silenciar estos avisos.

## Exclusiones y alcance

`.gitignore` excluye `.godot/`, `android/build/`, `builds/`, `releases/`, `*.aab`, `*.keystore`, `*.jks`, `*.p12`, `*.pfx`, `*.password` y `google-services.json`. No guardar contraseñas en presets, scripts o documentación. Las variables de entorno usadas para firmar no se deben persistir a nivel de usuario/sistema.

Sin cambios en gameplay, UI, audio, récord, física, controles o código/eventos de Analytics. No se publicó, subió ni aceptó ningún acuerdo de Play. Firebase sigue en Spark y no se habilitó billing.

Referencias: [target API de Play](https://support.google.com/googleplay/android-developer/answer/11926878?hl=es), [compatibilidad AGP](https://developer.android.com/build/releases/about-agp), [bundletool](https://github.com/google/bundletool/releases/tag/1.18.3).
