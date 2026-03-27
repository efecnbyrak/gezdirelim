import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gezdirelim/core/app_colors.dart';
import 'package:gezdirelim/features/profile/presentation/profile_provider.dart';
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
                iconColor: AppColors.eflatun,
                title: 'Karanlık Mod',
                subtitle: 'Koyu tema kullan',
                value: profile.isDarkMode,
                onChanged: (_) => notifier.toggleDarkMode(),
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: LucideIcons.bell,
                iconColor: AppColors.osmanliAltini,
                title: 'Bildirimler',
                subtitle: 'Bildirim almayı yönet',
                value: profile.notificationsEnabled,
                onChanged: (_) => notifier.toggleNotifications(),
              ),
              _buildDivider(),
              _buildNavTile(
                icon: LucideIcons.globe,
                iconColor: AppColors.ciniMavisi,
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
                iconColor: AppColors.zumrutYesili,
                title: 'Gizlilik',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gizlilik ayarları yakında...')),
                  );
                },
              ),
              _buildDivider(),
              _buildNavTile(
                icon: LucideIcons.helpCircle,
                iconColor: AppColors.ciniMavisi,
                title: 'Yardım & Destek',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Destek ekranı yakında...')),
                  );
                },
              ),
              _buildDivider(),
              _buildNavTile(
                icon: LucideIcons.fileText,
                iconColor: AppColors.textSecondary,
                title: 'Kullanım Koşulları',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kullanım koşulları yakında...')),
                  );
                },
              ),
            ]),

            const SizedBox(height: 28),

            // Tehlike Bölüm
            _buildSectionTitle('Tehlikeli Bölge'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildNavTile(
                icon: LucideIcons.trash2,
                iconColor: AppColors.mercanKirmizi,
                title: 'Hesabı Sil',
                titleColor: AppColors.mercanKirmizi,
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
                      color: AppColors.ciniMavisi.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(LucideIcons.map, color: AppColors.ciniMavisi, size: 24),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Gezdirelim',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Versiyon 1.0.0',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
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
                Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.ciniMavisi,
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
              color: titleColor ?? AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, ProfileNotifier notifier, String current) {
    final languages = ['Türkçe', 'English', 'Deutsch', 'Français'];
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
                  color: isSelected ? AppColors.ciniMavisi : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              trailing: isSelected
                  ? const Icon(LucideIcons.check, color: AppColors.ciniMavisi, size: 20)
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
                color: AppColors.mercanKirmizi.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.warning_rounded, color: AppColors.mercanKirmizi, size: 22),
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
              backgroundColor: AppColors.mercanKirmizi,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hesabı Sil'),
          ),
        ],
      ),
    );
  }
}
