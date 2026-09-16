import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../constants/app_constants.dart';
import '../../services/session_service.dart';

// Layar pembuka (Splash Screen) yang bertugas memeriksa sesi login pengguna.
// Jika sesi aktif ditemukan, pengguna langsung diarahkan ke menu utama.
// Jika belum login, diarahkan ke layar login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  // Memeriksa status sesi login di penyimpanan lokal
  Future<void> _checkUserSession() async {
    // Memberikan jeda singkat agar splash screen terlihat profesional
    await Future.delayed(const Duration(milliseconds: 1200));

    // Memastikan widget masih terpasang pada tree sebelum navigasi
    if (!mounted) return;

    final isLoggedIn = await SessionService.isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      // Jika sudah login, langsung ke menu utama
      Navigator.pushReplacementNamed(context, AppRoutes.mainNavigation);
    } else {
      // Jika belum, arahkan ke layar login
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withAlpha(210),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ikon logo kebugaran
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                size: 72,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            // Nama aplikasi
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            // Tagline aplikasi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                AppConstants.appTagline,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withAlpha(220),
                ),
              ),
            ),
            const SizedBox(height: 48),
            // Indikator loading
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
