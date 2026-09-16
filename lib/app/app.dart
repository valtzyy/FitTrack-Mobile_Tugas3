import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../screens/age/age_calculator_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/bmi/bmi_screen.dart';
import '../screens/calendar/weton_saka_screen.dart';
import '../screens/converter/weight_converter_screen.dart';
import '../screens/help/help_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/members/members_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/stopwatch/stopwatch_screen.dart';
import '../screens/workouts/workouts_screen.dart';
import 'routes.dart';
import 'theme.dart';

// Widget utama konfigurasi MaterialApp FitTrack
class FitTrackApp extends StatelessWidget {
  const FitTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.mainNavigation: (context) => const MainNavigationScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.members: (context) => const MembersScreen(),
        AppRoutes.bmi: (context) => const BmiScreen(),
        AppRoutes.workouts: (context) => const WorkoutsScreen(),
        AppRoutes.converter: (context) => const WeightConverterScreen(),
        AppRoutes.age: (context) => const AgeCalculatorScreen(),
        AppRoutes.calendar: (context) => const WetonSakaScreen(),
        AppRoutes.stopwatch: (context) => const StopwatchScreen(),
        AppRoutes.help: (context) => const HelpScreen(),
      },
    );
  }
}
