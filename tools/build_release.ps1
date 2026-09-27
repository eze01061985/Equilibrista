param(
    [string]$GodotPath = "$env:USERPROFILE\Downloads\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64.exe",
    [string]$SdkPath = "$env:LOCALAPPDATA\Android\Sdk",
    [string]$JavaPath = "$env:LOCALAPPDATA\EquilibristaTools\jdk\jdk-17.0.20.1+1"
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
foreach ($required in @($GodotPath, "$SdkPath\platforms\android-36\android.jar", "$JavaPath\bin\java.exe", "$projectRoot\google-services.json", "$projectRoot\android\build\config.gradle")) {
    if (-not (Test-Path -LiteralPath $required)) { throw "Falta componente: $required" }
}
$engineVersion = & $GodotPath --version
if ($engineVersion -notlike '4.6.1.*') { throw 'Esta release requiere Godot 4.6.1 y su plantilla correspondiente.' }
# Compilar fuera de OneDrive evita los bloqueos de temporales observados en RC1.
$workRoot = Join-Path $env:LOCALAPPDATA ('EquilibristaTools\release-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $workRoot | Out-Null
& robocopy $projectRoot $workRoot /E /XD .git .godot builds releases "$projectRoot\android\build\build" "$projectRoot\android\build\.gradle" "$projectRoot\android\build\src\main\assets" "$projectRoot\android\build\assetPackInstallTime\src\main\assets" /NFL /NDL /NJH /NJS /NP | Out-Null
if ($LASTEXITCODE -ge 8) { throw 'No se pudo preparar la copia de compilación.' }
& (Join-Path $workRoot 'tools\prepare_analytics.ps1')
$configPath = Join-Path $workRoot 'android\build\config.gradle'
$config = Get-Content -LiteralPath $configPath -Raw
$config = $config.Replace("androidGradlePlugin: '8.6.1'", "androidGradlePlugin: '8.9.1'")
$config = $config -replace '(compileSdk\s*:\s*)35\b', '${1}36'
if ($config -notmatch "androidGradlePlugin: '8.9.1'" -or $config -notmatch 'compileSdk\s*:\s*36') { throw 'La plantilla Android cambió; revisar antes de compilar.' }
[IO.File]::WriteAllText($configPath, $config, [Text.UTF8Encoding]::new($false))
# Solo la copia temporal se exporta sin firma. La firma final se realiza con jarsigner,
# para que Godot/Gradle nunca reciban ni registren contraseñas como argumentos.
$presetPath = Join-Path $workRoot 'export_presets.cfg'
$presets = Get-Content -LiteralPath $presetPath -Raw
$releaseSection = $presets.IndexOf('[preset.2]')
if ($releaseSection -lt 0 -or $presets.Substring($releaseSection) -notmatch 'name="Android Release"') { throw 'No se encontró el preset Android Release.' }
$presets = $presets.Substring(0, $releaseSection) + $presets.Substring($releaseSection).Replace('package/signed=true', 'package/signed=false')
[IO.File]::WriteAllText($presetPath, $presets, [Text.UTF8Encoding]::new($false))
$outputDirectory = Join-Path $projectRoot 'builds'
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $workRoot 'builds') -Force | Out-Null
$env:JAVA_HOME = $JavaPath
$env:ANDROID_HOME = $SdkPath
Write-Host "Copia de build: $workRoot"
& $GodotPath --headless --path $workRoot --editor --import 2>&1 | Out-File -FilePath "$outputDirectory\release-import.log" -Encoding utf8
if ($LASTEXITCODE -ne 0) { throw 'Falló la importación; revisar builds/release-import.log.' }
$unsigned = Join-Path $workRoot 'builds\Equilibrista-0.2.4-unsigned.aab'
& $GodotPath --headless --path $workRoot --export-release 'Android Release' $unsigned 2>&1 | Out-File -FilePath "$outputDirectory\release-export.log" -Encoding utf8
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $unsigned)) { throw 'Falló la exportación; revisar builds/release-export.log.' }
Copy-Item -LiteralPath $unsigned -Destination "$outputDirectory\Equilibrista-0.2.4-unsigned.aab"
Write-Host 'Bundle RELEASE compilado; todavía NO está firmado. Ejecutar tools/sign_release.ps1.'
