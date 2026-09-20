import 'package:flutter/material.dart';
import '../../utils/calculations.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

// Layar Menu Konversi Kalender Weton Jawa ke Kalender Saka Bali & Pawukon
class WetonSakaScreen extends StatefulWidget {
  const WetonSakaScreen({super.key});

  @override
  State<WetonSakaScreen> createState() => _WetonSakaScreenState();
}

class _WetonSakaScreenState extends State<WetonSakaScreen> {
  DateTime _selectedDate = DateTime.now();
  final _dateController = TextEditingController();
  WetonSakaResult? _conversionResult;

  @override
  void initState() {
    super.initState();
    _dateController.text = AppFormatters.formatDate(_selectedDate);
    // Jalankan konversi awal untuk tanggal hari ini
    _conversionResult = AppCalculations.calculateWetonAndSaka(_selectedDate);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  // Dialog pemilih tanggal Gregorian
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = AppFormatters.formatDate(picked);
      });
    }
  }

  // Melakukan konversi tanggal ke Weton dan Kalender Saka Bali
  void _convertDate() {
    try {
      final result = AppCalculations.calculateWetonAndSaka(_selectedDate);
      setState(() {
        _conversionResult = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan konversi: $e'),
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
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weton & Saka Bali'),
      ),
      body: SafeArea(
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
                        'Pilih Tanggal Gregorian',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Pilih tanggal Masehi yang ingin dikonversi ke Weton dan Saka Bali.',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 16),

                      AppTextField(
                        controller: _dateController,
                        label: 'Tanggal Gregorian',
                        hint: 'DD/MM/YYYY',
                        readOnly: true,
                        prefixIcon: Icons.calendar_month_outlined,
                        suffixIcon: const Icon(Icons.event_note_rounded),
                        onTap: _pickDate,
                      ),
                      const SizedBox(height: 18),

                      AppButton(
                        text: 'KONVERSI',
                        icon: Icons.sync_rounded,
                        onPressed: _convertDate,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Kartu Hasil Konversi
              if (_conversionResult != null) ...[
                // 1. Kartu Weton Jawa
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFEAB308), width: 1.5),
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
                                color: Colors.amber.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Hasil Weton Jawa',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(height: 20),

                        _buildInfoRow(
                          label: 'Tanggal Masehi',
                          value: AppFormatters.formatDateFull(_conversionResult!.gregorianDate),
                          icon: Icons.calendar_today_rounded,
                        ),
                        _buildInfoRow(
                          label: 'Hari Masehi',
                          value: _conversionResult!.gregorianDayName,
                          icon: Icons.today_rounded,
                        ),
                        _buildInfoRow(
                          label: 'Pasaran Jawa',
                          value: _conversionResult!.javanesePasaran,
                          icon: Icons.storefront_rounded,
                        ),
                        _buildInfoRow(
                          label: 'Weton Lengkap',
                          value: _conversionResult!.wetonFull,
                          icon: Icons.auto_awesome_rounded,
                          valueColor: Colors.amber.shade900,
                        ),
                        _buildInfoRow(
                          label: 'Neptu Hari + Pasaran',
                          value:
                              '${_conversionResult!.neptuDay} + ${_conversionResult!.neptuPasaran} = ${_conversionResult!.totalNeptu}',
                          icon: Icons.tag_rounded,
                          valueColor: const Color(0xFF0F766E),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Kartu Kalender Tradisional Saka Bali & Pawukon
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
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
                              child: const Icon(Icons.temple_hindu_rounded,
                                  color: Color(0xFF0F766E), size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Informasi Kalender Saka Bali',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(height: 20),

                        _buildInfoRow(
                          label: 'Sapta Wara (Bali)',
                          value: _conversionResult!.balineseSaptaWara,
                          icon: Icons.view_week_rounded,
                        ),
                        _buildInfoRow(
                          label: 'Panca Wara (Bali)',
                          value: _conversionResult!.balinesePancaWara,
                          icon: Icons.filter_5_rounded,
                        ),
                        _buildInfoRow(
                          label: 'Wuku Pawukon',
                          value: _conversionResult!.balineseWuku,
                          icon: Icons.account_tree_rounded,
                          valueColor: const Color(0xFF0F766E),
                        ),
                        _buildInfoRow(
                          label: 'Hari ke- (Siklus 210 Hari)',
                          value: 'Hari ke-${_conversionResult!.pawukonDay} dari 210',
                          icon: Icons.repeat_rounded,
                        ),
                        _buildInfoRow(
                          label: 'Estimasi Tahun Saka',
                          value: '${_conversionResult!.approximateSakaYear} Saka',
                          icon: Icons.history_edu_rounded,
                          valueColor: Colors.deepPurple,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Catatan Akademik & Batasan Referensi
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.menu_book_rounded, color: Colors.grey.shade700, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _conversionResult!.academicNotes,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
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
