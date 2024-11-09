import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  // Guarda el userId en SharedPreferences
  Future<void> setUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
  }

  // Obtiene el userId de SharedPreferences
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }
}