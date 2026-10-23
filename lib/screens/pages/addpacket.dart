import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kayros/models/paquete_data.dart';
import 'package:kayros/theme/app_theme.dart';
import 'package:kayros/utils/form_validators.dart';

class Packet extends StatefulWidget {
  const Packet({
    super.key,
    this.reference,
    this.initialData,
  }) : assert(
          (reference == null) == (initialData == null),
          'La edición necesita el documento y sus datos.',
        );

  final DocumentReference<Map<String, dynamic>>? reference;
  final PaqueteData? initialData;

  @override
  State<Packet> createState() => _PacketState();
}

class _PacketState extends State<Packet> {
  final _formKey = GlobalKey<FormState>();
  late final List<TextEditingController> _controllers;
  bool _saving = false;

  static const _labels = [
    'Nombre',
    'Apellidos',
    'Cédula',
    'Producto',
    'Tipo de producto',
    'Correo electrónico',
    'Dirección',
    'Valor del domicilio',
  ];

  static const _icons = [
    Icons.person_outline,
    Icons.people_outline,
    Icons.badge_outlined,
    Icons.inventory_2_outlined,
    Icons.category_outlined,
    Icons.email_outlined,
    Icons.location_on_outlined,
    Icons.payments_outlined,
  ];

  @override
  void initState() {
    super.initState();
    final defaults = widget.initialData?.formValues ?? List.filled(8, '');
    _controllers =
        defaults.map((text) => TextEditingController(text: text)).toList();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _validate(int index, String? value) {
    if (index == 5) return FormValidators.email(value);
    if (index == 7) return FormValidators.amount(value);
    return FormValidators.required(value, _labels[index].toLowerCase());
  }

  Future<void> _save() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para guardar un paquete.')),
      );
      return;
    }

    setState(() => _saving = true);
    final record = PaqueteData.fromForm(
      _controllers.map((controller) => controller.text).toList(),
    );

    try {
      final fields = record.toFirestoreFields();
      if (widget.reference != null) {
        // No permitir que el formulario edite un documento de otro usuario.
        if (widget.reference!.parent.parent?.id != user.uid) {
          throw StateError('No puedes modificar paquetes de otra cuenta.');
        }
        // No modificamos 'timestamp' ni 'time' para preservar el orden histórico.
        await widget.reference!.update(fields);
      } else {
        final now = DateTime.now();
        await FirebaseFirestore.instance
            .collection('paquetes')
            .doc(user.uid)
            .collection('mispaquetes')
            .add({
          ...fields,
          'time': now.toIso8601String(),
          'timestamp': Timestamp.fromDate(now),
        });
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } on FirebaseException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(error.message ?? 'No se pudo guardar el paquete.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.reference != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Editar paquete' : 'Agregar paquetes'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 25,
                            backgroundColor: AppPalette.softRed,
                            child: Icon(Icons.local_shipping_outlined,
                                color: AppPalette.primary, size: 27),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    editing
                                        ? 'Actualizar solicitud'
                                        : 'Nueva solicitud',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800)),
                                const SizedBox(height: 3),
                                const Text(
                                    'Completa los datos del destinatario y el envío.',
                                    style: TextStyle(
                                        color: AppPalette.muted, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 21),
                  for (int i = 0; i < _controllers.length; i++) ...[
                    TextFormField(
                      controller: _controllers[i],
                      decoration: InputDecoration(
                        labelText: _labels[i],
                        prefixIcon: Icon(_icons[i]),
                      ),
                      textCapitalization: i == 0 || i == 1 || i == 6
                          ? TextCapitalization.words
                          : TextCapitalization.none,
                      keyboardType: i == 5
                          ? TextInputType.emailAddress
                          : i == 2
                              ? TextInputType.number
                              : i == 7
                                  ? const TextInputType.numberWithOptions(
                                      decimal: true)
                                  : i == 6
                                      ? TextInputType.streetAddress
                                      : TextInputType.text,
                      textInputAction:
                          i == 7 ? TextInputAction.done : TextInputAction.next,
                      onFieldSubmitted: i == 7 ? (_) => _save() : null,
                      validator: (value) => _validate(i, value),
                      maxLength: i == 5
                          ? 120
                          : i == 6
                              ? 170
                              : 90,
                    ),
                    const SizedBox(height: 7),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 19,
                          height: 19,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_outlined),
                  label: Text(_saving
                      ? 'Guardando...'
                      : editing
                          ? 'Guardar cambios'
                          : 'Agregar paquete'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
