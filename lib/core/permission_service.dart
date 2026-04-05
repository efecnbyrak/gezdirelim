import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Permission Service — İzin yönetim sistemi (Production-Grade)
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Belirli bir iznin durumunu kontrol et
  Future<PermissionStatus> getStatus(Permission permission) async {
    return await permission.status;
  }

  /// İlk açılışta veya ihtiyaç anında izin iste
  Future<void> requestPermission(
    BuildContext context, {
    required Permission permission,
    required IconData icon,
    required Color color,
    required String title,
    required String message,
  }) async {
    final status = await permission.status;

    if (status.isGranted) return;

    if (!context.mounted) return;

    // Custom UI Göster
    final bool? proceed = await _showPermissionDialog(
      context,
      icon: icon,
      color: color,
      title: title,
      message: message,
    );

    if (proceed == true) {
      if (status.isPermanentlyDenied) {
        // Sistem ayarlarına yönlendir
        await openAppSettings();
      } else {
        // Normal sistem dialog'unu tetikle
        await permission.request();
      }
    }
  }

  Future<bool?> _showPermissionDialog(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String message,
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF8FAFC),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Ayarları Aç / İzin Ver',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Şimdi Değil',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
