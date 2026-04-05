import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gezdirelim/core/app_colors.dart';
import 'package:gezdirelim/features/auth/presentation/login_screen.dart';
import 'package:gezdirelim/features/navigation/presentation/main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Lock orientation to portrait over splash
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // Initial Fade In (0.0 to 1.0)
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn), // Rapid fade
      ),
    );

    // Smooth Scale Up (0.85 to 1.0)
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack), // Slight bounce snap
      ),
    );
    
    // Core Glow Intensity Pulse
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOutSine), // Smooth breath effect
      ),
    );

    _controller.forward();

    // Navigate out upon theoretical completion
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      
      final session = Supabase.instance.client.auth.currentSession;
      final targetRoute = session != null ? '/home' : '/login';

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) => targetRoute == '/home' 
              ? const MainNavigationScreen() 
              : const LoginScreen(),
          settings: RouteSettings(name: targetRoute),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35 * _glowAnimation.value),
                        blurRadius: 40 + (20 * _glowAnimation.value), // Expansive glow
                        spreadRadius: 8 * _glowAnimation.value,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/icons/logo.png',
                    width: 160,
                    height: 160,
                    // Note: if the logo intrinsically has background corners, 
                    // wrapping it in a ClipRRect might be necessary depending on the PNG transparency.
                    // Assuming high-fidelity transparent PNG here.
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
