import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kayros/config/firebase_runtime.dart';
import 'package:kayros/main.dart';

// Espera una pantalla real, sin depender de tiempos fijos del emulador.
Future<void> waitForElement(WidgetTester tester, Finder finder) async {
  final deadline = DateTime.now().add(const Duration(seconds: 45));
  while (finder.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 250));
  }
  expect(finder, findsWidgets);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('QA: registro, perfil, recuperación e inicio de sesión',
      (tester) async {
    expect(FirebaseRuntime.useEmulators, isTrue,
        reason: 'Necesitas --dart-define=KAYROS_USE_FIREBASE_EMULATORS=true');
    await FirebaseRuntime.initialize();
    expect(FirebaseRuntime.auth.app.options.projectId,
        FirebaseRuntime.demoProjectId);
    await FirebaseRuntime.auth.signOut();

    // Cada ejecución utiliza una cuenta ficticia diferente y aislada.
    final suffix = DateTime.now().microsecondsSinceEpoch;
    final email = 'e2e.auth.$suffix@example.com';
    final password = 'QaTest$suffix' 'Ab9!';

    // Recorrer las mismas pantallas que utiliza una persona.
    await tester.pumpWidget(const KayrosApp());
    await waitForElement(tester, find.text('Regístrate aquí'));
    await tester.tap(find.text('Regístrate aquí'));
    await waitForElement(tester, find.text('Crear cuenta'));

    final fields = find.byType(TextFormField);
    final values = ['QA', 'Autenticación', email, password, password];
    for (var i = 0; i < values.length; i++) {
      await tester.ensureVisible(fields.at(i));
      await tester.enterText(fields.at(i), values[i]);
      await tester.pump();
    }

    final createButton = find.widgetWithText(FilledButton, 'Crear cuenta');
    await tester.ensureVisible(createButton);
    await tester.tap(createButton);
    await waitForElement(tester, find.text('Hola, bienvenido'));

    final user = FirebaseRuntime.auth.currentUser;
    expect(user, isNotNull);
    expect(user!.email, email);

    // Comprobar que el perfil se guardó en el Firestore de pruebas.
    final profile =
        await FirebaseRuntime.firestore.collection('users').doc(user.uid).get();
    expect(profile.exists, isTrue);
    expect(profile.data()?['nombre'], 'QA');
    expect(profile.data()?['apellidos'], 'Autenticación');

    // Comprobar el cierre de sesión y la recuperación de la cuenta.
    await tester.tap(find.byTooltip('Cerrar sesión'));
    await waitForElement(tester, find.text('Salir'));
    await tester.tap(find.widgetWithText(FilledButton, 'Salir'));
    await waitForElement(tester, find.text('¿Olvidaste tu contraseña?'));

    // El correo de recuperación queda en el Auth Emulator (sin Internet).
    await tester.tap(find.text('¿Olvidaste tu contraseña?'));
    await waitForElement(tester, find.text('Enviar enlace'));
    await tester.enterText(find.byType(TextFormField).last, email);
    await tester.tap(find.text('Enviar enlace'));
    await waitForElement(
        tester, find.textContaining('recibirás un enlace de recuperación'));

    final loginFields = find.byType(TextFormField);
    await tester.enterText(loginFields.at(0), email);
    await tester.enterText(loginFields.at(1), password);
    await tester.tap(find.widgetWithText(FilledButton, 'Ingresar'));
    await waitForElement(tester, find.text('Hola, bienvenido'));
    expect(FirebaseRuntime.auth.currentUser?.uid, user.uid);

    // Cerrar la sesión al terminar para no contaminar la prueba siguiente.
    await FirebaseRuntime.auth.signOut();
  });
}
