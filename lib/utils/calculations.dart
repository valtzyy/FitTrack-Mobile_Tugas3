import 'package:hijri/hijri_calendar.dart';
import '../constants/app_constants.dart';

// Model hasil konversi Tanggal Hijriah
class HijriResult {
  final DateTime gregorianDate;
  final int hYear;
  final int hMonth;
  final int hDay;
  final String dayName;
  final String monthNameIndo;
  final String fullDateHijri;
  final String islamicNotes;

  const HijriResult({
    required this.gregorianDate,
    required this.hYear,
    required this.hMonth,
    required this.hDay,
    required this.dayName,
    required this.monthNameIndo,
    required this.fullDateHijri,
    required this.islamicNotes,
  });
}

// Model hasil perhitungan BMI
class BmiResult {
  final double bmiValue;
  final String category;
  final String description;

  const BmiResult({
    required this.bmiValue,
    required this.category,
    required this.description,
  });
}

// Model hasil perhitungan umur sadar kalender
class AgeResult {
  final int years;
  final int months;
  final int days;
  final int totalDays;
  final int totalHours;
  final int totalMinutes;
  final int totalSeconds;

  const AgeResult({
    required this.years,
    required this.months,
    required this.days,
    required this.totalDays,
    required this.totalHours,
    required this.totalMinutes,
    required this.totalSeconds,
  });
}

// Model hasil konversi Weton Jawa dan Kalender Saka Bali
class WetonSakaResult {
  final DateTime gregorianDate;
  final String gregorianDayName;
  final String javanesePasaran;
  final String wetonFull;
  final int neptuDay;
  final int neptuPasaran;
  final int totalNeptu;
  final String balineseSaptaWara;
  final String balinesePancaWara;
  final String balineseWuku;
  final int pawukonDay;
  final int approximateSakaYear;
  final String academicNotes;

  const WetonSakaResult({
    required this.gregorianDate,
    required this.gregorianDayName,
    required this.javanesePasaran,
    required this.wetonFull,
    required this.neptuDay,
    required this.neptuPasaran,
    required this.totalNeptu,
    required this.balineseSaptaWara,
    required this.balinesePancaWara,
    required this.balineseWuku,
    required this.pawukonDay,
    required this.approximateSakaYear,
    required this.academicNotes,
  });
}

// Kelas utilitas untuk seluruh formula perhitungan matematis dan kalender
class AppCalculations {
  // 1. Perhitungan Indeks Massa Tubuh (BMI)
  // Formula: BMI = berat (kg) / (tinggi (m) * tinggi (m))
  static BmiResult calculateBmi(double weightKg, double heightCm) {
    if (weightKg <= 0 || heightCm <= 0) {
      throw ArgumentError('Berat dan tinggi badan harus lebih besar dari 0.');
    }

    final heightInMeters = heightCm / 100.0;
    final bmi = weightKg / (heightInMeters * heightInMeters);

    String category;
    String description;

    if (bmi < 18.5) {
      category = AppConstants.bmiUnderweight;
      description = 'Disarankan untuk meningkatkan asupan nutrisi seimbang.';
    } else if (bmi < 25.0) {
      category = AppConstants.bmiNormal;
      description = 'Berat badan Anda tergolong ideal. Pertahankan pola hidup sehat!';
    } else if (bmi < 30.0) {
      category = AppConstants.bmiOverweight;
      description = 'Pertimbangkan untuk meningkatkan frekuensi latihan fisik.';
    } else {
      category = AppConstants.bmiObese;
      description = 'Sangat dianjurkan untuk berkonsultasi dengan ahli kesehatan/gizi.';
    }

    return BmiResult(
      bmiValue: bmi,
      category: category,
      description: description,
    );
  }

  // 2. Konversi Satuan Berat
  // Mengonversi nilai dari satuan asal ke kg terlebih dahulu, kemudian ke satuan tujuan
  static double convertWeight(double value, String fromUnit, String toUnit) {
    if (value < 0) {
      throw ArgumentError('Nilai berat tidak boleh bernilai negatif.');
    }

    // Faktor konversi ke satuan dasar Kilogram (kg)
    double valueInKg;
    switch (fromUnit) {
      case AppConstants.unitKg:
        valueInKg = value;
        break;
      case AppConstants.unitGram:
        valueInKg = value / 1000.0;
        break;
      case AppConstants.unitPound:
        // 1 pound (lbs) = 0.45359237 kg
        valueInKg = value * 0.45359237;
        break;
      case AppConstants.unitOunce:
        // 1 ounce (oz) = 0.028349523125 kg (1/16 pound)
        valueInKg = value * 0.028349523125;
        break;
      default:
        throw ArgumentError('Satuan asal tidak dikenali: $fromUnit');
    }

    // Konversi dari Kilogram (kg) ke satuan tujuan
    switch (toUnit) {
      case AppConstants.unitKg:
        return valueInKg;
      case AppConstants.unitGram:
        return valueInKg * 1000.0;
      case AppConstants.unitPound:
        return valueInKg / 0.45359237;
      case AppConstants.unitOunce:
        return valueInKg / 0.028349523125;
      default:
        throw ArgumentError('Satuan tujuan tidak dikenali: $toUnit');
    }
  }

  // 3. Perhitungan Umur Sadar Kalender (Calendar-aware)
  // Menghitung tahun, bulan, dan hari secara akurat dengan memperhatikan jumlah hari tiap bulan
  static AgeResult calculateAge(DateTime birthDate, {DateTime? asOfDate}) {
    final now = asOfDate ?? DateTime.now();

    // Normalisasi tanggal agar hanya membandingkan tahun, bulan, dan hari
    final birth = DateTime(birthDate.year, birthDate.month, birthDate.day);
    final target = DateTime(now.year, now.month, now.day);

    if (birth.isAfter(target)) {
      throw ArgumentError('Tanggal lahir tidak boleh berada di masa depan.');
    }

    int years = target.year - birth.year;
    int months = target.month - birth.month;
    int days = target.day - birth.day;

    // Jika hari bernilai negatif, pinjam hari dari bulan sebelumnya
    if (days < 0) {
      months--;
      // Hari terakhir dari bulan sebelumnya
      final prevMonthLastDay = DateTime(target.year, target.month, 0).day;
      if (birth.day > prevMonthLastDay) {
        days = target.day;
      } else {
        days += prevMonthLastDay;
      }
    }

    // Jika bulan bernilai negatif, pinjam bulan dari tahun sebelumnya
    if (months < 0) {
      years--;
      months += 12;
    }

    // Perhitungan total estimasi waktu selisih
    final totalDuration = now.difference(birthDate);
    final totalDays = totalDuration.inDays;
    final totalHours = totalDuration.inHours;
    final totalMinutes = totalDuration.inMinutes;
    final totalSeconds = totalDuration.inSeconds;

    return AgeResult(
      years: years,
      months: months,
      days: days,
      totalDays: totalDays,
      totalHours: totalHours,
      totalMinutes: totalMinutes,
      totalSeconds: totalSeconds,
    );
  }

  // 4. Konversi Kalender Weton Jawa ke Kalender Saka Bali & Pawukon
  // Didasarkan pada rujukan standar astronomi/kalender tradisional Nusantara
  // (Bambang Gede Rawi & Siklus Pawukon 210 hari).
  static WetonSakaResult calculateWetonAndSaka(DateTime gregorianDate) {
    final dateOnly = DateTime(
      gregorianDate.year,
      gregorianDate.month,
      gregorianDate.day,
    );

    // Pemetaan nama hari Gregorian (Minggu = 0 s/d Sabtu = 6)
    final dayIndex = dateOnly.weekday % 7;
    final gregorianDayName = AppConstants.javaneseDays[dayIndex];

    // Perhitungan Pasaran Jawa menggunakan tanggal acuan 1 Januari 1970 (Kamis Wage)
    // Hari Kamis = index 4, Pasaran Wage = index 3
    final epochRef = DateTime(1970, 1, 1);
    final daysElapsedFromEpoch = dateOnly.difference(epochRef).inDays;

    // Siklus 5 hari: 0: Legi, 1: Pahing, 2: Pon, 3: Wage, 4: Kliwon
    final pasaranIndex = ((daysElapsedFromEpoch % 5 + 5 + 3) % 5);
    final javanesePasaran = AppConstants.javanesePasaran[pasaranIndex];

    // Menghitung bobot Neptu Weton
    final neptuDay = AppConstants.neptuDayValues[gregorianDayName] ?? 0;
    final neptuPasaran = AppConstants.neptuPasaranValues[javanesePasaran] ?? 0;
    final totalNeptu = neptuDay + neptuPasaran;

    // Komponen Kalender Tradisional Bali (Pawukon 210 Hari)
    // Sapta Wara Bali sejajar dengan Sapta Wara Jawa (Redite = Minggu, dst.)
    final balineseSaptaWara = AppConstants.balineseSaptaWara[dayIndex];

    // Panca Wara Bali sejajar langsung dengan Pasaran Jawa (Umanis = Legi, dst.)
    final balinesePancaWara = AppConstants.balinesePancaWara[pasaranIndex];

    // Perhitungan Siklus 210 Hari Pawukon (30 Wuku @ 7 hari)
    // Acuan Terverifikasi: 28 Februari 2024 adalah Hari Raya Galungan (Buda Kliwon Dungulan, hari ke-73 siklus Pawukon)
    final galunganRef = DateTime(2024, 2, 28);
    final daysFromGalungan = dateOnly.difference(galunganRef).inDays;
    final pawukonDay = ((daysFromGalungan + 73) % 210 + 210) % 210;

    final wukuIndex = pawukonDay ~/ 7;
    final balineseWuku = AppConstants.pawukonWukuList[wukuIndex];

    // Tahun Saka diperkirakan Gregorian Year - 78 (atau -79 sebelum pergantian Nyepi di bulan Maret)
    final approximateSakaYear = (dateOnly.month < 3 || (dateOnly.month == 3 && dateOnly.day < 20))
        ? dateOnly.year - 79
        : dateOnly.year - 78;

    const academicNotes =
        'Perhitungan Weton dan Pawukon (Wuku) didasarkan pada siklus matematis tetap 210 hari '
        'standar Bambang Gede Rawi. Penentuan Sasih lunisolar dan Hari Raya Nyepi memiliki '
        'penyesuaian Ngunalatri yang memerlukan pengamatan astronomis hilal.';

    return WetonSakaResult(
      gregorianDate: dateOnly,
      gregorianDayName: gregorianDayName,
      javanesePasaran: javanesePasaran,
      wetonFull: '$gregorianDayName $javanesePasaran',
      neptuDay: neptuDay,
      neptuPasaran: neptuPasaran,
      totalNeptu: totalNeptu,
      balineseSaptaWara: balineseSaptaWara,
      balinesePancaWara: balinesePancaWara,
      balineseWuku: balineseWuku,
      pawukonDay: pawukonDay + 1, // 1-indexed untuk tampilan ramah pengguna
      approximateSakaYear: approximateSakaYear,
      academicNotes: academicNotes,
    );
  }

  // 5. Konversi Tanggal Masehi ke Kalender Hijriah (Metode Umm al-Qura)
  static HijriResult convertToHijri(DateTime gregorianDate) {
    final dateOnly = DateTime(
      gregorianDate.year,
      gregorianDate.month,
      gregorianDate.day,
    );

    final hijri = HijriCalendar.fromDate(dateOnly);
    final dayIndex = dateOnly.weekday % 7;
    final dayName = AppConstants.javaneseDays[dayIndex];

    // Normalisasi indeks bulan Hijriah (1 - 12)
    final monthIndex = (hijri.hMonth >= 1 && hijri.hMonth <= 12) ? hijri.hMonth - 1 : 0;
    final monthNameIndo = AppConstants.hijriMonthsIndo[monthIndex];
    final fullDateHijri = '${hijri.hDay} $monthNameIndo ${hijri.hYear} H';

    const islamicNotes =
        'Kalender Hijriah (Qamariyah) didasarkan pada peredaran bulan mengelilingi bumi (lunar cycle). '
        'Perhitungan ini mengacu pada standar kalender Umm al-Qura.';

    return HijriResult(
      gregorianDate: dateOnly,
      hYear: hijri.hYear,
      hMonth: hijri.hMonth,
      hDay: hijri.hDay,
      dayName: dayName,
      monthNameIndo: monthNameIndo,
      fullDateHijri: fullDateHijri,
      islamicNotes: islamicNotes,
    );
  }
}
