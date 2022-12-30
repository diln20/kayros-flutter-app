import 'package:flutter/material.dart';
import 'package:kayros/screens/Authentication/login.dart';
import 'package:kayros/screens/Authentication/register.dart';


class Authenticator extends StatefulWidget {
  @override
  _AuthenticatorState createState() => _AuthenticatorState();
}



class _AuthenticatorState extends State<Authenticator> {
  bool isToggle =false;
  void toggleScreen(){
    setState(() {
      isToggle = !isToggle;
    });
  }
  @override
  Widget build(BuildContext context) {
   if(isToggle){
     return Register(toggleScreen:toggleScreen);
   }else{
     return Login(toggleScreen:toggleScreen);
   }
  }
}