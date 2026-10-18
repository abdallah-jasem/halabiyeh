import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../../../core/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../bill/presentation/outing_notifier.dart';
import '../../nav/presentation/nav_provider.dart';
import 'history_notifier.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final history = ref.watch(historyProvider);
    final locale = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.navHistory, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: FilledButton.icon(
              icon: const Icon(Icons.add),
              label: Text(l.newOuting),
              onPressed: () {
                ref.read(outingProvider.notifier).startNew();
                ref.read(navProvider.notifier).goTo(0);
              },
            ),
          ),
        ],
      ),
      body: history.isEmpty
          ? Center(
              child: Text(l.noHistory, style: const TextStyle(color: kMuted)),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: history.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final outing = history[index];
                final date = DateFormat('d MMMM', locale).format(outing.createdAt);
                return Dismissible(
                  key: ValueKey(outing.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => ref.read(historyProvider.notifier).delete(outing.id),
                  background: Container(
                    color: Colors.red,
                    alignment: AlignmentDirectional.centerEnd,
                    padding: const EdgeInsetsDirectional.only(end: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    leading: outing.receiptPath != null && File(outing.receiptPath!).existsSync()
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(File(outing.receiptPath!), width: 44, height: 44, fit: BoxFit.cover),
                          )
                        : null,
                    title: Text(outing.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(l.historyRow(date, outing.members.length, outing.total.round())),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ref.read(outingProvider.notifier).open(outing);
                      ref.read(navProvider.notifier).goTo(0);
                    },
                  ),
                );
              },
            ),
    );
  }
}
