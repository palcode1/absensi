import 'package:absensi/views/absensi.dart';
import 'package:absensi/views/profile.dart';
import 'package:absensi/views/history.dart';
import 'package:absensi/views/izin.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _currentTime = '';
  String _currentDate = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('HH:mm:ss').format(now);
      _currentDate = DateFormat('EEEE - dd MMMM yyyy', 'id_ID').format(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        toolbarHeight: 0, // Menghilangkan height AppBar
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
            color: Colors.blue,
            width: double.infinity,
            child: Row(
              children: const [
                CircleAvatar(radius: 25, backgroundColor: Colors.grey),
                SizedBox(width: 12),
                Text(
                  "Halo, Username",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          ),

          // Waktu dan Tanggal
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  _currentTime,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(_currentDate, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),

          // Grid Menu
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildMenuCard(Icons.calendar_today, "Absensi", context),
                  _buildMenuCard(Icons.history, "History", context),
                  _buildMenuCard(Icons.request_page, "Penajuan Izin", context),
                  _buildMenuCard(Icons.request_page, "Penajuan Izin", context),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.edit_document), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
              // Home (tetap di halaman ini)
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryPage()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const IzinPage()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
              break;
          }
          // Tambahkan navigasi sesuai kebutuhan
        },
      ),
    );
  }

  Widget _buildMenuCard(IconData icon, String title, BuildContext context) {
    return InkWell(
      onTap: () {
        // Tambahkan navigasi berdasarkan title
        if (title == "Absensi") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AbsensiPage()),
          );
        } else if (title == "History") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HistoryPage()),
          );
        } else if (title == "Penajuan Izin") {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => const PenajuanIzinPage()),
          // );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.grey[600]),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
