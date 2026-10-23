import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kayros/screens/pages/addpacket.dart';
import 'package:kayros/theme/app_theme.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.onSelectTab});
  final ValueChanged<int> onSelectTab;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final PageController _controller = PageController();
  Timer? _autoPlay;
  int _currentSlide = 0;

  static const _slides = <({
    String eyebrow,
    String title,
    String detail,
    IconData icon,
    Color background,
  })>[
    (
      eyebrow: 'ENVÍOS MÁS SENCILLOS',
      title: 'Tus paquetes, a un toque',
      detail: 'Organiza tus solicitudes de envío desde Kayros Express.',
      icon: Icons.local_shipping_outlined,
      background: Color(0xFFC92B37),
    ),
    (
      eyebrow: 'TODO EN UN LUGAR',
      title: 'Consulta tus solicitudes',
      detail: 'Revisa los datos y el historial de paquetes que registraste.',
      icon: Icons.inventory_2_outlined,
      background: Color(0xFF853B65),
    ),
    (
      eyebrow: 'CREA UNA SOLICITUD',
      title: 'Registra un nuevo paquete',
      detail: 'Agrega los datos del destinatario, producto y domicilio.',
      icon: Icons.add_box_outlined,
      background: Color(0xFF285E74),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _autoPlay = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (!mounted || !_controller.hasClients) return;
      _controller.animateToPage(
        (_currentSlide + 1) % _slides.length,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoPlay?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _newPackage() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const Packet()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actions =
        <({String title, String detail, IconData icon, VoidCallback onTap})>[
      (
        title: 'Solicitar paquete',
        detail: 'Crear una solicitud',
        icon: Icons.add_box_outlined,
        onTap: _newPackage,
      ),
      (
        title: 'Mis paquetes',
        detail: 'Consultar registros',
        icon: Icons.inventory_2_outlined,
        onTap: () => widget.onSelectTab(1),
      ),
      (
        title: 'Información',
        detail: 'Conoce el servicio',
        icon: Icons.info_outline,
        onTap: () => widget.onSelectTab(2),
      ),
      (
        title: 'Ver solicitudes',
        detail: 'Administrar envíos',
        icon: Icons.list_alt_outlined,
        onTap: () => widget.onSelectTab(1),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 860
            ? 4
            : width >= 580
                ? 3
                : 2;
        return ListView(
          padding: EdgeInsets.symmetric(
            horizontal: width >= 720 ? 32 : 16,
            vertical: 20,
          ),
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hola, bienvenido',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                              color: AppPalette.ink,
                              fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  const Text('¿Qué necesitas hacer hoy?',
                      style: TextStyle(color: AppPalette.muted)),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 226,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: _slides.length,
                        onPageChanged: (index) =>
                            setState(() => _currentSlide = index),
                        itemBuilder: (context, i) {
                          final slide = _slides[i];
                          return DecoratedBox(
                            decoration: BoxDecoration(color: slide.background),
                            child: Padding(
                              padding: const EdgeInsets.all(23),
                              child: Stack(
                                children: [
                                  Positioned(
                                    right: -14,
                                    bottom: -8,
                                    child: Icon(slide.icon,
                                        size: width < 360 ? 90 : 140,
                                        color: Colors.white
                                            .withValues(alpha: 0.17)),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 550),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(slide.eyebrow,
                                              style: TextStyle(
                                                  letterSpacing: 1,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white
                                                      .withValues(
                                                          alpha: 0.84))),
                                          const SizedBox(height: 12),
                                          Text(slide.title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 25,
                                                height: 1.15,
                                                fontWeight: FontWeight.w800,
                                              )),
                                          const SizedBox(height: 9),
                                          Text(slide.detail,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  height: 1.4)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentSlide == index ? 23 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentSlide == index
                              ? AppPalette.primary
                              : const Color(0xFFD5DCE8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Accesos rápidos',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppPalette.ink, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  const Text('Gestiona tus envíos en pocos pasos.',
                      style: TextStyle(color: AppPalette.muted)),
                  const SizedBox(height: 14),
                  GridView.builder(
                    itemCount: actions.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisExtent: 150,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, i) {
                      final action = actions[i];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: action.onTap,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(action.icon,
                                    color: AppPalette.primary, size: 30),
                                const SizedBox(height: 10),
                                Text(action.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 3),
                                Text(action.detail,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: AppPalette.muted, fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
