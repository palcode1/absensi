import 'package:absensi/API_models/endpoint.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EditProfilePage extends StatefulWidget {
  final String currentName;

  const EditProfilePage({super.key, required this.currentName});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  Future<void> _saveProfile() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Token tidak ditemukan')));
      return;
    }

    final url = Uri.parse(profileEndpoint);
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': _nameController.text.trim()}),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama berhasil diperbarui!')),
      );
      Navigator.pop(context, true); // return success
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal memperbarui nama.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Nama'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Baru',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size.fromHeight(50),
              ),
              child:
                  isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                        'SIMPAN',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
