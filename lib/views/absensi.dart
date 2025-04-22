import 'package:absensi/services/auth_services.dart';
import 'package:absensi/services/absensi_service.dart';
import 'package:absensi/views/history.dart';
import 'package:absensi/views/main_home_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class AbsensiPage extends StatefulWidget {
  final VoidCallback? onFinishedAbsensi; // <--- Tambahkan callback
  const AbsensiPage({super.key, this.onFinishedAbsensi});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  String? userName;
  String _currentTime = '';
  String _currentDate = '';

  bool isCheckedIn = false;
  bool isCheckedOut = false;
  bool isWithinRange = false; // Status apakah dalam jangkauan
  bool isLoading = true;
  bool isProcessing = false;
  late Timer _timer;

  // Google Maps Controller
  late GoogleMapController mapController;
  LatLng? _currentPosition;

  // Titik tetap untuk absen
  final LatLng attendancePoint = const LatLng(-6.21087, 106.81298);

  @override
  void initState() {
    super.initState();
    _updateTime();
    _determinePosition();
    fetchProfile();
    _fetchStatusHariIni();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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

  Future<void> _fetchStatusHariIni() async {
    final status = await AbsensiService.fetchStatusHariIni();
    if (status.isNotEmpty) {
      setState(() {
        if (status['status'] == 'izin') {
          isCheckedIn = true;
          isCheckedOut = true;
        } else {
          if (status['check_in'] != null) {
            isCheckedIn = true;
          }
          if (status['check_out'] != null) {
            isCheckedOut = true;
          }
        }
      });
      print(
        '📡 Status Hari Ini -> Check-In: ${status['check_in']}, Check-Out: ${status['check_out']}',
      );
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

    final double distance = Geolocator.distanceBetween(
      attendancePoint.latitude,
      attendancePoint.longitude,
      position.latitude,
      position.longitude,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      isWithinRange = distance <= 15.0;
      isLoading = false;
    });
    print('Jarak ke titik absen: ${distance.toStringAsFixed(2)} meter');
  }

  Future<void> _showIzinDialog() async {
    TextEditingController alasanController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajukan Izin'),
          content: TextField(
            controller: alasanController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Masukkan alasan izin'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (alasanController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Alasan izin tidak boleh kosong'),
                    ),
                  );
                  return;
                }

                if (_currentPosition == null) return;

                final result = await AbsensiService.submitIzin(
                  latitude: _currentPosition!.latitude,
                  longitude: _currentPosition!.longitude,
                  address: "Lokasi Pengajuan Izin",
                  alasanIzin: alasanController.text,
                );

                if (result == "Success") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pengajuan Izin berhasil!')),
                  );
                  setState(() {
                    isCheckedIn = true;
                    isCheckedOut = true;
                  });
                  Future.delayed(const Duration(milliseconds: 300), () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MainHomePage(initialIndex: 1),
                      ),
                    );
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gagal mengajukan izin.')),
                  );
                }
              },
              child: const Text('Kirim'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleAbsensi() async {
    if (_currentPosition == null) return;

    setState(() {
      isProcessing = true;
    });

    if (!isCheckedIn) {
      // Check-In
      final result = await AbsensiService.checkIn(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        address: "Lokasi Check-In",
      );
      if (result == "Success") {
        setState(() {
          isCheckedIn = true;
        });
        print('✅ Berhasil Check-In pada ${_currentTime}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Check-In berhasil!')));
      } else if (result == "Sudah Check-In") {
        setState(() {
          isCheckedIn = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda sudah melakukan check-in hari ini!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check-In gagal. Coba lagi nanti.')),
        );
      }
    } else if (isCheckedIn && !isCheckedOut) {
      // Check-Out
      final result = await AbsensiService.checkOut(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        address: "Lokasi Check-Out",
      );
      if (result == "Success") {
        setState(() {
          isCheckedOut = true;
        });
        print('✅ Berhasil Check-Out pada ${_currentTime}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Check-Out berhasil!')));
      } else if (result == "Sudah Check-Out") {
        setState(() {
          isCheckedOut = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda sudah melakukan Check-Out hari ini!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check-Out gagal. Coba lagi nanti.')),
        );
      }
    } else if (isCheckedIn && isCheckedOut) {
      // Sudah absen semua ➔ Pergi ke HistoryPage
      if (widget.onFinishedAbsensi != null) {
        widget.onFinishedAbsensi!(); // Panggil callback jika ada
      }
    }

    setState(() {
      isProcessing = false;
    });
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
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                isWithinRange && !isProcessing
                                    ? _handleAbsensi
                                    : null,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor:
                                  !isCheckedIn
                                      ? Colors.blue
                                      : isCheckedIn && !isCheckedOut
                                      ? Colors.red
                                      : Colors.grey,
                              elevation: 6,
                            ),
                            child:
                                isProcessing
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : Text(
                                      !isCheckedIn
                                          ? "Check-In"
                                          : isCheckedIn && !isCheckedOut
                                          ? "Check-Out"
                                          : "Sudah Absen",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(width: 12), // Jarak antar tombol
                        Expanded(
                          child: ElevatedButton(
                            onPressed: !isProcessing ? _showIzinDialog : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 6, // Tambahkan elevation disini
                            ),
                            child: const Text(
                              'Ajukan Izin',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      !isCheckedIn
                          ? "Check-In dulu sebelum bekerja pada hari ini!"
                          : !isCheckedOut
                          ? "Check-Out dulu setelah bekerja pada hari ini!"
                          : "Terima kasih sudah bekerja hari ini!",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
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
