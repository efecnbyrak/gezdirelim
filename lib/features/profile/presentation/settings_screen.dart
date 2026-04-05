import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gezdirelim/core/app_colors.dart';
import 'package:gezdirelim/features/profile/presentation/profile_provider.dart';
import 'package:gezdirelim/features/profile/presentation/policy_screen.dart';
import 'package:gezdirelim/features/profile/presentation/help_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Genel Bölüm
            _buildSectionTitle('Genel'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: LucideIcons.moon,
                iconColor: AppColors.accent,
                title: 'Karanlık Mod',
                subtitle: 'Koyu tema kullan',
                value: profile.isDarkMode,
                onChanged: (_) => notifier.toggleDarkMode(),
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: LucideIcons.bell,
                iconColor: AppColors.secondary,
                title: 'Bildirimler',
                subtitle: 'Bildirim almayı yönet',
                value: profile.notificationsEnabled,
                onChanged: (_) => notifier.toggleNotifications(),
              ),
              _buildDivider(),
              _buildNavTile(
                icon: LucideIcons.globe,
                iconColor: AppColors.primary,
                title: 'Dil',
                trailing: profile.language,
                onTap: () => _showLanguageDialog(context, notifier, profile.language),
              ),
            ]),

            const SizedBox(height: 28),

            // Hesap Bölüm
            _buildSectionTitle('Hesap'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildNavTile(
                icon: LucideIcons.shield,
                iconColor: AppColors.success,
                title: 'Gizlilik Politikası',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PolicyScreen(
                      title: 'Gizlilik Politikası',
                      content: 'Gezdirelim olarak gizliliğinize önem veriyoruz. '
                          'Verileriniz sadece size en iyi deneyimi sunmak için kullanılır '
                          've asla üçüncü şahıslarla paylaşılmaz. '
                          '\n\n1. Toplanan Veriler: İsim, e-posta ve konum bilgileriniz '
                          'hesabınızı özelleştirmek ve rotalar oluşturmak için toplanır.'
                          '\n\n2. Veri Güvenliği: Tüm verileriniz Supabase altyapısı ile '
                          'en üst düzey güvenlik standartlarında saklanır.',
                    ),
                  ),
                ),
              ),
              _buildDivider(),
              _buildNavTile(
                icon: LucideIcons.helpCircle,
                iconColor: AppColors.primary,
                title: 'Yardım & Destek',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpScreen()),
                ),
              ),
              _buildDivider(),
              _buildNavTile(
                icon: LucideIcons.fileText,
                iconColor: AppColors.textSecondary,
                title: 'Kullanım Koşulları',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PolicyScreen(
                      title: 'Kullanım Koşulları',
                      content: 'Gezdirelim uygulamasını kullanarak aşağıdaki koşulları '
                          'kabul etmiş sayılırsınız: '
                          '\n\n1. Hesap Güvenliği: Hesabınızın güvenliğinden siz sorumlusunuz.'
                          '\n\n2. İçerik Paylaşımı: Oluşturduğunuz rotalarda telif hakkı '
                          'ihlali yapılmamalıdır.'
                          '\n\n3. Sorumluluk Reddi: Rotalarda oluşabilecek yol durumu '
                          'değişikliklerinden Gezdirelim sorumlu tutulamaz.',
                    ),
                  ),
                ),
              ),
              _buildDivider(),
              _buildNavTile(
                icon: LucideIcons.shieldCheck,
                iconColor: AppColors.error,
                title: 'Admin Paneli',
                onTap: () => Navigator.pushNamed(context, '/admin'),
              ),
            ]),

            const SizedBox(height: 28),

            // Tehlike Bölüm
            _buildSectionTitle('Tehlikeli Bölge'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildNavTile(
                icon: LucideIcons.trash2,
                iconColor: AppColors.error,
                title: 'Hesabı Sil',
                titleColor: AppColors.error,
                onTap: () => _showDeleteAccountDialog(context),
              ),
            ]),

            const SizedBox(height: 32),

            // Versiyon bilgisi
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(LucideIcons.map, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Gezdirelim',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Versiyon 1.0.0',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 56,
      color: AppColors.surfaceBorder,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                Text(subtitle, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    Color? titleColor,
    String? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: titleColor ?? AppColors.textPrimary,
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            const SizedBox(width: 8),
            Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: titleColor ?? AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, ProfileNotifier notifier, String current) {
    final languages = ['Türkçe', 'English'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Dil Seçin', style: TextStyle(fontSize: 17)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            final isSelected = lang == current;
            return ListTile(
              title: Text(
                lang,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              trailing: isSelected
                  ? const Icon(LucideIcons.check, color: AppColors.primary, size: 20)
                  : null,
              onTap: () {
                notifier.setLanguage(lang);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.warning_rounded, color: AppColors.error, size: 22),
            ),
            const SizedBox(width: 12),
            const Text('Hesabı Sil', style: TextStyle(fontSize: 17)),
          ],
        ),
        content: const Text(
          'Hesabınızı silmek istediğinize emin misiniz?\n\nBu işlem geri alınamaz ve tüm verileriniz kalıcı olarak silinecektir.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Hesap silme işlemi başlatıldı...')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hesabı Sil'),
          ),
        ],
      ),
    );
  }
}
