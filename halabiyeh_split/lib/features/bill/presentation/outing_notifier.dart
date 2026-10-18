import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers.dart';
import '../../groups/presentation/group_notifier.dart';
import '../../history/presentation/history_notifier.dart';
import '../domain/entities/member.dart';
import '../domain/entities/outing.dart';
import '../domain/entities/outing_item.dart';
import '../domain/usecases/calculate_balances.dart';
import '../domain/usecases/settle_up.dart';

const _uuid = Uuid();

/// The outing being edited on the Split screen. No business math here —
/// that lives in domain/usecases.
class OutingNotifier extends Notifier<Outing> {
  @override
  Outing build() => _newOuting();

  Outing _newOuting() => Outing(
    id: _uuid.v4(),
    title: 'Friday dinner',
    createdAt: DateTime.now(),
    // No "me": the outing starts with the saved group, names only.
    members: [for (final name in ref.read(groupProvider)) Member(id: _uuid.v4(), name: name, colorValue: 0xFFC9DDF2)],
    items: const [],
  );

  void setTitle(String title) => state = state.copyWith(title: title);

  /// Returns false for empty or duplicate names.
  bool addMember(String name) {
    final n = name.trim();
    if (n.isEmpty || state.members.any((m) => m.name == n)) return false;
    final member = Member(id: _uuid.v4(), name: n, colorValue: 0xFFC9DDF2);
    state = state.copyWith(members: [...state.members, member]);
    return true;
  }

  /// Adds the saved group's names that are not already in the outing.
  void loadGroup() {
    for (final name in ref.read(groupProvider)) {
      addMember(name);
    }
  }

  void renameMember(String memberId, String name) {
    final members = state.members.map((m) => m.id == memberId ? m.copyWith(name: name) : m).toList();
    state = state.copyWith(members: members);
  }

  /// Removing a member strips them from every item's sharers/fixed shares
  /// and from payments too — a dangling member id would silently break the
  /// balance math (itemShares divides by sharer count).
  void removeMember(String memberId) {
    final members = state.members.where((m) => m.id != memberId).toList();
    final items = state.items
        .map(
          (i) => i.copyWith(
            sharedByMemberIds: i.sharedByMemberIds.where((id) => id != memberId).toList(),
            fixedShares: Map.of(i.fixedShares)..remove(memberId),
          ),
        )
        .toList();
    final payments = Map.of(state.payments)..remove(memberId);
    state = state.copyWith(members: members, items: items, payments: payments);
  }

  void addItem({required String name, required double price, required List<String> sharedBy}) {
    final item = OutingItem(id: _uuid.v4(), name: name, price: price, sharedByMemberIds: sharedBy);
    state = state.copyWith(items: [...state.items, item]);
  }

  void updateItem(OutingItem item) =>
      state = state.copyWith(items: state.items.map((i) => i.id == item.id ? item : i).toList());

  void removeItem(String itemId) => state = state.copyWith(items: state.items.where((i) => i.id != itemId).toList());

  void setServicePercent(double percent) => state = state.copyWith(servicePercent: percent);

  void setTip(double tip) => state = state.copyWith(tip: tip);

  void setPayment(String memberId, double amount) =>
      state = state.copyWith(payments: {...state.payments, memberId: amount});

  void setReceipt(String? path) =>
      state = path == null ? state.copyWith(clearReceipt: true) : state.copyWith(receiptPath: path);

  /// Saves, then resets to an empty outing. Blank title falls back to
  /// `Outing <date>`.
  Future<void> save(String locale) async {
    var outing = state;
    if (outing.title.trim().isEmpty) {
      outing = outing.copyWith(title: 'Outing ${DateFormat('d MMMM', locale).format(outing.createdAt)}');
    }
    await ref.read(outingRepositoryProvider).save(outing);
    await ref.read(historyProvider.notifier).refresh();
    state = _newOuting();
  }

  void startNew() => state = _newOuting();

  void open(Outing outing) => state = outing;
}

final outingProvider = NotifierProvider<OutingNotifier, Outing>(OutingNotifier.new);

final balancesProvider = Provider<List<MemberBalance>>((ref) => calculateBalances(ref.watch(outingProvider)));

final transfersProvider = Provider<List<Transfer>>((ref) => settleUp(ref.watch(balancesProvider)));
