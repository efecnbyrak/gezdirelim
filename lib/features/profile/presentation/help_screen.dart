import 'package:flutter/material.dart';
import 'package:gezdirelim/core/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yardım'),
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
            // İletişim Kartı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.headphones,
                        color: AppColors.accent, size: 32),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Size nasıl yardımcı olabiliriz?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '7/24 size yardımcı olmaya hazırız.',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 24),

                  // Email — Clickable
                  InkWell(
                    onTap: () => _launchUrl('mailto:destek@example.com'),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        children: [
                          Icon(LucideIcons.mail,
                              color: AppColors.primary, size: 18),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'E-posta',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'destek@example.com',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(LucideIcons.externalLink,
                              color: AppColors.textMuted, size: 14),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Phone — Clickable
                  InkWell(
                    onTap: () => _launchUrl('tel:+905555555555'),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        children: [
                          Icon(LucideIcons.phone,
                              color: AppColors.success, size: 18),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Telefon',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '+90 555 555 55 55',
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(LucideIcons.externalLink,
                              color: AppColors.textMuted, size: 14),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // SSS Başlık
            const Text(
              'Sıkça Sorulan Sorular',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),

            // SSS Items
            _buildFaqItem(
              question: 'Nasıl rota oluşturabilirim?',
              answer:
                  'Ana sayfadaki pusula butonuna tıklayarak harita üzerinde rota oluşturabilirsiniz. '
                  'Haritada başlangıç ve bitiş noktalarınızı belirleyin, ara duraklar ekleyin ve '
                  'rotanızı kaydedin. Oluşturduğunuz rotalar "Rotalarım" sekmesinde görüntülenir.',
            ),
            const SizedBox(height: 10),
            _buildFaqItem(
              question: 'Favori rotalarımı nasıl görüntüleyebilirim?',
              answer:
                  'Alt menüdeki kalp ikonuna tıklayarak "Favorilerim" sekmesine geçebilirsiniz. '
                  'Beğendiğiniz rotaları kalp ikonuyla favorilere ekleyebilir, daha sonra '
                  'buradan kolayca erişebilirsiniz.',
            ),
            const SizedBox(height: 10),
            _buildFaqItem(
              question: 'Hesabımı nasıl silebilirim?',
              answer:
                  'Profil sayfasından "Ayarlar" ikonuna tıklayın. Ayarlar sayfasının en altında '
                  '"Hesabı Sil" seçeneğini bulabilirsiniz. Hesabınızı silmeden önce tüm verilerinizin '
                  'kalıcı olarak silineceğini unutmayın. Bu işlem geri alınamaz.',
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem({required String question, required String answer}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          childrenPadding:
              const EdgeInsets.only(left: 18, right: 18, bottom: 16),
          iconColor: AppColors.textMuted,
          collapsedIconColor: AppColors.textMuted,
          title: Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          children: [
            Text(
              answer,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
