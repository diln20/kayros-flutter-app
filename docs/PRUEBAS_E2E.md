# Pruebas E2E de Kayros con Flutter y Firebase local

Estas pruebas comprueban el registro, recuperación de contraseña y operaciones de paquetes sin modificar el Firebase real.

## Cobertura

**Autenticación (`integration_test/auth_e2e_test.dart`)**: crea un usuario ficticio, registra su perfil en Firestore, cierra sesión, solicita la recuperación de contraseña y vuelve a ingresar.

**Paquetes (`integration_test/paquetes_e2e_test.dart`)**: crea otro usuario ficticio, registra un paquete, lo busca, comprueba que una búsqueda sin coincidencias muestre el mensaje adecuado, edita el producto sin cambiar la fecha y elimina el documento.

Las contraseñas se generan dentro del test y no se guardan en archivos ni repositorios.

## Ejecución en Windows

Requisitos: Flutter 3.41.9, emulador Android, Node.js, Firebase CLI y Java 21.

Abre una terminal PowerShell para Firebase:

```powershell
cd C:\Users\user\Documents\kayros-flutter-app
$env:JAVA_HOME = 'C:\Program Files\Eclipse Adoptium\jdk-21.0.11.10-hotspot'
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
npx.cmd --yes firebase-tools@15.34.1 emulators:start --project demo-kayros-e2e --only auth,firestore --config firebase.e2e.json
```

Los servicios escuchan en 127.0.0.1:9099 (Authentication) y 127.0.0.1:8080 (Firestore). El Android Emulator usa 10.0.2.2 para acceder al equipo anfitrión.

Abre otra terminal PowerShell:

```powershell
cd C:\Users\user\Documents\kayros-flutter-app
flutter devices
flutter pub get
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tool\ejecutar_e2e.ps1 -Recorrido Autenticacion
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tool\ejecutar_e2e.ps1 -Recorrido Paquetes
```

El script de Windows impide que dos ejecuciones intenten usar el mismo emulador Android al mismo tiempo. Si ya hay una prueba activa, deténla o deja que termine antes de iniciar otra.

También se pueden ejecutar las pruebas por separado:

```powershell
flutter test integration_test\auth_e2e_test.dart -d emulator-5554 --dart-define=KAYROS_USE_FIREBASE_EMULATORS=true
flutter test integration_test\paquetes_e2e_test.dart -d emulator-5554 --dart-define=KAYROS_USE_FIREBASE_EMULATORS=true
```

## Aislamiento y seguridad

El modo E2E se habilita **únicamente** con `--dart-define=KAYROS_USE_FIREBASE_EMULATORS=true` y en modo depuración. Se conecta a una instancia Firebase secundaria del proyecto local ficticio `demo-kayros-e2e`.

- Las pruebas no utilizan usuarios reales, ni el proyecto de producción, ni credenciales personales.
- Si los emuladores fallan, la prueba debe fallar; nunca debe reconectar a producción.
- Las reglas `test/firebase/firestore.rules` solo permiten leer y escribir los documentos del usuario de pruebas autenticado. No cambian las reglas de producción.
- El restablecimiento de contraseña se valida contra el servicio local. No prueba la entrega de correos reales.
- Para eliminar todos los datos de prueba, detén el proceso Firebase Emulator Suite; no exporta información salvo configuración explícita.

## GitHub Actions

El archivo `.github/workflows/flutter-quality.yml` añade dos trabajos automáticos para `main` y sus pull requests:

1. Formato Dart, análisis de Flutter y pruebas unitarias y de widgets.
2. Preparación de Java 21, Node.js, Android Emulator y Firebase Emulator Suite, seguida de los recorridos E2E en máquinas Android separadas para mejorar la estabilidad.

El segundo trabajo utiliza una matriz con dos runners Linux independientes, uno por recorrido; necesitan virtualización KVM. No requiere secretos de GitHub ni conexión con Firebase de producción.

## Diagnóstico

- **Conexión rechazada:** verifica que estén abiertos los puertos 9099 y 8080.
- **Java incompatible:** selecciona Java 21 para Firebase CLI.
- **Dispositivo ausente:** ejecuta `flutter devices` y abre el emulador Android.
- **Permisos denegados:** revisa el UID de pruebas y las reglas del emulador Firestore.
- **Falla de interfaz:** busca la primera excepción dentro del resultado de `flutter test`.

Para las pruebas con cuentas reales y un buzón de recuperación autorizado, consulta también [QA_FIREBASE.md](QA_FIREBASE.md).
