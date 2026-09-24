# Equilibrista — Versión 0.2.2

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
| Fall Limit Degrees | 14 | Inclinación máxima en cualquiera de los sentidos |
| Natural Torque | 1 | Fuerza hacia el lado actual de inclinación |
| Player Torque | 2.2 | Fuerza de empuje, con dirección fija durante cada pulsación |
| Acceleration | 24 | Conversión de torque a aceleración angular |
| Sensitivity | 1 | Multiplicador de entrada del jugador |
| Damping | 1.4 | Amortiguación de velocidad para facilitar correcciones |

La partida comienza cayendo hacia la izquierda. La fuerza natural sigue el signo del ángulo; exactamente horizontal conserva el último lado. La velocidad mantiene su inercia. La primera pulsación elige una fuerza opuesta al lado inclinado; cada nueva pulsación posterior invierte la dirección de empuje anterior, incluso si todavía no cruzó el centro. La dirección permanece fija hasta soltar, incluso al cruzar el centro: mantener presionado termina pasando la barra hacia el lado opuesto. Para corregir desde el nuevo lado hay que soltar y volver a pulsar. La corrección frena primero la inercia: no invierte instantáneamente la velocidad.

El torque modifica la velocidad angular y esta modifica el ángulo en pasos
de física. No usa una simulación física de cuerpos rígidos. El objeto permanece
encima hasta perder y entonces se anima su caída. El tiempo cuenta solamente
durante una partida activa. La UI usa anclajes, escalado canvas_items y aspecto
expand; Android se configura en vertical.


| Parámetro adicional | Inicial | Función |
| --- | --- | --- |
| Warning Ratio | 0.40 | Inicio de amarillo, 5.6° con límite 14° |
| Critical Ratio | 0.75 | Inicio de rojo, 10.5° con límite 14° |
| Color Transition Seconds | 0.08 s | Constante de suavizado del color, 0 para cambio instantáneo |
| Loss Flash Seconds | 0.18 s | Duración del flash único al perder |
| Loss Flash Opacity | 0.12 | Intensidad máxima del flash; 0 para desactivarlo |

En el Inspector, Settings > Gameplay contiene el balance y Settings > Danger Feedback
contiene umbrales, colores y transiciones. Verde por debajo del 40%, amarillo desde
40% hasta 75%, rojo desde 75%; derrota a partir del 100%. El cálculo usa el ángulo
absoluto, por lo que ambos lados son simétricos. Mantener Warning Ratio menor que
Critical Ratio; si se invierten, el código coloca el umbral crítico por encima del amarillo.
Los colores Safe Color, Warning Color y Critical Color también son editables.

La versión 0.2.1 restaura la física de e4d4d6c: fuerza natural 1, corrección 2.2,
aceleración 24, sensibilidad 1 y damping 1.4. Se elimina el tope de velocidad
introducido en 0.2. Solo cambia la dificultad por el límite de 14° (antes 25°).
La velocidad sigue acumulándose y la dirección se conserva durante cada pulsación.

Reintento: una nueva pulsación touch o clic en cualquier punto reinicia al perder.
El código anterior solo conectaba el botón a _restart; no existía un manejador de
reintento fuera de él, y touch no emulaba mouse. No era una pausa del árbol.
PlayerInput comunica la nueva pulsación y Game la consume al reiniciar para que
no aplique fuerza ni dispare de nuevo la UI. Soltar no reinicia. No hay timers.

Prueba adicional: tests/balance_v02_test.gd verifica colores, flash, inercia y ocho
ciclos de pérdida/reintento alternando touch y mouse fuera del botón, incluidos
ángulo, velocidad, tiempo, entrada, direcciones, animación y mensajes reiniciados.
Sin tocar se pierde en 1.43 s frente a 2.15 s con 25°; mantener desde el centro
produce caída en 0.72 s frente a 1 s. La prueba automática de control de 60 s pasa.
La sensación humana requiere volver a probarlo; touch se validó con eventos
simulados en Godot, no en un teléfono físico.

La corrección 0.2.2 elimina la selección automática hacia el centro en cada tap: ese comportamiento permitía estabilizar con taps periódicos. No había impulsos extra. El input sigue siendo un estado y el torque se integra por delta. Se mantienen todos los parámetros, UI, colores y reintento. No se agregan cooldowns. tests/tap_input_test.gd cubre eventos duplicados, presión acumulada equivalente, spam y reintento con mouse y touch simulado. Los patrones de spam antes sobrevivían 120 s; ahora caen entre 1.37 y 1.45 s. Mantener una pulsación conserva exactamente la trayectoria anterior; alternar pulsaciones deliberadamente cambia de dirección y exige dosificarlas.

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

Resultado v0.2.2: builds/Equilibrista-0.2.2.apk, firmado para pruebas, ARM de 32 y 64 bits.
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
