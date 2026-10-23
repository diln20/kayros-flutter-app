abstract final class FormValidators {
  static String? required(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa $label.';
    }
    return null;
  }

  static String? email(String? value) {
    final missing = required(value, 'un correo electrónico');
    if (missing != null) return missing;

    final emailValue = value!.trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(emailValue)) {
      return 'Ingresa un correo electrónico válido.';
    }
    return null;
  }

  static String? amount(String? value) {
    final missing = required(value, 'el valor del domicilio');
    if (missing != null) return missing;

    final text = value!.trim();
    if (!RegExp(r'^\d+(?:[.,]\d+)*$').hasMatch(text)) {
      return 'Escribe un valor numérico sin símbolos.';
    }
    if (!RegExp(r'[1-9]').hasMatch(text)) {
      return 'El valor debe ser mayor que cero.';
    }
    return null;
  }
}
