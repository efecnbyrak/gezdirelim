import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gezdirelim/core/app_colors.dart';
import 'package:gezdirelim/features/route/presentation/route_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MapRoutePlannerScreen extends ConsumerStatefulWidget {
  const MapRoutePlannerScreen({super.key});

  @override
  ConsumerState<MapRoutePlannerScreen> createState() => _MapRoutePlannerScreenState();
}

class _MapRoutePlannerScreenState extends ConsumerState<MapRoutePlannerScreen> {
  GoogleMapController? _mapController;
  final LatLng _initialPosition = const LatLng(41.0082, 28.9784); // Istanbul

  // Route modes: 0 = Özel Rota (Custom), 1 = Hazır Rotalar (Pre-defined)
  int _selectedModeIndex = 0;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routeState = ref.watch(routeManagementProvider);
    final selectedRoute = routeState.selectedRoute;

    // Build markers from the selected route's stops
    Set<Marker> markers = {};
    if (selectedRoute != null) {
      for (var stop in selectedRoute.stops) {
        if (stop.latitude != 0 && stop.longitude != 0) {
          markers.add(
            Marker(
              markerId: MarkerId(stop.id?.toString() ?? stop.hashCode.toString()),
              position: LatLng(stop.latitude, stop.longitude),
              infoWindow: InfoWindow(title: stop.title, snippet: stop.category),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            ),
          );
        }
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 13,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onTap: (latLng) {
              if (_selectedModeIndex == 0) {
                // If in "Özel Rota" mode, tapping map could prompt to add a stop.
                _onMapTapped(latLng);
              }
            },
          ),
          
          // Bottom Panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomPanel(routeState),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(RouteManagementState routeState) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Segmented Control for Route Modes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildModeTab(0, 'Özel Rota', LucideIcons.mapPin),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildModeTab(1, 'Hazır Rotalar', LucideIcons.navigation),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.surfaceBorder),
            // Panel Content
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _selectedModeIndex == 0
                  ? _buildCustomRouteView(routeState)
                  : _buildPredefinedRoutesView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTab(int index, String title, IconData icon) {
    final isSelected = _selectedModeIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedModeIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomRouteView(RouteManagementState routeState) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kendi Rotanızı Oluşturun',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Yeni bir rota başlatmak veya mevcut duraklara yenilerini eklemek için haritaya dokunun.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          if (routeState.selectedRoute != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.navigation, color: AppColors.primary),
              ),
              title: Text(routeState.selectedRoute!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${routeState.selectedRoute!.stops.length} Durak'),
              trailing: const Icon(LucideIcons.chevronRight, size: 20),
            )
          else
            ElevatedButton.icon(
              onPressed: _createNewRoute,
              icon: const Icon(LucideIcons.plus),
              label: const Text('Yeni Özel Rota Başlat'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPredefinedRoutesView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Önerilen Tur Rotaları',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildPredefinedRouteCard(
            title: 'Fatih Osmanlı Mimarisi Turu',
            subtitle: '8 Durak • Ortalama 4-5 Saat',
            icon: LucideIcons.landmark,
            onTap: () {
              // Add preset points or load preset route logic here.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fatih Osmanlı Mimarisi Turu Yakında!')),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildPredefinedRouteCard(
            title: 'Tarihi Yarımada Yürüyüş Rotosu',
            subtitle: '12 Durak • Tüm Gün',
            icon: LucideIcons.footprints,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tarihi Yarımada Rotası Yakında!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPredefinedRouteCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.surfaceBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.secondary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  void _onMapTapped(LatLng latLng) {
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Konum seçildi: ${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}')),
    );
    // TODO: Create a new stop dynamically here with ref.read(routeManagementProvider.notifier)
  }

  void _createNewRoute() {
    final notifier = ref.read(routeManagementProvider.notifier);
    notifier.addRoute('Yeni Harita Rotası');
  }
}
