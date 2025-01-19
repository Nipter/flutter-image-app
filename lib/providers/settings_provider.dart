import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsNotifier extends StateNotifier<Map<String, RemoteConfigValue>> {
  SettingsNotifier() : super({});

  Future<void> loadSettings() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await remoteConfig.fetchAndActivate();

    state.addAll(remoteConfig.getAll());
  }

  Map<String, RemoteConfigValue> get settings {
    return state;
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, Map<String, RemoteConfigValue>>((ref) {
  return SettingsNotifier();
});
