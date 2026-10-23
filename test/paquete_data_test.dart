import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kayros/models/paquete_data.dart';
import 'package:kayros/screens/pages/addpacket.dart';
import 'package:kayros/theme/app_theme.dart';
import 'package:kayros/utils/form_validators.dart';

void main() {
  group('Compatibilidad y búsqueda de paquetes', () {
    test('Lee registros históricos sin cambiar nombres de campos', () {
      final data = PaqueteData.fromMap({
        'title': 'Andrés',
        'description': 'Pérez',
        'cedula': '12345',
        'producto': 'Zapatos',
        'tipo': 'Ropa',
        'email': 'ejemplo@correo.com',
        'dirrecion': 'Carrera 12',
        'valor': '15.000',
        'time': '2026-10-23 13:45:00.000',
      });
      expect(data.destinatario, 'Andrés Pérez');
      expect(data.direccion, 'Carrera 12');
      expect(data.fecha, DateTime(2026, 10, 23, 13, 45));
      expect(data.toFirestoreFields()['dirrecion'], 'Carrera 12');
      expect(data.matches('ANDRES zapatos'), isTrue);
      expect(data.matches('peréz 123'), isTrue);
      expect(data.matches('computador'), isFalse);
    });

    test('Usa timestamp Firestore y ordena paquetes sin fecha al final', () {
      final date = DateTime.utc(2026, 10, 20);
      final newer = PaqueteData.fromMap({
        'title': 'Lucía',
        'timestamp': Timestamp.fromDate(date),
      });
      final older = PaqueteData.fromMap({
        'title': 'Juan',
        'time': '2025-01-10T10:00:00.000',
      });
      final unknown = PaqueteData.fromMap({'title': 'Sin fecha'});
      final ordered = [unknown, older, newer]
        ..sort((a, b) => PaqueteData.compare(a, b));
      expect(ordered.map((record) => record.nombre).toList(),
          ['Lucía', 'Juan', 'Sin fecha']);
      ordered.sort((a, b) => PaqueteData.compare(a, b, newestFirst: false));
      expect(ordered.map((record) => record.nombre).toList(),
          ['Juan', 'Lucía', 'Sin fecha']);
    });

    test('Preserva el esquema al construir un paquete de formulario', () {
      final record = PaqueteData.fromForm([
        ' Ana ',
        ' López ',
        ' 1010 ',
        ' Caja ',
        ' Fragil ',
        ' ana@correo.com ',
        ' Calle 12 ',
        ' 25000 ',
      ]);
      expect(record.destinatario, 'Ana López');
      expect(record.toFirestoreFields()['email'], 'ana@correo.com');
      expect(record.toFirestoreFields()['valor'], '25000');
      expect(record.toFirestoreFields().keys.toList(), PaqueteData.fieldKeys);
      expect(() => PaqueteData.fromForm(['solo uno']), throwsArgumentError);
    });
  });

  group('Validación de formularios', () {
    test('Rechaza campos vacíos y correos incorrectos', () {
      expect(FormValidators.required('  ', 'un campo'), isNotNull);
      expect(FormValidators.required('Dato', 'un campo'), isNull);
      expect(FormValidators.email('correo-invalido'), isNotNull);
      expect(FormValidators.email('correo@dominio.com'), isNull);
    });

    test('Acepta valores numéricos y bloquea texto libre', () {
      expect(FormValidators.amount(''), isNotNull);
      expect(FormValidators.amount('abc'), isNotNull);
      expect(FormValidators.amount('0'), isNotNull);
      expect(FormValidators.amount('25000'), isNull);
      expect(FormValidators.amount('25.000'), isNull);
    });
  });

  testWidgets('El formulario comprueba los campos antes de usar Firebase',
      (tester) async {
    tester.view.physicalSize = const Size(375, 750);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const Packet()),
    );
    await tester.tap(find.text('Agregar paquete'));
    await tester.pump();
    expect(find.text('Ingresa nombre.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
