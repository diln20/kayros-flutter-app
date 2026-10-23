import 'package:flutter/material.dart';
import 'package:kayros/screens/services/authentication_services/auth_services.dart';
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
  bool obscurePassword = true;

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

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<AuthServices>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 490),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        'src/logo kairos1.jpg',
                        height: 215,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text('Bienvenido',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 26,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    const Text('Inicia sesión para continuar'),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return 'Ingresa tu correo.';
                        if (!email.contains('@')) return 'Correo electrónico inválido.';
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Correo',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 19),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Ingresa una contraseña de al menos 6 caracteres.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          tooltip: obscurePassword ? 'Mostrar contraseña' : 'Ocultar contraseña',
                          icon: Icon(obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => obscurePassword = !obscurePassword),
                        ),
                      ),
                    ),
                    if (loginProvider.errorMessage != null) ...[
                      const SizedBox(height: 14),
                      Card(
                        color: Colors.orange.shade50,
                        child: ListTile(
                          leading: const Icon(Icons.error_outline, color: Colors.red),
                          title: Text(loginProvider.errorMessage!),
                          trailing: IconButton(
                            tooltip: 'Cerrar error',
                            icon: const Icon(Icons.close),
                            onPressed: () => loginProvider.setMessage(null),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: loginProvider.isloading ? null : _submit,
                        child: loginProvider.isloading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white))
                            : const Text('Ingresar', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Flexible(child: Text('¿No tienes una cuenta?')),
                        TextButton(
                          onPressed: loginProvider.isloading ? null : widget.toggleScreen,
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
    );
  }
}
