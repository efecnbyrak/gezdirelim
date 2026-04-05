import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:gezdirelim/core/app_colors.dart';
import 'package:gezdirelim/core/common_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gezdirelim/features/route/presentation/route_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AddRouteScreen extends ConsumerStatefulWidget {
  const AddRouteScreen({super.key});

  @override
  ConsumerState<AddRouteScreen> createState() => _AddRouteScreenState();
}

class _AddRouteScreenState extends ConsumerState<AddRouteScreen> with SingleTickerProviderStateMixin {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routeState = ref.watch(routeManagementProvider);
    final notifier = ref.read(routeManagementProvider.notifier);
    final selectedRoute = routeState.selectedRoute;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rotalarım'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() => _selectedTabIndex = 0);
              _showAddRouteDialog(context, notifier);
            },
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.plus, color: AppColors.primary, size: 20),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Özel ve Hazır Seçici (Pill Style)
            _buildPillTabSelector(),
            
            Expanded(
              child: IndexedStack(
                index: _selectedTabIndex,
                children: [
                  // 1. Sekme: Özel Rotalar (Senin Eklediklerin)
                  _buildPrivateRoutesTab(routeState, notifier, selectedRoute),
                  _buildPredefinedRoutesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivateRoutesTab(RouteManagementState state, RouteManagementNotifier notifier, RouteModel? selectedRoute) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    
    if (state.routes.isEmpty) {
      return _buildEmptyState(context, notifier);
    }

    return Column(
      children: [
        // Rota Seçici - Üst Kategori (Horizontal Chips)
        _buildRouteSelector(state, notifier),

        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Admin Map Editor
                SizedBox(
                  height: 300, // Increased height for better visibility
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: const LatLng(41.0082, 28.9784),
                      initialZoom: 12,
                      onLongPress: (tapPosition, point) => _showAddStopDialogAtPoint(context, selectedRoute?.id, point, notifier),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.gezdirelim.app',
                      ),
                      if (selectedRoute != null && selectedRoute.stops.length > 1)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: selectedRoute.stops
                                  .where((s) => s.latitude != 0)
                                  .map((s) => LatLng(s.latitude, s.longitude))
                                  .toList(),
                              color: AppColors.primary.withOpacity(0.7),
                              strokeWidth: 4,
                            ),
                          ],
                        ),
                      MarkerLayer(
                        markers: _buildMarkers(selectedRoute),
                      ),
                    ],
                  ),
                ),

                // Seçili Rotanın Detayları ve Duraklar
                if (selectedRoute != null)
                  _buildStopsList(selectedRoute, notifier)
                else
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text(
                        'Bir rota seçin',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPillTabSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: Row(
        children: [
          _buildPillTab(
            title: 'Özel',
            icon: LucideIcons.user,
            isSelected: _selectedTabIndex == 0,
            onTap: () => setState(() => _selectedTabIndex = 0),
          ),
          const SizedBox(width: 4),
          _buildPillTab(
            title: 'Hazır',
            icon: LucideIcons.layers,
            isSelected: _selectedTabIndex == 1,
            onTap: () => setState(() => _selectedTabIndex = 1),
          ),
        ],
      ),
    );
  }

  Widget _buildPillTab({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isSelected
                ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8)]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPredefinedRoutesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPredefinedRouteCard(
          title: 'Fatih Osmanlı Mimarisi Turu',
          stops: '8 Durak',
          duration: 'Ortalama 4-5 Saat',
          image: 'assets/images/Sultanahmet-Camii.jpg',
        ),
        const SizedBox(height: 16),
        _buildPredefinedRouteCard(
          title: 'Tarihi Yarımada Yürüyüş Rotosu',
          stops: '12 Durak',
          duration: 'Tüm Gün',
          image: 'assets/images/Sultanahmet-Camii.jpg', // Placeholder
        ),
        const SizedBox(height: 16),
        _buildPredefinedRouteCard(
          title: 'Boğaz Kıyısı Lezzet Durakları',
          stops: '5 Durak',
          duration: 'Ortalama 3 Saat',
          image: 'assets/images/restorant.jpg', // Placeholder
        ),
      ],
    );
  }

  Widget _buildPredefinedRouteCard({
    required String title,
    required String stops,
    required String duration,
    required String image,
  }) {
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(image, height: 140, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(LucideIcons.mapPin, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(stops, style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(width: 16),
                    const Icon(LucideIcons.clock, size: 16, color: AppColors.secondary),
                    const SizedBox(width: 4),
                    Text(duration, style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Hazır rota detayları yakında eklenecek')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Rotayı İncele'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, RouteManagementNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.mapPin, color: AppColors.primary, size: 48),
            ),
            const SizedBox(height: 24),
            const Text(
              'Henüz Rota Yok',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'İlk rotanızı oluşturarak seyahat planlamaya başlayın!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddRouteDialog(context, notifier),
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('İlk Rotanı Oluştur'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteSelector(RouteManagementState state, RouteManagementNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.surfaceBorder, width: 0.5)),
      ),
      child: SizedBox(
        height: 44,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: state.routes.length,
          itemBuilder: (context, index) {
            final route = state.routes[index];
            final isSelected = route.id == state.selectedRouteId;

            return GestureDetector(
              onTap: () => notifier.selectRoute(route.id!),
              onLongPress: () => _showRouteOptionsMenu(context, route, notifier),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.navigation,
                      size: 14,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      route.name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white.withOpacity(0.2) : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${route.stops.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStopsList(RouteModel route, RouteManagementNotifier notifier) {
    return Column(
      children: [
        // Rota başlık alanı
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${route.stops.length} Durak',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              // Favorilere Ekle / Sil Butonu (Yeri burası veya üst köşe olabilir)
              IconButton(
                onPressed: () {
                  // Favorilere ekleme mantığı
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('"${route.name}" favorilere eklendi')),
                  );
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.heart, size: 16, color: AppColors.error),
                ),
              ),
              const SizedBox(width: 4),
              // Rota silme butonu
              IconButton(
                onPressed: () => _confirmDeleteRoute(context, route, notifier),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.trash2, size: 16, color: AppColors.error),
                ),
              ),
            ],
          ),
        ),

        const Divider(color: AppColors.surfaceBorder, height: 1),

        // Durak listesi
        Expanded(
          child: route.stops.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.mapPin, size: 36, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      const Text(
                        'Bu rotada henüz durak yok',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: route.stops.length,
                  itemBuilder: (context, index) {
                    final stop = route.stops[index];
                    return Column(
                      children: [
                        _buildStopItem(index + 1, stop, notifier),
                        if (index < route.stops.length - 1)
                          _buildConnectorLine(),
                      ],
                    );
                  },
                ),
        ),

        // Durak ekleme butonu
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.background,
            border: Border(top: BorderSide(color: AppColors.surfaceBorder, width: 0.5)),
          ),
          child: SafeArea(
            child: ElevatedButton.icon(
              onPressed: () => _showAddStopDialog(context, route.id!, notifier),
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Durak Ekle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStopItem(int number, StopModel stop, RouteManagementNotifier notifier) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Numara dairesi
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Durak kartı
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.mapPin, size: 18, color: AppColors.secondary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stop.title,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      if (stop.category.isNotEmpty)
                        Text(
                          stop.category,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _confirmDeleteStop(context, stop, notifier),
                  icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.textMuted),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectorLine() {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      height: 24,
      width: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.5),
            AppColors.primary.withOpacity(0.1),
          ],
        ),
      ),
    );
  }

  List<Marker> _buildMarkers(RouteModel? route) {
    if (route == null) return [];
    return route.stops
        .asMap()
        .entries
        .where((entry) => entry.value.latitude != 0 && entry.value.longitude != 0)
        .map((entry) {
          final index = entry.key;
          final stop = entry.value;
          return Marker(
            point: LatLng(stop.latitude, stop.longitude),
            width: 45,
            height: 45,
            child: GestureDetector(
              onTap: () {
                // Focus on this stop in the list or show tooltip
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(stop.title), duration: const Duration(seconds: 1)),
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.location_on, color: AppColors.primary, size: 45),
                  Positioned(
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        })
        .toList();
  }

  void _showAddStopDialogAtPoint(BuildContext context, int? routeId, LatLng point, RouteManagementNotifier notifier) {
    if (routeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen önce bir rota seçin')),
      );
      return;
    }
    _showAddStopDialog(context, routeId, notifier, lat: point.latitude, lng: point.longitude);
  }

  // ============ DİALOGLAR ============

  void _showAddRouteDialog(BuildContext context, RouteManagementNotifier notifier) {
    final controller = TextEditingController();
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
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.navigation, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Yeni Rota', style: TextStyle(fontSize: 17)),
          ],
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Rota adı (örn: İstanbul Turu)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                notifier.addRoute(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Oluştur'),
          ),
        ],
      ),
    );
  }

  void _showAddStopDialog(BuildContext context, int routeId, RouteManagementNotifier notifier, {double? lat, double? lng}) {
    final titleController = TextEditingController();
    final categoryController = TextEditingController();
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
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.mapPin, color: AppColors.secondary, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Durak Ekle', style: TextStyle(fontSize: 17)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Mekan adı (örn: Kapalıçarşı)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: categoryController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Kategori (örn: Tarihi Mekan)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                notifier.addStop(
                  routeId,
                  titleController.text,
                  category: categoryController.text.isNotEmpty
                      ? categoryController.text
                      : 'Durak',
                  lat: lat ?? 0,
                  lng: lng ?? 0,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _showRouteOptionsMenu(BuildContext context, RouteModel route, RouteManagementNotifier notifier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.trash2, color: AppColors.error, size: 20),
                ),
                title: const Text('Rotayı Sil', style: TextStyle(color: AppColors.error)),
                subtitle: Text(
                  '${route.stops.length} durak da silinecek',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteRoute(context, route, notifier);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteRoute(BuildContext context, RouteModel route, RouteManagementNotifier notifier) async {
    final confirmed = await showDeleteConfirmDialog(
      context: context,
      title: 'Rotayı Sil',
      message: '"${route.name}" rotasını silmek istediğinize emin misiniz?\n\nBu rotadaki ${route.stops.length} durak da silinecektir.',
    );
    if (confirmed) {
      notifier.deleteRoute(route.id!);
    }
  }

  Future<void> _confirmDeleteStop(BuildContext context, StopModel stop, RouteManagementNotifier notifier) async {
    final confirmed = await showDeleteConfirmDialog(
      context: context,
      title: 'Durağı Sil',
      message: '"${stop.title}" durağını silmek istediğinize emin misiniz?',
    );
    if (confirmed) {
      notifier.deleteStop(stop.id!);
    }
  }

}
