import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Packet extends StatefulWidget {
  const Packet({super.key});

  @override
  State<Packet> createState() => _PacketState();
}

class _PacketState extends State<Packet> {
  final formKey = GlobalKey<FormState>();
  final controllers = List.generate(8, (_) => TextEditingController());
  static const fields = [
    'Nombre', 'Apellidos', 'Cédula', 'Producto', 'Tipo',
    'Correo electrónico', 'Dirección', 'Valor domicilio',
  ];
  bool saving = false;

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> addTaskToFirebase() async {
    if (saving || !(formKey.currentState?.validate() ?? false)) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión antes de agregar paquetes.')),
      );
      return;
    }

    setState(() => saving = true);
    final now = DateTime.now();
    final values = controllers.map((controller) => controller.text.trim()).toList();

    try {
      await FirebaseFirestore.instance
          .collection('paquetes')
          .doc(user.uid)
          .collection('mispaquetes')
          .add({
        'title': values[0],
        'description': values[1],
        'time': now.toIso8601String(),
        'timestamp': Timestamp.fromDate(now),
        'cedula': values[2],
        'producto': values[3],
        'tipo': values[4],
        'email': values[5],
        'dirrecion': values[6],
        'valor': values[7],
      });
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error al guardar el paquete.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar el paquete: $e')),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar paquetes')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Form(
              key: formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('Completa la información del envío.',
                      style: TextStyle(fontSize: 17)),
                  const SizedBox(height: 16),
                  for (var i = 0; i < fields.length; i++) ...[
                    TextFormField(
                      controller: controllers[i],
                      textCapitalization: (i == 0 || i == 1 || i == 6)
                          ? TextCapitalization.words
                          : TextCapitalization.none,
                      keyboardType: i == 5
                          ? TextInputType.emailAddress
                          : (i == 2 || i == 7)
                              ? TextInputType.number
                              : TextInputType.text,
                      decoration: InputDecoration(
                        labelText: fields[i],
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El campo ${fields[i].toLowerCase()} es obligatorio.';
                        }
                        if (i == 5 && !value.contains('@')) {
                          return 'Ingresa un correo válido.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 13),
                  ],
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: saving ? null : addTaskToFirebase,
                      icon: saving
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(color: Colors.white))
                          : const Icon(Icons.save_outlined),
                      label: Text(saving ? 'Guardando...' : 'Agregar paquete'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
