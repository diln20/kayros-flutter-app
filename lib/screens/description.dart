import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Description extends StatelessWidget {
  const Description({
    super.key,
    required this.title,
    required this.description,
    this.details = const {},
  });

  final String title;
  final String description;
  final Map<String, dynamic> details;

  @override
  Widget build(BuildContext context) {
    const fields = <(String, String)>[
      ('cedula', 'Cédula'),
      ('producto', 'Producto'),
      ('tipo', 'Tipo'),
      ('email', 'Correo'),
      ('dirrecion', 'Dirección'),
      ('valor', 'Valor domicilio'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Descripción del paquete')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text('$title $description',
              style: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          for (final (key, label) in fields)
            if (details[key] != null && details[key].toString().isNotEmpty)
              Card(
                child: ListTile(
                  title: Text(label),
                  subtitle: Text(details[key].toString()),
                ),
              ),
        ],
      ),
    );
  }
}
