/// Traduce códigos de Firebase Auth sin exponer detalles técnicos al usuario.
abstract final class AuthErrorMessages {
  static String forCode(String code, {String? fallback}) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este correo ya está registrado.';
      case 'invalid-email':
      case 'missing-email':
        return 'El correo electrónico no es válido.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'user-disabled':
        return 'Esta cuenta está deshabilitada. Contacta a soporte.';
      case 'network-request-failed':
        return 'Comprueba tu conexión a Internet.';
      case 'too-many-requests':
        return 'Demasiados intentos. Prueba más tarde.';
      case 'operation-not-allowed':
        return 'El acceso por correo no está habilitado en Firebase.';
      case 'requires-recent-login':
        return 'Cierra sesión y vuelve a ingresar para continuar.';
      default:
        return fallback ?? 'No se pudo completar la operación.';
    }
  }
}
