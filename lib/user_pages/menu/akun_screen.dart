import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cmsapp/Auth/login_screen.dart';

class AkunScreen extends StatefulWidget {
  const AkunScreen({super.key});

  @override
  _AkunScreenState createState() => _AkunScreenState();
}

class _AkunScreenState extends State<AkunScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  User? user;
  Map<String, dynamic>? userData;
  File? _imageFile;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user!.uid).get();
      setState(() {
        userData = userDoc.data() as Map<String, dynamic>?;
        _usernameController.text = userData!['username'] ?? '';
        _emailController.text = userData!['email'] ?? '';
        _phoneNumberController.text = userData!['nomorhp'] ?? '';
      });
    }
  }
  
  Future<void> _updateUserData() async {
    if (user != null) {
      String newEmail = _emailController.text;
      try {
        await user!.updateEmail(newEmail);
        await _firestore.collection('users').doc(user!.uid).update({
          'username': _usernameController.text,
          'email': newEmail,
          'nomorhp': _phoneNumberController.text,
        });
        Get.snackbar('Update Berhasil', 'Informasi akun telah diperbarui.');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          Get.snackbar('Error', 'Harap login ulang dan coba lagi.');
        } else {
          Get.snackbar('Error', 'Terjadi kesalahan: ${e.message}');
        }
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _uploadImage(_imageFile!);
    }
  }

  Future<void> _uploadImage(File imageFile) async {
  if (user != null && imageFile != null) {
    try {
      Reference storageReference =
          _storage.ref().child('profile_images/${user!.uid}.jpg');
      await storageReference.putFile(imageFile);
      String imageUrl = await storageReference.getDownloadURL();
      await _firestore
          .collection('users')
          .doc(user!.uid)
          .update({'photoUrl': imageUrl}); // Menyimpan URL gambar ke Firestore
      setState(() {
        userData!['photoUrl'] = imageUrl;
      });
      Get.snackbar('Upload Berhasil', 'Foto profil telah diperbarui.');
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengunggah foto profil.');
    }
  }
}

  void _resetPassword() async {
    if (user != null) {
      await _auth.sendPasswordResetEmail(email: user!.email!);
      Get.snackbar(
          'Reset Password', 'Link reset password telah dikirim ke email Anda.');
    }
  }

  void _logout() async {
    await _auth.signOut();
    Get.offAll(() => LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akun'),
        backgroundColor: Color(0xFF6F6FDB),
      ),
      body: Container(
        decoration: BoxDecoration(
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
        child: userData == null
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _pickImage(ImageSource.gallery),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                              child: ClipOval(
                                child: userData!['photoUrl'] != null
                                    ? Image.network(
                                        userData!['photoUrl'],
                                        fit: BoxFit.cover,
                                        width: 120,
                                        height: 120,
                                      )
                                    : Image.asset(
                                        'path/to/profile_image.jpg',
                                        fit: BoxFit.cover,
                                        width: 120,
                                        height: 120,
                                      ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _pickImage(ImageSource.gallery),
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Galeri'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Kamera'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _usernameController,
                        decoration:
                            const InputDecoration(labelText: 'Nama Pengguna'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _phoneNumberController,
                        decoration:
                            const InputDecoration(labelText: 'Nomor HP'),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _updateUserData,
                        child: const Text('Simpan Perubahan'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _resetPassword,
                        child: const Text('Reset Password'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _logout,
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
