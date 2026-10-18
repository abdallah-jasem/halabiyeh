import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  final String name;
  final Color accent;
  final int roundStep; // 0 = off, 500, 1000
  final String language; // 'en' | 'ar'

  const Settings({this.name = 'AJ', this.accent = const Color(0xFF1E5F48), this.roundStep = 0, this.language = 'en'});

  Locale get locale => Locale(language);

  Settings copyWith({String? name, Color? accent, int? roundStep, String? language}) => Settings(
    name: name ?? this.name,
    accent: accent ?? this.accent,
    roundStep: roundStep ?? this.roundStep,
    language: language ?? this.language,
  );
}

const accentOptions = [Color(0xFF1E5F48), Color(0xFF24508C), Color(0xFF8A3B1E), Color(0xFF17211D)];

/// App-level prefs, persisted in SharedPreferences (key-value, cross-outing).
class SettingsNotifier extends Notifier<Settings> {
  @override
  Settings build() {
    _load();
    return const Settings();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = Settings(
      name: prefs.getString('name') ?? state.name,
      accent: Color(prefs.getInt('accent') ?? state.accent.toARGB32()),
      roundStep: prefs.getInt('roundStep') ?? 0,
      language: prefs.getString('language') ?? 'en',
    );
  }

  Future<void> setName(String v) async {
    state = state.copyWith(name: v);
    (await SharedPreferences.getInstance()).setString('name', v);
  }

  Future<void> setAccent(Color c) async {
    state = state.copyWith(accent: c);
    (await SharedPreferences.getInstance()).setInt('accent', c.toARGB32());
  }

  Future<void> setRoundStep(int v) async {
    state = state.copyWith(roundStep: v);
    (await SharedPreferences.getInstance()).setInt('roundStep', v);
  }

  Future<void> setLanguage(String v) async {
    state = state.copyWith(language: v);
    (await SharedPreferences.getInstance()).setString('language', v);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(SettingsNotifier.new);
