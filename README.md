# Equilibrista — MVP 0.1

Proyecto para Godot 4.6.1 estable, GDScript y renderizador Compatibility.
Instalación detectada y utilizada:
`C:\Users\damer\Downloads\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64.exe`.
No se encontró Godot en el Escritorio; no se descargó ni reemplazó el motor.

## Ejecutar

Abrir Godot, importar el archivo project.godot de esta carpeta y pulsar F6
con scenes/game.tscn abierta, o F5 para ejecutar el proyecto.
La partida comienza automáticamente. Mantener touch, botón izquierdo del mouse
o espacio para iniciar un empuje hacia el centro desde cualquiera de los dos lados; al soltar, la fuerza natural actúa hacia el lado inclinado.
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
| Natural Torque | 1 | Fuerza hacia el lado actual de inclinación |
| Player Torque | 2.2 | Fuerza de empuje, con dirección fija durante cada pulsación |
| Acceleration | 24 | Conversión de torque a aceleración angular |
| Sensitivity | 1 | Multiplicador de entrada del jugador |
| Damping | 1.4 | Amortiguación de velocidad para facilitar correcciones |

La partida comienza cayendo hacia la izquierda. La fuerza natural sigue el signo del ángulo; exactamente horizontal conserva el último lado. La velocidad mantiene su inercia. Cada pulsación elige una fuerza opuesta al lado inclinado al iniciarse. La dirección permanece fija hasta soltar, incluso al cruzar el centro: mantener presionado termina pasando la barra hacia el lado opuesto. Para corregir desde el nuevo lado hay que soltar y volver a pulsar. La corrección frena primero la inercia: no invierte instantáneamente la velocidad.

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

## Android: APK de prueba generado

Se instalaron y configuraron con autorización del usuario:

- Temurin OpenJDK 17.0.20.1 en C:\Users\damer\AppData\Local\EquilibristaTools\jdk\jdk-17.0.20.1+1.
- Android SDK en C:\Users\damer\AppData\Local\Android\Sdk: platform-tools 37.0.1, build-tools 35.0.1, plataforma Android 35 y herramientas de línea de comandos.
- Plantillas Android de Godot 4.6.1.stable en la carpeta de plantillas del editor.
- Clave de depuración en AppData\Roaming\Godot\keystores\debug.keystore, fuera de Git.

Las rutas de Java y Android SDK quedaron configuradas en Godot. No se reemplazó
el motor ni se modificó el PATH global. La exportación usa plantillas precompiladas,
sin Gradle: no fue necesario instalar NDK ni CMake para este APK.
Se activó la importación ETC2/ASTC requerida por el exportador y se agregó un ícono
simple basado en las primitivas del juego.

Resultado: builds/Equilibrista.apk, firmado para pruebas, ARM de 32 y 64 bits.
Para regenerarlo, abrir Proyecto > Exportar > Android > Exportar proyecto con
la opción de depuración activada, o ejecutar desde esta carpeta:

```powershell
& 'C:\Users\damer\Downloads\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe' --headless --path . --export-debug Android builds/Equilibrista.apk
```

Copiar el APK al teléfono y abrirlo para instalar; permitir la instalación desde
esa aplicación si Android lo solicita. Probar pulsaciones cortas, pulsación sostenida,
reintento y cambio de foco. La firma se verifica con apksigner; aún falta probarlo
manualmente en un teléfono físico. No se publicó en una tienda.
La publicación requiere firma release y el proceso correspondiente de distribución.
No guardar claves privadas ni contraseñas en Git.

Referencia: https://docs.godotengine.org/en/4.6/tutorials/export/exporting_for_android.html

## Fuera de alcance

Sin monedas, tienda, skins, anuncios, login, backend, niveles, historia,
multijugador, logros ni progreso. Sin assets externos, física perfecta ni
arquitectura empresarial.




