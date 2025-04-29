import 'package:absensi/services/absensi_service.dart';
import 'package:absensi/API_models/absen_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
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
                                  ? DateFormat('HH:mm:ss').format(item.checkIn!)
                                  : '-';
                          final checkOut =
                              item.checkOut != null
                                  ? DateFormat(
                                    'HH:mm:ss',
                                  ).format(item.checkOut!)
                                  : '-';

                          final address =
                              item.checkInAddress ??
                              item.checkOutAddress ??
                              '-';

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              title: Text(
                                "Tanggal : $createdAt",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  Text(
                                    "Status : ${item.status}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Check-In : $checkIn",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Check-Out : $checkOut",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Alamat :",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    address,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
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
                                            ),
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
                                            ),
                                          ],
                                        ),
                                  );

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
                                      _fetchHistory();
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
                              ),
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
