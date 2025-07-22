import 'package:shared_preferences/shared_preferences.dart';

const String _ACCESS_TOKEN = 'access_token';

class LocalDatasource {
  SharedPreferences? prefs;

  LocalDatasource({
    SharedPreferences? sharedPreferences,
  }) {
    prefs = sharedPreferences;
  }

  Future<void> setAccessToken(String value) async {
    await prefs!.setString(_ACCESS_TOKEN, value);
  }

  Future<String?> getAccessToken() async {
    return prefs!.getString(_ACCESS_TOKEN);
  }

  void clearAccessToken() {
    prefs!.remove(_ACCESS_TOKEN);
  }
}