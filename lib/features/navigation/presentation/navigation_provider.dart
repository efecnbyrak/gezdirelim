import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod provider for controlling the bottom navigation tab index.
/// Used by ProfileScreen to programmatically switch to "Rotalarım" tab.
final navigationIndexProvider = StateProvider<int>((ref) => 0);
