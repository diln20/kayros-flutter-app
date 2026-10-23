import 'package:flutter/material.dart';
import 'package:kayros/utils/form_validators.dart';

/// Permite probar el formulario de recuperación sin utilizar una cuenta real.
class PasswordResetDialog extends StatefulWidget {
  const PasswordResetDialog({
    super.key,
    required this.onSubmit,
    this.initialEmail = '',
  });

  /// Devuelve null si el correo se envió, o el mensaje de error.
  final Future<String?> Function(String email) onSubmit;
  final String initialEmail;

  @override
  State<PasswordResetDialog> createState() => _PasswordResetDialogState();
}

class _PasswordResetDialogState extends State<PasswordResetDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _email;
  String? _error;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: widget.initialEmail.trim());
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _error = null;
      _sending = true;
    });

    String? error;
    try {
      error = await widget.onSubmit(_email.text.trim());
    } catch (_) {
      error = 'No fue posible enviar el correo de recuperación.';
    }

    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _error = error;
      _sending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Recuperar contraseña'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Te enviaremos un enlace para recuperar el acceso a tu cuenta.',
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _email,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _send(),
              validator: FormValidators.email,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  )),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _sending ? null : _send,
          child: _sending
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Enviar enlace'),
        ),
      ],
    );
  }
}
