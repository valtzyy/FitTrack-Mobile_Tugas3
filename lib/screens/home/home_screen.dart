import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../constants/app_constants.dart';
import '../../services/session_service.dart';

// Layar utama (Home Screen) yang memuat salam personal dan 6 kartu menu fungsional vertikal
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userFullName = 'Pengguna';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // Mengambil nama pengguna yang sedang aktif dari sesi lokal
  Future<void> _loadUserInfo() async {
    final fullName = await SessionService.getCurrentUserFullName();
    if (mounted) {
      setState(() {
        _userFullName = fullName;
      });
    }
  }

  // Menampilkan dialog konfirmasi keluar (Logout) sederhana
  Future<void> _showLogoutDialog() async {
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

    if (confirmed == true && mounted) {
      // 1. Hapus sesi login pengguna di SharedPreferences
      await SessionService.clearSession();

      if (!mounted) return;

      // 2. Navigasi kembali ke halaman Login dan hapus seluruh tumpukan halaman
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  // Widget pembantu untuk merender kartu menu vertikal yang konsisten
  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              // Wadah Ikon Berwarna
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              // Teks Judul dan Deskripsi Menu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Ikon Panah Kanan
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          // Tombol logout praktis di AppBar beranda
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar (Logout)',
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bagian Salam dan Deskripsi
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withAlpha(200),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withAlpha(40),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.waving_hand_rounded, color: Colors.amber, size: 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Halo, $_userFullName!',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Tombol logout cepat di samping nama
                        IconButton(
                          icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 20),
                          tooltip: 'Logout',
                          onPressed: _showLogoutDialog,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Kelola aktivitas kebugaran Anda dengan mudah.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withAlpha(220),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Judul Bagian Menu
              const Text(
                'Menu Utama',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),

              // 1. Menu Daftar Anggota
              _buildMenuCard(
                title: 'Daftar Anggota',
                subtitle: 'Melihat dan mengelola anggota kelompok/pengguna',
                icon: Icons.groups_rounded,
                color: const Color(0xFF0284C7),
                onTap: () => Navigator.pushNamed(context, AppRoutes.members),
              ),

              // 2. Menu Komputasi Tema: Kalkulator BMI
              _buildMenuCard(
                title: 'Kalkulator BMI',
                subtitle: 'Hitung Indeks Massa Tubuh & ketahui status berat ideal',
                icon: Icons.monitor_weight_rounded,
                color: const Color(0xFF10B981),
                onTap: () => Navigator.pushNamed(context, AppRoutes.bmi),
              ),

              // 3. Menu CRUD Tema: Manajemen Latihan
              _buildMenuCard(
                title: 'Catatan Latihan Fisik',
                subtitle: 'Tambah, lihat, edit, dan hapus riwayat workout',
                icon: Icons.fitness_center_rounded,
                color: const Color(0xFFF97316),
                onTap: () => Navigator.pushNamed(context, AppRoutes.workouts),
              ),

              // 4. Menu Konversi Tema: Konversi Berat
              _buildMenuCard(
                title: 'Konversi Satuan Berat',
                subtitle: 'Konversi antara kg, gram, pound (lbs), dan ounce (oz)',
                icon: Icons.swap_horiz_rounded,
                color: const Color(0xFF8B5CF6),
                onTap: () => Navigator.pushNamed(context, AppRoutes.converter),
              ),

              // 5. Menu Konversi Tanggal Hijriah & Perhitungan Umur
              _buildMenuCard(
                title: 'Konversi Hijriah & Umur',
                subtitle: 'Konversi tanggal ke kalender Hijriah & hitung umur detail',
                icon: Icons.nights_stay_rounded,
                color: const Color(0xFF0F766E),
                onTap: () => Navigator.pushNamed(context, AppRoutes.age),
              ),

              // 6. Menu Konversi Kalender Weton ke Saka Bali
              _buildMenuCard(
                title: 'Weton → Kalender Saka Bali',
                subtitle: 'Konversi tanggal ke Pasaran Jawa, Neptu, dan Pawukon Bali',
                icon: Icons.calendar_month_rounded,
                color: const Color(0xFFEAB308),
                onTap: () => Navigator.pushNamed(context, AppRoutes.calendar),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
