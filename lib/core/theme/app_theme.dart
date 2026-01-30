import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppAccent {
  cyan(Color(0xFF00E5FF)),
  yellow(Color(0xFFFFEB3B)),
  monochrome(Colors.white);

  final Color color;
  const AppAccent(this.color);
}

class ThemeState {
  final AppAccent accent;
  ThemeState({this.accent = AppAccent.cyan});

  ThemeState copyWith({AppAccent? accent}) {
    return ThemeState(accent: accent ?? this.accent);
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(ThemeState());

  void setAccent(AppAccent accent) {
    state = state.copyWith(accent: accent);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

class AppTheme {
  static ThemeData getTheme(AppAccent accent) {
    final primaryColor = accent.color;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black, // OLED Black
      primaryColor: primaryColor,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor,
        surface: const Color(0xFF121212),

        error: const Color(0xFFCF6679),
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E), // Slightly lighter than black
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor:
            accent == AppAccent.yellow || accent == AppAccent.monochrome
            ? Colors.black
            : Colors.white,
      ),
    );
  }
}
