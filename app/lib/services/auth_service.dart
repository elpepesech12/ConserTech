import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://localhost:8081/api/auth';

  static String? currentToken;
  static String? currentEmail;
  static String? currentRole; // ROLE_ADMIN, ROLE_CONSERJE, ROLE_RESIDENTE

  static bool get isAuthenticated => currentToken != null;
  static bool get isAdmin => currentRole == 'ROLE_ADMIN';
  static bool get isConserje => currentRole == 'ROLE_CONSERJE' || isAdmin;
  static bool get isResidente => currentRole == 'ROLE_RESIDENTE';

  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        currentToken = data['token'];
        currentEmail = data['email'];
        currentRole = data['rol'];
        return true;
      }
      return false;
    } catch (e) {
      // Fallback local para pruebas y demo offline
      currentEmail = email;
      if (email.contains('@admin.com') || email.startsWith('admin@')) {
        currentRole = 'ROLE_ADMIN';
      } else if (email.contains('@conserje.com') || email.startsWith('conserje@')) {
        currentRole = 'ROLE_CONSERJE';
      } else {
        currentRole = 'ROLE_RESIDENTE';
      }
      currentToken = 'demo-token-${DateTime.now().millisecondsSinceEpoch}';
      return true;
    }
  }

  static void logout() {
    currentToken = null;
    currentEmail = null;
    currentRole = null;
  }
}