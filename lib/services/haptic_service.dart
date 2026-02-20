import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

class HapticService {
  static void light(WidgetRef ref) {
    final enabled = ref.read(settingsProvider).hapticFeedbackEnabled;
    if (enabled) {
      HapticFeedback.lightImpact();
    }
  }

  static void selection(WidgetRef ref) {
    final enabled = ref.read(settingsProvider).hapticFeedbackEnabled;
    if (enabled) {
      HapticFeedback.selectionClick();
    }
  }

  static void success(WidgetRef ref) {
    final enabled = ref.read(settingsProvider).hapticFeedbackEnabled;
    if (enabled) {
      HapticFeedback.vibrate();
    }
  }
}
