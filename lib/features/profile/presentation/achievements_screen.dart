import 'package:flutter/material.dart';
import 'package:gezdirelim/core/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Başarılar'),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _achievements.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final a = _achievements[index];
          return _AchievementCard(
            icon: a.icon,
            title: a.title,
            description: a.description,
            progress: a.progress,
            isUnlocked: a.isUnlocked,
            color: a.color,
          );
        },
      ),
    );
  }
}

class _AchievementData {
  final IconData icon;
  final String title;
  final String description;
  final double progress; // 0.0 - 1.0
  final bool isUnlocked;
  final Color color;

  const _AchievementData({
    required this.icon,
    required this.title,
    required this.description,
    required this.progress,
    required this.isUnlocked,
    required this.color,
  });
}

const List<_AchievementData> _achievements = [
  _AchievementData(
    icon: LucideIcons.footprints,
    title: 'İlk Adım',
    description: 'İlk rotanı başarıyla tamamladın!',
    progress: 1.0,
    isUnlocked: true,
    color: AppColors.success,
  ),
  _AchievementData(
    icon: LucideIcons.map,
    title: '10 Rota Ustası',
    description: '10 farklı rota tamamla.',
    progress: 0.8,
    isUnlocked: false,
    color: AppColors.primary,
  ),
  _AchievementData(
    icon: LucideIcons.target,
    title: '5.000 KM Kulübü',
    description: 'Toplam 5.000 KM mesafe kat et.',
    progress: 0.65,
    isUnlocked: false,
    color: AppColors.secondary,
  ),
  _AchievementData(
    icon: LucideIcons.medal,
    title: '100 KM Tek Sürüş',
    description: 'Tek bir sürüşte 100 KM tamamla.',
    progress: 0.42,
    isUnlocked: false,
    color: AppColors.accent,
  ),
  _AchievementData(
    icon: LucideIcons.compass,
    title: 'Kaşif',
    description: '5 farklı şehirde rota tamamla.',
    progress: 0.2,
    isUnlocked: false,
    color: AppColors.info,
  ),
];

class _AchievementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final double progress;
  final bool isUnlocked;
  final Color color;

  const _AchievementCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.progress,
    required this.isUnlocked,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor = isUnlocked ? color : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isUnlocked
              ? color.withOpacity(0.3)
              : AppColors.surfaceBorder,
          width: isUnlocked ? 1.5 : 0.5,
        ),
      ),
      child: Row(
        children: [
          // Icon Badge
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: displayColor.withOpacity(isUnlocked ? 0.15 : 0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, color: displayColor, size: 24),
                if (!isUnlocked)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Icon(
                      LucideIcons.lock,
                      size: 12,
                      color: AppColors.textMuted.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isUnlocked
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                    if (isUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Kazanıldı',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          color: displayColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: isUnlocked
                        ? AppColors.textSecondary
                        : AppColors.textMuted.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: AppColors.surfaceBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(displayColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
