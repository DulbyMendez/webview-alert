import 'package:flutter/material.dart';
import 'package:test_web/widget/custom_webview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Visor Web',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 81, 2, 142),
        ),
        useMaterial3: true,
      ),
      home: const WebViewPage(),
    );
  }
}
