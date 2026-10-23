import 'package:flutter/material.dart';
import 'package:kayros/screens/Authentication/login.dart';
import 'package:kayros/screens/Authentication/register.dart';

class Authenticator extends StatefulWidget {
  const Authenticator({super.key});

  @override
  State<Authenticator> createState() => _AuthenticatorState();
}

class _AuthenticatorState extends State<Authenticator> {
  bool showRegister = false;

  void toggleScreen() {
    setState(() => showRegister = !showRegister);
  }

  @override
  Widget build(BuildContext context) {
    return showRegister
        ? Register(toggleScreen: toggleScreen)
        : Login(toggleScreen: toggleScreen);
  }
}
