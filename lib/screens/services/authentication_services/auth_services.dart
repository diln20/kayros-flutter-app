import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class AuthServices with ChangeNotifier{
  bool _isLoading = false;
  String _errorMessage;
  bool get isloading => _isLoading;
  String get errorMessage => _errorMessage;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  
  Future register(String email , String password, String text, String trim)async{
    try{
     setLoading(true);
     UserCredential authResult = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
     User user = authResult.user;
     String uid = authResult.user.uid;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({ 'email': email, 'uid':uid});
     setLoading(false);
     return user;  
    }on SocketException{
      setLoading(false);
      setMessage("No internet,please connect to internet");
    }
    catch(e){
      setLoading(false);
      setMessage(e.message);
    }
    notifyListeners();
  }
















  

Future login(String email , String password)async{
    setLoading(true);
    try{
     UserCredential authResult = await firebaseAuth
     .signInWithEmailAndPassword(email: email, password: password);
     User user = authResult.user;
     setLoading(false);
     return user;  
     
    }on SocketException{
      setLoading(false);
      setMessage("No internet,please connect to internet");
    }
    catch(e){
      setLoading(false);
      setMessage(e.message);
    }
    notifyListeners();
  }
  
  Future logout() async{
    await firebaseAuth.signOut();
  }
  

  void setLoading(val){
    _isLoading=val;
    notifyListeners();
  }

  void setMessage(message){
    _errorMessage= message;
    notifyListeners();
  }
  


  Stream<User> get user=>
  firebaseAuth.authStateChanges().map((event) => event);
}