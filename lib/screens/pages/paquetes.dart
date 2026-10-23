import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kayros/config/firebase_runtime.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kayros/models/paquete_data.dart';
import 'package:kayros/screens/description.dart';
import 'package:kayros/screens/pages/addpacket.dart';
import 'package:kayros/theme/app_theme.dart';

class Paquetes extends StatefulWidget {
  const Paquetes({super.key});

  @override
  State<Paquetes> createState() => _PaquetesState();
}

class _PaquetesState extends State<Paquetes> {
  final _searchController = TextEditingController();
  Stream<QuerySnapshot<Map<String, dynamic>>>? _packages;
  String _search = '';
  bool _newestFirst = true;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseRuntime.auth.currentUser?.uid;
    if (uid != null) {
      _packages = FirebaseRuntime.firestore
          .collection('paquetes')
          .doc(uid)
          .collection('mispaquetes')
          .snapshots();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _editPackage(
    DocumentReference<Map<String, dynamic>> reference,
    PaqueteData data,
  ) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => Packet(reference: reference, initialData: data),
      ),
    );
    if (!mounted || changed != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paquete actualizado correctamente.')),
    );
  }

  Future<void> _deletePackage(
    DocumentReference<Map<String, dynamic>> reference,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar paquete'),
        content: const Text('¿Deseas eliminar este paquete definitivamente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await reference.delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paquete eliminado correctamente.')),
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'No se pudo eliminar el paquete.'),
        ),
      );
    }
  }

  Widget _emptyState({required bool filtered}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              filtered ? Icons.search_off_outlined : Icons.inventory_2_outlined,
              size: 64,
              color: AppPalette.muted,
            ),
            const SizedBox(height: 15),
            Text(
              filtered
                  ? 'No encontramos coincidencias'
                  : 'Sin paquetes todavía',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 7),
            Text(
              filtered
                  ? 'Prueba otra palabra, cédula o nombre de producto.'
                  : 'Crea tu primera solicitud desde el botón +.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppPalette.muted),
            ),
            if (filtered) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _search = '');
                },
                icon: const Icon(Icons.close),
                label: const Text('Limpiar búsqueda'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildList(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final entries = snapshot.docs
        .map((document) => (
              document: document,
              data: PaqueteData.fromMap(document.data()),
            ))
        .where((entry) => entry.data.matches(_search))
        .toList()
      ..sort((first, second) => PaqueteData.compare(
            first.data,
            second.data,
            newestFirst: _newestFirst,
          ));

    if (entries.isEmpty) return _emptyState(filtered: _search.isNotEmpty);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      itemCount: entries.length,
      separatorBuilder: (_, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final record = entry.data;
        final document = entry.document;
        final date = record.fecha == null
            ? 'Sin fecha'
            : DateFormat('dd/MM/yyyy · HH:mm').format(record.fecha!);

        return Card(
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
            leading: const CircleAvatar(
              backgroundColor: AppPalette.softRed,
              child:
                  Icon(Icons.inventory_2_outlined, color: AppPalette.primary),
            ),
            title: Text(
              record.destinatario.isEmpty
                  ? 'Destinatario sin nombre'
                  : record.destinatario,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '${record.producto.isEmpty ? 'Producto sin nombre' : record.producto}\n$date',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppPalette.muted, height: 1.45),
              ),
            ),
            isThreeLine: true,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Description(
                  title: record.nombre,
                  description: record.apellidos,
                  details: document.data(),
                ),
              ),
            ),
            trailing: PopupMenuButton<String>(
              tooltip: 'Opciones del paquete',
              onSelected: (action) {
                if (action == 'edit') {
                  _editPackage(document.reference, record);
                } else if (action == 'delete') {
                  _deletePackage(document.reference);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem<String>(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Editar'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_outline),
                    title: Text('Eliminar'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_packages == null) {
      return const Center(
          child: Text('Inicia sesión para consultar tus paquetes.'));
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Consulta tus solicitudes',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppPalette.ink,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text('Busca por destinatario, cédula o producto.',
                      style: TextStyle(color: AppPalette.muted, fontSize: 13)),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) =>
                        setState(() => _search = value.trim()),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      labelText: 'Buscar paquete',
                      hintText: 'Ej. Camila, caja o 123456',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _search.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Limpiar búsqueda',
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _search = '');
                              },
                              icon: const Icon(Icons.close),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () =>
                          setState(() => _newestFirst = !_newestFirst),
                      icon: const Icon(Icons.sort),
                      label:
                          Text(_newestFirst ? 'Más recientes' : 'Más antiguos'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _packages,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No se pudieron consultar los paquetes.\n${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _buildList(snapshot.data!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
