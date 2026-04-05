import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gezdirelim/core/app_colors.dart';
import 'package:gezdirelim/core/common_widgets.dart';
import 'package:gezdirelim/features/favorites/presentation/favorites_provider.dart';
import 'package:gezdirelim/features/home/presentation/explore_destinations_screen.dart';
import 'package:gezdirelim/features/home/presentation/destination_detail_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Destination data model for home screen
class DestinationData {
  final String title;
  final String location;
  final String imagePath;
  final double rating;
  final String category;

  const DestinationData({
    required this.title,
    required this.location,
    required this.imagePath,
    required this.rating,
    required this.category,
  });
}

/// Tüm destinasyonlar
const List<DestinationData> _allDestinations = [
  DestinationData(
    title: 'Sultanahmet Camii',
    location: 'İstanbul, Türkiye',
    imagePath: 'assets/images/Sultanahmet-Camii.jpg',
    rating: 4.9,
    category: 'Gezilecek',
  ),
  DestinationData(
    title: 'Gezgin Mutfağı',
    location: 'Ankara, Türkiye',
    imagePath: 'assets/images/restorant.jpg',
    rating: 4.7,
    category: 'Yemek',
  ),
  DestinationData(
    title: 'Gece Hayatı',
    location: 'İzmir, Türkiye',
    imagePath: 'assets/images/amsterdam-gece-kulubu.jpg',
    rating: 4.5,
    category: 'Eğlence',
  ),
];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  String _selectedCategory = 'Tümü';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Search animation
  bool _isSearchActive = false;
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _searchAnimController;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;

  // Search debounce
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    _searchAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _contentFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _searchAnimController, curve: Curves.easeOut),
    );

    _contentSlideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-0.05, 0.0))
            .animate(
      CurvedAnimation(
          parent: _searchAnimController, curve: Curves.easeOutCubic),
    );

    _searchFocusNode.addListener(_onSearchFocusChange);
  }

  void _onSearchFocusChange() {
    if (_searchFocusNode.hasFocus && !_isSearchActive) {
      setState(() => _isSearchActive = true);
      _searchAnimController.forward();
    }
  }

  void _deactivateSearch() {
    _searchFocusNode.unfocus();
    _searchAnimController.reverse().then((_) {
      if (mounted) {
        setState(() => _isSearchActive = false);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    _searchAnimController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _searchQuery = value);
      }
    });
  }

  List<DestinationData> get _filteredDestinations {
    return _allDestinations.where((d) {
      final categoryMatch =
          _selectedCategory == 'Tümü' || d.category == _selectedCategory;
      final searchMatch = _searchQuery.isEmpty ||
          d.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.location.toLowerCase().contains(_searchQuery.toLowerCase());
      return categoryMatch && searchMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return PopScope(
      canPop: !_isSearchActive,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isSearchActive) {
          _deactivateSearch();
        }
      },
      child: Scaffold(
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
                        image:
                            AssetImage('assets/images/Sultanahmet-Camii.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.heroGradient,
                      ),
                    ),
                  ),
                  // Top bar (logo + notification)
                  Positioned(
                    top: 50,
                    left: 20,
                    right: 20,
                    child: AnimatedBuilder(
                      animation: _contentFadeAnimation,
                      builder: (context, child) {
                        return SlideTransition(
                          position: _contentSlideAnimation,
                          child: Opacity(
                            opacity: _contentFadeAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Image.asset(
                                  'assets/images/icons/logo.png',
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.contain,
                                ),
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
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.1)),
                              ),
                              child: const Icon(LucideIcons.bell,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Title + Search bar
                  Positioned(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title area — fades out during search
                        AnimatedBuilder(
                          animation: _contentFadeAnimation,
                          builder: (context, child) {
                            return SlideTransition(
                              position: _contentSlideAnimation,
                              child: Opacity(
                                opacity: _contentFadeAnimation.value,
                                child: child,
                              ),
                            );
                          },
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
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Search bar — enhanced with focus animation
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: _isSearchActive
                                ? AppColors.surface.withOpacity(0.95)
                                : AppColors.surface.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _isSearchActive
                                  ? AppColors.primary.withOpacity(0.5)
                                  : AppColors.surfaceBorder,
                              width: _isSearchActive ? 1.5 : 1.0,
                            ),
                            boxShadow: _isSearchActive
                                ? [
                                    BoxShadow(
                                      color:
                                          AppColors.primary.withOpacity(0.15),
                                      blurRadius: 16,
                                      spreadRadius: 2,
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocusNode,
                                  onChanged: _onSearchChanged,
                                  style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14),
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(LucideIcons.search,
                                        color: AppColors.textMuted, size: 18),
                                    hintText: 'Nereye gitmek istersin?',
                                    hintStyle: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 14),
                                    border: InputBorder.none,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            vertical: 14),
                                    suffixIcon: _isSearchActive
                                        ? IconButton(
                                            icon: const Icon(LucideIcons.x,
                                                size: 16,
                                                color: AppColors.textMuted),
                                            onPressed: () {
                                              _searchController.clear();
                                              setState(
                                                  () => _searchQuery = '');
                                              _deactivateSearch();
                                            },
                                          )
                                        : Container(
                                            margin: const EdgeInsets.all(6),
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: AppColors.ciniMavisi
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                                LucideIcons.sliders,
                                                color: AppColors.ciniMavisi,
                                                size: 14),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Kategoriler — animated hide during search
              AnimatedBuilder(
                animation: _contentFadeAnimation,
                builder: (context, child) {
                  return SlideTransition(
                    position: _contentSlideAnimation,
                    child: Opacity(
                      opacity: _contentFadeAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.only(left: 20, top: 24, bottom: 14),
                      child: Text(
                        'Kategoriler',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 110,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 20),
                        children: [
                          _buildCategoryCard('Gezilecek',
                              LucideIcons.mapPin, AppColors.ciniMavisi),
                          _buildCategoryCard('Yemek',
                              LucideIcons.utensils, AppColors.osmanliAltini),
                          _buildCategoryCard('Konaklama',
                              LucideIcons.hotel, AppColors.eflatun),
                          _buildCategoryCard('Eğlence',
                              LucideIcons.music, AppColors.mercanKirmizi),
                          _buildCategoryCard('Doğa', LucideIcons.trees,
                              AppColors.zumrutYesili),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Popüler Destinasyonlar header
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 28, bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        _selectedCategory == 'Tümü'
                            ? 'Popüler Destinasyonlar'
                            : _selectedCategory,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _navigateToExplore(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.ciniMavisi.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Hepsini Gör',
                          style: TextStyle(
                              color: AppColors.ciniMavisi,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Filtered destination cards — OVERFLOW FIX
              if (_filteredDestinations.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(LucideIcons.searchX,
                            size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 16),
                        const Text(
                          'Bu kategoride destinasyon bulunamadı',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SizedBox(
                  // OVERFLOW FIX: Card is 180 (image) + 20+6+16+16+20 (padding+gaps) + text ~= 310
                  height: 320,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 20, right: 4),
                    itemCount: _filteredDestinations.length,
                    itemBuilder: (context, index) {
                      final dest = _filteredDestinations[index];
                      final isFav = ref.watch(favoritesProvider).isFavorite(dest.title);
                      return DestinationCard(
                        title: dest.title,
                        location: dest.location,
                        imagePath: dest.imagePath,
                        rating: dest.rating,
                        category: dest.category,
                        isFavorite: isFav,
                        onFavoriteTap: () {
                          ref.read(favoritesProvider.notifier).toggleFavorite(
                                destinationId: dest.title,
                                type: 'place',
                                title: dest.title,
                                subtitle: dest.location,
                                imagePath: dest.imagePath,
                                rating: dest.rating,
                              );
                        },
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration:
                                  const Duration(milliseconds: 400),
                              reverseTransitionDuration:
                                  const Duration(milliseconds: 350),
                              pageBuilder: (_, __, ___) =>
                                  DestinationDetailScreen(
                                title: dest.title,
                                location: dest.location,
                                imagePath: dest.imagePath,
                                rating: dest.rating,
                                category: dest.category,
                              ),
                              transitionsBuilder:
                                  (_, animation, __, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

              // Bottom safe padding
              SizedBox(height: bottomPadding + 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, Color color) {
    final isActive = _selectedCategory == title;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory =
              _selectedCategory == title ? 'Tümü' : title;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? color : AppColors.surfaceBorder,
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(isActive ? 0.25 : 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                color: isActive ? color : AppColors.textSecondary,
              ),
            ),
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
            padding:
                const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Bildirimler',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildNotificationItem(
                    'Yeni Rota Eklendi!',
                    'Fatih Osmanlı Mimarisi turu yayınlandı.',
                    LucideIcons.mapPin,
                    AppColors.ciniMavisi),
                const SizedBox(height: 12),
                _buildNotificationItem(
                    'Kampanya',
                    'Hafta sonu İstanbul turlarında %20 indirim.',
                    LucideIcons.tag,
                    AppColors.mercanKirmizi),
                const SizedBox(height: 12),
                _buildNotificationItem(
                    'Sistem Mesajı',
                    'Gezdirelim\'e hoş geldiniz! Keşfe çıkın.',
                    LucideIcons.bell,
                    AppColors.osmanliAltini),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(
      String title, String desc, IconData icon, Color color) {
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
            decoration: BoxDecoration(
                color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(desc,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
