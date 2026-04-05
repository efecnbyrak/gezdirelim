import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Destination modeli (admin CRUD)
class DestinationModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final String category;
  final String imagePath;
  final double rating;
  final String history;
  final String createdAt;

  DestinationModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.location,
    this.category = '',
    this.imagePath = '',
    this.rating = 0,
    this.history = '',
    required this.createdAt,
  });

  DestinationModel copyWith({
    String? title,
    String? description,
    String? location,
    String? category,
    String? imagePath,
    double? rating,
    String? history,
  }) {
    return DestinationModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      rating: rating ?? this.rating,
      history: history ?? this.history,
      createdAt: createdAt,
    );
  }
}

/// Destination State
class DestinationState {
  final List<DestinationModel> destinations;

  DestinationState({this.destinations = const []});

  DestinationState copyWith({List<DestinationModel>? destinations}) {
    return DestinationState(
        destinations: destinations ?? this.destinations);
  }
}

/// Destination Notifier — Single Responsibility
class AdminRouteNotifier extends StateNotifier<DestinationState> {
  AdminRouteNotifier() : super(DestinationState()) {
    _initDefaults();
  }

  void _initDefaults() {
    state = state.copyWith(
      destinations: [
        DestinationModel(
          id: '1',
          title: 'Sultanahmet Camii',
          description: 'İstanbul\'un en ikonik yapılarından biri.',
          location: 'İstanbul, Türkiye',
          category: 'Gezilecek',
          imagePath: 'assets/images/Sultanahmet-Camii.jpg',
          rating: 4.9,
          history: '1609-1616 yılları arasında inşa edilmiştir.',
          createdAt: DateTime.now().toIso8601String(),
        ),
        DestinationModel(
          id: '2',
          title: 'Gezgin Mutfağı',
          description: 'Anadolu\'nun eşsiz lezzetleri.',
          location: 'Ankara, Türkiye',
          category: 'Yemek',
          imagePath: 'assets/images/restorant.jpg',
          rating: 4.7,
          history: '2018 yılında kurulmuştur.',
          createdAt: DateTime.now().toIso8601String(),
        ),
        DestinationModel(
          id: '3',
          title: 'Gece Hayatı',
          description: 'İzmir\'in canlı gece hayatı.',
          location: 'İzmir, Türkiye',
          category: 'Eğlence',
          imagePath: 'assets/images/amsterdam-gece-kulubu.jpg',
          rating: 4.5,
          history: 'Kozmopolit eğlence kültürü.',
          createdAt: DateTime.now().toIso8601String(),
        ),
      ],
    );
  }

  void addDestination(DestinationModel dest) {
    state = state.copyWith(
      destinations: [...state.destinations, dest],
    );
  }

  void updateDestination(String id, DestinationModel updated) {
    state = state.copyWith(
      destinations: state.destinations.map((d) {
        return d.id == id ? updated : d;
      }).toList(),
    );
  }

  void removeDestination(String id) {
    state = state.copyWith(
      destinations: state.destinations.where((d) => d.id != id).toList(),
    );
  }
}

final adminRouteProvider =
    StateNotifierProvider<AdminRouteNotifier, DestinationState>((ref) {
  return AdminRouteNotifier();
});
