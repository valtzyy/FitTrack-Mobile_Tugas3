import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tugas3/constants/app_constants.dart';
import 'package:tugas3/screens/age/age_calculator_screen.dart';
import 'package:tugas3/screens/bmi/bmi_screen.dart';
import 'package:tugas3/screens/help/help_screen.dart';
import 'package:tugas3/screens/home/home_screen.dart';
import 'package:tugas3/screens/main_navigation_screen.dart';
import 'package:tugas3/screens/stopwatch/stopwatch_screen.dart';
import 'package:tugas3/services/database_service.dart';
import 'package:tugas3/utils/calculations.dart';
import 'package:tugas3/utils/validators.dart';

void main() {
  group('⚡ STRESS TEST 1: Konversi Kalender Hijriah (10.000 Hari Berturut-turut)', () {
    test('Eksekusi 10.000 konversi tanggal Masehi ke Hijriah tanpa exception & validasi integritas data', () {
      final startDate = DateTime(2000, 1, 1);
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 10000; i++) {
        final date = startDate.add(Duration(days: i));
        final result = AppCalculations.convertToHijri(date);

        // Validasi struktur data keluaran
        expect(result.hYear, greaterThanOrEqualTo(1420));
        expect(result.hMonth, inInclusiveRange(1, 12));
        expect(result.hDay, inInclusiveRange(1, 30));
        expect(result.dayName, isNotEmpty);
        expect(result.monthNameIndo, isNotEmpty);
        expect(result.fullDateHijri, endsWith('H'));
        expect(AppConstants.hijriMonthsIndo.contains(result.monthNameIndo), isTrue);
      }

      stopwatch.stop();
      // Pastikan performa tinggi: 10.000 konversi selesai dalam waktu di bawah 3 detik
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
    });
  });

  group('⚡ STRESS TEST 2: Konversi Weton Jawa & Kalender Saka Bali (10.000 Hari)', () {
    test('Uji keutuhan siklus Pawukon 210 hari dan Pasaran 5 hari pada 10.000 hari berturut-turut', () {
      final startDate = DateTime(1980, 1, 1);
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 10000; i++) {
        final date = startDate.add(Duration(days: i));
        final result = AppCalculations.calculateWetonAndSaka(date);

        // Validasi Pasaran Jawa
        expect(AppConstants.javaneseDays.contains(result.gregorianDayName), isTrue);
        expect(AppConstants.javanesePasaran.contains(result.javanesePasaran), isTrue);
        // Validasi Neptu (Hari: 3-9, Pasaran: 4-9 => Total Neptu: 7-18)
        expect(result.totalNeptu, inInclusiveRange(7, 18));
        expect(result.totalNeptu, equals(result.neptuDay + result.neptuPasaran));

        // Validasi Pawukon Bali (30 Wuku, siklus 210 hari)
        expect(result.pawukonDay, inInclusiveRange(1, 210));
        expect(AppConstants.pawukonWukuList.contains(result.balineseWuku), isTrue);
        expect(AppConstants.balineseSaptaWara.contains(result.balineseSaptaWara), isTrue);
        expect(AppConstants.balinesePancaWara.contains(result.balinesePancaWara), isTrue);
      }

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
    });
  });

  group('⚡ STRESS TEST 3: Perhitungan Umur Sadar Kalender & Kasus Batas (Edge Cases)', () {
    test('Simulasi 5.000 kelahiran acak dengan normalisasi peminjaman hari & bulan', () {
      final asOfDate = DateTime(2026, 9, 19);
      final baseDate = DateTime(1950, 1, 1);

      for (int i = 0; i < 5000; i++) {
        final birthDate = baseDate.add(Duration(days: i * 5));
        if (birthDate.isAfter(asOfDate)) break;

        final result = AppCalculations.calculateAge(birthDate, asOfDate: asOfDate);

        expect(result.years, greaterThanOrEqualTo(0));
        expect(result.months, inInclusiveRange(0, 11));
        expect(result.days, inInclusiveRange(0, 31));
        expect(result.totalDays, greaterThanOrEqualTo(0));
        expect(result.totalHours, equals(result.totalDays * 24 + asOfDate.difference(birthDate).inHours % 24));
      }
    });

    test('Kasus batas tahun kabisat (Leap Year: 29 Februari)', () {
      final leapBirth = DateTime(2000, 2, 29);
      
      // Tepat 1 tahun setelahnya (bukan tahun kabisat: 28 Februari 2001)
      final ageNonLeap = AppCalculations.calculateAge(leapBirth, asOfDate: DateTime(2001, 2, 28));
      expect(ageNonLeap.years, 0);
      expect(ageNonLeap.months, 11);
      expect(ageNonLeap.days, greaterThanOrEqualTo(28));

      // Tepat 4 tahun setelahnya (tahun kabisat berikutnya: 29 Februari 2004)
      final ageNextLeap = AppCalculations.calculateAge(leapBirth, asOfDate: DateTime(2004, 2, 29));
      expect(ageNextLeap.years, 4);
      expect(ageNextLeap.months, 0);
      expect(ageNextLeap.days, 0);
    });

    test('Kasus batas akhir bulan: pinjam hari dari bulan Februari (28/29 hari)', () {
      final birth = DateTime(2023, 1, 31);
      final asOf = DateTime(2023, 3, 2); // Setelah Februari
      final result = AppCalculations.calculateAge(birth, asOfDate: asOf);

      expect(result.years, 0);
      expect(result.months, 1);
      expect(result.days, 2); // 31 Jan -> 28 Feb (1 bln) -> 2 Mar (2 hari)
    });
  });

  group('⚡ STRESS TEST 4: Ketelitian Konversi Satuan Berat (Round-trip Precision)', () {
    test('Konversi presisi dua arah bolak-balik (Round-trip) 1.000 iterasi', () {
      for (double kg = 1.0; kg <= 1000.0; kg += 1.0) {
        // kg -> lbs -> kg
        final lbs = AppCalculations.convertWeight(kg, AppConstants.unitKg, AppConstants.unitPound);
        final backKgFromLbs = AppCalculations.convertWeight(lbs, AppConstants.unitPound, AppConstants.unitKg);
        expect((backKgFromLbs - kg).abs(), lessThan(1e-5));

        // kg -> gram -> kg
        final gram = AppCalculations.convertWeight(kg, AppConstants.unitKg, AppConstants.unitGram);
        final backKgFromGram = AppCalculations.convertWeight(gram, AppConstants.unitGram, AppConstants.unitKg);
        expect((backKgFromGram - kg).abs(), lessThan(1e-5));

        // kg -> oz -> kg
        final oz = AppCalculations.convertWeight(kg, AppConstants.unitKg, AppConstants.unitOunce);
        final backKgFromOz = AppCalculations.convertWeight(oz, AppConstants.unitOunce, AppConstants.unitKg);
        expect((backKgFromOz - kg).abs(), lessThan(1e-5));
      }
    });

    test('Uji input ekstrem: nilai sangat besar (1 juta kg)', () {
      final hugeLbs = AppCalculations.convertWeight(1000000, AppConstants.unitKg, AppConstants.unitPound);
      expect(hugeLbs, greaterThan(2000000));
      final back = AppCalculations.convertWeight(hugeLbs, AppConstants.unitPound, AppConstants.unitKg);
      expect((back - 1000000).abs(), lessThan(0.01));
    });
  });

  group('⚡ STRESS TEST 5: Validator Formulir dengan Input Ekstrem (Fuzzing / Robustness)', () {
    test('Input string sangat panjang (10.000 karakter)', () {
      final longString = 'A' * 10000;
      expect(AppValidators.validateRequired(longString, 'Field'), isNull);
    });

    test('Input karakter spesial, emoji, dan karakter Unicode', () {
      expect(AppValidators.validateRequired('M. Eufrat Ayyash 🏋️‍♂️', 'Nama'), isNull);
      expect(AppValidators.validateRequired('<script>alert("hack")</script>', 'Input'), isNull);
      expect(AppValidators.validateRequired("'; DROP TABLE members; --", 'Input'), isNull);
    });

    test('Ketahanan validasi angka terhadap format desimal lokal dan internasional', () {
      expect(AppValidators.validateNumber('75.5', 'Berat'), isNull);
      expect(AppValidators.validateNumber('75,5', 'Berat'), isNull);
      expect(AppValidators.validateNumber('0.001', 'Berat', allowZero: false), isNull);
      expect(AppValidators.validateNumber('-0.001', 'Berat'), isNotNull);
      expect(AppValidators.validateNumber('abc123', 'Berat'), isNotNull);
      expect(AppValidators.validateNumber('12.34.56', 'Berat'), isNotNull);
    });

    test('Validasi format email kompleks', () {
      expect(AppValidators.validateEmail('124240092@student.upnyk.ac.id'), isNull);
      expect(AppValidators.validateEmail('user.name+tag@sub.domain.co.id'), isNull);
      expect(AppValidators.validateEmail('plainaddress'), isNotNull);
      expect(AppValidators.validateEmail('@missingusername.com'), isNotNull);
      expect(AppValidators.validateEmail('username@.com'), isNotNull);
    });
  });

  group('⚡ STRESS TEST 6: Hash Password SHA-256 Konsistensi & Keamanan', () {
    test('Memastikan hashing SHA-256 bersifat deterministik dan unik', () {
      final hash1 = DatabaseService.hashPassword('admin123');
      final hash2 = DatabaseService.hashPassword('admin123');
      final hashDifferent = DatabaseService.hashPassword('admin124');

      expect(hash1, equals(hash2));
      expect(hash1, isNot(equals(hashDifferent)));
      expect(hash1.length, 64); // Panjang baku string heksadesimal SHA-256
    });
  });

  group('⚡ STRESS TEST 7: UI Render Smoke Test di Berbagai Resolusi Layar', () {
    testWidgets('Layar Beranda (HomeScreen) menampilkan tepat 5 kartu menu tanpa overflow pada layar kecil (360x640)', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen()),
      );
      await tester.pumpAndSettle();

      // Memastikan tepat 5 kartu menu ditemukan
      expect(find.text('Daftar Anggota'), findsOneWidget);
      expect(find.text('Kalkulator BMI'), findsOneWidget);
      expect(find.text('Catatan Latihan Fisik'), findsOneWidget);
      expect(find.text('Konversi Hijriah & Umur'), findsOneWidget);
      expect(find.text('Weton → Kalender Saka Bali'), findsOneWidget);

      // Memastikan menu ke-6 lama tidak ada lagi
      expect(find.text('Konversi Satuan Berat'), findsNothing);
    });

    testWidgets('Layar Navigasi Bawah (MainNavigationScreen) memuat 3 tab tanpa exception', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(home: MainNavigationScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Stopwatch'), findsOneWidget);
      expect(find.text('Bantuan'), findsOneWidget);

      // Berpindah ke tab Stopwatch
      await tester.tap(find.text('Stopwatch'));
      await tester.pumpAndSettle();
      expect(find.byType(StopwatchScreen), findsOneWidget);

      // Berpindah ke tab Bantuan
      await tester.tap(find.text('Bantuan'));
      await tester.pumpAndSettle();
      expect(find.byType(HelpScreen), findsOneWidget);
      expect(find.text('KELUAR DARI APLIKASI (LOGOUT)'), findsOneWidget);
    });

    testWidgets('Layar Konversi Hijriah & Umur (AgeCalculatorScreen) dapat dimuat dan dioperasikan', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AgeCalculatorScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Konversi Hijriah & Umur'), findsOneWidget);
      expect(find.text('HITUNG UMUR & KONVERSI HIJRIAH'), findsOneWidget);
    });

    testWidgets('Layar Kalkulator BMI (BmiScreen) memuat tombol pintasan konversi berat', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: BmiScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kalkulator BMI'), findsOneWidget);
      expect(find.byIcon(Icons.swap_horiz_rounded), findsOneWidget);
    });
  });
}
