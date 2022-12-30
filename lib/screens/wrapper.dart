import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kayros/screens/Authentication/authenticator.dart';
import 'package:kayros/screens/homeScreens/home_screen.dart';
import 'package:provider/provider.dart';


class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    if(user !=null){
      return HomeScreen();
    }else{
      return Authenticator();
    }
  }
}