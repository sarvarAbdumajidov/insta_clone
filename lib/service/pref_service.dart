import 'package:shared_preferences/shared_preferences.dart';

class PrefService {
  static Future<bool> saveFCM(String fcm_token) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString('fcm_token', fcm_token);
  }

  static Future<String> loadFCM() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('fcm_token');
    return token!;
  }
}
