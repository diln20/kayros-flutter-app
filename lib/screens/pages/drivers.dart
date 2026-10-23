import 'package:flutter/material.dart';

class Drivers extends StatelessWidget {
  const Drivers({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.engineering_outlined, color: Colors.red, size: 70),
            SizedBox(height: 16),
            Text('En construcción',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
