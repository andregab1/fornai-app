import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../features/collection/presentation/home_screen.dart';

class FornaiApp extends StatelessWidget {
  const FornaiApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Fornai Checklist',
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    home: const HomeScreen(),
  );
}
