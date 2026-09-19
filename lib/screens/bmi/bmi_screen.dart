import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../constants/app_constants.dart';
import '../../utils/calculations.dart';
import '../../utils/formatters.dart';
import '../../utils/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

// Layar Menu Komputasi Tema: Kalkulator Indeks Massa Tubuh (BMI)
class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  BmiResult? _bmiResult;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  // Menjalankan kalkulasi BMI berdasarkan input berat dan tinggi
  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final weight = double.tryParse(_weightController.text.trim().replaceAll(',', '.')) ?? 0;
    final height = double.tryParse(_heightController.text.trim().replaceAll(',', '.')) ?? 0;

    try {
      final result = AppCalculations.calculateBmi(weight, height);
      setState(() {
        _bmiResult = result;
      });
      // Tutup keyboard
      FocusScope.of(context).unfocus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan kalkulasi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Mengatur ulang input dan hasil kalkulasi
  void _reset() {
    setState(() {
      _weightController.clear();
      _heightController.clear();
      _bmiResult = null;
    });
  }

  // Mendapatkan warna indikator berdasarkan kategori BMI
  Color _getCategoryColor(String category) {
    switch (category) {
      case AppConstants.bmiUnderweight:
        return Colors.orange.shade700;
      case AppConstants.bmiNormal:
        return Colors.green.shade700;
      case AppConstants.bmiOverweight:
        return Colors.amber.shade800;
      case AppConstants.bmiObese:
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator BMI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded),
            tooltip: 'Konversi Satuan Berat (lbs/oz)',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.converter),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner Disclaimer Medis Wajib
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber.shade900, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppConstants.bmiDisclaimer,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Formulir Input Berat dan Tinggi
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Masukkan Data Tubuh',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Input Berat Badan (kg)
                        AppTextField(
                          controller: _weightController,
                          label: 'Berat Badan (kg)',
                          hint: 'Contoh: 70',
                          prefixIcon: Icons.monitor_weight_outlined,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (val) => AppValidators.validateNumber(val, 'Berat badan'),
                        ),
                        const SizedBox(height: 14),

                        // Input Tinggi Badan (cm)
                        AppTextField(
                          controller: _heightController,
                          label: 'Tinggi Badan (cm)',
                          hint: 'Contoh: 170',
                          prefixIcon: Icons.height_rounded,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (val) => AppValidators.validateNumber(val, 'Tinggi badan'),
                        ),
                        const SizedBox(height: 20),

                        // Tombol Hitung BMI
                        AppButton(
                          text: 'HITUNG BMI',
                          icon: Icons.calculate_outlined,
                          onPressed: _calculate,
                        ),

                        if (_bmiResult != null) ...[
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _reset,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Reset Perhitungan'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Kartu Hasil Perhitungan BMI
              if (_bmiResult != null) ...[
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: _getCategoryColor(_bmiResult!.category),
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text(
                          'Skor Indeks Massa Tubuh Anda',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppFormatters.formatDecimal(_bmiResult!.bmiValue),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: _getCategoryColor(_bmiResult!.category),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(_bmiResult!.category).withAlpha(25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _bmiResult!.category,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _getCategoryColor(_bmiResult!.category),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _bmiResult!.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tabel Klasifikasi Rujukan BMI
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rujukan Kategori BMI Edukasi:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        _buildCategoryRow('Kurang dari 18.5', AppConstants.bmiUnderweight, Colors.orange.shade700),
                        _buildCategoryRow('18.5 – 24.9', AppConstants.bmiNormal, Colors.green.shade700),
                        _buildCategoryRow('25.0 – 29.9', AppConstants.bmiOverweight, Colors.amber.shade800),
                        _buildCategoryRow('30.0 atau lebih', AppConstants.bmiObese, Colors.red.shade700),
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

  Widget _buildCategoryRow(String range, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 8),
          Text(range, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
