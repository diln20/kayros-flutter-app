import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo compatible con los nombres de campos de Kayros existentes en Firestore.
class PaqueteData {
  const PaqueteData({
    required this.nombre,
    required this.apellidos,
    required this.cedula,
    required this.producto,
    required this.tipo,
    required this.email,
    required this.direccion,
    required this.valor,
    this.fecha,
  });

  static const fieldKeys = [
    'title',
    'description',
    'cedula',
    'producto',
    'tipo',
    'email',
    'dirrecion',
    'valor',
  ];

  final String nombre;
  final String apellidos;
  final String cedula;
  final String producto;
  final String tipo;
  final String email;
  final String direccion;
  final String valor;
  final DateTime? fecha;

  factory PaqueteData.fromMap(Map<String, dynamic> data) {
    final timestamp = data['timestamp'];
    DateTime? date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is DateTime) {
      date = timestamp;
    }
    date ??= DateTime.tryParse((data['time'] ?? '').toString());

    String stringField(String key) => (data[key] ?? '').toString();

    return PaqueteData(
      nombre: stringField('title'),
      apellidos: stringField('description'),
      cedula: stringField('cedula'),
      producto: stringField('producto'),
      tipo: stringField('tipo'),
      email: stringField('email'),
      direccion: stringField('dirrecion'),
      valor: stringField('valor'),
      fecha: date,
    );
  }

  factory PaqueteData.fromForm(List<String> fields) {
    if (fields.length != fieldKeys.length) {
      throw ArgumentError('Se esperan ocho campos para el paquete.');
    }
    return PaqueteData(
      nombre: fields[0].trim(),
      apellidos: fields[1].trim(),
      cedula: fields[2].trim(),
      producto: fields[3].trim(),
      tipo: fields[4].trim(),
      email: fields[5].trim(),
      direccion: fields[6].trim(),
      valor: fields[7].trim(),
    );
  }

  List<String> get formValues => [
        nombre,
        apellidos,
        cedula,
        producto,
        tipo,
        email,
        direccion,
        valor,
      ];

  Map<String, dynamic> toFirestoreFields() => {
        'title': nombre,
        'description': apellidos,
        'cedula': cedula,
        'producto': producto,
        'tipo': tipo,
        'email': email,
        'dirrecion': direccion,
        'valor': valor,
      };

  String get destinatario => '$nombre $apellidos'.trim();

  bool matches(String query) {
    if (query.trim().isEmpty) return true;
    final haystack = _normalize(
      '$nombre $apellidos $cedula $producto $tipo $email $direccion',
    );
    return _normalize(query).split(RegExp(r'\s+')).every(haystack.contains);
  }

  static int compare(PaqueteData first, PaqueteData second,
      {bool newestFirst = true}) {
    final a = first.fecha;
    final b = second.fecha;
    if (a == null && b == null) {
      return first.destinatario.compareTo(second.destinatario);
    }
    if (a == null) return 1;
    if (b == null) return -1;
    final comparison = a.compareTo(b);
    return newestFirst ? -comparison : comparison;
  }

  static String _normalize(String value) {
    var output = value.toLowerCase().trim();
    const substitutions = {
      'á': 'a',
      'à': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ë': 'e',
      'í': 'i',
      'ì': 'i',
      'ï': 'i',
      'ó': 'o',
      'ò': 'o',
      'ö': 'o',
      'ú': 'u',
      'ù': 'u',
      'ü': 'u',
    };
    for (final entry in substitutions.entries) {
      output = output.replaceAll(entry.key, entry.value);
    }
    return output;
  }
}
