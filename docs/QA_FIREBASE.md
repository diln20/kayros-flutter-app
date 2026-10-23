# Pruebas de registro y paquetes de Kayros

La aplicación utiliza **Firebase Authentication y Cloud Firestore del proyecto configurado en Android**. La ejecución de `flutter test` no crea cuentas ni escribe información en Firebase. Esta guía describe la verificación manual de la integración real.

## Antes de probar

1. Usa el APK de depuración y un emulador o teléfono de pruebas, no una cuenta de usuario real.
2. Verifica en Firebase Console que **Authentication > Sign-in method > Email/Password** está habilitado.
3. Verifica que las reglas de Firestore permiten a un usuario autenticado escribir su propio perfil y sus propios paquetes. Nunca abras las reglas globalmente al público para realizar estas pruebas.
4. Utiliza datos ficticios. Guarda la contraseña únicamente en un lugar privado **fuera del repositorio**. No la agregues a commits, issues, capturas o registros.
5. Un correo `@example.com` sirve para verificar el registro, pero **no recibe correos**. Para probar realmente la recuperación de contraseña se necesita una bandeja de correo de pruebas a la que tengas acceso.

## Registro de cuenta de QA

En la pantalla de acceso de Kayros:

1. Toca **Regístrate aquí**.
2. Nombre: `Prueba`. Apellidos: `Kayros`.
3. Correo: un correo único de QA, por ejemplo `qa.kayros.FECHA@example.com`.
4. Introduce una contraseña única, robusta, de al menos ocho caracteres, y repítela.
5. Presiona **Crear cuenta** una sola vez y observa el resultado.

**Resultado esperado:** Firebase Authentication crea el usuario, Firestore guarda el perfil en `users/{uid}`, y la aplicación entra en la pantalla de inicio. Si la autenticación tiene éxito pero las reglas de Firestore bloquean el perfil, podría quedar creada la cuenta de Authentication sin el documento `users/{uid}`. Ante `email-already-in-use`, comprueba antes en Firebase Console; no crees cuentas duplicadas.

## Prueba de paquetes

Ya dentro de Kayros, comprueba en este orden:

| Acción | Datos ficticios / resultado esperado |
| --- | --- |
| Crear paquete | Destinatario `Prueba Kayros`, cédula `000000`, producto `Caja de prueba`, tipo `Otros`, dirección `Calle Ejemplo 0`, domicilio `10000` |
| Guardar | Vuelve a Mis paquetes y muestra el nuevo documento |
| Consultar detalle | Muestra los ocho campos y la fecha correcta |
| Buscar | `caja`, `prueba` y `000000` encuentran el paquete |
| Editar | Cambia producto a `Caja actualizada` y guarda sin perder la fecha de creación |
| Ordenar | Alterna entre más recientes y más antiguos |
| Eliminar | Solicita confirmación y elimina el documento seleccionado |
| Salir y entrar | La sesión se cierra y el correo de QA puede volver a autenticarse |

Ubicación esperada del paquete: `paquetes/{uid}/mispaquetes/{documentId}`. Se mantienen los campos históricos, entre ellos `dirrecion` (ortografía de la base de datos original).

## Problemas comunes

- **`email-already-in-use`:** la cuenta ya existe. Prueba iniciar sesión antes de intentar registrarla nuevamente.
- **`operation-not-allowed`:** habilita Email/Password en Authentication.
- **`permission-denied`:** revisa las reglas de Cloud Firestore para el UID del usuario.
- **`network-request-failed`:** comprueba Internet y acceso a los servicios de Firebase desde el dispositivo.
- **Pantalla de inicio sin perfil:** confirma si el documento `users/{uid}` fue creado correctamente.

## Limpieza

Al terminar, elimina únicamente los documentos ficticios asociados con la cuenta de QA y, si la cuenta ya no se necesita, elimina el usuario de prueba en Firebase Authentication. **Eliminar un usuario de Authentication no borra automáticamente sus documentos de Firestore**; revisa ambas ubicaciones.

## Validaciones automáticas

Ejecuta lo siguiente antes de publicar cambios:

```powershell
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

La tarea **Flutter quality checks** de GitHub Actions ejecuta automáticamente el formato, el análisis y las pruebas en `main` y en sus pull requests, sin necesitar datos personales ni secretos de Firebase.
