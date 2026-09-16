import 'package:flutter/material.dart';
import '../../utils/calculations.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

// Layar Menu Perhitungan Umur Sadar Kalender berdasarkan Tanggal Lahir
class AgeCalculatorScreen extends StatefulWidget {
  const AgeCalculatorScreen({super.key});

  @override
  State<AgeCalculatorScreen> createState() => _AgeCalculatorScreenState();
}

class _AgeCalculatorScreenState extends State<AgeCalculatorScreen> {
  DateTime? _selectedBirthDate;
  final _dateController = TextEditingController();
  AgeResult? _ageResult;

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  // Membuka dialog pemilih tanggal lahir
  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: now, // Validasi otomatis: tidak boleh memilih tanggal di masa depan
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
        _dateController.text = AppFormatters.formatDate(picked);
      });
    }
  }

  // Menghitung umur sadar kalender
  void _calculateAge() {
    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih tanggal lahir terlebih dahulu.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final result = AppCalculations.calculateAge(_selectedBirthDate!);
      setState(() {
        _ageResult = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan perhitungan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Widget pembantu untuk merender kartu angka total waktu
  Widget _buildTimeStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
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
        title: const Text('Kalkulator Umur'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Formulir Pemilihan Tanggal Lahir
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Pilih Tanggal Lahir Anda',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tekan kolom di bawah untuk memilih tanggal dari kalender.',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 16),

                      // Input Tanggal Lahir (Read Only + Tap)
                      AppTextField(
                        controller: _dateController,
                        label: 'Tanggal Lahir',
                        hint: 'DD/MM/YYYY',
                        readOnly: true,
                        prefixIcon: Icons.cake_outlined,
                        suffixIcon: const Icon(Icons.calendar_month_rounded),
                        onTap: _pickBirthDate,
                      ),
                      const SizedBox(height: 20),

                      // Tombol Hitung Umur
                      AppButton(
                        text: 'HITUNG UMUR',
                        icon: Icons.calculate_outlined,
                        onPressed: _calculateAge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Hasil Perhitungan Umur
              if (_ageResult != null) ...[
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFEC4899), width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text(
                          'Umur Anda Saat Ini',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 14),

                        // Rincian Tahun, Bulan, Hari
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildAgeUnitCircle(
                              _ageResult!.years.toString(),
                              'Tahun',
                              const Color(0xFFEC4899),
                            ),
                            _buildAgeUnitCircle(
                              _ageResult!.months.toString(),
                              'Bulan',
                              const Color(0xFF8B5CF6),
                            ),
                            _buildAgeUnitCircle(
                              _ageResult!.days.toString(),
                              'Hari',
                              const Color(0xFF0284C7),
                            ),
                          ],
                        ),
                        const Divider(height: 32),

                        // Informasi Total Waktu Estimasi
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              const Text(
                                'Total Estimasi Waktu Hidup:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Perkiraan',
                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        _buildTimeStatCard(
                          label: 'Total Hari',
                          value: '${AppFormatters.formatNumber(_ageResult!.totalDays)} hari',
                          icon: Icons.calendar_today_rounded,
                          color: Colors.teal.shade700,
                        ),
                        const SizedBox(height: 8),

                        _buildTimeStatCard(
                          label: 'Total Jam',
                          value: '${AppFormatters.formatNumber(_ageResult!.totalHours)} jam',
                          icon: Icons.schedule_rounded,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(height: 8),

                        _buildTimeStatCard(
                          label: 'Total Menit',
                          value: '${AppFormatters.formatNumber(_ageResult!.totalMinutes)} menit',
                          icon: Icons.timelapse_rounded,
                          color: Colors.indigo.shade700,
                        ),
                        const SizedBox(height: 8),

                        _buildTimeStatCard(
                          label: 'Total Detik',
                          value: '${AppFormatters.formatNumber(_ageResult!.totalSeconds)} detik',
                          icon: Icons.alarm_rounded,
                          color: Colors.purple.shade700,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgeUnitCircle(String value, String unit, Color color) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withAlpha(20),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}
