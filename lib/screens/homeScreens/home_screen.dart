import 'package:flutter/material.dart';
import 'package:kayros/screens/pages/addpacket.dart';
import 'package:kayros/screens/pages/drivers.dart';
import 'package:kayros/screens/pages/home.dart';
import 'package:kayros/screens/pages/paquetes.dart';
import 'package:kayros/screens/services/authentication_services/auth_services.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPage = 0;

  void changePage(int index) {
    setState(() => currentPage = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      Home(onSelectTab: changePage),
      const Paquetes(),
      const Drivers(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayros Express'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthServices>().logout(),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.red),
                child: Center(
                  child: Icon(Icons.local_shipping,
                      size: 78, color: Colors.white),
                ),
              ),
              for (var i = 0; i < pages.length; i++)
                ListTile(
                  leading: Icon(
                    [Icons.home_outlined, Icons.inventory_2_outlined,
                      Icons.info_outline][i],
                  ),
                  title: Text(['Inicio', 'Solicitudes de paquetes',
                    'Información'][i]),
                  selected: currentPage == i,
                  onTap: () {
                    Navigator.pop(context);
                    changePage(i);
                  },
                ),
            ],
          ),
        ),
      ),
      body: pages[currentPage],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        onTap: changePage,
        selectedItemColor: Colors.red,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined), label: 'Paquetes'),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline), label: 'Información'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Agregar paquete',
        onPressed: () {
          Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const Packet()),
          );
        },
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
