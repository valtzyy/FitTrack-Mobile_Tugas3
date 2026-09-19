import 'package:flutter/material.dart';
import '../../utils/calculations.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

// Layar Menu 4: Konversi Kalender Hijriah & Kalkulator Umur Sadar Kalender
// Menggunakan 2 Tab terpisah:
// 1. Tab Konversi Hijriah (mendukung tanggal sejarah era 1500-an s/d 2200 M)
// 2. Tab Kalkulator Umur (menghitung rincian tahun, bulan, hari, jam, menit, detik)
class AgeCalculatorScreen extends StatefulWidget {
  const AgeCalculatorScreen({super.key});

  @override
  State<AgeCalculatorScreen> createState() => _AgeCalculatorScreenState();
}

class _AgeCalculatorScreenState extends State<AgeCalculatorScreen> {
  // State untuk Tab 1: Konversi Hijriah
  DateTime _hijriSelectedDate = DateTime.now();
  final _hijriDateController = TextEditingController();
  HijriResult? _hijriResult;

  // State untuk Tab 2: Kalkulator Umur
  DateTime? _ageSelectedDate;
  final _ageDateController = TextEditingController();
  AgeResult? _ageResult;

  @override
  void initState() {
    super.initState();
    // Default Tab 1 terisi tanggal hari ini
    _hijriDateController.text = AppFormatters.formatDate(_hijriSelectedDate);
    _hijriResult = AppCalculations.convertToHijri(_hijriSelectedDate);
  }

  @override
  void dispose() {
    _hijriDateController.dispose();
    _ageDateController.dispose();
    super.dispose();
  }

  // Pemilih tanggal untuk Tab Konversi Hijriah (Rentang luas: 1200 M s/d 2200 M)
  Future<void> _pickHijriDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _hijriSelectedDate,
      firstDate: DateTime(1200), // Mendukung tanggal sejarah era 1500-an
      lastDate: DateTime(2200),
    );

    if (picked != null) {
      _applyHijriDate(picked);
    }
  }

  // Terapkan tanggal konversi Hijriah dan langsung hitung
  void _applyHijriDate(DateTime date) {
    setState(() {
      _hijriSelectedDate = date;
      _hijriDateController.text = AppFormatters.formatDate(date);
      _hijriResult = AppCalculations.convertToHijri(date);
    });
  }

  // Pemilih tanggal untuk Tab Kalkulator Umur (Rentang 1200 M s/d Hari Ini)
  Future<void> _pickAgeDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _ageSelectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1200), // Mendukung pengujian usia tokoh/pahlawan sejarah
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _ageSelectedDate = picked;
        _ageDateController.text = AppFormatters.formatDate(picked);
      });
    }
  }

  // Menghitung umur
  void _calculateAge() {
    if (_ageSelectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih tanggal lahir terlebih dahulu.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final result = AppCalculations.calculateAge(_ageSelectedDate!);
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

  // Chip pintasan tanggal sejarah untuk pengujian cepat saat demo
  Widget _buildQuickDateChip(String label, DateTime date) {
    final isSelected = _hijriSelectedDate.year == date.year &&
        _hijriSelectedDate.month == date.month &&
        _hijriSelectedDate.day == date.day;

    return ActionChip(
      avatar: Icon(
        Icons.history_rounded,
        size: 16,
        color: isSelected ? Colors.white : const Color(0xFF0F766E),
      ),
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 11.5,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.white : const Color(0xFF0F766E),
      ),
      backgroundColor: isSelected ? const Color(0xFF0F766E) : const Color(0xFF0F766E).withAlpha(20),
      side: BorderSide(
        color: isSelected ? const Color(0xFF0F766E) : const Color(0xFF0F766E).withAlpha(50),
      ),
      onPressed: () => _applyHijriDate(date),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hijriah & Umur'),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.nights_stay_rounded),
                text: 'Konversi Hijriah',
              ),
              Tab(
                icon: Icon(Icons.cake_rounded),
                text: 'Kalkulator Umur',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // =================================================================
            // TAB 1: KONVERSI KALENDER HIJRIAH
            // =================================================================
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Formulir Pemilihan Tanggal
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Pilih Tanggal Masehi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Mendukung penanggalan sejarah tokoh/pahlawan (mulai tahun 1200 M) hingga masa depan.',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 16),

                            AppTextField(
                              controller: _hijriDateController,
                              label: 'Tanggal Masehi',
                              hint: 'DD/MM/YYYY',
                              readOnly: true,
                              prefixIcon: Icons.calendar_month_rounded,
                              suffixIcon: const Icon(Icons.event_note_rounded),
                              onTap: _pickHijriDate,
                            ),
                            const SizedBox(height: 14),

                            // Pintasan Tanggal Sejarah / Uji Dosen
                            const Text(
                              'Pintasan Uji Coba Cepat:',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _buildQuickDateChip('1 Jan 1500 (Era Pahlawan)', DateTime(1500, 1, 1)),
                                _buildQuickDateChip('22 Jun 1527 (Fatahillah)', DateTime(1527, 6, 22)),
                                _buildQuickDateChip('17 Ags 1945 (Proklamasi)', DateTime(1945, 8, 17)),
                                _buildQuickDateChip('Hari Ini', DateTime.now()),
                              ],
                            ),
                            const SizedBox(height: 16),

                            AppButton(
                              text: 'KONVERSI KE HIJRIAH',
                              icon: Icons.sync_rounded,
                              onPressed: () => _applyHijriDate(_hijriSelectedDate),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Kartu Hasil Konversi Kalender Hijriah
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
                                          'Hasil Kalender Hijriah',
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

                              // Banner Highlight Tanggal Hijriah
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

                              // Catatan Edukatif
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
                    ],
                  ],
                ),
              ),
            ),

            // =================================================================
            // TAB 2: KALKULATOR UMUR DETAIL
            // =================================================================
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Formulir Tanggal Lahir
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
                              'Tekan kolom di bawah untuk memilih tanggal lahir dari kalender.',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 16),

                            AppTextField(
                              controller: _ageDateController,
                              label: 'Tanggal Lahir',
                              hint: 'DD/MM/YYYY',
                              readOnly: true,
                              prefixIcon: Icons.cake_outlined,
                              suffixIcon: const Icon(Icons.calendar_month_rounded),
                              onTap: _pickAgeDate,
                            ),
                            const SizedBox(height: 20),

                            AppButton(
                              text: 'HITUNG UMUR LENGKAP',
                              icon: Icons.calculate_outlined,
                              onPressed: _calculateAge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Kartu Hasil Perhitungan Umur
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
          ],
        ),
      ),
    );
  }
}
