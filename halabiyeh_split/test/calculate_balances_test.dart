import 'package:flutter_test/flutter_test.dart';
import 'package:halabiyeh_split/features/bill/domain/entities/member.dart';
import 'package:halabiyeh_split/features/bill/domain/entities/outing.dart';
import 'package:halabiyeh_split/features/bill/domain/entities/outing_item.dart';
import 'package:halabiyeh_split/features/bill/domain/usecases/calculate_balances.dart';

void main() {
  test('equal split divides price evenly among sharers', () {
    final item = OutingItem(id: '1', name: 'Food', price: 60, sharedByMemberIds: ['a', 'b', 'c']);
    final shares = itemShares(item);
    expect(shares, {'a': 20.0, 'b': 20.0, 'c': 20.0});
  });

  test('uneven split: fixed share taken first, rest split equally', () {
    final item = OutingItem(
      id: '1',
      name: 'Mixed',
      price: 210,
      sharedByMemberIds: ['k', 'aj', 'z'],
      splitMode: SplitMode.uneven,
      fixedShares: {'k': 40},
    );
    final shares = itemShares(item);
    expect(shares['k'], 40);
    expect(shares['aj'], 85);
    expect(shares['z'], 85);
  });

  test('balances: diff is paid minus share, zero-sums across group', () {
    final members = [
      const Member(id: 'k', name: 'Kekhia', colorValue: 0),
      const Member(id: 'aj', name: 'AJ', colorValue: 0),
      const Member(id: 'z', name: 'Ziad', colorValue: 0),
    ];
    final outing = Outing(
      id: 'o1',
      title: 'Test',
      createdAt: DateTime(2026, 10, 16),
      members: members,
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
      payments: {'k': 210, 'aj': 75, 'z': 0},
    );

    final balances = calculateBalances(outing);
    final totalDiff = balances.fold(0.0, (sum, b) => sum + b.diff);
    expect(totalDiff, closeTo(0, 0.001));

    final kekhia = balances.firstWhere((b) => b.memberId == 'k');
    expect(kekhia.share, 65);
    expect(kekhia.diff, 145);
  });
}
