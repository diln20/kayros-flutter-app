import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kayros/screens/Authentication/password_reset_dialog.dart';
import 'package:kayros/utils/auth_error_messages.dart';
import 'package:kayros/utils/form_validators.dart';

void main() {
  test('Traduce errores de Firebase Authentication', () {
    expect(AuthErrorMessages.forCode('invalid-credential'),
        'Correo o contraseña incorrectos.');
    expect(AuthErrorMessages.forCode('too-many-requests'),
        contains('Demasiados intentos'));
    expect(
      AuthErrorMessages.forCode('custom-error', fallback: 'Mensaje específico'),
      'Mensaje específico',
    );
  });

  test('Contraseña nueva y confirmación', () {
    expect(FormValidators.newPassword('1234567'), isNotNull);
    expect(FormValidators.newPassword('12345678'), isNull);
    expect(FormValidators.confirmPassword('', '12345678'), isNotNull);
    expect(FormValidators.confirmPassword('12345679', '12345678'), isNotNull);
    expect(FormValidators.confirmPassword('12345678', '12345678'), isNull);
  });

  testWidgets('Recuperación valida correo antes de enviar', (tester) async {
    String? submittedEmail;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(builder: (context) {
          return TextButton(
            onPressed: () => showDialog<bool>(
              context: context,
              builder: (_) => PasswordResetDialog(
                onSubmit: (email) async {
                  submittedEmail = email;
                  return null;
                },
              ),
            ),
            child: const Text('Abrir'),
          );
        }),
      ),
    ));

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enviar enlace'));
    await tester.pump();
    expect(find.text('Ingresa un correo electrónico.'), findsOneWidget);
    expect(submittedEmail, isNull);

    await tester.enterText(find.byType(TextFormField), 'correo@ejemplo.com');
    await tester.tap(find.text('Enviar enlace'));
    await tester.pumpAndSettle();
    expect(submittedEmail, 'correo@ejemplo.com');
    expect(find.text('Recuperar contraseña'), findsNothing);
  });

  testWidgets('Recuperación presenta los errores de servicio', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: PasswordResetDialogProxy(),
      ),
    ));
    await tester.enterText(find.byType(TextFormField), 'correo@ejemplo.com');
    await tester.tap(find.text('Enviar enlace'));
    await tester.pumpAndSettle();
    expect(find.text('Servicio no disponible'), findsOneWidget);
  });
}

class PasswordResetDialogProxy extends StatelessWidget {
  const PasswordResetDialogProxy({super.key});

  @override
  Widget build(BuildContext context) => PasswordResetDialog(
        onSubmit: (_) async => 'Servicio no disponible',
      );
}
