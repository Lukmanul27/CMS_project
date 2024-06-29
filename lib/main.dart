import 'package:cmsapp/user_pages/dashboard_screen.dart';
import 'package:cmsapp/Admin/dashboard_admin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_page.dart';
import 'package:cmsapp/widget/background_gradien.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  Widget mainView = MainPage();
  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isAdmin = prefs.getBool('isAdmin') ?? false;

    if (isAdmin) {
      mainView = AdminDashboardScreen();
    } else {
      // Fetch user ID from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        mainView = DashboardScreen(user_id: currentUser.uid);
      } else {
        mainView = MainPage();
      }
    }
  }

  runApp(MyApp(mainView: mainView));
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

class MyApp extends StatelessWidget {
  final Widget mainView;

  const MyApp({required this.mainView, super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cikajang Mini Soccer',
      theme: ThemeData(
        textTheme: GoogleFonts.changaTextTheme(),
      ),
      home: GradientBackground(
        child: mainView,
      ),
    );
  }
}
