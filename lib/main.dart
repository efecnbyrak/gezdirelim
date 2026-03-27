import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gezdirelim/core/app_theme.dart';
import 'package:gezdirelim/core/database_helper.dart';
import 'package:gezdirelim/features/navigation/presentation/main_navigation_screen.dart';
import 'package:gezdirelim/features/auth/presentation/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Status bar stilini ayarla
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  // Veritabanını başlat
  await DatabaseHelper().database;

  runApp(
    const ProviderScope(
      child: GezdirelimApp(),
    ),
  );
}

class GezdirelimApp extends StatelessWidget {
  const GezdirelimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gezdirelim',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainNavigationScreen(),
      },
      home: const LoginScreen(),
    );
  }
}
