import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../bill/domain/entities/outing.dart';

class HistoryNotifier extends Notifier<List<Outing>> {
  @override
  List<Outing> build() {
    refresh();
    return [];
  }

  Future<void> refresh() async {
    state = await ref.read(outingRepositoryProvider).getHistory();
  }

  Future<void> delete(String id) async {
    await ref.read(outingRepositoryProvider).delete(id);
    await refresh();
  }
}

final historyProvider = NotifierProvider<HistoryNotifier, List<Outing>>(HistoryNotifier.new);
