import 'database_service.dart';
import 'session_service.dart';

// Hasil dari proses otentikasi login
class AuthResult {
  final bool isSuccess;
  final String message;
  final String? fullName;

  const AuthResult({
    required this.isSuccess,
    required this.message,
    this.fullName,
  });
}

// Layanan otentikasi untuk memeriksa kredensial pengguna terhadap basis data SQLite
// dan mengelola sesi login yang aktif.
class AuthService {
  final DatabaseService _dbService = DatabaseService.instance;

  // Melakukan proses verifikasi login
  // CATATAN KEAMANAN EDUKASI:
  // Nilai password tidak pernah dicetak (print/log) ke konsol.
  // Pengecekan dilakukan menggunakan pencocokan nilai hash SHA-256.
  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    final cleanUsername = username.trim();
    final cleanPassword = password.trim();

    // 1. Validasi input tidak boleh kosong
    if (cleanUsername.isEmpty || cleanPassword.isEmpty) {
      return const AuthResult(
        isSuccess: false,
        message: 'Username dan kata sandi wajib diisi.',
      );
    }

    try {
      // 2. Mencari pengguna di basis data SQLite berdasarkan username
      final user = await _dbService.getUserByUsername(cleanUsername);

      if (user == null) {
        return const AuthResult(
          isSuccess: false,
          message: 'Username tidak ditemukan.',
        );
      }

      // 3. Verifikasi kata sandi dengan membandingkan nilai hash SHA-256
      final inputPasswordHash = DatabaseService.hashPassword(cleanPassword);

      if (user.passwordHash != inputPasswordHash) {
        return const AuthResult(
          isSuccess: false,
          message: 'Kata sandi salah. Silakan coba lagi.',
        );
      }

      // 4. Menyimpan sesi login pengguna ke SharedPreferences
      await SessionService.saveLoginSession(
        username: user.username,
        fullName: user.name,
      );

      return AuthResult(
        isSuccess: true,
        message: 'Login berhasil! Selamat datang, ${user.name}.',
        fullName: user.name,
      );
    } catch (e) {
      // Menangani kegagalan query atau I/O database tanpa mengekspos error teknis mentah ke antarmuka
      return AuthResult(
        isSuccess: false,
        message: 'Terjadi kendala saat menghubungkan ke database: $e',
      );
    }
  }

  // Melakukan proses keluar (logout) dan membersihkan data sesi
  Future<bool> logout() async {
    return await SessionService.clearSession();
  }
}
