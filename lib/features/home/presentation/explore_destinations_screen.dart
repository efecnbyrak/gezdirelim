import 'package:flutter/material.dart';
import 'package:gezdirelim/core/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ExploreDestinationsScreen extends StatefulWidget {
  const ExploreDestinationsScreen({super.key});

  @override
  State<ExploreDestinationsScreen> createState() => _ExploreDestinationsScreenState();
}

class _ExploreDestinationsScreenState extends State<ExploreDestinationsScreen> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['Tümü', 'Tarihi', 'Doğa', 'Müze', 'Yemek'];
  
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Keşfet'),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Arama Çubuğu
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Nereye gitmek istersin?',
                prefixIcon: const Icon(LucideIcons.search, color: AppColors.textSecondary),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.ciniMavisi.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(LucideIcons.slidersHorizontal, color: AppColors.ciniMavisi, size: 18),
                ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          // Kategori Seçici
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedCategoryIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategoryIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.ciniMavisi : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.ciniMavisi : AppColors.surfaceBorder,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _categories[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // Sonuç Grid'i
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.75,
              children: const [
                DestinationGridCard(
                  title: 'Sultanahmet Camii',
                  location: 'İstanbul',
                  imagePath: 'assets/images/Sultanahmet-Camii.jpg',
                  rating: 4.9,
                ),
                DestinationGridCard(
                  title: 'Gezgin Mutfağı',
                  location: 'Ankara',
                  imagePath: 'assets/images/restorant.jpg',
                  rating: 4.7,
                ),
                DestinationGridCard(
                  title: 'Gece Hayatı',
                  location: 'İzmir',
                  imagePath: 'assets/images/amsterdam-gece-kulubu.jpg',
                  rating: 4.5,
                ),
                // Placeholders for visual population
                DestinationGridCard(
                  title: 'Galata Kulesi',
                  location: 'İstanbul',
                  imagePath: 'assets/images/Sultanahmet-Camii.jpg',
                  rating: 4.8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DestinationGridCard extends StatelessWidget {
  final String title;
  final String location;
  final String imagePath;
  final double rating;

  const DestinationGridCard({
    super.key,
    required this.title,
    required this.location,
    required this.imagePath,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(rating.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(LucideIcons.mapPin, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
