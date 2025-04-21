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
                          final checkIn =
                              item.checkIn != null
                                  ? DateFormat(
                                    'yyyy-MM-dd HH:mm:ss',
                                  ).format((item.checkIn!))
                                  : '-';
                          final checkOut =
                              item.checkOut != null
                                  ? DateFormat(
                                    'yyyy-MM-dd HH:mm:ss',
                                  ).format((item.checkOut!))
                                  : '-';
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.calendar_today),
                              title: Text(
                                "Tanggal : $createdAt",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ), //title
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    "Status : ${item.status}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Check-In : ${item.checkIn != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(item.checkIn!) : '-'}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Check-Out : ${item.checkOut != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(item.checkOut!) : '-'}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Alasan Izin : ${item.alasanIzin ?? '-'}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ), //subtitle
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text('Hapus Absen'),
                                          content: const Text(
                                            'Apakah Anda yakin ingin menghapus absen ini?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    false,
                                                  ),
                                              child: const Text('Batal'),
                                            ), // TextButton Batal
                                            ElevatedButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    true,
                                                  ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              child: const Text(
                                                'Hapus',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ), // ElevatedButton Hapus
                                          ],
                                        ), // AlertDialog
                                  ); // showDialog

                                  if (confirm == true) {
                                    final success =
                                        await AbsensiService.deleteAbsensi(
                                          item.id!,
                                        );
                                    if (success) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Absen berhasil dihapus',
                                          ),
                                        ),
                                      );
                                      _fetchHistory(); // Refresh data setelah delete
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Gagal menghapus absen',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ), // trailing
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
