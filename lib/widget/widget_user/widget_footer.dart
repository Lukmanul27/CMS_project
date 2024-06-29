import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Booking',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history ),
          label: 'History',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: const Color.fromARGB(255, 37, 52, 85), // Warna item terpilih
      unselectedItemColor: Colors.grey, // Warna item tidak terpilih
      backgroundColor: Colors.white, // Warna latar belakang BottomNavigationBar
      onTap: onTap,
    );
  }
}
