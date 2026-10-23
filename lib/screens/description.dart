import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kayros/models/paquete_data.dart';
import 'package:kayros/theme/app_theme.dart';

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
    final record = PaqueteData.fromMap({
      ...details,
      'title': title,
      'description': description,
    });
    final information = <({String label, String value, IconData icon})>[
      (label: 'Cédula', value: record.cedula, icon: Icons.badge_outlined),
      (
        label: 'Producto',
        value: record.producto,
        icon: Icons.inventory_2_outlined
      ),
      (label: 'Tipo', value: record.tipo, icon: Icons.category_outlined),
      (label: 'Correo', value: record.email, icon: Icons.email_outlined),
      (
        label: 'Dirección',
        value: record.direccion,
        icon: Icons.location_on_outlined
      ),
      (
        label: 'Valor domicilio',
        value: record.valor,
        icon: Icons.payments_outlined
      ),
      if (record.fecha != null)
        (
          label: 'Fecha de solicitud',
          value: DateFormat('dd/MM/yyyy HH:mm').format(record.fecha!),
          icon: Icons.calendar_today_outlined
        ),
    ].where((field) => field.value.trim().isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Detalles del paquete')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 27,
                        backgroundColor: AppPalette.softRed,
                        child: Icon(Icons.local_shipping_outlined,
                            size: 28, color: AppPalette.primary),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Destinatario',
                                style: TextStyle(
                                    fontSize: 12, color: AppPalette.muted)),
                            const SizedBox(height: 4),
                            Text(record.destinatario,
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 23),
              const Text('Información del envío',
                  style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppPalette.ink)),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final twoColumns = constraints.maxWidth >= 580;
                  final itemWidth = twoColumns
                      ? (constraints.maxWidth - 12) / 2
                      : constraints.maxWidth;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final field in information)
                        SizedBox(
                          width: itemWidth,
                          child: Card(
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading:
                                  Icon(field.icon, color: AppPalette.primary),
                              title: Text(field.label,
                                  style: const TextStyle(
                                      color: AppPalette.muted, fontSize: 12)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(field.value,
                                    style: const TextStyle(
                                        color: AppPalette.ink,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
