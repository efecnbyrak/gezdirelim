import 'package:flutter/material.dart';
import 'package:gezdirelim/core/app_colors.dart';
import 'package:gezdirelim/core/common_widgets.dart';
import 'package:gezdirelim/features/home/presentation/explore_destinations_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Stack(
              children: [
                Container(
                  height: 360,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/Sultanahmet-Camii.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.heroGradient,
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.ciniMavisi.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(LucideIcons.map, color: AppColors.ciniMavisi, size: 22),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Gezdirelim',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _showNotifications(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: const Icon(LucideIcons.bell, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Türkiye\'yi Keşfet',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'En iyi rotalar, lezzetler ve deneyimler burada.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => _navigateToExplore(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.search, color: AppColors.textMuted, size: 18),
                              const SizedBox(width: 12),
                              const Text(
                                'Nereye gitmek istersin?',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.ciniMavisi.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(LucideIcons.sliders, color: AppColors.ciniMavisi, size: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Kategoriler
            const Padding(
              padding: EdgeInsets.only(left: 20, top: 24, bottom: 14),
              child: Text(
                'Kategoriler',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 20),
                children: [
                  CategoryCard(title: 'Gezilecek', icon: LucideIcons.mapPin, color: AppColors.ciniMavisi, onTap: () => _navigateToExplore(context)),
                  CategoryCard(title: 'Yemek', icon: LucideIcons.utensils, color: AppColors.osmanliAltini, onTap: () => _navigateToExplore(context)),
                  CategoryCard(title: 'Konaklama', icon: LucideIcons.hotel, color: AppColors.eflatun, onTap: () => _navigateToExplore(context)),
                  CategoryCard(title: 'Eğlence', icon: LucideIcons.music, color: AppColors.mercanKirmizi, onTap: () => _navigateToExplore(context)),
                  CategoryCard(title: 'Doğa', icon: LucideIcons.trees, color: AppColors.zumrutYesili, onTap: () => _navigateToExplore(context)),
                ],
              ),
            ),

            // Popüler Destinasyonlar
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 28, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Popüler Destinasyonlar',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () => _navigateToExplore(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.ciniMavisi.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Hepsini Gör',
                        style: TextStyle(color: AppColors.ciniMavisi, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 300,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 20),
                children: const [
                  DestinationCard(
                    title: 'Sultanahmet Camii',
                    location: 'İstanbul, Türkiye',
                    imagePath: 'assets/images/Sultanahmet-Camii.jpg',
                    rating: 4.9,
                  ),
                  DestinationCard(
                    title: 'Gezgin Mutfağı',
                    location: 'Ankara, Türkiye',
                    imagePath: 'assets/images/restorant.jpg',
                    rating: 4.7,
                  ),
                  DestinationCard(
                    title: 'Gece Hayatı',
                    location: 'İzmir, Türkiye',
                    imagePath: 'assets/images/amsterdam-gece-kulubu.jpg',
                    rating: 4.5,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // Responsive padding for bottom nav bar
          ],
        ),
      ),
    );
  }

  void _navigateToExplore(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ExploreDestinationsScreen()),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Bildirimler', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildNotificationItem('Yeni Rota Eklendi!', 'Fatih Osmanlı Mimarisi turu yayınlandı.', LucideIcons.mapPin, AppColors.ciniMavisi),
                const SizedBox(height: 12),
                _buildNotificationItem('Kampanya', 'Hafta sonu İstanbul turlarında %20 indirim.', LucideIcons.tag, AppColors.mercanKirmizi),
                const SizedBox(height: 12),
                _buildNotificationItem('Sistem Mesajı', 'Gezdirelim\'e hoş geldiniz! Keşfe çıkın.', LucideIcons.bell, AppColors.osmanliAltini),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(String title, String desc, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
