import 'package:chronospin/core/theme/app_theme.dart';
import 'package:chronospin/features/timer/presentation/pages/timer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:supabase_flutter/supabase_flutter.dart'; // Commented out until credentials are present

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Supabase.initialize(url: '...', anonKey: '...');

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
