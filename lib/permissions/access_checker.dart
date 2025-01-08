import 'package:flutter_dotenv/flutter_dotenv.dart';

//TODO: move and adjust logic to SettingsNotifier
bool isFeatureAvailable(env) {
  return dotenv.env[env]?.toLowerCase() == 'true';
}
