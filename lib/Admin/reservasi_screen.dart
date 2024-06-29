import 'package:cmsapp/widget/widget_admin/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:cmsapp/widget/widget_admin/sidebar_admin.dart'; // Pastikan Anda mengimpor file sidebar_page.dart

class ReservasiScreen extends StatefulWidget {
  const ReservasiScreen({super.key});

  @override
  State<ReservasiScreen> createState() => _ReservasiScreenState();
}

class _ReservasiScreenState extends State<ReservasiScreen> {
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
              Color(0xFF6F6FDB),
              Color(0xFF817AA7),
              Color(0xFF898B8B),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(height: 10),
            Text(
              'Reservasi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            // Tambahkan elemen UI tambahan di sini, mis. kartu ringkasan, grafik, dll.
          ],
        ),
      ),
    );
  }
}
