import 'package:flutter/material.dart';
import 'package:kayros/screens/services/authentication_services/auth_services.dart';
import 'package:provider/provider.dart';



class Login extends StatefulWidget {
  final Function toggleScreen;

  const Login({Key key, this.toggleScreen}) : super(key: key);
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _emailController;
  TextEditingController _passwordController;
  final _formkey = GlobalKey<FormState>();
  
  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();  
  }
  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<AuthServices>(context);
    return Scaffold(
       body: SafeArea(
          child: SingleChildScrollView (
             child: Padding(
             padding: const EdgeInsets.all(20.0),
             child: Form(
               key: _formkey,
                   child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children:[
                    // IconButton(icon: Icon(Icons.arrow_back_ios,
                     //color: Theme.of(context).primaryColor,),
                      //onPressed: (){
                        
                     //}),
                     Container(
                     
                     height: 220,
                     width: 512,
                     child:Image(
                       image: AssetImage('src/logo kairos1.jpg'),
                     ),
                     ),
                     SizedBox(height: 30,),
                     Text(
                       "Bienvenido",style: TextStyle(
                         fontSize: 22,
                         color: Colors.red,
                         fontWeight: FontWeight.bold
                         ),
                     ),
                     SizedBox(height:10),
                     Text("Inicia sesión para continuar",
                     style: TextStyle(fontSize: 14,
                     color: Colors.black),
                     ),
                     SizedBox(height:30),
                     TextFormField(
                       controller: _emailController,
                       validator: (val)=> val.isNotEmpty ? null : "Please enter a email address",
                       decoration: InputDecoration(
                         hintText: "Correo",
                         prefixIcon: Icon(Icons.email),
                         border: OutlineInputBorder(
                            borderRadius:BorderRadius.circular(10),
                         ),
                       ),
                     ),
                    SizedBox(height:30),
                     TextFormField(
                      obscureText: true,
                      controller: _passwordController,
                      validator: (val)=>val.length < 6 ?"Enter more than 6 char":null,
                       decoration: InputDecoration(
                         hintText: "Contraseña",
                          prefixIcon: Icon(Icons.vpn_key),
                         border: OutlineInputBorder(
                            borderRadius:BorderRadius.circular(10),
                         ),
                       ),
                     ),
                     SizedBox(height:30),
                     MaterialButton(
                      onPressed: () async{
                        if(_formkey.currentState.validate()){
                          print("Email: ${_emailController.text}");
                          print("password: ${_passwordController.text}");
                          await loginProvider.login(
                           _emailController.text.trim(),
                           _passwordController.text.trim()
                           );
                        }
                      },
                      height: 60,
                      minWidth:loginProvider.isloading ? null : double.infinity,
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child:loginProvider.isloading ? CircularProgressIndicator()
                      :Text(
                        "Ingresar",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                     ),
                     SizedBox(height: 2 ),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children:[
                       Text("No tienes una cuenta ?"),
                       SizedBox(width:5),
                       TextButton(
                         onPressed: () => widget.toggleScreen(),
                          child: Text("Registrate aquí"),
                       )
                    ]),
                   ]
                 ),
               
             ),
         ),
          ),
       ),
    );
  }



}