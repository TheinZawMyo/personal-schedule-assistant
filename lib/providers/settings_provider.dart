import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/settings_model.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsModel>(
  (ref) {
    return SettingsNotifier();
  },
);

class SettingsNotifier extends StateNotifier<SettingsModel> {
  SettingsNotifier() : super(SettingsModel()) {
    _loadSettings();
  }

  late Box<SettingsModel> _box;

  Future<void> _loadSettings() async {
    try {
      _box = await Hive.openBox<SettingsModel>('settings');
      if (_box.isEmpty) {
        await _box.put(0, SettingsModel());
        state = _box.get(0)!;
      } else {
        state = _box.get(0) ?? SettingsModel();
      }
    } catch (e) {
      // If there's a serialization error (e.g. added new fields), reset settings
      await Hive.deleteBoxFromDisk('settings');
      _box = await Hive.openBox<SettingsModel>('settings');
      await _box.put(0, SettingsModel());
      state = _box.get(0)!;
    }
  }

  Future<void> updateSettings(SettingsModel settings) async {
    await _box.put(0, settings);
    state = settings;
  }
}
