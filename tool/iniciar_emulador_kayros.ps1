$ErrorActionPreference = 'Stop'

# Inicia el emulador de Kayros con aceleracion grafica de la GPU.
# Evita crear dos instancias simultaneas y desperdiciar memoria.
$nombre = 'Kayros_Ligero_API37'
$ruta = Join-Path $env:LOCALAPPDATA 'Android\Sdk\emulator\emulator.exe'

if (-not (Test-Path $ruta)) {
    throw 'No se encontro Android Emulator en el SDK configurado.'
}

$abierto = Get-CimInstance Win32_Process | Where-Object {
    $_.Name -eq 'qemu-system-x86_64.exe' -and
    $_.CommandLine -match ('-avd\s+' + [regex]::Escape($nombre))
}

if ($abierto) {
    Write-Output ('El emulador ya esta ejecutandose: ' + $nombre)
    exit 0
}

# El modo host utiliza la aceleracion grafica de la GPU del equipo.
# Se mantiene Quick Boot para facilitar los siguientes inicios.
Start-Process -FilePath $ruta -ArgumentList @(
    '-avd', $nombre,
    '-gpu', 'host',
    '-no-audio',
    '-no-boot-anim'
)
Write-Output ('Emulador iniciado: ' + $nombre)
