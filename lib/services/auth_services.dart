import 'dart:convert';
import 'package:absensi/API/profile_model.dart';
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
        final loginData = loginFromJson(response.body);

        // Simpan token ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', loginData.data?.token ?? '');
        print("Token login disimpan: ${loginData.data?.token}");

        return loginData;
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
        final registerData = registerFromJson(response.body);

        // Simpan token ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', registerData.data?.token ?? '');
        print("Token register disimpan: ${registerData.data?.token}");

        return registerData;
      } else {
        print("Gagal register: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error saat register: $e");
      return null;
    }
  }

  // GET PROFILE
  static Future<ProfileData?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return null;

    final url = Uri.parse('$baseUrl/profile');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final profile = profileFromJson(response.body);
        print(
          "Data profil berhasil diambil: ${profile.data?.name}, ${profile.data?.email}",
        );
        return profile.data;
      } else {
        print("Gagal mendapatkan profil: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error saat get profile: $e");
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
