import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// La aplicación real usa Firebase predeterminado. Los tests E2E usan una
/// aplicación Firebase secundaria con proyecto DEMO y dos emuladores locales.
///
/// Solo se activa en modo DEBUG y con un --dart-define explícito. En caso de
/// error nunca vuelve a Firebase de producción.
abstract final class FirebaseRuntime {
  static const useEmulators = bool.fromEnvironment(
    'KAYROS_USE_FIREBASE_EMULATORS',
    defaultValue: false,
  );
  static const emulatorHost = String.fromEnvironment(
    'KAYROS_EMULATOR_HOST',
    defaultValue: '10.0.2.2',
  );

  static const demoProjectId = 'demo-kayros-e2e';
  static const _demoAppName = 'kayros-e2e';

  static FirebaseApp? _selectedApp;
  static bool _configured = false;

  static FirebaseAuth get auth =>
      FirebaseAuth.instanceFor(app: _selectedApp ?? Firebase.app());

  static FirebaseFirestore get firestore =>
      FirebaseFirestore.instanceFor(app: _selectedApp ?? Firebase.app());

  static Future<FirebaseApp> initialize() async {
    if (!useEmulators) {
      return _selectedApp ??= await Firebase.initializeApp();
    }

    if (!kDebugMode) {
      throw StateError(
        'Los emuladores de Kayros solo pueden activarse en modo debug.',
      );
    }
    if (emulatorHost.isEmpty) {
      throw StateError('Debes indicar el host del emulador de Firebase.');
    }

    final app = _selectedApp ??= await Firebase.initializeApp(
      name: _demoAppName,
      options: const FirebaseOptions(
        apiKey: 'local-firebase-emulator-no-secret',
        appId: '1:1234567890:android:kayrose2etesting',
        messagingSenderId: '1234567890',
        projectId: demoProjectId,
      ),
    );
    if (!_configured) {
      // Configurar ambas rutas antes de instanciar pantallas o servicios.
      await FirebaseAuth.instanceFor(app: app).useAuthEmulator(
        emulatorHost,
        9099,
      );
      final database = FirebaseFirestore.instanceFor(app: app);
      database.settings = const Settings(persistenceEnabled: false);
      database.useFirestoreEmulator(emulatorHost, 8080);
      _configured = true;
    }
    return app;
  }
}
