import 'package:flutter/material.dart';

class AlgorithmsPage extends StatelessWidget {
  const AlgorithmsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Algorithms'),
        backgroundColor: Colors.transparent,
      ),
      body: const Center(
        child: Text(
          'Algorithms',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
