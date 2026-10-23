import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kayros/screens/pages/home.dart';
import 'package:kayros/theme/app_theme.dart';

void main() {
  testWidgets('Inicio adapta accesos y permite navegar en pantalla estrecha',
      (tester) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    int? selectedTab;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: Home(onSelectTab: (tab) => selectedTab = tab),
      ),
    ));
    expect(find.text('Accesos rápidos'), findsOneWidget);
    await tester.ensureVisible(find.text('Mis paquetes'));
    await tester.tap(find.text('Mis paquetes'));
    await tester.pump();
    expect(selectedTab, 1);
    expect(tester.takeException(), isNull);
  });
}
