import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.56.1:3000'; // Update if needed

  static Future<bool> login(String email, String password, String role) async {
    final endpointMap = {
      'student': '/loginStudent',
      'admin': '/loginAdmin',
      'instructor': '/loginInstructor',
    };

    final endpoint = endpointMap[role];
    final url = Uri.parse('$baseUrl$endpoint');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json', // 🟢 THIS IS CRUCIAL
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('role', data['userType']);
      await prefs.setString('userId', data['user']['id'].toString());
      await prefs.setString('userName', data['user']['name']);
      await prefs.setString('userEmail', data['user']['email']);
      return true;
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
