import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
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
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.yourName, style: const TextStyle(fontSize: 12, color: kMuted)),
                      TextFormField(
                        initialValue: settings.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        decoration: const InputDecoration.collapsed(hintText: ''),
                        onChanged: notifier.setName,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _Box(
            title: l.accentColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final color in accentOptions)
                  GestureDetector(
                    onTap: () => notifier.setAccent(color),
                    child: CircleAvatar(
                      backgroundColor: color,
                      radius: 18,
                      child: settings.accent.toARGB32() == color.toARGB32()
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : null,
                    ),
                  ),
              ],
            ),
          ),
          _Box(
            title: l.rounding,
            child: SegmentedButton<int>(
              showSelectedIcon: false,
              expandedInsets: EdgeInsets.zero,
              segments: [
                ButtonSegment(value: 0, label: Text(l.roundNone)),
                ButtonSegment(value: 500, label: Text(l.round500)),
                ButtonSegment(value: 1000, label: Text(l.round1000)),
              ],
              selected: {settings.roundStep},
              onSelectionChanged: (s) => notifier.setRoundStep(s.first),
            ),
          ),
          _Box(
            title: l.language,
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              expandedInsets: EdgeInsets.zero,
              segments: const [
                ButtonSegment(value: 'en', label: Text('English')),
                ButtonSegment(value: 'ar', label: Text('العربية')),
              ],
              selected: {settings.language},
              onSelectionChanged: (s) => notifier.setLanguage(s.first),
            ),
          ),
          _Box(
            title: l.savedGroup,
            hint: l.savedGroupHint,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (group.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var i = 0; i < group.length; i++)
                        InputChip(
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          label: Text(group[i]),
                          onPressed: () => _promptName(
                            context,
                            l,
                            initial: group[i],
                          ).then((n) => n == null ? null : ref.read(groupProvider.notifier).rename(i, n)),
                          onDeleted: () => ref.read(groupProvider.notifier).remove(i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                OutlinedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
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

/// One settings card. Same inner padding, title gap and card gap everywhere.
/// The control always stretches to the full card width (segmented buttons
/// also need `expandedInsets: EdgeInsets.zero` to split it evenly).
class _Box extends StatelessWidget {
  final String? title;
  final String? hint;
  final Widget child;
  const _Box({this.title, this.hint, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null) Text(title!, style: const TextStyle(fontWeight: FontWeight.w600)),
        if (hint != null) ...[
          const SizedBox(height: 2),
          Text(hint!, style: const TextStyle(fontSize: 12, color: kMuted)),
        ],
        if (title != null) const SizedBox(height: 12),
        child,
      ],
    ),
  );
}
