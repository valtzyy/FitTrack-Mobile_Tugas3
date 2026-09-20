import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../constants/app_constants.dart';
import '../../services/session_service.dart';

// Layar utama (Home Screen) yang memuat salam personal dan 5 kartu menu vertikal terpusat di tengah layar
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
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              // Wadah Ikon Berwarna
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              // Teks Judul dan Deskripsi Menu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Ikon Panah Kanan
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Salam Personal Ringkas
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withAlpha(200),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withAlpha(35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.waving_hand_rounded, color: Colors.amber, size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Halo, $_userFullName!',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Pilih salah satu dari 5 menu utama di bawah:',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withAlpha(220),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 20),
                            tooltip: 'Logout',
                            onPressed: _showLogoutDialog,
                          ),
                        ],
                      ),
                    ),

                    // 1. Menu Daftar Anggota
                    _buildMenuCard(
                      title: 'Daftar Anggota',
                      subtitle: 'Daftar anggota kelompok pengembang & pengguna',
                      icon: Icons.groups_rounded,
                      color: const Color(0xFF0284C7),
                      onTap: () => Navigator.pushNamed(context, AppRoutes.members),
                    ),

                    // 2. Menu Komputasi Tema: Kalkulator BMI
                    _buildMenuCard(
                      title: 'Kalkulator BMI',
                      subtitle: 'Hitung Indeks Massa Tubuh & ketahui berat ideal',
                      icon: Icons.monitor_weight_rounded,
                      color: const Color(0xFF10B981),
                      onTap: () => Navigator.pushNamed(context, AppRoutes.bmi),
                    ),

                    // 3. Menu CRUD Tema: Catatan Latihan Fisik
                    _buildMenuCard(
                      title: 'Catatan Latihan Fisik',
                      subtitle: 'Kelola aktivitas workout (tambah, lihat, ubah, hapus)',
                      icon: Icons.fitness_center_rounded,
                      color: const Color(0xFFF97316),
                      onTap: () => Navigator.pushNamed(context, AppRoutes.workouts),
                    ),

                    // 4. Menu Konversi Hijriah & Umur Detail
                    _buildMenuCard(
                      title: 'Konversi Hijriah & Umur',
                      subtitle: 'Konversi kalender Hijriah & hitung umur detail',
                      icon: Icons.nights_stay_rounded,
                      color: const Color(0xFF0F766E),
                      onTap: () => Navigator.pushNamed(context, AppRoutes.age),
                    ),

                    // 5. Menu Konversi Kalender Weton & Saka Bali
                    _buildMenuCard(
                      title: 'Weton & Kalender Saka Bali',
                      subtitle: 'Konversi tanggal ke Pasaran Jawa, Neptu, & Pawukon Bali',
                      icon: Icons.calendar_month_rounded,
                      color: const Color(0xFFEAB308),
                      onTap: () => Navigator.pushNamed(context, AppRoutes.calendar),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
