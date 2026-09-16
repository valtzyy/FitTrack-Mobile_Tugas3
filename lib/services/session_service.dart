import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

// Layanan untuk mengelola sesi login pengguna menggunakan SharedPreferences.
// Menyimpan informasi apakah pengguna sedang aktif login agar saat aplikasi ditutup
// dan dibuka kembali, pengguna tidak perlu mengetikkan sandi lagi.
class SessionService {
  // Menyimpan sesi login pengguna setelah verifikasi berhasil
  static Future<bool> saveLoginSession({
    required String username,
    required String fullName,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsLoggedIn, true);
      await prefs.setString(AppConstants.keyUsername, username);
      await prefs.setString(AppConstants.keyUserFullName, fullName);
      return true;
    } catch (_) {
      // Jika terjadi kesalahan pada I/O storage, kembalikan false
      return false;
    }
  }

  // Memeriksa apakah ada sesi login yang masih aktif
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
    } catch (_) {
      return false;
    }
  }

  // Mengambil informasi nama lengkap pengguna yang sedang aktif login
  static Future<String> getCurrentUserFullName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConstants.keyUserFullName) ?? 'Pengguna FitTrack';
    } catch (_) {
      return 'Pengguna FitTrack';
    }
  }

  // Mengambil username pengguna yang sedang aktif login
  static Future<String?> getCurrentUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConstants.keyUsername);
    } catch (_) {
      return null;
    }
  }

  // Menghapus sesi login saat pengguna melakukan logout
  static Future<bool> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyIsLoggedIn);
      await prefs.remove(AppConstants.keyUsername);
      await prefs.remove(AppConstants.keyUserFullName);
      return true;
    } catch (_) {
      return false;
    }
  }
}
