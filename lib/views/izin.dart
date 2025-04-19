import 'package:absensi/views/absensi.dart';
import 'package:absensi/views/profile.dart';
import 'package:absensi/views/history.dart';
import 'package:flutter/material.dart';

class IzinPage extends StatefulWidget {
  const IzinPage({super.key});

  @override
  State<IzinPage> createState() => _IzinPageState();
}

class _IzinPageState extends State<IzinPage> {
  int currentIndex = 2;

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
              "Izin",
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
          // Konten utama
          const Expanded(child: Center(child: Text("Halaman Izin"))),
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
