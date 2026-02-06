import 'package:flutter/material.dart';

class LimitedLandsApp extends StatelessWidget {
  const LimitedLandsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Limited Lands',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Limited Lands'),
        ),
      ),
    );
  }
}
