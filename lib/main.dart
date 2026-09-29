import 'package:flutter/material.dart';

import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const KilasApp());
}

/// Root widget for the KILAS application.
///
/// Configures [MaterialApp] with the centralized [AppTheme]
/// and sets named routes via [AppRoutes].
class KilasApp extends StatelessWidget {
  const KilasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KILAS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Named routes dari AppRoutes (Langkah 6)
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      onUnknownRoute: AppRoutes.onUnknownRoute,
    );
  }
}
