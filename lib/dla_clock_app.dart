import 'package:dla_clock/home_page.dart';
import 'package:flutter/material.dart';

class DlaClockApp extends StatelessWidget {
  const DlaClockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DLA Clock',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
