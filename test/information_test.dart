import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kayros/screens/pages/drivers.dart';
import 'package:kayros/theme/app_theme.dart';

void main() {
  testWidgets('La sección Información explica pasos y permite abrir ayuda',
      (tester) async {
    tester.view.physicalSize = const Size(390, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: const Scaffold(body: Drivers()),
    ));

    expect(find.text('¿Cómo funciona Kayros?'), findsOneWidget);
    expect(find.text('1. Registra tu solicitud'), findsOneWidget);

    await tester.ensureVisible(find.text('¿Olvidé mi contraseña?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('¿Olvidé mi contraseña?'));
    await tester.pumpAndSettle();
    expect(find.textContaining('En la pantalla de acceso'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
