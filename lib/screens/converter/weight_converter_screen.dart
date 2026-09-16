import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../utils/calculations.dart';
import '../../utils/formatters.dart';
import '../../utils/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

// Layar Menu Konversi Satuan Berat (kg, gram, pound, ounce)
class WeightConverterScreen extends StatefulWidget {
  const WeightConverterScreen({super.key});

  @override
  State<WeightConverterScreen> createState() => _WeightConverterScreenState();
}

class _WeightConverterScreenState extends State<WeightConverterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();

  String _fromUnit = AppConstants.unitKg;
  String _toUnit = AppConstants.unitGram;

  double? _convertedResult;
  String? _resultText;

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  // Melakukan konversi nilai berat
  void _convert() {
    if (!_formKey.currentState!.validate()) return;

    final value = double.tryParse(_valueController.text.trim().replaceAll(',', '.')) ?? 0;

    try {
      final result = AppCalculations.convertWeight(value, _fromUnit, _toUnit);
      setState(() {
        _convertedResult = result;
        _resultText =
            '${AppFormatters.formatDecimal(value, fractionDigits: 3)} $_fromUnit = '
            '${AppFormatters.formatDecimal(result, fractionDigits: 3)} $_toUnit';
      });
      FocusScope.of(context).unfocus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan konversi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Menukar satuan asal dan satuan tujuan
  void _swapUnits() {
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
      _convertedResult = null;
      _resultText = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konversi Satuan Berat'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                          'Pilih Satuan & Masukkan Nilai',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Input Nilai Berat
                        AppTextField(
                          controller: _valueController,
                          label: 'Nilai Berat',
                          hint: 'Contoh: 70',
                          prefixIcon: Icons.scale_rounded,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (val) => AppValidators.validateNumber(
                            val,
                            'Nilai berat',
                            allowZero: true,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Dropdown Satuan Asal
                        DropdownButtonFormField<String>(
                          key: ValueKey('from_$_fromUnit'),
                          initialValue: _fromUnit,
                          decoration: InputDecoration(
                            labelText: 'Dari Satuan',
                            prefixIcon: const Icon(Icons.logout_rounded, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: AppConstants.weightUnits
                              .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _fromUnit = val);
                          },
                        ),
                        const SizedBox(height: 8),

                        // Tombol Tukar Satuan
                        Center(
                          child: IconButton.filledTonal(
                            icon: const Icon(Icons.swap_vert_rounded),
                            tooltip: 'Tukar Satuan',
                            onPressed: _swapUnits,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Dropdown Satuan Tujuan
                        DropdownButtonFormField<String>(
                          key: ValueKey('to_$_toUnit'),
                          initialValue: _toUnit,
                          decoration: InputDecoration(
                            labelText: 'Ke Satuan',
                            prefixIcon: const Icon(Icons.login_rounded, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: AppConstants.weightUnits
                              .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _toUnit = val);
                          },
                        ),
                        const SizedBox(height: 24),

                        // Tombol Eksekusi Konversi
                        AppButton(
                          text: 'KONVERSI',
                          icon: Icons.transform_rounded,
                          onPressed: _convert,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Kartu Hasil Konversi
              if (_convertedResult != null) ...[
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text(
                          'Hasil Konversi',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppFormatters.formatDecimal(_convertedResult!, fractionDigits: 4),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B5CF6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _toUnit,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const Divider(height: 24),
                        Text(
                          _resultText ?? '',
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
              ],
            ],
          ),
        ),
      ),
    );
  }
}
