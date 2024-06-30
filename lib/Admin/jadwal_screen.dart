import 'package:flutter/material.dart';
import 'package:cmsapp/widget/widget_admin/custom_appbar.dart';
import 'package:cmsapp/widget/widget_admin/sidebar_admin.dart';
import 'package:cmsapp/services/jadwal_services.dart';

TextEditingController pukulController = TextEditingController();
TextEditingController hargaController = TextEditingController();

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _siangJadwal = [];
  List<Map<String, dynamic>> _soreJadwal = [];
  List<Map<String, dynamic>> _malamJadwal = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchJadwal();
  }

  Future<void> _fetchJadwal() async {
    try {
      final siangJadwal = await _firestoreService.getJadwalOnce('Siang');
      final soreJadwal = await _firestoreService.getJadwalOnce('Sore');
      final malamJadwal = await _firestoreService.getJadwalOnce('Malam');
      
      // Logging data
      print('Siang Jadwal: $siangJadwal');
      print('Sore Jadwal: $soreJadwal');
      print('Malam Jadwal: $malamJadwal');
      
      setState(() {
        _siangJadwal = siangJadwal;
        _soreJadwal = soreJadwal;
        _malamJadwal = malamJadwal;
        _loading = false;
      });
    } catch (error) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching jadwal: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomDrawer(),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4CAF50), // Green shade for soccer field
              Color(0xFF388E3C), // Darker green shade for contrast
              Color(0xFF1B5E20), // Even darker green shade for depth
            ],
          ),
        ),
        child: _loading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text(
                    'Jadwal Lapangan Minisoccer',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildJadwalTable('Siang', _siangJadwal),
                  SizedBox(height: 20),
                  _buildJadwalTable('Sore', _soreJadwal),
                  SizedBox(height: 20),
                  _buildJadwalTable('Malam', _malamJadwal),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addJadwalDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildJadwalTable(String jenisWaktu, List<Map<String, dynamic>> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          jenisWaktu,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(
                  label: Text('Pukul', style: TextStyle(color: Colors.white))),
              DataColumn(
                  label: Text('Harga (Rp)',
                      style: TextStyle(color: Colors.white))),
              DataColumn(
                  label: Text('Aksi', style: TextStyle(color: Colors.white))),
            ],
            rows: data
                .map((jadwal) => DataRow(cells: [
                      DataCell(Text(jadwal['pukul'] ?? '',
                          style: TextStyle(color: Colors.white))),
                      DataCell(Text('Rp.${jadwal['harga'] ?? 0}',
                          style: TextStyle(color: Colors.white))),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            color: Colors.white,
                            onPressed: () {
                              _editJadwalDialog(context, jadwal['id'],
                                  jadwal['pukul'] ?? '', jadwal['harga'] ?? 0);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            color: Colors.white,
                            onPressed: () {
                              _deleteJadwal(jadwal['id']);
                            },
                          ),
                        ],
                      )),
                    ]))
                .toList(),
          ),
        ),
      ],
    );
  }

  void _addJadwalDialog(BuildContext context) async {
    String? selectedWaktu;
    String defaultPukul = '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Jadwal'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    hint: Text('Pilih Waktu'),
                    value: selectedWaktu,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedWaktu = newValue!;
                        switch (selectedWaktu) {
                          case 'Siang':
                            defaultPukul = '10:00';
                            break;
                          case 'Sore':
                            defaultPukul = '15:00';
                            break;
                          case 'Malam':
                            defaultPukul = '18:00';
                            break;
                          default:
                            defaultPukul = '';
                        }
                        pukulController.text = defaultPukul;
                      });
                    },
                    items: <String>['Siang', 'Sore', 'Malam']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  TextField(
                    controller: pukulController,
                    decoration: InputDecoration(labelText: 'Pukul'),
                  ),
                  TextField(
                    controller: hargaController,
                    decoration: InputDecoration(labelText: 'Harga (Rp)'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedWaktu != null &&
                    pukulController.text.isNotEmpty &&
                    hargaController.text.isNotEmpty) {
                  _firestoreService.addJadwal(
                    selectedWaktu!,
                    pukulController.text,
                    int.tryParse(hargaController.text) ?? 0,
                  );
                  Navigator.pop(context);
                  _fetchJadwal();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Pastikan semua kolom terisi')),
                  );
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _editJadwalDialog(BuildContext context, String id, String pukulLama, int hargaLama) async {
    pukulController.text = pukulLama;
    hargaController.text = hargaLama.toString();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Jadwal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pukulController,
                decoration: InputDecoration(labelText: 'Pukul'),
              ),
              TextField(
                controller: hargaController,
                decoration: InputDecoration(labelText: 'Harga (Rp)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (pukulController.text.isNotEmpty &&
                    hargaController.text.isNotEmpty) {
                  _firestoreService.updateJadwal(
                    id,
                    pukulController.text,
                    int.tryParse(hargaController.text) ?? 0,
                  );
                  Navigator.pop(context);
                  _fetchJadwal();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Pastikan semua kolom terisi')),
                  );
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _deleteJadwal(String id) async {
    try {
      await _firestoreService.deleteJadwal(id);
      _fetchJadwal();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting jadwal: $error')),
      );
    }
  }
}
