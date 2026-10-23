import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kayros/screens/description.dart';

class Paquetes extends StatelessWidget {
  const Paquetes({super.key});

  Future<void> deletePackage(
      BuildContext context, DocumentReference<Map<String, dynamic>> reference) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar paquete'),
        content: const Text('¿Deseas eliminar este paquete definitivamente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await reference.delete();
    } on FirebaseException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'No fue posible eliminar el paquete.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Inicia sesión para consultar tus paquetes.'));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('paquetes')
          .doc(user.uid)
          .collection('mispaquetes')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('No se pudieron cargar los paquetes: ${snapshot.error}',
                  textAlign: TextAlign.center),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Todavía no tienes paquetes registrados.',
                  textAlign: TextAlign.center),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();
            final title = (data['title'] ?? 'Sin nombre').toString();
            final surname = (data['description'] ?? '').toString();
            final stamp = data['timestamp'];
            final createdAt = stamp is Timestamp
                ? stamp.toDate()
                : DateTime.tryParse((data['time'] ?? '').toString());
            final dateString = createdAt != null
                ? DateFormat('dd/MM/yyyy h:mm a').format(createdAt)
                : 'Sin fecha';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                leading: const Icon(Icons.inventory_2_outlined, color: Colors.red),
                title: Text('$title $surname',
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  '${data['producto'] ?? 'Paquete'}\n$dateString',
                  maxLines: 2,
                ),
                isThreeLine: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Description(
                      title: title,
                      description: surname,
                      details: data,
                    ),
                  ),
                ),
                trailing: IconButton(
                  tooltip: 'Eliminar paquete',
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => deletePackage(context, doc.reference),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
