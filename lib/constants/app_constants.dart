// File ini berisi nilai-nilai konstan yang digunakan di seluruh aplikasi.
// Tujuannya agar tidak ada teks atau nilai acak yang ditulis berulang (hardcoded).

class AppConstants {
  // Informasi aplikasi
  static const String appName = 'FitTrack';
  static const String appTagline = 'Aplikasi Manajemen Kebugaran & Kesehatan Pribadi';
  static const String appVersion = '1.0.0';

  // Akun bawaan untuk demo presentasi tugas kuliah
  // Catatan: Kredensial ini ditujukan untuk kebutuhan pembelajaran/demo.
  static const String defaultUsername = 'admin';
  static const String defaultPassword = 'admin123';
  static const String defaultFullName = 'Administrator FitTrack';

  // Kunci penyimpanan sesi lokal (SharedPreferences)
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUsername = 'logged_in_username';
  static const String keyUserFullName = 'logged_in_full_name';

  // Batas dan kategori edukasi BMI (Body Mass Index)
  static const String bmiUnderweight = 'Berat Badan Kurang';
  static const String bmiNormal = 'Berat Badan Normal / Ideal';
  static const String bmiOverweight = 'Kelebihan Berat Badan';
  static const String bmiObese = 'Obesitas';

  // Pesan disclaimer medis untuk BMI
  static const String bmiDisclaimer =
      'Hasil BMI merupakan perhitungan umum untuk informasi dan bukan merupakan diagnosis medis profesional.';

  // Pilihan satuan konversi berat
  static const String unitKg = 'Kilogram (kg)';
  static const String unitGram = 'Gram (g)';
  static const String unitPound = 'Pound / Pon (lbs)';
  static const String unitOunce = 'Ounce / Ons (oz)';

  static const List<String> weightUnits = [
    unitKg,
    unitGram,
    unitPound,
    unitOunce,
  ];

  // Daftar nama hari dan pasaran Jawa
  static const List<String> javaneseDays = [
    'Minggu',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
  ];

  static const List<String> javanesePasaran = [
    'Legi',
    'Pahing',
    'Pon',
    'Wage',
    'Kliwon',
  ];

  // Bobot nilai neptu hari dan pasaran
  static const Map<String, int> neptuDayValues = {
    'Minggu': 5,
    'Senin': 4,
    'Selasa': 3,
    'Rabu': 7,
    'Kamis': 8,
    'Jumat': 6,
    'Sabtu': 9,
  };

  static const Map<String, int> neptuPasaranValues = {
    'Legi': 5,
    'Pahing': 9,
    'Pon': 7,
    'Wage': 4,
    'Kliwon': 8,
  };

  // Kalender Bali: 7 Hari Sapta Wara
  static const List<String> balineseSaptaWara = [
    'Redite', // Minggu
    'Soma', // Senin
    'Anggara', // Selasa
    'Buda', // Rabu
    'Wraspati', // Kamis
    'Sukra', // Jumat
    'Saniscara', // Sabtu
  ];

  // Kalender Bali: 5 Hari Panca Wara
  static const List<String> balinesePancaWara = [
    'Umanis',
    'Paing',
    'Pon',
    'Wage',
    'Kliwon',
  ];

  // 30 Wuku dalam siklus Pawukon 210 hari
  static const List<String> pawukonWukuList = [
    'Sinta', 'Landep', 'Wukir', 'Kurantil', 'Tolu', 'Gumbreg',
    'Wariga', 'Warigadean', 'Julungwangi', 'Sungsang', 'Dungulan', 'Kuningan',
    'Langkir', 'Medangsia', 'Pujut', 'Pahang', 'Krulut', 'Merakih',
    'Tambir', 'Medangkungan', 'Matal', 'Uye', 'Menail', 'Prangbakat',
    'Bala', 'Ugu', 'Wayang', 'Kelawu', 'Dukut', 'Watugunung',
  ];

  // Daftar 12 Nama Bulan Kalender Hijriah (Bahasa Indonesia)
  static const List<String> hijriMonthsIndo = [
    'Muharram',
    'Safar',
    "Rabi'ul Awwal",
    "Rabi'ul Akhir",
    'Jumadil Awwal',
    'Jumadil Akhir',
    'Rajab',
    "Sya'ban",
    'Ramadhan',
    'Syawwal',
    "Dzulqa'dah",
    'Dzulhijjah',
  ];
}
