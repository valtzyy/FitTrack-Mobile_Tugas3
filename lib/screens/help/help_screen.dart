import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../constants/app_constants.dart';
import '../../services/session_service.dart';

// Layar Bantuan, Tutorial Penggunaan, Informasi Aplikasi, serta Tombol Keluar (Logout)
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  // Menampilkan dialog konfirmasi sebelum keluar (Logout)
  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Konfirmasi Keluar'),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi FitTrack?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // 1. Bersihkan sesi pengguna di SharedPreferences
      await SessionService.clearSession();

      if (!context.mounted) return;

      // 2. Navigasi kembali ke Login dan hapus seluruh tumpukan halaman sebelumnya
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  // Widget pembantu untuk item panduan/tutorial dalam bentuk ExpansionTile
  Widget _buildHelpItem({
    required String number,
    required String title,
    required String content,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          radius: 14,
          backgroundColor: const Color(0xFF0F766E).withAlpha(30),
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F766E),
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              content,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bantuan & Informasi'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kartu Informasi Aplikasi
              Card(
                color: const Color(0xFF0F766E).withAlpha(15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFF0F766E), width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.health_and_safety_rounded,
                        size: 40,
                        color: Color(0xFF0F766E),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              AppConstants.appName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F766E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppConstants.appTagline,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Versi ${AppConstants.appVersion} • Tugas Pemrograman Aplikasi Mobile',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Judul Bagian Tutorial
              const Text(
                'Tutorial & Petunjuk Penggunaan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),

              // 10 Poin Tutorial Penggunaan
              _buildHelpItem(
                number: '1',
                title: 'Tentang FitTrack',
                content:
                    'FitTrack adalah aplikasi sederhana untuk mencatat aktivitas kebugaran, menghitung metrik kesehatan (BMI), konversi satuan, perhitungan umur, serta kalender Weton dan Saka Bali.',
              ),
              _buildHelpItem(
                number: '2',
                title: 'Cara Login',
                content:
                    'Masukkan username dan password pada form login. Untuk keperluan demo presentasi, gunakan akun bawaan: username "admin" dan password "admin123". Sesi login Anda akan tersimpan otomatis.',
              ),
              _buildHelpItem(
                number: '3',
                title: 'Cara Menggunakan Kalkulator BMI',
                content:
                    'Buka menu "Kalkulator BMI" dari Beranda. Masukkan berat badan (kg) dan tinggi badan (cm), lalu tekan tombol "HITUNG BMI" untuk melihat nilai dan kategori berat badan Anda.',
              ),
              _buildHelpItem(
                number: '4',
                title: 'Cara Menambah Catatan Latihan',
                content:
                    'Buka menu "Catatan Latihan Fisik" dari Beranda, lalu tekan tombol bulat tanda tambah (+) di pojok kanan bawah. Lengkapi nama latihan, durasi (menit), estimasi kalori, tanggal, dan catatan, lalu tekan "Simpan".',
              ),
              _buildHelpItem(
                number: '5',
                title: 'Cara Mengedit Catatan Latihan',
                content:
                    'Pada daftar riwayat latihan, tekan ikon pensil pada kartu latihan yang ingin diubah. Ubah data yang diinginkan, kemudian tekan tombol "Simpan Perubahan".',
              ),
              _buildHelpItem(
                number: '6',
                title: 'Cara Menghapus Catatan Latihan',
                content:
                    'Tekan ikon tempat sampah pada kartu latihan yang ingin dihapus. Konfirmasikan penghapusan pada kotak dialog. Data akan langsung terhapus dari basis data SQLite.',
              ),
              _buildHelpItem(
                number: '7',
                title: 'Cara Menggunakan Konversi Berat',
                content:
                    'Akses fitur konversi berat melalui tombol ikon di pojok kanan atas halaman Kalkulator BMI. Masukkan angka, pilih satuan (kg, gram, pound/lbs, atau ounce/oz), lalu tekan tombol "KONVERSI".',
              ),
              _buildHelpItem(
                number: '8',
                title: 'Cara Konversi Hijriah & Hitung Umur',
                content:
                    'Buka menu "Konversi Hijriah & Umur" dari Beranda. Pilih tanggal lahir atau tanggal Masehi yang diinginkan, lalu tekan tombol "HITUNG UMUR & KONVERSI HIJRIAH" untuk melihat rincian tanggal kalender Hijriah (Umm al-Qura) dan rincian umur sadar kalender dalam tahun, bulan, hari, jam, menit, dan detik.',
              ),
              _buildHelpItem(
                number: '9',
                title: 'Cara Menggunakan Stopwatch',
                content:
                    'Akses tab "Stopwatch" pada navigasi bawah. Tekan tombol hijau (Play) untuk mulai, tombol kuning (Pause) untuk jeda, dan tombol reset untuk mengembalikan ke nol.',
              ),
              _buildHelpItem(
                number: '10',
                title: 'Cara Keluar (Logout)',
                content:
                    'Tekan tombol "KELUAR DARI APLIKASI" berwarna merah di bagian bawah halaman Bantuan ini. Konfirmasikan dialog untuk mengakhiri sesi login.',
              ),
              const SizedBox(height: 24),

              // Tombol Logout
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text(
                    'KELUAR DARI APLIKASI (LOGOUT)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
