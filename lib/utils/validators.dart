// File ini berisi fungsi-fungsi validasi form yang dapat digunakan kembali.
// Setiap fungsi mengembalikan pesan error dalam Bahasa Indonesia jika input tidak valid,
// atau null jika input sudah benar.

class AppValidators {
  // Validasi nilai teks tidak boleh kosong
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong.';
    }
    return null;
  }

  // Validasi input angka (desimal atau bulat)
  static String? validateNumber(
    String? value,
    String fieldName, {
    bool allowZero = false,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong.';
    }

    // Mengganti koma dengan titik agar desimal format lokal Indonesia tetap terbaca
    final normalized = value.trim().replaceAll(',', '.');
    final parsed = double.tryParse(normalized);

    if (parsed == null) {
      return '$fieldName harus berupa angka yang valid.';
    }

    if (parsed.isNaN || parsed.isInfinite) {
      return '$fieldName tidak valid.';
    }

    if (!allowZero && parsed <= 0) {
      return '$fieldName harus lebih besar dari 0.';
    }

    if (allowZero && parsed < 0) {
      return '$fieldName tidak boleh bernilai negatif.';
    }

    return null;
  }

  // Validasi angka bulat positif (misal: durasi latihan, usia)
  static String? validatePositiveInteger(
    String? value,
    String fieldName, {
    bool allowZero = false,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong.';
    }

    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      return '$fieldName harus berupa bilangan bulat.';
    }

    if (!allowZero && parsed <= 0) {
      return '$fieldName harus lebih besar dari 0.';
    }

    if (allowZero && parsed < 0) {
      return '$fieldName tidak boleh bernilai negatif.';
    }

    return null;
  }

  // Validasi format email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong.';
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid (contoh: user@mail.com).';
    }

    return null;
  }

  // Validasi panjang kata sandi minimal
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.trim().isEmpty) {
      return 'Kata sandi tidak boleh kosong.';
    }

    if (value.length < minLength) {
      return 'Kata sandi minimal harus $minLength karakter.';
    }

    return null;
  }
}
