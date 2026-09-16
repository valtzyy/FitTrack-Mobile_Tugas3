import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../constants/app_constants.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

// Layar login untuk masuk ke aplikasi FitTrack
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    // Membersihkan controller agar tidak terjadi memory leak
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Mengisi form secara otomatis dengan kredensial demo untuk mempermudah penilaian
  void _fillDemoCredentials() {
    setState(() {
      _usernameController.text = AppConstants.defaultUsername;
      _passwordController.text = AppConstants.defaultPassword;
    });
  }

  // Menangani proses pengiriman form login
  Future<void> _handleLogin() async {
    // 1. Validasi form input
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Mencegah submit berulang saat sedang proses
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.login(
        username: _usernameController.text,
        password: _passwordController.text,
      );

      // Pastikan widget masih aktif sebelum melakukan manipulasi UI/navigasi
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (result.isSuccess) {
        // Tampilkan pesan sukses singkat
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigasi ke menu utama dan hapus riwayat login agar tidak bisa di-back
        Navigator.pushReplacementNamed(context, AppRoutes.mainNavigation);
      } else {
        // Tampilkan pesan kesalahan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo dan Judul Aplikasi
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.fitness_center_rounded,
                        size: 56,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppConstants.appName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Masuk untuk mengelola kesehatan dan latihan Anda',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Kartu informasi kredensial demo untuk kemudahan penguji
                  Card(
                    color: Colors.blue.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.blue.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Akun Demo Kuliah:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                                Text(
                                  'Username: ${AppConstants.defaultUsername} | Sandi: ${AppConstants.defaultPassword}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: _fillDemoCredentials,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: const Text('Isi Otomatis', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Input Username
                  AppTextField(
                    controller: _usernameController,
                    label: 'Username atau Email',
                    hint: 'Masukkan username',
                    prefixIcon: Icons.person_outline,
                    validator: (val) => AppValidators.validateRequired(val, 'Username'),
                  ),
                  const SizedBox(height: 16),

                  // Input Password
                  AppTextField(
                    controller: _passwordController,
                    label: 'Kata Sandi',
                    hint: 'Masukkan kata sandi',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    validator: (val) => AppValidators.validatePassword(val, minLength: 4),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tombol Masuk
                  AppButton(
                    text: 'MASUK',
                    icon: Icons.login,
                    isLoading: _isLoading,
                    onPressed: _handleLogin,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
