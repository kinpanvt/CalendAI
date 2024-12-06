import 'package:flutter/material.dart';

class AIPage extends StatelessWidget {
  const AIPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 100),
            SizedBox(height: 30),
            Text('This page is currently under construction...', style: TextStyle(fontSize: 18),),
          ],
        ),
      ),
    );
  }
}