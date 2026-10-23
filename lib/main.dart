import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kayros/screens/services/authentication_services/auth_services.dart';
import 'package:kayros/screens/wrapper.dart';
import 'package:kayros/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KayrosApp());
}

class KayrosApp extends StatelessWidget {
  const KayrosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kayros Express',
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      home: const FirebaseBootstrap(),
    );
  }
}

class FirebaseBootstrap extends StatefulWidget {
  const FirebaseBootstrap({super.key});

  @override
  State<FirebaseBootstrap> createState() => _FirebaseBootstrapState();
}

class _FirebaseBootstrapState extends State<FirebaseBootstrap> {
  late Future<FirebaseApp> initialization;

  @override
  void initState() {
    super.initState();
    initialization = Firebase.initializeApp();
  }

  void retry() {
    setState(() => initialization = Firebase.initializeApp());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Kayros Express')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off,
                        size: 56, color: AppPalette.primary),
                    const SizedBox(height: 16),
                    const Text('No se pudo conectar con Firebase.',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: retry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthServices>(
              create: (_) => AuthServices(),
            ),
            StreamProvider<User?>(
              create: (_) => FirebaseAuth.instance.authStateChanges(),
              initialData: null,
              catchError: (context, error) => null,
            ),
          ],
          child: const Wrapper(),
        );
      },
    );
  }
}
