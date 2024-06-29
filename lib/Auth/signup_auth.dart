import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cmsapp/Auth/login_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:math';

class SignUpPage extends StatelessWidget {
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtPhoneNumber = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();
  final TextEditingController txtConfirmPassword = TextEditingController();

  SignUpPage({super.key});

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  Future<void> saveTokenToDatabase(String userId) async {
    String? token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'token': token,
      });
    }
  }

  String generateRandomUsername() {
    const letters = 'abcdefghijklmnopqrstuvwxyz';
    final random = Random();
    return 'user_' + List.generate(8, (index) => letters[random.nextInt(letters.length)]).join();
  }

  void signUp(BuildContext context) async {
    if (txtPassword.text != txtConfirmPassword.text) {
      Get.snackbar('Error', 'Password tidak sesuai', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: txtEmail.text,
        password: txtPassword.text,
      );

      // Menambahkan user ID secara default
      String userId = userCredential.user!.uid;

      // Generate a random username if needed
      String username = 'CMS_';
      if (username == 'CMS_') {
        username = generateRandomUsername();
      }

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'user_id': userId, // Menyimpan ID pengguna
        'username': username, // Menyimpan nama pengguna
        'email': txtEmail.text,
        'nomorhp': txtPhoneNumber.text, // Menyimpan nomor telepon
        'role': 'user', // Peran default adalah 'user'
      });

      // Panggil fungsi untuk meminta izin dan menyimpan token
      requestPermission();
      await saveTokenToDatabase(userId);

      // Tampilkan dialog setelah pendaftaran berhasil
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Berhasil'),
            content: const Text('Pendaftaran berhasil. Silakan login.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Get.offAll(() => LoginPage());
                },
              ),
            ],
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'Password yang Anda masukkan terlalu lemah.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Akun sudah ada untuk email tersebut.';
      } else {
        message = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      Get.snackbar('Error Daftar', message, snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 50), // Adding space for the logo
          Image.asset(
            "lib/assets/img/logo.png",
            width: 100,
            height: 100,
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Silahkan Daftar Terlebih Dahulu',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 50),
          _buildSignUpForm(context),
        ],
      ),
    );
  }

  Widget _buildSignUpForm(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: txtEmail,
          decoration: _buildInputDecoration('Email'),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: txtPhoneNumber,
          decoration: _buildInputDecoration('Nomor HP'),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: txtPassword,
          decoration: _buildInputDecoration('Kata Sandi'),
          obscureText: true,
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: txtConfirmPassword,
          decoration: _buildInputDecoration('Konfirmasi Kata Sandi'),
          obscureText: true,
        ),
        const SizedBox(height: 32.0),
        ElevatedButton(
          onPressed: () => signUp(context),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 5.0,
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Signup',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF141414),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        _buildLoginLink(),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah Punya Akun?',
          style: TextStyle(
            color: Colors.blueGrey[900],
            fontSize: 18,
          ),
        ),
        TextButton(
          onPressed: () {
            Get.to(() => LoginPage());
          },
          child: const Text(
            'Login',
            style: TextStyle(
              color: Color(0xFF000000),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
