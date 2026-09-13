# Equilibrista — MVP 0.1

Proyecto para Godot 4.6.1 estable, GDScript y renderizador Compatibility.
Instalación detectada y utilizada:
`C:\Users\damer\Downloads\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64.exe`.
No se encontró Godot en el Escritorio; no se descargó ni reemplazó el motor.

## Ejecutar

Abrir Godot, importar el archivo project.godot de esta carpeta y pulsar F6
con scenes/game.tscn abierta, o F5 para ejecutar el proyecto.
La partida comienza automáticamente. Mantener touch, botón izquierdo del mouse
o espacio para aplicar torque hacia la derecha; soltar para volver hacia la izquierda.
Al superar el límite, el reloj se detiene y aparece Volver a intentar.
Al perder el foco se pausa la simulación y se limpia la entrada.

## Estructura

- scenes/game.tscn: única pantalla y recurso de configuración.
- scripts/balance_settings.gd: parámetros de balance.
- scripts/balance_model.gd: simulación, tiempo y derrota.
- scripts/player_input.gd: touch, mouse y teclado.
- scripts/game_view.gd: primitivas y animación de caída.
- scripts/game_ui.gd: contador, instrucciones y reintento.
- scripts/game.gd: coordinación de los componentes.
- tests/smoke_test.gd: pruebas reproducibles con eventos de entrada.
- export_presets.cfg: preset Android de APK debug.
- AGENTS.md: reglas de desarrollo escritas antes de implementar.

## Mecánica y ajustes

Seleccionar el nodo raíz Equilibrista en game.tscn y desplegar Settings en el Inspector.
Guardar la escena después de cambiar valores.

| Parámetro | Inicial | Función |
| --- | --- | --- |
| Fall Limit Degrees | 25 | Inclinación máxima en cualquiera de los sentidos |
| Natural Left Torque | 1 | Fuerza continua hacia la izquierda |
| Player Right Torque | 2.2 | Fuerza adicional mientras se mantiene pulsado |
| Acceleration | 24 | Conversión de torque a aceleración angular |
| Sensitivity | 1 | Multiplicador de entrada del jugador |
| Damping | 1.4 | Amortiguación de velocidad para facilitar correcciones |

El torque modifica la velocidad angular y esta modifica el ángulo en pasos
de física. No usa una simulación física de cuerpos rígidos. El objeto permanece
encima hasta perder y entonces se anima su caída. El tiempo cuenta solamente
durante una partida activa. La UI usa anclajes, escalado canvas_items y aspecto
expand; Android se configura en vertical.

## Validación

Desde esta carpeta, usando el ejecutable console de la instalación:

```powershell
& 'C:\Users\damer\Downloads\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe' --headless --path . --script tests/smoke_test.gd
```

Pruebas: caída por ambos lados, reloj detenido al perder, reinicio, control
automático durante 60 segundos y eventos touch/mouse/espacio. También se ejecutó
la prueba con renderizado OpenGL en Windows y se inspeccionó una captura.
Esto no reemplaza una prueba táctil en un dispositivo Android ni valida todavía
si el balance resulta divertido para una persona.

## Android: preparado, sin APK generado

El intento real de exportación identificó estos bloqueos:

- Faltan las plantillas de exportación 4.6.1.stable (android_debug.apk y android_release.apk).
- Godot no tiene una ruta válida de Java SDK configurada; Java no se encontró en PATH.
- La ruta configurada C:\Users\damer\AppData\Local\Android\Sdk no existe.
  Faltan platform-tools/adb y build-tools/apksigner.

No se instaló software ni se cambiaron configuraciones globales.
Para continuar, instalar/configurar con autorización OpenJDK 17, Android SDK y
las plantillas correspondientes a esta misma versión de Godot.
La documentación 4.6 especifica platform-tools, build-tools 35.0.1,
platforms android-35, cmdline-tools latest, cmake 3.10.2.4988404 y NDK 28.1.13356709:
https://docs.godotengine.org/en/4.6/tutorials/export/exporting_for_android.html

Después, establecer Java SDK Path y Android SDK Path en las opciones del editor,
abrir Proyecto > Exportar > Android y exportar con depuración a builds/Equilibrista.apk.
Probar el APK en un teléfono: pulsar/soltar, multitouch, reintento, cambio de foco,
distintas relaciones de aspecto. No se generó APK ni se publicó nada.
La publicación en tienda queda para otro hito; requiere firma release y su proceso
de distribución. No guardar claves privadas ni contraseñas en Git.

## Fuera de alcance

Sin monedas, tienda, skins, anuncios, login, backend, niveles, historia,
multijugador, logros ni progreso. Sin assets externos, física perfecta ni
arquitectura empresarial.
