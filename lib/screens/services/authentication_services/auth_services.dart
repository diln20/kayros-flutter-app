import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kayros/config/firebase_runtime.dart';
import 'package:flutter/foundation.dart';
import 'package:kayros/utils/auth_error_messages.dart';

class AuthServices extends ChangeNotifier {
  AuthServices({FirebaseAuth? auth, FirebaseFirestore? database})
      : firebaseAuth = auth ?? FirebaseRuntime.auth,
        firestore = database ?? FirebaseRuntime.firestore;

  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

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
        email: email.trim(),
        password: password,
      );
      final user = credentials.user;
      if (user == null) {
        throw StateError('Firebase no devolvió un usuario.');
      }

      // Mantiene la estructura original sin exponer la contraseña.
      await firestore.collection('users').doc(user.uid).set({
        'email': email.trim(),
        'uid': user.uid,
        'nombre': firstName.trim(),
        'apellidos': lastName.trim(),
      }, SetOptions(merge: true));
      return user;
    } on FirebaseAuthException catch (error) {
      setMessage(AuthErrorMessages.forCode(
        error.code,
        fallback: error.message,
      ));
    } on FirebaseException catch (error) {
      setMessage(error.message ?? 'No se pudo guardar el perfil.');
    } on SocketException {
      setMessage('Sin conexión a Internet.');
    } catch (error) {
      setMessage('No fue posible crear la cuenta: $error');
    } finally {
      setLoading(false);
    }
    return null;
  }

  Future<User?> login(String email, String password) async {
    setMessage(null);
    setLoading(true);
    try {
      final credentials = await firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credentials.user;
    } on FirebaseAuthException catch (error) {
      setMessage(AuthErrorMessages.forCode(
        error.code,
        fallback: error.message,
      ));
    } on SocketException {
      setMessage('Sin conexión a Internet.');
    } catch (error) {
      setMessage('No se pudo iniciar sesión: $error');
    } finally {
      setLoading(false);
    }
    return null;
  }

  Future<bool> requestPasswordReset(String email) async {
    setMessage(null);
    setLoading(true);
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (error) {
      setMessage(AuthErrorMessages.forCode(
        error.code,
        fallback: error.message,
      ));
    } on SocketException {
      setMessage('Sin conexión a Internet.');
    } catch (_) {
      setMessage('No fue posible enviar el correo de recuperación.');
    } finally {
      setLoading(false);
    }
    return false;
  }

  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
      setMessage(null);
    } on FirebaseAuthException catch (error) {
      setMessage(AuthErrorMessages.forCode(
        error.code,
        fallback: error.message,
      ));
    } catch (_) {
      setMessage('No fue posible cerrar sesión.');
    }
  }
}
