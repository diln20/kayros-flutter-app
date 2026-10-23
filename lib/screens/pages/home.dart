import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kayros/screens/pages/addpacket.dart';

const List<String> imageList = [
  'https://www.channelbiz.es/wp-content/uploads/2015/08/paquetes.jpg',
  'https://allstarservicecorp.com/wp-content/uploads/2020/07/a-enviosurgentes1-1024x597.jpg',
  'https://s3.amazonaws.com/businessinsider.mx/wp-content/uploads/2021/06/07130217/robo-de-identidad-paquetes.jpg',
  'https://blablanegocios.com/wp-content/uploads/sites/2/2016/11/EL-EMBALAJE-DE-LOS-PAQUETES-ES-IMPORTANTE-1.jpg',
  'https://thumbs.dreamstime.com/b/cami%C3%B3n-de-reparto-con-el-icono-del-paquete-ejemplo-transporte-art%C3%ADculo-env%C3%ADo-dise%C3%B1o-simple-s%C3%ADmbolo-vector-esquema-126378536.jpg',
  'https://www.neostuff.net/wp-content/uploads/2015/09/rastreo-de-envios-internacionales.jpg',
];

class Home extends StatefulWidget {
  const Home({super.key, required this.onSelectTab});
  final ValueChanged<int> onSelectTab;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final PageController pageController = PageController();
  Timer? autoplay;
  int page = 0;

  @override
  void initState() {
    super.initState();
    autoplay = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || !pageController.hasClients) return;
      final next = (page + 1) % imageList.length;
      pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    autoplay?.cancel();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actions = <({String title, IconData icon, VoidCallback onTap})>[
      (
        title: 'Solicitar paquete',
        icon: Icons.add_box_outlined,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const Packet()),
        ),
      ),
      (
        title: 'Mis paquetes',
        icon: Icons.inventory_2_outlined,
        onTap: () => widget.onSelectTab(1),
      ),
      (
        title: 'Información',
        icon: Icons.info_outline,
        onTap: () => widget.onSelectTab(2),
      ),
      (
        title: 'Ver solicitudes',
        icon: Icons.list_alt_outlined,
        onTap: () => widget.onSelectTab(1),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      children: [
        SizedBox(
          height: 230,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: PageView.builder(
              controller: pageController,
              itemCount: imageList.length,
              onPageChanged: (index) => setState(() => page = index),
              itemBuilder: (context, index) => Image.network(
                imageList[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const ColoredBox(
                  color: Color(0xFFFFE7E7),
                  child: Center(
                    child: Icon(Icons.local_shipping, size: 84, color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            imageList.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: page == index ? 16 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: page == index ? Colors.red : Colors.red.shade100,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Bienvenido a Kayros Express',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: actions.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.45,
          ),
          itemBuilder: (context, i) => Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: actions[i].onTap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(actions[i].icon, size: 36, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(actions[i].title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
