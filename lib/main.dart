import 'package:flutter/material.dart';

import 'screens/auth/login_screen.dart';
import 'theme/app_theme.dart';

import 'routes/app_routes.dart';

void main() {
  runApp(const KilasApp());
}

/// Root widget for the KILAS application.
class KilasApp extends StatelessWidget {
  const KilasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KILAS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      onUnknownRoute: AppRoutes.onUnknownRoute,
    );
  }
}
