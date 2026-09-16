import 'package:flutter/material.dart';
import 'app/app.dart';
import 'services/database_service.dart';

// Titik masuk utama (Main Entry Point) aplikasi FitTrack
void main() async {
  // Memastikan sistem binding Flutter siap sebelum inisialisasi asynchronous
  WidgetsFlutterBinding.ensureInitialized();

  // Membuka dan menyiapkan basis data lokal SQLite beserta data seed awal
  try {
    await DatabaseService.instance.database;
  } catch (e) {
    // Jika ada kendala inisialisasi basis data awal, aplikasi tetap berjalan
    // dan error akan ditangani secara elegan pada masing-masing layar
    debugPrint('Pemberitahuan inisialisasi basis data: $e');
  }

  // Menjalankan aplikasi FitTrack
  runApp(const FitTrackApp());
}
