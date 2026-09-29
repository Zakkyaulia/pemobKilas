import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/not_found_screen.dart';
import '../screens/profile_screen.dart';
import '../models/laporan.dart';
import '../screens/detail_screen.dart';
import '../screens/catatan_form_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String home = '/home'; // Kita arahkan home ke profile
  static const String detail = '/detail';
  static const String catatanForm = '/catatan-form';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute<void>(
          builder: (_) => const ProfileScreen(), // Sementara Profil menjadi laman utama
          settings: settings,
        );
      case detail:
        final args = settings.arguments;
        if (args is Laporan) {
          return MaterialPageRoute<void>(
            builder: (_) => DetailScreen(item: args),
            settings: settings,
          );
        }
        return null;
      case catatanForm:
        return MaterialPageRoute<String>(
          builder: (_) => const CatatanFormScreen(),
          settings: settings,
        );
      default:
        return null; // Route tidak terdaftar
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => NotFoundScreen(routeName: settings.name),
      settings: settings,
    );
  }
}
