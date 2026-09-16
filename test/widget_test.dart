import 'package:flutter_test/flutter_test.dart';
import 'package:tugas3/app/app.dart';
import 'package:tugas3/constants/app_constants.dart';

void main() {
  testWidgets('Smoke test: Aplikasi FitTrack dapat dimuat dan menampilkan SplashScreen', (WidgetTester tester) async {
    // Membangun widget FitTrackApp dan menjalankan frame pertama
    await tester.pumpWidget(const FitTrackApp());

    // Memverifikasi nama aplikasi muncul pada SplashScreen
    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text(AppConstants.appTagline), findsOneWidget);

    // Menyelesaikan timer penundaan splash screen agar tidak ada pending timer
    await tester.pump(const Duration(milliseconds: 1500));
  });
}
