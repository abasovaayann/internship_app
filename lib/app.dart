import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_colors.dart';
import 'router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.dark(useMaterial3: true);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Mental Wellness',
      theme: base.copyWith(
        scaffoldBackgroundColor: AppColors.backgroundDark,
        colorScheme: base.colorScheme.copyWith(
          primary: AppColors.primary,
          surface: AppColors.surfaceDark,
        ),
        textTheme: GoogleFonts.manropeTextTheme(base.textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      routerConfig: router,
    );
  }
}
