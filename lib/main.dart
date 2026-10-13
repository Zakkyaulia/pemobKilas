import 'package:flutter/material.dart';

import 'screens/splash/splash_screen.dart';
import 'theme/app_theme.dart';
import 'theme/app_theme_controller.dart';
import 'theme/home_colors.dart';

void main() {
  runApp(const KilasApp());
}

/// Root widget for the KILAS application.
///
/// Configures [MaterialApp] with the centralized [AppTheme]
/// and sets [SplashScreen] as the initial animated entry point.
class KilasApp extends StatelessWidget {
  const KilasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeController.themeMode,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'KILAS',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: AppTheme.light.copyWith(
            extensions: <ThemeExtension<dynamic>>[StatusColors.light],
          ),
          darkTheme: AppTheme.dark.copyWith(
            extensions: <ThemeExtension<dynamic>>[StatusColors.light],
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
