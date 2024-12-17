import 'package:flutter/material.dart';
import 'screens/home.dart';

void main() {
  runApp(const WatermarkRemoverApp());
}

class WatermarkRemoverApp extends StatelessWidget {
  const WatermarkRemoverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
