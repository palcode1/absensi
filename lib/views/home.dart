// import 'package:flutter/material.dart';
// import 'package:absensi/views/absensi.dart';
// import 'package:absensi/views/history.dart';
// import 'package:absensi/views/izin.dart';
// import 'package:absensi/views/profile.dart';

// class MainHomePage extends StatefulWidget {
//   const MainHomePage({Key? key}) : super(key: key);

//   @override
//   State<MainHomePage> createState() => _MainHomePageState();
// }

// class _MainHomePageState extends State<MainHomePage> {
//   int _currentIndex = 0;
//   late PageController _pageController;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(initialPage: _currentIndex);
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   void onTabTapped(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//     _pageController.animateToPage(
//       index,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: PageView(
//           controller: _pageController,
//           physics: const NeverScrollableScrollPhysics(),
//           children: [AbsensiPage(), HistoryPage(), IzinPage(), ProfilePage()],
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: Colors.blue,
//         currentIndex: _currentIndex,
//         selectedItemColor: Colors.white,
//         unselectedItemColor: Colors.grey[400],
//         selectedLabelStyle: TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.bold,
//         ),
//         unselectedLabelStyle: TextStyle(fontSize: 12),
//         onTap: onTabTapped,
//         items: [
//           _buildNavItem('assets/images/home_icon.png', 0, 'Home'),
//           _buildNavItem('assets/images/history_icon.png', 1, 'Riwayat'),
//           _buildNavItem('assets/images/izin_icon.png', 2, 'Izin'),
//           _buildNavItem('assets/images/profile_icon.png', 3, 'Profil'),
//         ],
//       ),
//     );
//   }

//   BottomNavigationBarItem _buildNavItem(
//     String assetPath,
//     int index,
//     String label,
//   ) {
//     bool isSelected = _currentIndex == index;
//     return BottomNavigationBarItem(
//       icon: Container(
//         padding: const EdgeInsets.all(4),
//         decoration: BoxDecoration(
//           color:
//               isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
//           shape: BoxShape.circle,
//         ),
//         child: Image.asset(
//           assetPath,
//           width: 24,
//           height: 24,
//           color: isSelected ? Colors.white : Colors.grey[400],
//         ),
//       ),
//       label: label,
//     );
//   }
// }
