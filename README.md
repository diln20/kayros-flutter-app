# Kayros Express

Aplicación Flutter para gestionar solicitudes de envío. Proyecto original migrado a **Flutter 3 / Dart 3**, conservando Firebase Authentication y Cloud Firestore y modernizando su interfaz.

## Funcionalidades

- **Cuenta y acceso:** registro con confirmación de contraseña, inicio y cierre de sesión, mensajes claros y recuperación por correo.
- **Inicio:** panel adaptable a móvil y escritorio, carrusel informativo local y accesos rápidos.
- **Paquetes:** registrar, consultar, buscar, ordenar por fecha, abrir detalles, editar y eliminar con confirmación.
- **Información:** instrucciones integradas y preguntas frecuentes.
- **Errores:** muestra problemas de conexión y de Firestore sin simular guardados exitosos.

## Requisitos

- Flutter SDK compatible con Dart 3 (validado con Flutter 3.41.9 / Dart 3.11.5).
- Android SDK y JDK compatibles para ejecutar en Android.
- Proyecto Firebase activo, con **Email/Password** habilitado en Authentication y reglas de Firestore que permitan acceso a los datos del usuario autenticado.
- `android/app/google-services.json` correspondiente a la aplicación Android `com.kayros.kayros`.

## Ejecutar localmente

Desde la carpeta del proyecto:

```powershell
flutter pub get
flutter analyze
flutter test
flutter devices
flutter run -d emulator-5554
```

Crear APK Android de depuración:

```powershell
flutter build apk --debug
```

Archivo resultante: `build/app/outputs/flutter-apk/app-debug.apk`.

Para generar una versión publicable se necesita la firma release correspondiente; el APK debug no es una versión de producción.

## Compatibilidad con Firestore

Los registros antiguos **no necesitan migración de documentos**. Se preservan las rutas y nombres de los campos, incluso `dirrecion` (ortografía heredada):

| Ruta | Uso |
| --- | --- |
| `users/{uid}` | Perfil del usuario: `uid`, `email`, `nombre`, `apellidos` |
| `paquetes/{uid}/mispaquetes/{id}` | Solicitudes de paquetes de cada usuario |
| `notes/{uid}/items/{id}` | Colección auxiliar heredada |

Cada paquete mantiene los campos:
`title`, `description`, `cedula`, `producto`, `tipo`, `email`, `dirrecion`, `valor`, `timestamp` y `time`.

La aplicación:
- Consulta documentos de Firestore usando su identificador real, incluso los creados en versiones antiguas.
- Al crear, usa un identificador automático y guarda ambas fechas (`timestamp` y `time`).
- Al editar, actualiza los datos del paquete **sin sobrescribir la fecha de creación**.
- Permite buscar ignorando mayúsculas y tildes comunes; ordena los registros fechados y coloca los que no tienen fecha al final.

## Validación

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

Hay pruebas unitarias y de widgets para navegación responsiva, validaciones, documentos antiguos, orden y búsqueda, recuperación de contraseña y ayuda integrada. **Estas pruebas no escriben datos reales en Firebase.**

Antes de usar la aplicación en producción, verificar con una cuenta de pruebas autorizada el registro, inicio, recuperación y CRUD de paquetes contra las reglas reales de Firebase.

## Otras plataformas

- **Web:** necesita registrar una aplicación Web en Firebase y generar las opciones de FlutterFire. La configuración Android por sí sola no habilita el acceso desde el navegador.
- **iOS:** requiere macOS, Xcode y el archivo de configuración Firebase iOS. No se ha verificado una compilación iOS.
- **Windows:** se conserva un respaldo anterior de la plataforma; no se ha habilitado ni probado como destino de escritorio.

## Git y respaldos

La rama `main` contiene la migración y las mejoras en **commits individuales**; `master` conserva el proyecto original. Los respaldos previos de código se encuentran en `C:\Users\user\Documents\kayros-flutter-backups`.

Para consultar qué aporta cada mejora:

```powershell
git log --oneline
git show <hash-del-commit>
```

## Seguridad y límites

- Nunca guardar contraseñas ni credenciales privadas en el repositorio.
- Configurar y revisar las reglas de Firebase antes de distribuir.
- La recuperación de contraseña depende de que Firebase Authentication y su plantilla de correo estén disponibles.
- La confirmación de guardado o eliminación se muestra solo después de que Firestore responde correctamente.

## QA y GitHub Actions

La guía [Pruebas reales con Firebase](docs/QA_FIREBASE.md) explica cómo crear una cuenta exclusiva de pruebas y validar paquetes sin utilizar datos personales. No se deben guardar contraseñas en el repositorio.

El workflow `Flutter quality checks` se ejecuta en cada push y pull request dirigido a `main`, validando formato, análisis Dart/Flutter y las pruebas automatizadas.
