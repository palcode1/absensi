import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:absensi/API_models/absen_model.dart'; // Pastikan path sesuai dengan project kamu
import 'package:absensi/API_models/endpoint.dart';

class AbsensiService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<String> checkIn({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    final token = await _getToken();
    if (token == null) return "Token tidak ditemukan";

    final url = Uri.parse(checkInEndpoint);
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

    print('📡 Response Check-In: ${response.body}');

    // Debugging response
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['message'] == "Absen masuk berhasil") {
        return "Success";
      } else if (responseData['message'] ==
          "Anda sudah melakukan absen hari ini") {
        return "Sudah Check-In";
      } else {
        return "Error";
      }
    } else {
      return "Error";
    }
  }

  static Future<String> checkOut({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    final token = await _getToken();
    if (token == null) return "Token tidak ditemukan";

    final url = Uri.parse(checkOutEndpoint);
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

    print('📡 Response Check-Out: ${response.body}');

    // Debugging response
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      if (responseData['message'] == "Absen keluar berhasil") {
        return "Success";
      } else if (responseData['message'] ==
          "Anda sudah melakukan absen keluar hari ini") {
        return "Sudah Check-Out";
      } else {
        return "Error";
      }
    } else {
      return "Error";
    }
  }

  static Future<Map<String, dynamic>> fetchStatusHariIni() async {
    final token = await _getToken();
    if (token == null) return {};

    final url = Uri.parse(historyAbsensiEndpoint);

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    print('📡 Response Fetch Status Hari Ini: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final List<dynamic> dataList = responseData['data'];

      // Cari absensi untuk tanggal hari ini
      final now = DateTime.now();
      final today = DateFormat('yyyy-MM-dd').format(now);

      for (var data in dataList) {
        final createdAt = data['created_at']?.toString() ?? '';
        if (createdAt.startsWith(today)) {
          return {"check_in": data['check_in'], "check_out": data['check_out']};
        }
      }
    }

    return {}; // Tidak ada absensi hari ini
  }

  static Future<String> submitIzin({
    required double latitude,
    required double longitude,
    required String address,
    required String alasanIzin,
  }) async {
    final token = await _getToken();
    if (token == null) return "Token tidak ditemukan";

    final url = Uri.parse(checkInEndpoint);
    final body = {
      "check_in_lat": latitude.toString(),
      "check_in_lng": longitude.toString(),
      "check_in_address": address,
      "status": "izin",
      "alasan_izin": alasanIzin,
    };

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    print('📡 Response Submit Izin: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['message'] == "Izin berhasil dicatat") {
        return "Success";
      }
      return "Error";
    } else {
      return "Error";
    }
  }

  static Future<List<AbsensiData>> getHistory() async {
    final token = await _getToken();
    if (token == null) return [];

    final url = Uri.parse(historyAbsensiEndpoint);

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

  static Future<bool> deleteAbsensi(int id) async {
    final token = await _getToken();
    if (token == null) return false;

    final url = Uri.parse(
      '$deleteAbsensiEndpoint/$id',
    ); // atau sesuai struktur URL API kamu
    final response = await http.delete(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    print('📡 Response Delete Absen: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
