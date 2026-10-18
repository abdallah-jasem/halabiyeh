import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/hive_setup.dart';
import 'core/theme.dart';
import 'features/nav/presentation/root_screen.dart';
import 'features/settings/presentation/settings_provider.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(overrides: [sharedPrefsProvider.overrideWithValue(prefs)], child: const HalabiyehApp()));
}

class HalabiyehApp extends ConsumerStatefulWidget {
  const HalabiyehApp({super.key});

  @override
  ConsumerState<HalabiyehApp> createState() => _HalabiyehAppState();
}

/// A language switch flips the layout direction. Fade out, swap the locale
/// while hidden, fade back in. The widget tree stays mounted, so screens
/// keep their scroll position.
class _HalabiyehAppState extends ConsumerState<HalabiyehApp> with SingleTickerProviderStateMixin {
  late final _fade = AnimationController(vsync: this, duration: const Duration(milliseconds: 140), value: 1);
  late String _language = ref.read(settingsProvider).language;

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  Future<void> _switchTo(String language) async {
    await _fade.animateTo(0, curve: Curves.easeOut);
    if (!mounted) return;
    setState(() => _language = language);
    await _fade.animateTo(1, curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(settingsProvider.select((s) => s.language), (_, next) {
      if (next != _language) _switchTo(next);
    });
    final accent = ref.watch(settingsProvider.select((s) => s.accent));
    // Fade against the app background, not the black window behind it.
    return ColoredBox(
      color: kPaper,
      child: FadeTransition(
        opacity: _fade,
        child: MaterialApp(
          title: 'Halabiyeh',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(accent, arabic: _language == 'ar'),
          locale: Locale(_language),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const RootScreen(),
        ),
      ),
    );
  }
}
