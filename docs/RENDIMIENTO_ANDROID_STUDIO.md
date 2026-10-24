# Optimización de Android Studio para Kayros (Windows)

Esta configuración está pensada para un equipo con 16 GB de RAM, procesador Ryzen de 16 núcleos, Flutter y Android Studio. El objetivo es reducir la presión de memoria al compilar y ejecutar un único emulador.

## Cambios aplicados

| Componente | Configuración |
| --- | --- |
| Android Studio | Conservar el heap de 2 GB de la instalación oficial; no aumentarlo en un equipo de 16 GB |
| Gradle de Kayros | Heap máximo de 2560 MB, Metaspace máximo de 768 MB y dos trabajadores simultáneos |
| Caché Gradle | Habilitada mediante `org.gradle.caching=true` |
| Gradle inactivo | Permitir que el daemon termine tras 15 minutos de inactividad |
| Java para Flutter | Eclipse Adoptium JDK 21, compatible con Gradle 8.14 |
| Emulador `Kayros_Ligero_API37` | 1792 MB de RAM, dos núcleos y resolución de 720 × 1280 |
| Aceleración | WHPX (Windows Hypervisor Platform), aceleración gráfica `host` |
| Animaciones Android | Escalas de ventana, transición y duración del animador a 0,5 |

El dispositivo Android API 37 utiliza una imagen preliminar con páginas de 16 KB. Funciona en este equipo, aunque para una versión estable de desarrollo puede convenir utilizar una imagen Android estable cuando el SDK Manager permita descargarla correctamente. La instalación de Google APIs API 35 falló por un ZIP incompleto y **no se debe utilizar esa imagen dañada**.

## Comprobaciones realizadas

- `flutter devices` reconoció `emulator-5554`.
- ADB devolvió `sys.boot_completed=1`.
- `flutter build apk --debug` completó correctamente en 23,9 segundos.
- El APK se instaló correctamente en el dispositivo virtual.
- Se inició la actividad principal `com.kayros.kayros/.MainActivity` sin errores fatales registrados por Android.

Esta medición corresponde a una sola compilación, no a un estudio comparativo antes/después.

## Cómo utilizarlo

Abre solamente un Android Emulator y utiliza el proyecto desde Android Studio o VS Code:

```powershell
flutter devices
flutter run -d emulator-5554
```

Si necesitas iniciar el emulador desde una terminal:

```powershell
& "$env:LOCALAPPDATA\Android\sdk\emulator\emulator.exe" -avd Kayros_Ligero_API37
```

Para inspeccionar el JDK activo:

```powershell
flutter config --list
flutter doctor -v
```

Si necesitas restablecer la ruta Java recomendada para Flutter:

```powershell
flutter config --jdk-dir="C:\Program Files\Eclipse Adoptium\jdk-21.0.11.10-hotspot"
```

## Recomendaciones de uso

- No mantengas Docker Desktop y el emulador abierto si no los estás utilizando simultáneamente.
- Evita varias instancias de emulador: cada una puede reservar más de 2 GB.
- Cierra ventanas duplicadas de VS Code o navegadores cuando tengas poca RAM libre.
- Mantén el heap de Android Studio en su valor predeterminado de 2 GB. No lo aumentes para solucionar un problema causado por procesos externos.
- Usa **Hot Reload** al modificar pantallas Flutter, en lugar de reconstruir el APK con cada cambio.
- Antes de borrar cachés de Gradle o hacer `flutter clean`, verifica que exista realmente un problema de compilación: borrarlas obliga a recompilar.

## Restauración

El archivo anterior de Gradle y la configuración previa del emulador están respaldados en:

`$env:USERPROFILE\Documents\Kayros-AndroidStudio-Respaldos`

Se puede restaurar el archivo original `android/gradle.properties` desde su respaldo correspondiente si alguna compilación particular necesita más memoria.

## Observaciones

La compilación Android ya se comprobó. `flutter doctor` seguía informando algunas licencias del SDK pendientes; deberán revisarse desde Android Studio o con `flutter doctor --android-licenses` si una instalación futura las requiere. No afecta al APK ya compilado.
