param(
    [string]$KeystorePath = "$env:USERPROFILE\.android\keystores\Equilibrista\equilibrista-upload.jks",
    [string]$Alias = 'equilibrista-upload',
    [string]$JavaPath = "$env:LOCALAPPDATA\EquilibristaTools\jdk\jdk-17.0.20.1+1"
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$unsigned = Join-Path $projectRoot 'builds\Equilibrista-0.2.5-unsigned.aab'
$outputDir = Join-Path $projectRoot 'releases'
$outputFile = Join-Path $outputDir 'Equilibrista-0.2.5-release.aab'
foreach ($required in @($unsigned, "$JavaPath\bin\keytool.exe", "$JavaPath\bin\jarsigner.exe")) {
    if (-not (Test-Path -LiteralPath $required)) { throw "Falta: $required" }
}
if (Test-Path -LiteralPath $outputFile) { throw 'Ya existe el AAB firmado. No se sobrescribe; conservá la release antes de generar otra.' }
Write-Host "Keystore: $KeystorePath"
Write-Host "Alias: $Alias"
Write-Host 'Guardá la contraseña en tu gestor de contraseñas. No la envíes por chat.'
if (-not (Test-Path -LiteralPath $KeystorePath)) { throw 'Falta el keystore existente. No se genera ninguna clave nueva.' }
$securePassword = Read-Host 'Contraseña del keystore (entrada oculta)' -AsSecureString
$pointer = [IntPtr]::Zero
try {
    $pointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
    $env:EQUILIBRISTA_SIGN_PASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($pointer)
    if ($env:EQUILIBRISTA_SIGN_PASSWORD.Length -lt 6) { throw 'Java requiere al menos 6 caracteres; usá preferiblemente una contraseña larga y única.' }
    # Reutilizar la clave existente y validar contraseña/alias antes de firmar.
    & "$JavaPath\bin\keytool.exe" -list -keystore $KeystorePath -alias $Alias -storepass:env EQUILIBRISTA_SIGN_PASSWORD
    if ($LASTEXITCODE -ne 0) { throw 'Alias o contraseña incorrectos. No se generó otra clave.' }
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    $staging = Join-Path $outputDir ('signing-' + [guid]::NewGuid().ToString('N') + '.aab')
    & "$JavaPath\bin\jarsigner.exe" -keystore $KeystorePath -storepass:env EQUILIBRISTA_SIGN_PASSWORD -keypass:env EQUILIBRISTA_SIGN_PASSWORD -sigalg SHA256withRSA -digestalg SHA-256 -signedjar $staging $unsigned $Alias
    if ($LASTEXITCODE -ne 0) { throw 'La firma falló; el archivo temporal no es una release válida.' }
    & "$JavaPath\bin\jarsigner.exe" -verify $staging
    if ($LASTEXITCODE -ne 0) { throw 'La verificación de la firma falló.' }
    Move-Item -LiteralPath $staging -Destination $outputFile
    & "$JavaPath\bin\keytool.exe" -exportcert -rfc -keystore $KeystorePath -alias $Alias -storepass:env EQUILIBRISTA_SIGN_PASSWORD -file (Join-Path $outputDir 'equilibrista-upload-certificate.pem')
    if ($LASTEXITCODE -ne 0) { throw 'AAB firmado, pero falló exportar el certificado público.' }
    Write-Host "AAB firmado: $outputFile"
    Write-Host 'No se publicó ni se subió nada a Google Play.'
} finally {
    $env:EQUILIBRISTA_SIGN_PASSWORD = $null
    if ($pointer -ne [IntPtr]::Zero) { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($pointer) }
    $securePassword.Dispose()
}
