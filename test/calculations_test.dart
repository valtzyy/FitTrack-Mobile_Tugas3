import 'package:flutter_test/flutter_test.dart';
import 'package:tugas3/constants/app_constants.dart';
import 'package:tugas3/utils/calculations.dart';
import 'package:tugas3/utils/validators.dart';

void main() {
  group('1. Pengujian Kalkulator BMI (AppCalculations.calculateBmi)', () {
    test('Kalkulasi BMI normal dengan berat 70 kg dan tinggi 170 cm', () {
      final result = AppCalculations.calculateBmi(70, 170);

      expect(result.bmiValue, closeTo(24.22, 0.05));
      expect(result.category, AppConstants.bmiNormal);
    });

    test('Kalkulasi BMI kategori berat badan kurang (< 18.5)', () {
      final result = AppCalculations.calculateBmi(45, 170);

      expect(result.bmiValue, lessThan(18.5));
      expect(result.category, AppConstants.bmiUnderweight);
    });

    test('Kalkulasi BMI kategori kelebihan berat badan (25.0 - 29.9)', () {
      final result = AppCalculations.calculateBmi(80, 170);

      expect(result.bmiValue, greaterThanOrEqualTo(25.0));
      expect(result.bmiValue, lessThan(30.0));
      expect(result.category, AppConstants.bmiOverweight);
    });

    test('Kalkulasi BMI kategori obesitas (>= 30.0)', () {
      final result = AppCalculations.calculateBmi(100, 170);

      expect(result.bmiValue, greaterThanOrEqualTo(30.0));
      expect(result.category, AppConstants.bmiObese);
    });

    test('Menolak nilai berat atau tinggi nol dan negatif dengan melempar ArgumentError', () {
      expect(() => AppCalculations.calculateBmi(0, 170), throwsArgumentError);
      expect(() => AppCalculations.calculateBmi(70, 0), throwsArgumentError);
      expect(() => AppCalculations.calculateBmi(-10, 170), throwsArgumentError);
    });
  });

  group('2. Pengujian Konversi Satuan Berat (AppCalculations.convertWeight)', () {
    test('Konversi dari Kilogram (kg) ke Gram (g)', () {
      final result = AppCalculations.convertWeight(70, AppConstants.unitKg, AppConstants.unitGram);
      expect(result, closeTo(70000.0, 0.001));
    });

    test('Konversi dari Gram (g) ke Kilogram (kg)', () {
      final result = AppCalculations.convertWeight(2500, AppConstants.unitGram, AppConstants.unitKg);
      expect(result, closeTo(2.5, 0.001));
    });

    test('Konversi dari Kilogram (kg) ke Pound / Pon (lbs)', () {
      final result = AppCalculations.convertWeight(1, AppConstants.unitKg, AppConstants.unitPound);
      expect(result, closeTo(2.20462, 0.001));
    });

    test('Konversi dari Pound (lbs) ke Ounce (oz)', () {
      final result = AppCalculations.convertWeight(1, AppConstants.unitPound, AppConstants.unitOunce);
      expect(result, closeTo(16.0, 0.01));
    });

    test('Menolak nilai berat negatif dengan melempar ArgumentError', () {
      expect(
        () => AppCalculations.convertWeight(-5, AppConstants.unitKg, AppConstants.unitGram),
        throwsArgumentError,
      );
    });
  });

  group('3. Pengujian Kalkulator Umur Sadar Kalender (AppCalculations.calculateAge)', () {
    test('Kalkulasi umur tepat 21 tahun 4 bulan 4 hari', () {
      final birthDate = DateTime(2005, 5, 12);
      final asOfDate = DateTime(2026, 9, 16);

      final result = AppCalculations.calculateAge(birthDate, asOfDate: asOfDate);

      expect(result.years, 21);
      expect(result.months, 4);
      expect(result.days, 4);
      expect(result.totalDays, greaterThan(0));
      expect(result.totalHours, greaterThan(0));
      expect(result.totalMinutes, greaterThan(0));
      expect(result.totalSeconds, greaterThan(0));
    });

    test('Kalkulasi umur pada hari kelahiran yang sama bernilai 0 tahun 0 bulan 0 hari', () {
      final today = DateTime(2026, 9, 16);
      final result = AppCalculations.calculateAge(today, asOfDate: today);

      expect(result.years, 0);
      expect(result.months, 0);
      expect(result.days, 0);
    });

    test('Menolak tanggal lahir di masa depan dengan melempar ArgumentError', () {
      final futureDate = DateTime(2030, 1, 1);
      final asOfDate = DateTime(2026, 9, 16);

      expect(
        () => AppCalculations.calculateAge(futureDate, asOfDate: asOfDate),
        throwsArgumentError,
      );
    });
  });

  group('4. Pengujian Konversi Weton Jawa dan Kalender Saka Bali', () {
    test('Verifikasi Weton Proklamasi Kemerdekaan RI 17 Agustus 1945 adalah Jumat Legi', () {
      final date = DateTime(1945, 8, 17);
      final result = AppCalculations.calculateWetonAndSaka(date);

      expect(result.gregorianDayName, 'Jumat');
      expect(result.javanesePasaran, 'Legi');
      expect(result.wetonFull, 'Jumat Legi');
      expect(result.neptuDay, 6);
      expect(result.neptuPasaran, 5);
      expect(result.totalNeptu, 11);
    });

    test('Verifikasi Weton Epoch Acuan 1 Januari 1970 adalah Kamis Wage', () {
      final date = DateTime(1970, 1, 1);
      final result = AppCalculations.calculateWetonAndSaka(date);

      expect(result.gregorianDayName, 'Kamis');
      expect(result.javanesePasaran, 'Wage');
      expect(result.wetonFull, 'Kamis Wage');
      expect(result.neptuDay, 8);
      expect(result.neptuPasaran, 4);
      expect(result.totalNeptu, 12);
    });

    test('Verifikasi Hari Raya Galungan 28 Februari 2024 adalah Buda Kliwon Dungulan', () {
      final date = DateTime(2024, 2, 28);
      final result = AppCalculations.calculateWetonAndSaka(date);

      expect(result.balineseSaptaWara, 'Buda');
      expect(result.balinesePancaWara, 'Kliwon');
      expect(result.balineseWuku, 'Dungulan');
      expect(result.pawukonDay, 74); // 1-indexed (hari ke-74 dari 210)
    });
  });

  group('5. Pengujian Validator Form (AppValidators)', () {
    test('Validasi field wajib diisi', () {
      expect(AppValidators.validateRequired(null, 'Nama'), isNotNull);
      expect(AppValidators.validateRequired('', 'Nama'), isNotNull);
      expect(AppValidators.validateRequired('   ', 'Nama'), isNotNull);
      expect(AppValidators.validateRequired('FitTrack', 'Nama'), isNull);
    });

    test('Validasi angka numerik dan batas nilai', () {
      expect(AppValidators.validateNumber(null, 'Berat'), isNotNull);
      expect(AppValidators.validateNumber('abc', 'Berat'), isNotNull);
      expect(AppValidators.validateNumber('-10', 'Berat'), isNotNull);
      expect(AppValidators.validateNumber('0', 'Berat', allowZero: false), isNotNull);
      expect(AppValidators.validateNumber('0', 'Berat', allowZero: true), isNull);
      expect(AppValidators.validateNumber('70.5', 'Berat'), isNull);
      expect(AppValidators.validateNumber('70,5', 'Berat'), isNull); // format koma lokal
    });

    test('Validasi format email', () {
      expect(AppValidators.validateEmail(''), isNotNull);
      expect(AppValidators.validateEmail('bukanemail'), isNotNull);
      expect(AppValidators.validateEmail('user@domain.com'), isNull);
    });
  });

  group('6. Pengujian Konversi Kalender Hijriah (AppCalculations.convertToHijri)', () {
    test('Verifikasi konversi tanggal Proklamasi RI 17 Agustus 1945 ke kalender Hijriah (Ramadhan 1364 H)', () {
      final date = DateTime(1945, 8, 17);
      final result = AppCalculations.convertToHijri(date);

      expect(result.dayName, 'Jumat');
      expect(result.hYear, 1364);
      expect(result.hMonth, 9); // Ramadhan
      expect(result.monthNameIndo, 'Ramadhan');
      expect(result.fullDateHijri, contains('Ramadhan 1364 H'));
    });

    test('Verifikasi konversi tahun baru Islam 1 Muharram 1446 H (7 Juli 2024)', () {
      final date = DateTime(2024, 7, 7);
      final result = AppCalculations.convertToHijri(date);

      expect(result.hYear, 1446);
      expect(result.hMonth, 1); // Muharram
      expect(result.monthNameIndo, 'Muharram');
      expect(result.fullDateHijri, contains('Muharram 1446 H'));
    });

    test('Memastikan seluruh properti hasil konversi terisi dan valid', () {
      final now = DateTime.now();
      final result = AppCalculations.convertToHijri(now);

      expect(result.hYear, greaterThan(1440));
      expect(result.hMonth, inInclusiveRange(1, 12));
      expect(result.hDay, inInclusiveRange(1, 30));
      expect(AppConstants.hijriMonthsIndo, contains(result.monthNameIndo));
      expect(result.fullDateHijri, endsWith('H'));
      expect(result.islamicNotes, isNotEmpty);
    });
  });
}
