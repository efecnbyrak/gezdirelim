import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gezdirelim/features/admin/presentation/admin_provider.dart';
import 'package:gezdirelim/features/admin/presentation/admin_login_screen.dart';

/// Admin Guard Widget
/// Admin sayfalarını sararak, giriş yapılmamışsa login ekranına yönlendirir.
/// Kullanım: AdminGuard(child: AdminDashboardScreen())
class AdminGuard extends ConsumerWidget {
  final Widget child;

  const AdminGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(adminProvider).isAuthenticated;

    if (!isAuthenticated) {
      // Giriş yapılmamış → login'e redirect
      return const AdminLoginScreen();
    }

    return child;
  }
}
