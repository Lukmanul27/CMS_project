import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatelessWidget {
  final TextEditingController txtEmail = TextEditingController();
  ForgotPasswordPage({super.key});

  // Fungsi untuk mereset kata sandi
  void resetPassword() async {
    try {
      // Kirim email reset password
      await FirebaseAuth.instance.sendPasswordResetEmail(email: txtEmail.text);
      // Tampilkan snackbar jika berhasil
      Get.snackbar('Berhasil', 'Email reset password telah dikirim',
          snackPosition: SnackPosition.BOTTOM);
    } on FirebaseAuthException catch (e) {
      // Tangani jika terjadi FirebaseAuthException
      if (e.code == 'user-not-found') {
        // Jika email tidak terdaftar
        Get.snackbar('Error', 'Tidak ada pengguna dengan email ini',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        // Jika terjadi kesalahan lain
        String message = 'Terjadi kesalahan: ${e.message}';
        Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      // Tangani kesalahan lainnya
      String message = 'Terjadi kesalahan: $e';
      Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resset Password'),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: const Color(0xFF6F6FDB),
        elevation: 4.0, // Tambahkan bayangan pada AppBar
      ),
      body: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center, // Konten ditengah
            children: [
              // Judul "Lupa Kata Sandi"
              Text(
                'Lupa Kata Sandi?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Warna teks
                ),
                textAlign: TextAlign.center, // Teks ditengah
              ),
              const SizedBox(height: 20),
              // Field input email
              TextFormField(
                controller: txtEmail,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white, // Latar belakang field email
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              // Tombol "Kirim Email Reset"
              ElevatedButton(
                onPressed: resetPassword,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  'Kirim Email Reset',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Warna teks tombol
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
