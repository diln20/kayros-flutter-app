import 'package:flutter/material.dart';
import 'package:kayros/screens/Authentication/password_reset_dialog.dart';
import 'package:kayros/screens/services/authentication_services/auth_services.dart';
import 'package:kayros/theme/app_theme.dart';
import 'package:kayros/utils/form_validators.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key, required this.toggleScreen});
  final VoidCallback toggleScreen;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await context.read<AuthServices>().login(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  Future<void> _recoverPassword() async {
    final service = context.read<AuthServices>();
    final sent = await showDialog<bool>(
      context: context,
      builder: (_) => PasswordResetDialog(
        initialEmail: _emailController.text.trim(),
        onSubmit: (email) async {
          final success = await service.requestPasswordReset(email);
          return success
              ? null
              : service.errorMessage ?? 'No se pudo enviar el correo.';
        },
      ),
    );
    if (!mounted || sent != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Si el correo está registrado, recibirás un enlace de recuperación.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthServices>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 510),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.asset(
                          'src/logo kairos1.jpg',
                          height: 165,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Bienvenido a Kayros',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppPalette.ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Inicia sesión para gestionar tus solicitudes.',
                        style: TextStyle(color: AppPalette.muted),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        validator: FormValidators.email,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onFieldSubmitted: (_) => _submit(),
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Ingresa una contraseña válida.';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? 'Mostrar contraseña'
                                : 'Ocultar contraseña',
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: auth.isloading ? null : _recoverPassword,
                          child: const Text('¿Olvidaste tu contraseña?'),
                        ),
                      ),
                      if (auth.errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Card(
                          color: const Color(0xFFFFEFEF),
                          child: ListTile(
                            leading: const Icon(Icons.error_outline,
                                color: AppPalette.primary),
                            title: Text(auth.errorMessage!),
                            trailing: IconButton(
                              tooltip: 'Cerrar aviso',
                              icon: const Icon(Icons.close),
                              onPressed: () => auth.setMessage(null),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: auth.isloading ? null : _submit,
                          child: auth.isloading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('Ingresar'),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Flexible(child: Text('¿No tienes una cuenta?')),
                          TextButton(
                            onPressed:
                                auth.isloading ? null : widget.toggleScreen,
                            child: const Text('Regístrate aquí'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
