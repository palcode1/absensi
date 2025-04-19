import 'package:absensi/services/auth_services.dart';
import 'package:absensi/views/history.dart';
import 'package:absensi/views/profile.dart';
import 'package:absensi/views/izin.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class AbsensiPage extends StatefulWidget {
  const AbsensiPage({super.key});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  String? userName;
  String? checkInTime;
  String? checkOutTime;
  String _currentTime = '';
  String _currentDate = '';
  bool isWithinRange = false; // Status apakah dalam jangkauan
  bool isLoading = true;
  int currentIndex = 0; // Menyimpan index menu yang aktif

  // Google Maps Controller
  late GoogleMapController mapController;
  LatLng? _currentPosition;

  // Titik tetap untuk absen
  final LatLng attendancePoint = const LatLng(-6.21087, 106.81298);

  // Lokasi awal (misalnya Jakarta)
  static const LatLng _initialPosition = LatLng(-6.2088, 106.8456);

  // Kamera posisi untuk Google Maps
  CameraPosition _initialCameraPosition = CameraPosition(
    target: _initialPosition,
    zoom: 50.0,
  );

  @override
  void initState() {
    super.initState();
    _updateTime();
    _determinePosition();
    fetchProfile();

    Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('HH:mm:ss').format(now);
      _currentDate = DateFormat('EEEE - dd MMMM yyyy', 'id_ID').format(now);
    });
  }

  Future<void> fetchProfile() async {
    final user = await AuthService.getProfile();

    if (user != null) {
      setState(() {
        userName = user.name;
      });
    } else {
      print("User is null saat fetchProfile()");
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final double distanceInMeters = Geolocator.distanceBetween(
      attendancePoint.latitude,
      attendancePoint.longitude,
      position.latitude,
      position.longitude,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      isWithinRange = distanceInMeters <= 15.0;
      isLoading = false;
    });
    print('Jarak ke titik absen: ${distanceInMeters.toStringAsFixed(2)} meter');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 15),
            color: Colors.blue,
            width: double.infinity,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.blue),
                ),
                SizedBox(width: 10),
                Text(
                  "Hi, ${userName ?? 'User'}",
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Map placeholder google maps
                    Container(
                      height: 300,
                      width: double.infinity,
                      child:
                          isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: _currentPosition!,
                                  zoom: 17,
                                ),
                                myLocationEnabled: true,
                                onMapCreated: (GoogleMapController controller) {
                                  mapController = controller;
                                },
                                markers: {
                                  Marker(
                                    markerId: const MarkerId('absen'),
                                    position: attendancePoint,
                                    infoWindow: const InfoWindow(
                                      title: 'Titik Absen',
                                    ),
                                  ),
                                  Marker(
                                    markerId: const MarkerId('user'),
                                    position: _currentPosition!,
                                    infoWindow: const InfoWindow(
                                      title: 'Posisi Anda',
                                    ),
                                  ),
                                },
                                circles: {
                                  Circle(
                                    circleId: const CircleId('absen-radius'),
                                    center: attendancePoint,
                                    radius: 15.0,
                                    fillColor: Colors.red.withOpacity(0.2),
                                    strokeColor: Colors.red,
                                    strokeWidth: 1,
                                  ),
                                },
                              ),
                    ),
                    const SizedBox(height: 16),

                    // Jam dan Tanggal
                    Text(
                      _currentTime,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(_currentDate, style: const TextStyle(fontSize: 16)),

                    const SizedBox(height: 16),

                    // Tombol Check-In
                    ElevatedButton(
                      onPressed: () {
                        if (!isWithinRange) return;
                        final now = DateFormat(
                          'HH:mm:ss',
                        ).format(DateTime.now());
                        if (checkInTime == null) {
                          setState(() {
                            checkInTime = now;
                          });
                        } else if (checkOutTime == null) {
                          setState(() {
                            checkOutTime = now;
                          });
                        } else {
                          // Sudah absen, arahkan ke halaman history
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HistoryPage(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(50),
                        backgroundColor:
                            checkInTime == null
                                ? Colors.blue
                                : checkOutTime == null
                                ? Colors.red
                                : Colors.grey,
                        elevation: 6,
                      ),
                      child: Text(
                        checkInTime == null
                            ? "Check-In"
                            : checkOutTime == null
                            ? "Check-Out"
                            : "Sudah Absen",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Text(
                      checkInTime == null
                          ? "Check-In sebelum bekerja pada hari ini !"
                          : checkOutTime == null
                          ? "Check-Out setelah selesai bekerja !"
                          : "Terima kasih sudah bekerja hari ini !",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
        padding: EdgeInsets.all(6),
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
