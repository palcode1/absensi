import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:absensi/API_models/absen_model.dart'; // Pastikan path sesuai dengan project kamu

class AbsensiService {
  static const String _baseUrl = 'https://absen.quidi.id/api/absen';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<bool> checkIn({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    final token = await _getToken();
    if (token == null) return false;

    final url = Uri.parse('$_baseUrl/check-in');
    final body = {
      "check_in_lat": latitude.toString(),
      "check_in_lng": longitude.toString(),
      "check_in_address": address,
      "status": "masuk",
    };

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    return response.statusCode == 200;
  }

  static Future<bool> checkOut({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    final token = await _getToken();
    if (token == null) return false;

    final url = Uri.parse('$_baseUrl/check-out');
    final body = {
      "check_out_lat": latitude.toString(),
      "check_out_lng": longitude.toString(),
      "check_out_address": address,
      "check_out_location": "$latitude, $longitude",
    };

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    return response.statusCode == 200;
  }

  static Future<List<AbsensiData>> getHistory() async {
    final token = await _getToken();
    if (token == null) return [];

    final url = Uri.parse('$_baseUrl/history');

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((item) => AbsensiData.fromJson(item)).toList();
    } else {
      return [];
    }
  }
}
