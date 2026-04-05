import 'package:flutter/material.dart';
import 'package:gezdirelim/core/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İstatistikler'),
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
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: LucideIcons.navigation,
                    label: 'Toplam KM',
                    value: '1.240',
                    unit: 'KM',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: LucideIcons.clock,
                    label: 'Toplam Süre',
                    value: '86',
                    unit: 'Saat',
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: LucideIcons.gauge,
                    label: 'Ort. Hız',
                    value: '18',
                    unit: 'km/h',
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: LucideIcons.map,
                    label: 'Tamamlanan',
                    value: '8',
                    unit: 'Rota',
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Bar Chart Section
            const Text(
              'Son 6 Ay — KM Dağılımı',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _BarChartSection(
              data: _monthlyData,
            ),
          ],
        ),
      ),
    );
  }
}

// Static dummy data — ready to be replaced by API
const List<_MonthData> _monthlyData = [
  _MonthData('Kas', 120),
  _MonthData('Ara', 200),
  _MonthData('Oca', 180),
  _MonthData('Şub', 310),
  _MonthData('Mar', 250),
  _MonthData('Nis', 180),
];

class _MonthData {
  final String label;
  final double value;
  const _MonthData(this.label, this.value);
}

// ─────────────────────────────────────────────────
// Stat Card Widget
// ─────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Bar Chart Section (responsive with LayoutBuilder)
// ─────────────────────────────────────────────────
class _BarChartSection extends StatelessWidget {
  final List<_MonthData> data;

  const _BarChartSection({required this.data});

  @override
  Widget build(BuildContext context) {
    // Edge case: no data
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    final maxVal = data.fold<double>(
        0, (prev, e) => e.value > prev ? e.value : prev);

    // Edge case: all values are 0
    if (maxVal <= 0) {
      return _buildEmptyState();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final chartHeight = 160.0;
          // Protection against zero width
          final safeWidth = constraints.maxWidth > 0 ? constraints.maxWidth : 1.0;
          final barWidth = (safeWidth - 40) / data.length - 12;
          final clampedBarWidth = barWidth.clamp(14.0, 50.0);

          return Column(
            children: [
              SizedBox(
                height: chartHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: data.map((d) {
                    final ratio = d.value / maxVal;
                    final barHeight =
                        (chartHeight - 30) * ratio; // leave room for value

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${d.value.toInt()}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          width: clampedBarWidth,
                          height: barHeight.clamp(4.0, chartHeight - 30),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.5),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: data.map((d) {
                  return SizedBox(
                    width: clampedBarWidth + 12,
                    child: Text(
                      d.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 50),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.barChart2,
                color: AppColors.success, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'Henüz veri yok',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Rota tamamladıkça istatistiklerin burada görünecek.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
