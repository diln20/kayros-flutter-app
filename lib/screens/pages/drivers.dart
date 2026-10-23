import 'package:flutter/material.dart';
import 'package:kayros/theme/app_theme.dart';

class Drivers extends StatelessWidget {
  const Drivers({super.key});

  static const _steps = <({
    String title,
    String detail,
    IconData icon,
  })>[
    (
      title: '1. Registra tu solicitud',
      detail: 'Presiona el botón +, completa los datos y guarda el paquete.',
      icon: Icons.add_box_outlined,
    ),
    (
      title: '2. Consulta tus paquetes',
      detail:
          'En la pestaña Paquetes puedes buscar por nombre, cédula o producto.',
      icon: Icons.search_outlined,
    ),
    (
      title: '3. Corrige o elimina un registro',
      detail:
          'Abre el menú de tres puntos de un paquete para editarlo o eliminarlo.',
      icon: Icons.edit_note_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(22),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 27,
                          backgroundColor: AppPalette.softRed,
                          child: Icon(Icons.help_outline,
                              size: 28, color: AppPalette.primary),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('¿Cómo funciona Kayros?',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800)),
                              SizedBox(height: 5),
                              Text(
                                'Guía rápida para administrar tus envíos.',
                                style: TextStyle(color: AppPalette.muted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                const Text('Comienza en tres pasos',
                    style: TextStyle(
                      color: AppPalette.ink,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    )),
                const SizedBox(height: 12),
                for (final step in _steps) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: [
                          Icon(step.icon, color: AppPalette.primary, size: 29),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(step.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 5),
                                Text(step.detail,
                                    style: const TextStyle(
                                        color: AppPalette.muted, height: 1.4)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 14),
                const Text('Preguntas frecuentes',
                    style: TextStyle(
                      color: AppPalette.ink,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    )),
                const SizedBox(height: 12),
                const Card(
                  child: Column(
                    children: [
                      ExpansionTile(
                        leading: Icon(Icons.lock_reset_outlined),
                        title: Text('¿Olvidé mi contraseña?'),
                        childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 18),
                        children: [
                          Text('En la pantalla de acceso presiona '
                              '“¿Olvidaste tu contraseña?” e ingresa tu correo.'),
                        ],
                      ),
                      Divider(height: 1),
                      ExpansionTile(
                        leading: Icon(Icons.wifi_off_outlined),
                        title: Text('¿Qué pasa si falla la conexión?'),
                        childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 18),
                        children: [
                          Text('Comprueba tu Internet e inténtalo de nuevo. '
                              'Las solicitudes solo se guardan cuando Firestore '
                              'confirma la operación.'),
                        ],
                      ),
                      Divider(height: 1),
                      ExpansionTile(
                        leading: Icon(Icons.delete_outline),
                        title: Text('¿Puedo eliminar una solicitud?'),
                        childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 18),
                        children: [
                          Text(
                              'Sí. En Mis paquetes abre el menú de tres puntos, '
                              'selecciona Eliminar y confirma la operación.'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                const Row(
                  children: [
                    Icon(Icons.engineering_outlined, color: AppPalette.muted),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text('Información de conductores',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    Chip(label: Text('En construcción')),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
