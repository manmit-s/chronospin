import 'package:chronospin/core/theme/app_theme.dart';
import 'package:chronospin/features/timer/presentation/pages/timer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");

    // Initialize Supabase
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
  } catch (e) {
    debugPrint(
      "Failed to load environment variables or initialize Supabase: $e",
    );
    // Continue anyway as we might be in local-only mode
  }

  runApp(const ProviderScope(child: ChronoSpinApp()));
}

class ChronoSpinApp extends ConsumerWidget {
  const ChronoSpinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp(
      title: 'ChronoSpin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(themeState.accent),
      home: const TimerPage(),
    );
  }
}
