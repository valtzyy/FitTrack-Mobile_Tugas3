import 'package:flutter/material.dart';
import '../../utils/calculations.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_text_field.dart';

// Layar Menu 4: Konversi Kalender Hijriah & Hitung Umur
// Menggunakan 1 layar terpadu dengan 2 tombol aksi terpisah:
// 1. Tombol "KONVERSI KE HIJRIAH" (Mendukung tanggal sejarah era 1500-an s/d masa depan)
// 2. Tombol "HITUNG UMUR" (Menghitung rincian tahun, bulan, hari, jam, menit, detik)
class AgeCalculatorScreen extends StatefulWidget {
  const AgeCalculatorScreen({super.key});

  @override
  State<AgeCalculatorScreen> createState() => _AgeCalculatorScreenState();
}

class _AgeCalculatorScreenState extends State<AgeCalculatorScreen> {
  DateTime _selectedDate = DateTime.now();
  final _dateController = TextEditingController();

  HijriResult? _hijriResult;
  AgeResult? _ageResult;

  @override
  void initState() {
    super.initState();
    _dateController.text = AppFormatters.formatDate(_selectedDate);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  // Pemilih tanggal (Rentang luas: 1200 M s/d 2200 M untuk mendukung era sejarah 1500-an)
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1200), // Mendukung tanggal pahlawan/sejarah era 1500-an
      lastDate: DateTime(2200),
    );

    if (picked != null) {
      _applyDate(picked);
    }
  }

  // Terapkan tanggal terpilih ke form
  void _applyDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _dateController.text = AppFormatters.formatDate(date);
    });
  }

  // Aksi Tombol 1: Konversi ke Kalender Hijriah
  void _convertHijri() {
    try {
      final result = AppCalculations.convertToHijri(_selectedDate);
      setState(() {
        _hijriResult = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kendala konversi Hijriah: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Aksi Tombol 2: Hitung Umur Detail
  void _calculateAge() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    if (target.isAfter(today)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perhitungan umur hanya untuk tanggal lahir di masa lalu atau hari ini.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final result = AppCalculations.calculateAge(_selectedDate);
      setState(() {
        _ageResult = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan perhitungan umur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Widget baris informasi detail
  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
    Color? iconColor,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor ?? Colors.grey.shade600),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor ?? const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  // Widget kartu total estimasi waktu
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

  // Widget lingkaran satuan umur
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
                fontSize: 22,
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konversi Hijriah & Umur'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Kartu Pemilihan Tanggal & Tombol Aksi
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Pilih Tanggal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Pilih tanggal untuk konversi kalender Hijriah atau perhitungan umur.',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 16),

                      // Input Tanggal
                      AppTextField(
                        controller: _dateController,
                        label: 'Tanggal Masehi / Tanggal Lahir',
                        hint: 'DD/MM/YYYY',
                        readOnly: true,
                        prefixIcon: Icons.calendar_month_rounded,
                        suffixIcon: const Icon(Icons.event_available_rounded),
                        onTap: _pickDate,
                      ),
                      const SizedBox(height: 18),

                      // DUA TOMBOL AKSI TERPISAH
                      // Tombol 1: Konversi ke Hijriah
                      ElevatedButton.icon(
                        onPressed: _convertHijri,
                        icon: const Icon(Icons.nights_stay_rounded),
                        label: const Text(
                          'KONVERSI KE HIJRIAH',
                          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F766E),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(46),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Tombol 2: Hitung Umur
                      ElevatedButton.icon(
                        onPressed: _calculateAge,
                        icon: const Icon(Icons.cake_rounded),
                        label: const Text(
                          'HITUNG UMUR',
                          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEC4899),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(46),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 2. Kartu Hasil Konversi Kalender Hijriah
              if (_hijriResult != null) ...[
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFF0F766E), width: 1.8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F766E).withAlpha(30),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.nights_stay_rounded,
                                color: Color(0xFF0F766E),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hasil Konversi Kalender Hijriah',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'Penanggalan Komariah / Islam',
                                    style: TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Highlight Banner Tanggal Hijriah
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F766E), Color(0xFF115E59)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _hijriResult!.fullDateHijri,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Hari ${_hijriResult!.dayName}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withAlpha(220),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        _buildInfoRow(
                          label: 'Tanggal Masehi',
                          value: AppFormatters.formatDateFull(_hijriResult!.gregorianDate),
                          icon: Icons.calendar_today_rounded,
                        ),
                        _buildInfoRow(
                          label: 'Hari',
                          value: _hijriResult!.dayName,
                          icon: Icons.today_rounded,
                        ),
                        _buildInfoRow(
                          label: 'Tanggal Hijriah',
                          value: '${_hijriResult!.hDay}',
                          icon: Icons.tag_rounded,
                          valueColor: const Color(0xFF0F766E),
                        ),
                        _buildInfoRow(
                          label: 'Bulan Hijriah',
                          value: '${_hijriResult!.monthNameIndo} (Bulan ke-${_hijriResult!.hMonth})',
                          icon: Icons.brightness_medium_rounded,
                          valueColor: const Color(0xFF0F766E),
                        ),
                        _buildInfoRow(
                          label: 'Tahun Hijriah',
                          value: '${_hijriResult!.hYear} H / AH',
                          icon: Icons.auto_awesome_rounded,
                          valueColor: const Color(0xFF0F766E),
                        ),
                        const Divider(height: 20),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline_rounded, size: 16, color: Colors.teal.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _hijriResult!.islamicNotes,
                                style: TextStyle(
                                  fontSize: 11,
                                  height: 1.4,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // 3. Kartu Hasil Perhitungan Umur
              if (_ageResult != null) ...[
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFEC4899), width: 1.8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEC4899).withAlpha(30),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.cake_rounded,
                                color: Color(0xFFEC4899),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Rincian Umur Sadar Kalender',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'Perhitungan presisi tahun, bulan, hari, jam, menit, detik',
                                    style: TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

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
                        const Divider(height: 30),

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
}
