import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthServices extends ChangeNotifier {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isloading => _isLoading;
  String? get errorMessage => _errorMessage;
  Stream<User?> get user => firebaseAuth.authStateChanges();

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  String _messageFor(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'Este correo ya está registrado.';
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'network-request-failed':
        return 'Comprueba tu conexión a Internet.';
      case 'too-many-requests':
        return 'Demasiados intentos. Prueba nuevamente más tarde.';
      case 'operation-not-allowed':
        return 'La autenticación por correo no está habilitada en Firebase.';
      default:
        return error.message ?? 'No fue posible completar la autenticación.';
    }
  }

  Future<User?> register(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    setMessage(null);
    setLoading(true);
    try {
      final credentials = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credentials.user;
      if (user == null) {
        throw StateError('Firebase no devolvió un usuario.');
      }
      await firestore.collection('users').doc(user.uid).set({
        'email': email,
        'uid': user.uid,
        'nombre': firstName.trim(),
        'apellidos': lastName.trim(),
      }, SetOptions(merge: true));
      return user;
    } on FirebaseAuthException catch (e) {
      setMessage(_messageFor(e));
    } on FirebaseException catch (e) {
      setMessage(e.message ?? 'No se pudo guardar el perfil.');
    } on SocketException {
      setMessage('Sin conexión a Internet.');
    } catch (e) {
      setMessage('Error al crear la cuenta: $e');
    } finally {
      setLoading(false);
    }
    return null;
  }

  Future<User?> login(String email, String password) async {
    setMessage(null);
    setLoading(true);
    try {
      final result = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      setMessage(_messageFor(e));
    } on SocketException {
      setMessage('Sin conexión a Internet.');
    } catch (e) {
      setMessage('Error al iniciar sesión: $e');
    } finally {
      setLoading(false);
    }
    return null;
  }

  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
      setMessage(null);
    } catch (e) {
      setMessage('No fue posible cerrar sesión: $e');
    }
  }
}
