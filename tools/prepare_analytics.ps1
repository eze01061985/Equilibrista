$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$gradlePath = Join-Path $projectRoot 'android/build/build.gradle'
if (-not (Test-Path -LiteralPath $gradlePath)) {
    throw 'Instalá la plantilla Android 4.6.1 desde Proyecto > Instalar plantilla de compilación Android y volvé a ejecutar.'
}
$content = Get-Content -LiteralPath $gradlePath -Raw
if (-not $content.Contains("id 'com.google.gms.google-services'")) {
    $content = $content.Replace("id 'com.android.application'", "id 'com.android.application'" + [Environment]::NewLine + "    id 'com.google.gms.google-services' version '4.4.4'")
    Set-Content -LiteralPath $gradlePath -Value $content -Encoding utf8
}
$configPath = Join-Path $projectRoot 'google-services.json'
if (-not (Test-Path -LiteralPath $configPath)) {
    Write-Output 'Gradle preparado. Falta google-services.json del proyecto Firebase real en la raíz.'
    exit 0
}
$config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
$matching = @($config.client | Where-Object { $_.client_info.android_client_info.package_name -eq 'com.ezequielflores.equilibrista' })
if ($matching.Count -eq 0) {
    throw 'google-services.json no contiene el paquete com.ezequielflores.equilibrista.'
}
Write-Output 'Configuración lista. Exportá con el preset Android Analytics.'
