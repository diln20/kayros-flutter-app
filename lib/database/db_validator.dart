class DbValidator {
  static String? validateField({String? value}) {
    if (value == null || value.trim().isEmpty) {
      return 'El campo es obligatorio.';
    }
    return null;
  }
}
