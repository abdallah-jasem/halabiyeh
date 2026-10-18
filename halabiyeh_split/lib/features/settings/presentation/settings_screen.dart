import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../groups/presentation/group_notifier.dart';
import 'settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final group = ref.watch(groupProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.navSettings, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Box(
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: settings.accent,
                  foregroundColor: Colors.white,
                  child: Text(settings.name.isEmpty ? '?' : settings.name[0]),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextFormField(
                    initialValue: settings.name,
                    decoration: InputDecoration(labelText: l.yourName, border: InputBorder.none, isDense: true),
                    onChanged: notifier.setName,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Box(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.accentColor, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final color in accentOptions)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 10),
                        child: GestureDetector(
                          onTap: () => notifier.setAccent(color),
                          child: CircleAvatar(
                            backgroundColor: color,
                            radius: 18,
                            child: settings.accent.toARGB32() == color.toARGB32()
                                ? const Icon(Icons.check, color: Colors.white, size: 18)
                                : null,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Box(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.rounding, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                SegmentedButton<int>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(value: 0, label: Text(l.roundNone)),
                    ButtonSegment(value: 500, label: Text(l.round500)),
                    ButtonSegment(value: 1000, label: Text(l.round1000)),
                  ],
                  selected: {settings.roundStep},
                  onSelectionChanged: (s) => notifier.setRoundStep(s.first),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Box(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.language, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: 'en', label: Text('English')),
                    ButtonSegment(value: 'ar', label: Text('العربية')),
                  ],
                  selected: {settings.language},
                  onSelectionChanged: (s) => notifier.setLanguage(s.first),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Box(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.savedGroup, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(l.savedGroupHint, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < group.length; i++)
                      InputChip(
                        label: Text(group[i]),
                        onPressed: () => _promptName(
                          context,
                          l,
                          initial: group[i],
                        ).then((n) => n == null ? null : ref.read(groupProvider.notifier).rename(i, n)),
                        onDeleted: () => ref.read(groupProvider.notifier).remove(i),
                      ),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: Text(l.add),
                      onPressed: () async {
                        final n = await _promptName(context, l);
                        if (n == null) return;
                        if (!ref.read(groupProvider.notifier).add(n) && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.duplicateName)));
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _promptName(BuildContext context, AppLocalizations l, {String initial = ''}) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.addFriend),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l.hintName),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text), child: Text(l.save)),
        ],
      ),
    );
  }
}

class _Box extends StatelessWidget {
  final Widget child;
  const _Box({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: child,
  );
}
