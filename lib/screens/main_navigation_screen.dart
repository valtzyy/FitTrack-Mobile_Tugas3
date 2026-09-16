import 'package:flutter/material.dart';
import 'help/help_screen.dart';
import 'home/home_screen.dart';
import 'stopwatch/stopwatch_screen.dart';

// Layar pembungkus utama dengan BottomNavigationBar
// Menghubungkan 3 bagian utama: Beranda (Home), Stopwatch, dan Bantuan (Help).
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Daftar 3 layar utama navigasi bawah
  final List<Widget> _screens = const [
    HomeScreen(),
    StopwatchScreen(),
    HelpScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan IndexedStack agar state Stopwatch tidak ter-reset saat pengguna berpindah tab
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            activeIcon: Icon(Icons.timer_rounded),
            label: 'Stopwatch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline_rounded),
            activeIcon: Icon(Icons.help_rounded),
            label: 'Bantuan',
          ),
        ],
      ),
    );
  }
}
