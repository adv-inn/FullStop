import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/services/track_dispatcher.dart';

const String _scheduleTypeKey = 'schedule_type'; // 'traditional' or 'smart'
const String _dispatchModeKey = 'dispatch_mode';

/// Schedule type preference
enum ScheduleType { traditional, smart }

/// State for schedule preferences
class SchedulePreferences {
  final ScheduleType scheduleType;
  final DispatchMode dispatchMode;

  const SchedulePreferences({
    this.scheduleType = ScheduleType.traditional,
    this.dispatchMode = DispatchMode.balanced,
  });

  SchedulePreferences copyWith({
    ScheduleType? scheduleType,
    DispatchMode? dispatchMode,
  }) {
    return SchedulePreferences(
      scheduleType: scheduleType ?? this.scheduleType,
      dispatchMode: dispatchMode ?? this.dispatchMode,
    );
  }
}

/// Notifier for managing schedule preferences
class SchedulePreferencesNotifier extends StateNotifier<SchedulePreferences> {
  SchedulePreferencesNotifier() : super(const SchedulePreferences()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load schedule type
      final savedType = prefs.getString(_scheduleTypeKey);
      final scheduleType = savedType == 'smart'
          ? ScheduleType.smart
          : ScheduleType.traditional;

      // Load dispatch mode
      final savedMode = prefs.getString(_dispatchModeKey);
      final dispatchMode = _parseDispatchMode(savedMode);

      state = SchedulePreferences(
        scheduleType: scheduleType,
        dispatchMode: dispatchMode,
      );
    } catch (e) {
      // Ignore errors, use defaults
    }
  }

  DispatchMode _parseDispatchMode(String? value) {
    switch (value) {
      case 'hitsOnly':
        return DispatchMode.hitsOnly;
      case 'balanced':
        return DispatchMode.balanced;
      case 'deepDive':
        return DispatchMode.deepDive;
      case 'unfiltered':
        return DispatchMode.unfiltered;
      default:
        return DispatchMode.balanced;
    }
  }

  String _dispatchModeToString(DispatchMode mode) {
    switch (mode) {
      case DispatchMode.hitsOnly:
        return 'hitsOnly';
      case DispatchMode.balanced:
        return 'balanced';
      case DispatchMode.deepDive:
        return 'deepDive';
      case DispatchMode.unfiltered:
        return 'unfiltered';
    }
  }

  Future<void> setScheduleType(ScheduleType type) async {
    state = state.copyWith(scheduleType: type);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _scheduleTypeKey,
        type == ScheduleType.smart ? 'smart' : 'traditional',
      );
    } catch (e) {
      // Ignore save errors
    }
  }

  Future<void> setDispatchMode(DispatchMode mode) async {
    state = state.copyWith(dispatchMode: mode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_dispatchModeKey, _dispatchModeToString(mode));
    } catch (e) {
      // Ignore save errors
    }
  }
}

/// Provider for schedule preferences
final schedulePreferencesProvider =
    StateNotifierProvider<SchedulePreferencesNotifier, SchedulePreferences>((
      ref,
    ) {
      return SchedulePreferencesNotifier();
    });
