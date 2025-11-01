import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _accessTokenKey = 'token';
  static const String _userTypeKey = 'userType';

  static const String _userIdKey = 'userId';
  static const String _userEmail = 'userEmail';
// Save access token
  static Future<void> saveAccessToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
    await prefs.setBool('isLogin', true);
  }

  // Retrieve access token
  static Future<String?> getAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }
  /*// Save access token
  static Future<void> saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
    await prefs.setBool('isLogin', true);
  }*/
// Save user ID
  static Future<void> saveUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, id);
  }
// Retrieve user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }
// Save user email
  static Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmail, email);
  }
  // Retrieve user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmail);
  }

  // Clear access token
  static Future<void> clearAllData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey); // Clear the token
    await prefs.remove(_userTypeKey); // Clear the role
    await prefs.remove('isLogin'); // Clear the login status
  }

  static Future<String?> getPickerLocationUuid() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('pickerLocationUuid');
  }

  // Clear access token
  static Future<void> clearAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove('isLogin');
  }

  static Future<bool?> checkLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isLogin") ?? false;
  }

  // Save user type
  static Future<void> saveUserType(String userType) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userTypeKey, userType);
  }

  // Retrieve user type
  static Future<String?> getUserType() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userTypeKey);
  }
}
