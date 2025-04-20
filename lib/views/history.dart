import 'package:absensi/services/absensi_service.dart';
import 'package:absensi/API_models/absen_model.dart';
import 'package:absensi/views/absensi.dart';
import 'package:absensi/views/profile.dart';
import 'package:absensi/views/izin.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int currentIndex = 1;
  List<AbsensiData> _historyList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final data = await AbsensiService.getHistory();
    setState(() {
      _historyList = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Custom AppBar
          Container(
            padding: const EdgeInsets.only(
              top: 40,
              left: 16,
              right: 16,
              bottom: 20,
            ),
            width: double.infinity,
            color: Colors.blue,
            child: const Text(
              "Riwayat",
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
          // Konten utama
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _historyList.isEmpty
                    ? const Center(child: Text("Belum ada data absensi"))
                    : Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8, top: 2),
                      child: ListView.builder(
                        itemCount: _historyList.length,
                        itemBuilder: (context, index) {
                          final item = _historyList[index];
                          final createdAt =
                              item.createdAt != null
                                  ? DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(item.createdAt!)
                                  : '-';
                          final checkIn = item.checkIn ?? '-';
                          final checkOut = item.checkOut ?? '-';
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.calendar_today),
                              title: Text(
                                "Tanggal: $createdAt",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    "Check-In: $checkIn",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Check-Out: $checkOut",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.blue,
          items: [
            _buildNavItem('assets/images/home_icon.png', 0, 'Beranda'),
            _buildNavItem('assets/images/history_icon.png', 1, 'Riwayat'),
            _buildNavItem('assets/images/izin_icon.png', 2, 'Izin'),
            _buildNavItem('assets/images/profile_icon.png', 3, 'Profile'),
          ],
          currentIndex: currentIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey[800],
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
            switch (index) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AbsensiPage()),
                );
                break;
              case 1:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryPage()),
                );
                break;
              case 2:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const IzinPage()),
                );
                break;
              case 3:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
                break;
            }
          },
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    String assetPath,
    int index,
    String label,
  ) {
    bool isSelected = currentIndex == index;
    return BottomNavigationBarItem(
      icon: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color:
              currentIndex == index
                  ? Colors.white.withOpacity(0.2)
                  : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Image.asset(
          assetPath,
          width: 24,
          height: 24,
          color:
              isSelected ? Colors.white : Colors.grey[800], // Dynamic coloring
        ),
      ),
      label: label,
    );
  }
}
