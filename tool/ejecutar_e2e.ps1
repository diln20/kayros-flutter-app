param(
    [ValidateSet('Autenticacion', 'Paquetes', 'Todas')]
    [string]$Recorrido = 'Todas'
)

$ErrorActionPreference = 'Stop'

# Impedir dos pruebas simultáneas sobre el mismo emulador Android.
# El bloqueo se libera aunque ocurra un error o se cierre el proceso.
$mutex = [System.Threading.Mutex]::new($false, 'Local\KayrosE2EAndroid')
$bloqueoAdquirido = $false

try {
    try {
        $bloqueoAdquirido = $mutex.WaitOne(0)
    }
    catch [System.Threading.AbandonedMutexException] {
        # Recuperar el bloqueo si una ejecución anterior terminó inesperadamente.
        $bloqueoAdquirido = $true
    }

    if (-not $bloqueoAdquirido) {
        throw 'Ya existen pruebas de Kayros ejecutándose en este emulador Android.'
    }

    # Usar exclusivamente Firebase local mediante la opción de depuración.
    $flutter = (Get-Command flutter -ErrorAction SilentlyContinue).Source
    if (-not $flutter) {
        $flutter = 'C:\dev\flutter\bin\flutter.bat'
    }
    if (-not (Test-Path $flutter)) {
        throw 'Flutter no está instalado o no se encuentra en la ruta esperada.'
    }

    $adb = Join-Path $env:LOCALAPPDATA 'Android\sdk\platform-tools\adb.exe'
    if (-not (Test-Path $adb)) {
        throw 'No se encontró ADB. Comprueba el Android SDK.'
    }

    & $adb start-server
    if ($LASTEXITCODE -ne 0) {
        throw 'No se pudo iniciar el servidor ADB.'
    }

    $pruebas = @()
    if ($Recorrido -in @('Autenticacion', 'Todas')) {
        $pruebas += 'integration_test\auth_e2e_test.dart'
    }
    if ($Recorrido -in @('Paquetes', 'Todas')) {
        $pruebas += 'integration_test\paquetes_e2e_test.dart'
    }

    foreach ($prueba in $pruebas) {
        # Cerrar la instancia anterior antes de iniciar un nuevo recorrido.
        & $adb -s emulator-5554 shell am force-stop com.kayros.kayros
        if ($LASTEXITCODE -ne 0) {
            throw 'El emulador Android no responde por ADB.'
        }

        & $flutter test $prueba -d emulator-5554 --dart-define=KAYROS_USE_FIREBASE_EMULATORS=true
        if ($LASTEXITCODE -ne 0) {
            throw "Falló la prueba de integración: $prueba"
        }
    }
}
finally {
    if ($bloqueoAdquirido) {
        $mutex.ReleaseMutex()
    }
    $mutex.Dispose()
}
