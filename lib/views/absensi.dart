import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import '../services/auth_services.dart';
import '../services/absensi_service.dart';
import 'main_home_page.dart';

class AbsensiPage extends StatefulWidget {
  final VoidCallback? onFinishedAbsensi;
  const AbsensiPage({super.key, this.onFinishedAbsensi});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  String? userName;
  String _currentTime = '';
  String _currentDate = '';
  String _currentAddress = 'Mengambil lokasi...';

  bool isCheckedIn = false;
  bool isCheckedOut = false;
  bool isWithinRange = false;
  bool isLoading = true;
  bool isProcessingCheckIn = false;
  bool isProcessingCheckOut = false;

  late Timer _timer;
  late GoogleMapController mapController;
  LatLng? _currentPosition;

  final LatLng attendancePoint = const LatLng(-6.21087, 106.81298);

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
    _determinePosition();
    fetchProfile();
    _fetchStatusHariIni();
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
      _currentDate = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(now);
    });
  }

  Future<void> fetchProfile() async {
    final user = await AuthService.getProfile();
    if (user != null) {
      setState(() => userName = user.name);
    }
  }

  Future<void> _fetchStatusHariIni() async {
    final status = await AbsensiService.fetchStatusHariIni();
    if (status.isNotEmpty) {
      setState(() {
        isCheckedIn = status['check_in'] != null;
        isCheckedOut = status['check_out'] != null;
      });
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    final position = await Geolocator.getCurrentPosition(
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

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            "${place.street}, ${place.subLocality}, ${place.locality}";
      });
    } catch (e) {
      print("Gagal mengambil alamat: $e");
    }
  }

  Future<void> _handleCheckIn() async {
    if (_currentPosition == null) return;

    setState(() => isProcessingCheckIn = true);

    final result = await AbsensiService.checkIn(
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      address: _currentAddress,
    );

    if (result == "Success") setState(() => isCheckedIn = true);

    _showSnackBar(result);
    setState(() => isProcessingCheckIn = false);
  }

  Future<void> _handleCheckOut() async {
    if (_currentPosition == null) return;

    setState(() => isProcessingCheckOut = true);

    final result = await AbsensiService.checkOut(
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      address: _currentAddress,
    );

    if (result == "Success") {
      setState(() => isCheckedOut = true);
      if (widget.onFinishedAbsensi != null) widget.onFinishedAbsensi!();
    }

    _showSnackBar(result);
    setState(() => isProcessingCheckOut = false);
  }

  void _showSnackBar(String result) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.replaceAll('_', ' '))));
  }

  PreferredSizeWidget _buildCustomAppBar() {
    return AppBar(
      backgroundColor: Colors.blue,
      automaticallyImplyLeading: false,
      elevation: 0,
      title: Text(
        'Hi, ${userName ?? 'User'}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildCustomAppBar(),
      body: SafeArea(
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _currentDate,
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          _currentTime,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildMapCard(),
                        const SizedBox(height: 16),
                        Text(
                          _currentAddress,
                          style: TextStyle(fontSize: 14, color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        _buildActionButtons(),
                        const SizedBox(height: 12),
                        _buildStatusText(),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildMapCard() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue, // warna outline
          width: 2, // ketebalan outline
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentPosition!,
            zoom: 17,
          ),
          myLocationEnabled: true,
          onMapCreated: (controller) => mapController = controller,
          markers: {
            Marker(
              markerId: const MarkerId('office'),
              position: attendancePoint,
              infoWindow: const InfoWindow(title: 'Titik Absen'),
            ),
            Marker(
              markerId: const MarkerId('user'),
              position: _currentPosition!,
              infoWindow: const InfoWindow(title: 'Lokasi Kamu'),
            ),
          },
          circles: {
            Circle(
              circleId: const CircleId('radius'),
              center: attendancePoint,
              radius: 15.0,
              fillColor: Colors.red.withOpacity(0.2),
              strokeColor: Colors.red,
              strokeWidth: 1,
            ),
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed:
                isWithinRange && !isCheckedIn && !isProcessingCheckIn
                    ? _handleCheckIn
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child:
                isProcessingCheckIn
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                      "Check-In",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed:
                isWithinRange &&
                        isCheckedIn &&
                        !isCheckedOut &&
                        !isProcessingCheckOut
                    ? _handleCheckOut
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child:
                isProcessingCheckOut
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                      "Check-Out",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusText() {
    String text =
        !isCheckedIn
            ? "Check-In dulu sebelum bekerja!"
            : !isCheckedOut
            ? "Check-Out setelah selesai bekerja!"
            : "Terima kasih sudah absen hari ini!";
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 16),
    );
  }
}
