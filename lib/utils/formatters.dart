import 'package:intl/intl.dart';

// File ini berisi helper untuk memformat tanggal, angka, dan durasi
// agar konsisten dengan standar lokal Indonesia di seluruh aplikasi.

class AppFormatters {
  // Format tanggal standar Indonesia: DD/MM/YYYY (contoh: 16/09/2026)
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Format tanggal lengkap dengan nama bulan (contoh: 16 September 2026)
  static String formatDateFull(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // Format tanggal beserta nama hari dalam Bahasa Indonesia
  static String formatDateWithDay(DateTime date) {
    const days = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    final dayName = days[date.weekday - 1];
    return '$dayName, ${formatDateFull(date)}';
  }

  // Format angka desimal dengan jumlah digit di belakang koma yang ditentukan
  static String formatDecimal(double value, {int fractionDigits = 2}) {
    if (value.isNaN || value.isInfinite) return '0.00';
    return value.toStringAsFixed(fractionDigits);
  }

  // Format angka ribuan (contoh: 10.000)
  static String formatNumber(num value) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return formatter.format(value);
  }

  // Parsing string DD/MM/YYYY kembali ke objek DateTime secara aman
  static DateTime? parseDate(String text) {
    try {
      final parts = text.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Format durasi stopwatch menjadi format MM:SS.ms atau HH:MM:SS
  static String formatStopwatch(int totalMilliseconds) {
    final hundreds = (totalMilliseconds ~/ 10) % 100;
    final seconds = (totalMilliseconds ~/ 1000) % 60;
    final minutes = (totalMilliseconds ~/ (1000 * 60)) % 60;
    final hours = totalMilliseconds ~/ (1000 * 60 * 60);

    final hStr = hours.toString().padLeft(2, '0');
    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');
    final msStr = hundreds.toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hStr:$mStr:$sStr.$msStr';
    }
    return '$mStr:$sStr.$msStr';
  }
}
