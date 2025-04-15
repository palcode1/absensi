import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:absensi/API/login_model.dart';
import 'package:absensi/API/regist_model.dart';
import 'package:absensi/API/endpoint.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // LOGIN
  static Future<Login?> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json'},
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        return loginFromJson(response.body); // parsing pakai model
      } else {
        print("Login gagal: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error saat login: $e");
      return null;
    }
  }

  // REGISTER
  static Future<Register?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json'},
        body: {'name': name, 'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return registerFromJson(response.body); // pakai model register
      } else {
        print("Gagal register: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error saat register: $e");
      return null;
    }
  }

  // LOGOUT
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Hapus token dari penyimpanan
    print("Token berhasil dihapus, user logout.");
  }
}
