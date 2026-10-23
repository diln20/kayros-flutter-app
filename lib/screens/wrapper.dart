import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kayros/screens/Authentication/authenticator.dart';
import 'package:kayros/screens/homeScreens/home_screen.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = context.watch<User?>();
    return user == null ? const Authenticator() : const HomeScreen();
  }
}
