import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kayros/database/db_validator.dart';
import 'package:kayros/screens/description.dart' as package_details;
import 'package:kayros/screens/pages/addpacket.dart';
import 'package:kayros/screens/pages/drivers.dart';

void main() {
  test('Valida campos vacíos correctamente', () {
    expect(DbValidator.validateField(value: ''), isNotNull);
    expect(DbValidator.validateField(value: '  '), isNotNull);
    expect(DbValidator.validateField(value: 'Correcto'), isNull);
  });

  testWidgets('Detalle muestra datos existentes del paquete', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: package_details.Description(
        title: 'Laura',
        description: 'López',
        details: {
          'producto': 'Caja',
          'cedula': '123456',
          'dirrecion': 'Calle 1',
        },
      ),
    ));
    expect(find.text('Laura López'), findsOneWidget);
    expect(find.text('Caja'), findsOneWidget);
    expect(find.text('Calle 1'), findsOneWidget);
  });

  testWidgets('Formulario original se abre', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Packet()));
    expect(find.text('Agregar paquetes'), findsOneWidget);
    expect(find.text('Nombre'), findsOneWidget);
    expect(find.text('Apellidos'), findsOneWidget);
  });

  testWidgets('Pantalla de información muestra estado original', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Drivers())));
    expect(find.text('En construcción'), findsOneWidget);
  });
}
