import 'package:absensi/services/geo_services.dart';
import 'package:absensi/views/profile.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class AbsensiPage extends StatefulWidget {
  const AbsensiPage({super.key});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  String _currentTime = '';
  String _currentDate = '';
  int _selectedIndex = 0; // Indeks halaman yang sedang aktif
  bool isWithinRange = false; // Status apakah dalam jangkauan
  bool isLoading = true;

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
    zoom: 14.0,
  );

  final List<Widget> _pages = [
    // HomePage(), // Halaman Beranda
    // IzinPage(), // Halaman Receipt
    // EditPage(), // Halaman Edit
    ProfilePage(), // Halaman Profile
  ];

  @override
  void initState() {
    super.initState();
    _updateTime();
    _determinePosition();
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('HH:mm:ss').format(now);
      _currentDate = DateFormat('EEEE - dd MMMM yyyy', 'id_ID').format(now);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Mengatur indeks aktif
        onTap: _onItemTapped, // Fungsi untuk menangani klik
        backgroundColor:
            Colors.blue[700], // Warna latar belakang BottomNavigationBar
        selectedItemColor: Colors.blue, // Warna item yang dipilih
        unselectedItemColor: Colors.black, // Warna item yang tidak dipilih
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Izin',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_document),
            label: 'Edit',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),

      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
            color: Colors.blue[700],
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

          // Kontainer Utama
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
                      height: 400,
                      width: double.infinity,
                      child:
                          isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: _currentPosition!,
                                  zoom: 16,
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
                        // Aksi check-in
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(50),
                        backgroundColor: Colors.blue,
                        elevation: 6,
                      ),
                      child: const Text(
                        "Check-In",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),

                    const SizedBox(height: 12),
                    const Text(
                      "Check-In sebelum bekerja pada hari ini !",
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
    );
  }
}
