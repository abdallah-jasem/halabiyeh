import 'package:flutter_test/flutter_test.dart';
import 'package:halabiyeh_split/features/bill/domain/entities/member.dart';
import 'package:halabiyeh_split/features/bill/domain/entities/outing.dart';
import 'package:halabiyeh_split/features/bill/domain/entities/outing_item.dart';
import 'package:halabiyeh_split/features/bill/domain/usecases/calculate_balances.dart';
import 'package:halabiyeh_split/features/bill/domain/usecases/parse_amount.dart';
import 'package:halabiyeh_split/features/bill/domain/usecases/settle_up.dart';
import 'package:halabiyeh_split/features/share/domain/format_outing_summary.dart';

Outing planExample({double servicePercent = 0, double tip = 0}) => Outing(
  id: 'o1',
  title: 'Friday dinner',
  createdAt: DateTime(2026, 10, 16),
  members: const [
    Member(id: 'k', name: 'Kekhia', colorValue: 0),
    Member(id: 'aj', name: 'Abood', colorValue: 0),
    Member(id: 'z', name: 'Ziad', colorValue: 0),
  ],
  items: [
    OutingItem(
      id: '1',
      name: 'Mixed',
      price: 210,
      sharedByMemberIds: ['k', 'aj', 'z'],
      splitMode: SplitMode.uneven,
      fixedShares: {'k': 40},
    ),
    OutingItem(id: '2', name: 'Food', price: 60, sharedByMemberIds: ['k', 'aj', 'z']),
    OutingItem(id: '3', name: 'Cola', price: 15, sharedByMemberIds: ['k', 'aj', 'z']),
  ],
  servicePercent: servicePercent,
  tip: tip,
  payments: {'k': 210, 'aj': 75, 'z': 0},
);

void main() {
  test('settle_up: plan example gives two transfers to Kekhia', () {
    final t = settleUp(calculateBalances(planExample()));
    expect(t.length, 2);
    expect(t.map((x) => (x.fromId, x.toId, x.amount.round())), containsAll([('z', 'k', 110), ('aj', 'k', 35)]));
  });

  test('settle_up: transfers cover every debt', () {
    final balances = calculateBalances(planExample());
    final t = settleUp(balances);
    final debt = balances.where((b) => b.diff < 0).fold(0.0, (s, b) => s - b.diff);
    expect(t.fold(0.0, (s, x) => s + x.amount), closeTo(debt, 0.001));
  });

  test('unbalanced bill gives no transfers', () {
    final o = planExample().copyWith(payments: {'k': 150});
    final b = calculateBalances(o);
    expect(isBalanced(b), isFalse);
    expect(settleUp(b), isEmpty);
  });

  test('uneven mismatch: amounts over the price are flagged', () {
    final item = OutingItem(
      id: '1',
      name: 'X',
      price: 75,
      sharedByMemberIds: ['a', 'b'],
      splitMode: SplitMode.uneven,
      fixedShares: {'a': 100, 'b': 110},
    );
    expect(unevenMismatch(item), 210);
    expect(unevenMismatch(item.copyWith(fixedShares: {'a': 40})), isNull);
    expect(unevenMismatch(item.copyWith(fixedShares: {'a': 40, 'b': 35})), isNull);
  });

  test('shareBreakdown sums to each share', () {
    final o = planExample(servicePercent: 10, tip: 15);
    final lines = shareBreakdown(o)['k']!;
    expect(lines['Mixed'], 40);
    expect(lines.containsKey(serviceTipKey), isTrue);
    final share = calculateBalances(o).firstWhere((b) => b.memberId == 'k').share;
    expect(lines.values.fold(0.0, (a, b) => a + b), closeTo(share, 0.001));
  });

  test('legacy "AJ (you)" dropped when unused, renamed when used', () {
    final withMe = planExample().copyWith(
      members: [
        ...planExample().members,
        const Member(id: 'me', name: 'AJ (you)', colorValue: 0),
      ],
    );
    expect(Outing.fromJson(withMe.toJson()).members.map((m) => m.name), isNot(contains('AJ (you)')));
    expect(Outing.fromJson(withMe.toJson()).members.length, 3);
    final used = withMe.copyWith(payments: {...withMe.payments, 'me': 10});
    expect(Outing.fromJson(used.toJson()).members.last.name, 'AJ');
  });

  test('parseAmountSum', () {
    expect(parseAmountSum('150 + 60'), 210);
    expect(parseAmountSum('150'), 150);
    expect(parseAmountSum(''), 0);
    expect(parseAmountSum('abc'), isNull);
    expect(parseAmountSum('150 +'), isNull);
  });

  test('user example: exact shares and settlement, no rounding', () {
    final o = Outing(
      id: 'o2',
      title: 'Test',
      createdAt: DateTime(2026, 10, 18),
      members: const [
        Member(id: 'aj', name: 'AJ', colorValue: 0),
        Member(id: 'k', name: 'Kikhya', colorValue: 0),
        Member(id: 'z', name: 'Ziad', colorValue: 0),
      ],
      items: [
        OutingItem(
          id: '1',
          name: 'صحيتن',
          price: 210,
          sharedByMemberIds: ['aj', 'k', 'z'],
          splitMode: SplitMode.uneven,
          fixedShares: {'k': 40},
        ),
        OutingItem(id: '2', name: 'اكلات', price: 75, sharedByMemberIds: ['aj', 'k', 'z']),
      ],
      payments: {'aj': 75, 'k': 210},
    );
    final b = {for (final x in calculateBalances(o)) x.memberId: x.share};
    expect(b, {'aj': 110, 'k': 65, 'z': 110});
    final t = settleUp(calculateBalances(o)).map((x) => (x.fromId, x.toId, x.amount)).toList();
    expect(t, containsAll([('z', 'k', 110.0), ('aj', 'k', 35.0)]));
    expect(t.length, 2);
  });

  test('service + tip split in proportion to item shares', () {
    final b = calculateBalances(planExample(servicePercent: 10, tip: 15));
    final total = planExample(servicePercent: 10, tip: 15).total;
    expect(b.fold(0.0, (s, x) => s + x.share), closeTo(total, 0.001));
    expect(b.firstWhere((x) => x.memberId == 'k').share, closeTo(65 * (total / 285), 0.001));
  });

  test('outing totalPaid and receiptPath json round trip', () {
    final o = planExample().copyWith(receiptPath: '/x/y.jpg');
    expect(o.totalPaid, 285);
    expect(Outing.fromJson(o.toJson()).receiptPath, '/x/y.jpg');
    final old = o.toJson()..remove('receiptPath');
    expect(Outing.fromJson(old).receiptPath, isNull);
  });

  test('summary contains title, diffs and transfers', () {
    final text = formatOutingSummary(
      planExample(),
      ShareLabels(
        total: 'Total',
        getsBack: 'gets back',
        owes: 'owes',
        settleUp: 'Settle up',
        name: 'Name',
        share: 'Share',
        paid: 'Paid',
        diff: 'Diff',
        gives: (f, t, a) => '$f gives $t $a',
      ),
    ).replaceAll(RegExp('[\u2066-\u2069]'), '');
    expect(text, contains('*Friday dinner*'));
    expect(text, contains('Total: 285'));
    expect(text, contains('Ziad gives Kekhia 110'));
    expect(text, contains('Abood gives Kekhia 35'));
  });
}
