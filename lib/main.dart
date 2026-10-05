import 'package:flutter/material.dart';

import 'screens/home/home_screen.dart';
import 'theme/app_theme.dart';
import 'theme/home_colors.dart';

void main() {
  runApp(const KilasApp());
}

/// Root widget for the KILAS application.
///
/// Configures [MaterialApp] with the centralized [AppTheme]
/// and sets [LoginScreen] as the initial route.
class KilasApp extends StatelessWidget {
  const KilasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KILAS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light.copyWith(
        extensions: <ThemeExtension<dynamic>>[StatusColors.light],
      ),
      home: const HomeScreen(),
    );
  }
}
