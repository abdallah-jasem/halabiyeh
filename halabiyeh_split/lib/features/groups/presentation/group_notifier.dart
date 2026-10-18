import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';

/// "The usual friends": names added to every new outing.
class GroupNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => ref.read(groupRepositoryProvider).load();

  void _set(List<String> names) {
    state = names;
    ref.read(groupRepositoryProvider).save(names);
  }

  /// Returns false for empty or duplicate names.
  bool add(String name) {
    final n = name.trim();
    if (n.isEmpty || state.contains(n)) return false;
    _set([...state, n]);
    return true;
  }

  void rename(int index, String name) {
    final n = name.trim();
    if (n.isEmpty) return;
    _set([...state]..[index] = n);
  }

  void remove(int index) => _set([...state]..removeAt(index));
}

final groupProvider = NotifierProvider<GroupNotifier, List<String>>(GroupNotifier.new);
