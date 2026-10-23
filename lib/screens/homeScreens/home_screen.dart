import 'package:flutter/material.dart';
import 'package:kayros/screens/pages/addpacket.dart';
import 'package:kayros/screens/pages/drivers.dart';
import 'package:kayros/screens/pages/home.dart';
import 'package:kayros/screens/pages/paquetes.dart';
import 'package:kayros/screens/services/authentication_services/auth_services.dart';
import 'package:kayros/theme/app_theme.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPage = 0;

  void changePage(int index) => setState(() => currentPage = index);

  Future<void> _newPackage() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const Packet()),
    );
    if (!mounted || created != true) return;
    changePage(1);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paquete guardado correctamente.')),
    );
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Quieres salir de tu cuenta de Kayros?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (shouldLogout == true && mounted) {
      await context.read<AuthServices>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      Home(onSelectTab: changePage),
      const Paquetes(),
      const Drivers(),
    ];
    const titles = ['Inicio', 'Mis paquetes', 'Información'];
    const icons = [
      Icons.home_outlined,
      Icons.inventory_2_outlined,
      Icons.info_outline,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_shipping, color: AppPalette.primary),
            const SizedBox(width: 10),
            Text(currentPage == 0 ? 'Kayros Express' : titles[currentPage]),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_outlined),
            onPressed: _confirmLogout,
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: AppPalette.primary),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.local_shipping, size: 56, color: Colors.white),
                    SizedBox(height: 10),
                    Text('Kayros Express',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              for (var i = 0; i < pages.length; i++)
                ListTile(
                  leading: Icon(icons[i]),
                  title: Text(titles[i]),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPage,
        onDestinationSelected: changePage,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined), label: 'Inicio'),
          NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined), label: 'Paquetes'),
          NavigationDestination(
              icon: Icon(Icons.info_outline), label: 'Información'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Agregar paquete',
        onPressed: _newPackage,
        backgroundColor: AppPalette.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
