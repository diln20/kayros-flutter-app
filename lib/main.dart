import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kayros/screens/services/authentication_services/auth_services.dart';
import 'package:kayros/screens/wrapper.dart';
import 'package:provider/provider.dart';

void main()=>runApp(MaterialApp(home: MyApp(),));



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _init= Firebase.initializeApp();
    return FutureBuilder(
      future: _init,
      builder: (context,snapshoot){
        if(snapshoot.hasError){
          return ErrorWidget();
        }else if (snapshoot.hasData){
          return MultiProvider(
              providers: [
                ChangeNotifierProvider<AuthServices>.value(value:AuthServices()),
                StreamProvider<User>.value(value: AuthServices().user,
                initialData:null,)
              ],
              child: MaterialApp(
                theme: ThemeData(
                  primarySwatch: Colors.red,
                ),
                debugShowCheckedModeBanner: false,
                home: Wrapper(),
            ),
          );
          
        }else{
          return Loading();
        }
      },
    );
  }
}

class ErrorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body:Center(
     child: Column(
       children: [
         Icon(Icons.error),
         Text("Something went wrong !")
       ]
     ),
    ),
    );
  }
}

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
      child: CircularProgressIndicator(),
    ),
    );
  }
}


