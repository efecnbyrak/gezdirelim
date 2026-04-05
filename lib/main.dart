import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gezdirelim/core/supabase_config.dart';
import 'package:gezdirelim/core/app_theme.dart';
import 'package:gezdirelim/core/database_helper.dart';
import 'package:gezdirelim/features/navigation/presentation/main_navigation_screen.dart';
import 'package:gezdirelim/features/auth/presentation/login_screen.dart';
import 'package:gezdirelim/features/splash/presentation/splash_screen.dart';
import 'package:gezdirelim/features/admin/presentation/admin_login_screen.dart';
import 'package:gezdirelim/features/profile/presentation/profile_provider.dart';

void main() {
  // Global Error Handler for synchronous Flutter errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
    // Here you could send to crashlytics/sentry
  };

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Status bar stilini ayarla
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      );

      // Initialize asynchronously to unblock first frame
      _initApp();

      runApp(const ProviderScope(child: GezdirelimApp()));
    },
    (error, stackTrace) {
      debugPrint('Zoned Guarded Error: $error');
      debugPrint('StackTrace: $stackTrace');
      // Here you could send to crashlytics/sentry
    },
  );
}

class GlobalErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;
  const GlobalErrorWidget({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.redAccent,
                  size: 64,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Bir Şeyler Yanlış Gitti',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Uygulama beklenmedik bir hata ile karşılaştı. Lütfen tekrar deneyin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // In production, maybe restart app or go home
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _initApp() async {
  try {
    // Initialize Dotenv
    await dotenv.load(fileName: ".env");
    
    // Initialize Supabase
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
    // Veritabanını başlat
    await DatabaseHelper().database;
  } catch (e) {
    debugPrint('Startup init error: $e');
  }
}

class GezdirelimApp extends ConsumerWidget {
  const GezdirelimApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return MaterialApp(
      title: 'Gezdirelim',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: profile.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      // Localization setup
      locale: profile.language == 'English'
          ? const Locale('en', 'US')
          : const Locale('tr', 'TR'),
      supportedLocales: const [Locale('tr', 'TR'), Locale('en', 'US')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainNavigationScreen(),
        '/admin': (context) => const AdminLoginScreen(),
      },
      home: const SplashScreen(),
    );
  }
}
