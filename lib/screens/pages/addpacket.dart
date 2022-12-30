import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kayros/screens/services/authentication_services/auth_services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

class Packet extends StatefulWidget {
  @override
  State<Packet> createState() => _PacketState();
}

class _PacketState extends State<Packet> {
  TextEditingController _nombreController = TextEditingController();
  TextEditingController _apellidoController = TextEditingController();
  TextEditingController _cedulaController = TextEditingController();
  TextEditingController _producController = TextEditingController();
  TextEditingController _tipoController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _dirrecionController = TextEditingController();
  TextEditingController _valorController = TextEditingController();

  addtasktofirebase() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    String uid = user.uid;
    var time = DateTime.now();
    await FirebaseFirestore.instance
        .collection('paquetes')
        .doc(uid)
        .collection('mispaquetes')
        .doc(time.toString())
        .set({
      'title': _nombreController.text,
      'description': _apellidoController.text,
      'time': time.toString(),
      'timestamp': time,
      'cedula': _cedulaController.text,
      'producto': _producController.text,
      'tipo': _tipoController.text,
      'email': _emailController.text,
      'dirrecion': _dirrecionController.text,
      'valor': _valorController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<AuthServices>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Agregar Paquetes"),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async => await loginProvider.logout(),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _nombreController,
                    decoration: InputDecoration(
                      labelText: "Nombre",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _apellidoController,
                    decoration: InputDecoration(
                      labelText: "Apellidos",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _cedulaController,
                    decoration: InputDecoration(
                      labelText: "cedula",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _producController,
                    decoration: InputDecoration(
                      labelText: "Producto",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _tipoController,
                    decoration: InputDecoration(
                      labelText: "tipo",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _dirrecionController,
                    decoration: InputDecoration(
                      labelText: "dirreción",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _valorController,
                    decoration: InputDecoration(
                      labelText: "Valor domicilio",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CupertinoButton.filled(
                      child: Text('Agregar paquete'),
                      onPressed: () {
                        addtasktofirebase();
                        Navigator.of(context).pop();
                        // MaterialPageRoute(
                        // builder: (context) =>HomeScreen(),
                        // ));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Company {
  int id;
  String name;

  Company(this.id, this.name);

  static List<Company> getCompanies() {
    return <Company>[
      Company(1, 'Apple'),
      Company(2, 'Google'),
      Company(3, 'Samsung'),
      Company(4, 'Sony'),
      Company(5, 'LG'),
    ];
  }
}
