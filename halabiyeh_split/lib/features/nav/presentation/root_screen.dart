import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../bill/presentation/screens/split_screen.dart';
import '../../history/presentation/history_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import 'nav_provider.dart';

class RootScreen extends ConsumerWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(navProvider);
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(index: index, children: const [SplitScreen(), HistoryScreen(), SettingsScreen()]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: ref.read(navProvider.notifier).goTo,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.receipt_long_outlined), label: l.navSplit),
          NavigationDestination(icon: const Icon(Icons.history), label: l.navHistory),
          NavigationDestination(icon: const Icon(Icons.settings_outlined), label: l.navSettings),
        ],
      ),
    );
  }
}
