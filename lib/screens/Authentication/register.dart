import 'package:flutter/material.dart';
import 'package:kayros/screens/services/authentication_services/auth_services.dart';
import 'package:provider/provider.dart';



class Register extends StatefulWidget {
  final Function toggleScreen;

  const Register({Key key, this.toggleScreen}) : super(key: key);
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Register> {
  TextEditingController _emailController;
  TextEditingController _passwordController;
  TextEditingController _nombreController;
  TextEditingController _apellidoController;
  final _formkey = GlobalKey<FormState>();
  
  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nombreController = TextEditingController();
    _apellidoController = TextEditingController();
    super.initState();  
  }
  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
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
                  //   color: Theme.of(context).primaryColor,),
                   //   onPressed: (){
                         
                   //  }
                   // ),
                     SizedBox(height: 30,),
                     Text(
                       "welcome",style: TextStyle(
                         fontSize: 22,
                         fontWeight: FontWeight.bold
                         ),
                     ),
                     SizedBox(height:10),
                     Text("Create account to continue",
                     style: TextStyle(fontSize: 14,
                     color: Colors.grey),
                     ),
                     SizedBox(height:30),
                     TextFormField(
                       controller: _nombreController,
                       validator: (val)=> val.isNotEmpty ? null : "Please enter a email address",
                       decoration: InputDecoration(
                         hintText: "nombre",
                         prefixIcon: Icon(Icons.email),
                         border: OutlineInputBorder(
                            borderRadius:BorderRadius.circular(10),
                         ),
                       ),
                     ),
                     SizedBox(height:30),
                     TextFormField(
                       controller: _apellidoController,
                       validator: (val)=> val.isNotEmpty ? null : "Please enter a email address",
                       decoration: InputDecoration(
                         hintText: "Apellido",
                         prefixIcon: Icon(Icons.email),
                         border: OutlineInputBorder(
                            borderRadius:BorderRadius.circular(10),
                         ),
                       ),
                     ),
                     SizedBox(height:30),
                     TextFormField(
                       controller: _emailController,
                       validator: (val)=> val.isNotEmpty ? null : "Please enter a email address",
                       decoration: InputDecoration(
                         hintText: "Email",
                         prefixIcon: Icon(Icons.email),
                         border: OutlineInputBorder(
                            borderRadius:BorderRadius.circular(10),
                         ),
                       ),
                     ),
                    SizedBox(height:30),
                     TextFormField(
                      controller: _passwordController,
                      validator: (val)=>val.length < 6 ?"Enter more than 6 char":null,
                       decoration: InputDecoration(
                         hintText: "Password",
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
                          print("nombre: ${_nombreController.text}");
                          print("apellidos: ${_apellidoController.text}");
                           await loginProvider.register(
                           _emailController.text.trim(),
                           _passwordController.text.trim(),
                           _nombreController.text,
                           _apellidoController.text.trim()
                           );
                        }
                      },
                      height: 70,
                      minWidth:loginProvider.isloading ? null: double.infinity,
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: loginProvider.isloading ?
                      CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white
                        )
                      ):
                       Text(
                        "Register",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                     ),
                     SizedBox(height: 20 ),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children:[
                       Text("Already have an account ?"),
                       SizedBox(width:5),
                       TextButton(
                         onPressed: () => widget.toggleScreen(),
                          child: Text("Login"),
                       )
                    ]),
                    SizedBox(height:20),
                    if(loginProvider.errorMessage != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal:10,vertical:5),
                      color: Colors.amberAccent,
                      child:ListTile(
                      title: Text(loginProvider.errorMessage),
                      leading: Icon(Icons.error),
                      trailing: IconButton(icon:Icon(Icons.close),onPressed:()=>loginProvider.setMessage(null) ,) ,
                      )
                    )
                   ]
                 ),
               
             ),
         ),
          ),
       ),
    );
  }



}