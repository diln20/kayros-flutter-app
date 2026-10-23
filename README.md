# Kayros Express

Aplicacion Flutter de gestion de solicitudes de paquetes, migrada desde la version original del repositorio a **Flutter 3.41 / Dart 3.11**.

## Funcionalidades recuperadas

- Registro de usuarios y acceso con correo y contrasena mediante Firebase Authentication.
- Inicio, cierre de sesion y cambio automatico de pantallas segun el estado de autenticacion.
- Datos basicos de usuario almacenados en Cloud Firestore, coleccion `users`.
- Registro, lista, detalle y eliminacion de paquetes por usuario.
- Carrusel de imagenes, menu de inicio y navegacion inferior.
- Formulario de ocho campos con validacion y mensajes de error.
- Pantalla "En construccion" para la seccion originalmente incompleta.

## Compatibilidad de datos

Se mantuvo el esquema original:
- `users/{uid}`: `uid`, `email`, `nombre`, `apellidos`.
- `paquetes/{uid}/mispaquetes/{documentId}`: `title`, `description`, `time`, `timestamp`, `cedula`, `producto`, `tipo`, `email`, `dirrecion`, `valor`.
- `notes/{uid}/items/{documentId}`: utilidades de base de datos heredadas.

Los documentos nuevos de paquetes usan identificadores automaticos de Firestore. Se siguen mostrando y eliminando documentos creados por la version anterior utilizando su identificador real, no el campo `time`.

## Ejecutar en Android

Prerequisitos: Flutter 3.27 o superior, Android SDK y JDK compatibles.

```powershell
cd C:\Users\user\Documents\kayros-flutter-app
C:\dev\flutter\bin\flutter.bat pub get
C:\dev\flutter\bin\flutter.bat analyze
C:\dev\flutter\bin\flutter.bat test
C:\dev\flutter\bin\flutter.bat devices
C:\dev\flutter\bin\flutter.bat run -d emulator-5554
```

Generar APK de depuracion:

```powershell
C:\dev\flutter\bin\flutter.bat build apk --debug
```

Resultado: `build/app/outputs/flutter-apk/app-debug.apk`.

## Firebase

Android conserva el `google-services.json` original con el identificador de paquete `com.kayros.kayros`. Se utiliza Firebase Core, Authentication y Cloud Firestore modernos. Es necesario que el proyecto Firebase original siga activo y que sus reglas de seguridad autoricen el acceso autenticado.

**No se incluyen credenciales de prueba ni se escriben datos reales durante las pruebas automatizadas.** Para una validacion integral de registro y CRUD hay que probar con una cuenta autorizada y reglas de Firestore adecuadas.

### Flutter Web

La aplicacion original no incluia una configuracion de Firebase para Web. La compilacion web puede completarse, pero para iniciar sesion y acceder a Firestore en Web debe registrarse una aplicacion web en el mismo proyecto Firebase y proporcionar las opciones de FlutterFire mediante `flutterfire configure`. No reutilizar a ciegas el identificador de aplicacion Android como identificador web.

### iOS

La carpeta iOS original se conserva, pero requiere macOS/Xcode y la configuracion de Firebase iOS para compilar y probar.

## Migracion tecnica

- Eliminado el antiguo limite de Dart 2 (`<3.0.0`) y migradas las clases a null safety.
- Sustituidos los accesos antiguos a snapshots (`documents`) por `docs` y `data()`.
- Actualizado el Android embedding y Gradle a configuracion Kotlin DSL moderna.
- Reemplazado el carrusel de `getwidget` por `PageView` nativo.
- Retiradas dependencias que no se usaban en el codigo: Firebase Messaging, Firebase Realtime Database, `unicorndial`, etc.
- El ingreso ya no imprime contrasenas en la consola.
- La eliminacion de paquetes solicita confirmacion; el formulario espera una escritura exitosa antes de cerrarse.

## Respaldos y Git

- Rama local de migracion: `fix/flutter3-compat`.
- El proyecto original sigue disponible en el historial de `master`.
- Respaldos externos: `C:\Users\user\Documents\kayros-flutter-backups`.
- No se ha modificado ni publicado ninguna rama remota.
- Para desarrollar Windows Desktop deben instalarse Visual Studio C++ y activarse el modo de desarrollador (enlaces simbolicos); esa plataforma esta en respaldo externo.

## Seguridad

El APK de depuracion esta firmado con llave de debug. Para distribucion real configure firma release, verifique reglas Firebase y habilite App Check donde corresponda.
