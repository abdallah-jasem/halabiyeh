import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  final String name;
  final Color accent;
  final int roundStep; // 0 = off, 500, 1000
  final String language; // 'en' | 'ar'

  const Settings({this.name = 'AJ', this.accent = const Color(0xFF1E5F48), this.roundStep = 0, this.language = 'en'});

  Settings copyWith({String? name, Color? accent, int? roundStep, String? language}) => Settings(
    name: name ?? this.name,
    accent: accent ?? this.accent,
    roundStep: roundStep ?? this.roundStep,
    language: language ?? this.language,
  );
}

const accentOptions = [Color(0xFF1E5F48), Color(0xFF24508C), Color(0xFF8A3B1E), Color(0xFF17211D)];

/// Loaded in main() before runApp, so saved settings (language, accent)
/// apply on the first frame instead of flipping in after an async load.
final sharedPrefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError('override in main'));

/// App-level prefs, persisted in SharedPreferences (key-value, cross-outing).
class SettingsNotifier extends Notifier<Settings> {
  SharedPreferences get _prefs => ref.read(sharedPrefsProvider);

  @override
  Settings build() {
    const d = Settings();
    return Settings(
      name: _prefs.getString('name') ?? d.name,
      accent: Color(_prefs.getInt('accent') ?? d.accent.toARGB32()),
      roundStep: _prefs.getInt('roundStep') ?? d.roundStep,
      language: _prefs.getString('language') ?? d.language,
    );
  }

  void setName(String v) {
    state = state.copyWith(name: v);
    _prefs.setString('name', v);
  }

  void setAccent(Color c) {
    state = state.copyWith(accent: c);
    _prefs.setInt('accent', c.toARGB32());
  }

  void setRoundStep(int v) {
    state = state.copyWith(roundStep: v);
    _prefs.setInt('roundStep', v);
  }

  void setLanguage(String v) {
    state = state.copyWith(language: v);
    _prefs.setString('language', v);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(SettingsNotifier.new);
