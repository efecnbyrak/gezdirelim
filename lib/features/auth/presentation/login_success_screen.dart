import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gezdirelim/core/app_colors.dart';
import 'package:gezdirelim/core/permission_service.dart';
import 'package:gezdirelim/features/navigation/presentation/main_navigation_screen.dart';

/// Login sonrası animasyonlu başarı ekranı
/// ✔ ikonu + fade/scale animasyonu + auto-navigate
class LoginSuccessScreen extends StatefulWidget {
  const LoginSuccessScreen({super.key});

  @override
  State<LoginSuccessScreen> createState() => _LoginSuccessScreenState();
}

class _LoginSuccessScreenState extends State<LoginSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _textController;
  late AnimationController _pulseController;

  late Animation<double> _checkScale;
  late Animation<double> _checkOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();

    // Check icon animation
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: Curves.elasticOut,
      ),
    );

    _checkOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Text animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeIn,
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Pulse glow animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    // Step 1: Show check icon
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _checkController.forward();

    // Step 2: Show text
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _textController.forward();

    // Step 3: Pulse glow
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _pulseController.repeat(reverse: true);

    // Step 4: Navigate after 1.5s
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const _PermissionWrapper(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _checkController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated check icon with glow
            AnimatedBuilder(
              animation: Listenable.merge([_checkController, _pulseController]),
              builder: (context, child) {
                return Opacity(
                  opacity: _checkOpacity.value,
                  child: Transform.scale(
                    scale: _checkScale.value * (_pulseController.isAnimating ? _pulseScale.value : 1.0),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withOpacity(
                              0.4 * _checkOpacity.value,
                            ),
                            blurRadius: 30 + (10 * (_pulseController.isAnimating ? _pulseScale.value : 1.0)),
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 52,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Animated text
            SlideTransition(
              position: _textSlide,
              child: FadeTransition(
                opacity: _textOpacity,
                child: Column(
                  children: [
                    const Text(
                      'Başarıyla Giriş Yapıldı',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hoş geldiniz! Yönlendiriliyorsunuz...',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wrapper that shows MainNavigationScreen and triggers permission dialogs
class _PermissionWrapper extends StatefulWidget {
  const _PermissionWrapper();

  @override
  State<_PermissionWrapper> createState() => _PermissionWrapperState();
}

class _PermissionWrapperState extends State<_PermissionWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissions();
    });
  }

  Future<void> _requestPermissions() async {
    final service = PermissionService();
    
    // Step 1: Location
    await service.requestPermission(
      context,
      permission: Permission.location,
      icon: Icons.location_on_rounded,
      color: const Color(0xFF10B981),
      title: 'Konum İzni',
      message: 'Size yakın rotaları ve en güzel durakları gösterebilmemiz için konum erişimine ihtiyacımız var.',
    );

    if (!mounted) return;

    // Step 2: Notifications
    await service.requestPermission(
      context,
      permission: Permission.notification,
      icon: Icons.notifications_rounded,
      color: const Color(0xFF3B82F6),
      title: 'Bildirim İzni',
      message: 'Yeni rotalar, popüler mekanlar ve güncellemelerden anında haberdar olmak için bildirimleri açabilirsiniz.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return const MainNavigationScreen();
  }
}
