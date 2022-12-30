import 'package:flutter/material.dart';
import 'package:kayros/screens/pages/addpacket.dart';
import 'package:kayros/screens/pages/drivers.dart';
import 'package:kayros/screens/pages/home.dart';
import 'package:kayros/screens/pages/paquetes.dart';
import 'package:kayros/screens/services/authentication_services/auth_services.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _paginActual = 0;
  List<Widget> _paginas = [
    Home(),
    Paquetes(),
    Drivers(),
  ];
  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<AuthServices>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Kayro Expres"),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async => await loginProvider.logout(),
          ),
        ],
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red,
              ),
              child: Icon(Icons.account_circle),
            ),
            ListTile(
              title: const Text('Item 4'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _paginas[_paginActual],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            _paginActual = index;
          });
        },
        currentIndex: _paginActual,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(
              icon: Icon(Icons.check_box), label: "Solicitud paquetes"),
          BottomNavigationBarItem(
              icon: Icon(Icons.info_outline), label: "Información")
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Packet(),
            ),
          );
        },
        backgroundColor: Colors.red,
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
