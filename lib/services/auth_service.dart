import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.1.108:3000';

  static Future<bool> login(String email, String password, String role) async {
    final endpointMap = {
      'student': '/loginStudent',
      'admin': '/loginAdmin',
      'instructor': '/loginInstructor',
    };

    final endpoint = endpointMap[role];
    if (endpoint == null) {
      print("❌ Invalid role: $role");
      return false;
    }

    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print("🔁 STATUS: ${response.statusCode}");
      print("🔁 BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final user = data['user'];
        final userType = data['userType'];

        if (user != null && userType != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('role', userType);
          await prefs.setString('userId', user['id'].toString());
          await prefs.setString('userName', user['name'] ?? '');
          await prefs.setString('userEmail', user['email'] ?? '');
          return true;
        }
      } else {
        print("❌ Login failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception during login: $e");
    }

    return false;
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('role') && prefs.containsKey('userId');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
