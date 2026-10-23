import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kayros/config/firebase_runtime.dart';
import 'package:kayros/main.dart';

// Reintenta encontrar un elemento mientras Firestore actualiza la interfaz.
Future<void> waitForLabel(WidgetTester tester, Finder finder) async {
  final deadline = DateTime.now().add(const Duration(seconds: 60));
  while (finder.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 300));
  }
  expect(finder, findsWidgets);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('QA: crear, buscar, editar y eliminar paquete en Firestore',
      (tester) async {
    // Protección obligatoria: ninguna operación E2E llega a Firebase real.
    expect(FirebaseRuntime.useEmulators, isTrue);
    await FirebaseRuntime.initialize();
    expect(FirebaseRuntime.auth.app.options.projectId,
        FirebaseRuntime.demoProjectId);
    await FirebaseRuntime.auth.signOut();

    // Crear un usuario ficticio exclusivo de esta ejecución.
    final suffix = DateTime.now().microsecondsSinceEpoch;
    final email = 'e2e.package.$suffix@example.com';
    final password = 'KayrosQa$suffix' 'A9!';
    final credentials =
        await FirebaseRuntime.auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credentials.user!.uid;
    final collection = FirebaseRuntime.firestore
        .collection('paquetes')
        .doc(uid)
        .collection('mispaquetes');

    // Utilizar las pantallas reales de Kayros para registrar un paquete.
    await tester.pumpWidget(const KayrosApp());
    await waitForLabel(tester, find.text('Hola, bienvenido'));
    await tester.tap(find.byTooltip('Agregar paquete'));
    await waitForLabel(tester, find.text('Agregar paquetes'));

    final inputs = find.byType(TextFormField);
    final values = [
      'Prueba',
      'Kayros',
      '000000',
      'Caja E2E',
      'Otros',
      email,
      'Calle Prueba 10',
      '10000',
    ];
    for (var i = 0; i < values.length; i++) {
      await tester.ensureVisible(inputs.at(i));
      await tester.enterText(inputs.at(i), values[i]);
      await tester.pump();
    }

    await tester.tap(find.widgetWithText(FilledButton, 'Agregar paquete'));
    await waitForLabel(tester, find.text('Consulta tus solicitudes'));
    final saved = await collection.get();
    expect(saved.docs.length, 1);
    final packageId = saved.docs.single.id;
    expect(saved.docs.single.data()['producto'], 'Caja E2E');

    // Comprobar la búsqueda con resultados y sin coincidencias.
    final search = find.byType(TextField).first;
    await tester.enterText(search, 'noexiste');
    await waitForLabel(tester, find.text('No encontramos coincidencias'));

    await tester.enterText(search, 'caja');
    await tester.pump();
    await waitForLabel(tester, find.text('Prueba Kayros'));

    // Actualizar un documento existente sin reemplazar su fecha de creación.
    await tester.tap(find.byTooltip('Opciones del paquete'));
    await waitForLabel(tester, find.text('Editar'));
    await tester.tap(find.text('Editar'));
    await waitForLabel(tester, find.text('Editar paquete'));

    final editFields = find.byType(TextFormField);
    await tester.ensureVisible(editFields.at(3));
    await tester.enterText(editFields.at(3), 'Caja E2E actualizada');
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar cambios'));
    await waitForLabel(tester, find.text('Consulta tus solicitudes'));

    final changed = await collection.doc(packageId).get();
    expect(changed.exists, isTrue);
    expect(changed.data()?['producto'], 'Caja E2E actualizada');
    expect(changed.data()?['time'], saved.docs.single.data()['time']);

    // Abrir las opciones y preparar la eliminación del documento.
    await tester.tap(find.byTooltip('Opciones del paquete'));
    await waitForLabel(tester, find.text('Eliminar'));
    await tester.tap(find.text('Eliminar'));
    await waitForLabel(tester, find.text('Eliminar paquete'));
    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pump();

    final deleted = await collection.doc(packageId).get();
    expect(deleted.exists, isFalse);

    // Borrar la cuenta ficticia del emulador al finalizar la prueba.
    await FirebaseRuntime.auth.currentUser?.delete();
  });
}
