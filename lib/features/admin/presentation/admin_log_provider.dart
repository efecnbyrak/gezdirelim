import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Kullanıcı log modeli
class UserLog {
  final String id;
  final String action; // 'login', 'favorite', 'search', 'category', 'destination'
  final String detail;
  final String timestamp;

  UserLog({
    required this.id,
    required this.action,
    required this.detail,
    required this.timestamp,
  });
}

/// Log State
class LogState {
  final List<UserLog> logs;

  LogState({this.logs = const []});

  LogState copyWith({List<UserLog>? logs}) {
    return LogState(logs: logs ?? this.logs);
  }
}

/// Log Notifier — Single Responsibility
class AdminLogNotifier extends StateNotifier<LogState> {
  AdminLogNotifier() : super(LogState());

  void addLog(String action, String detail) {
    final log = UserLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      action: action,
      detail: detail,
      timestamp: DateTime.now().toIso8601String(),
    );
    state = state.copyWith(
      logs: [log, ...state.logs],
    );
  }

  void clearLogs() {
    state = state.copyWith(logs: []);
  }
}

final adminLogProvider =
    StateNotifierProvider<AdminLogNotifier, LogState>((ref) {
  return AdminLogNotifier();
});
