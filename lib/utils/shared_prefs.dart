import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceService {
  static late SharedPreferences _prefsInstance;

  static Future<SharedPreferences> init() async {
    _prefsInstance = await SharedPreferences.getInstance();
    return _prefsInstance;
  }

  bool checkKey(String key) => _prefsInstance.containsKey(key);

  Future putString(String key, String value) =>
      _prefsInstance.setString(key, value);

  Future putInt(String key, int value) => _prefsInstance.setInt(key, value);

  Future putDouble(String key, double value) =>
      _prefsInstance.setDouble(key, value);

  Future putBool(String key, bool value) => _prefsInstance.setBool(key, value);

  String getString(String key) => _prefsInstance.getString(key) ?? '';

  int getInt(String key) => _prefsInstance.getInt(key) ?? 0;

  double getDouble(String key) => _prefsInstance.getDouble(key) ?? 0.0;

  bool getBool(String key) => _prefsInstance.getBool(key) ?? false;
}
