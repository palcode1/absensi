import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:absensi/API/login_model.dart';
import 'package:absensi/API/regist_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://absen.quidi.id/api';

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
  static Future<bool> logout() async {
    final url = Uri.parse('$baseUrl/logout');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print("Token tidak ditemukan. Sudah logout.");
        return true;
      }

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Hapus token dari SharedPreferences.
        await prefs.remove('token');
        print("Logout berhasil.");
        return true;
      } else {
        print("Logout gagal: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error saat logout: $e");
      return false;
    }
  }
}
