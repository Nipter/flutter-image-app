import 'package:flutter_riverpod/flutter_riverpod.dart';

//TODO: change type of Map<dynamic, dynamic> to typed correspondence from settings
class SettingsNotifier extends StateNotifier<Map<dynamic, dynamic>> {
  SettingsNotifier() : super({});

  Future<void> loadSettings() async {
    //TODO: add logic to load settings from Remote Config (.env)
  }
}

//TODO: change type of Map<dynamic, dynamic> to typed correspondence from settings
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, Map<dynamic, dynamic>>((ref) {
  return SettingsNotifier();
});
