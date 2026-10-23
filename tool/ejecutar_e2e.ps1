param(
    [ValidateSet('Autenticacion', 'Paquetes', 'Todas')]
    [string]$Recorrido = 'Todas'
)

$ErrorActionPreference = 'Stop'

# Utiliza siempre el emulador local Firebase; nunca la cuenta real.
# Para mayor estabilidad, ejecuta cada recorrido por separado en Android.
$flutter = (Get-Command flutter -ErrorAction SilentlyContinue).Source
if (-not $flutter) {
    $flutter = 'C:\dev\flutter\bin\flutter.bat'
}
if (-not (Test-Path $flutter)) {
    throw 'Flutter no está instalado o no se encuentra en la ruta esperada.'
}

$tests = @()
if ($Recorrido -in @('Autenticacion', 'Todas')) {
    $tests += 'integration_test\auth_e2e_test.dart'
}
if ($Recorrido -in @('Paquetes', 'Todas')) {
    $tests += 'integration_test\paquetes_e2e_test.dart'
}

$adb = Join-Path $env:LOCALAPPDATA 'Android\sdk\platform-tools\adb.exe'
foreach ($test in $tests) {
    # Detener la instancia anterior evita sesiones abiertas entre recorridos.
    if (Test-Path $adb) {
        & $adb -s emulator-5554 shell am force-stop com.kayros.kayros
    }
    & $flutter test $test -d emulator-5554 --dart-define=KAYROS_USE_FIREBASE_EMULATORS=true
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}
