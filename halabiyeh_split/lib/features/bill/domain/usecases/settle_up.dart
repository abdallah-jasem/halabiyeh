import 'calculate_balances.dart';

class Transfer {
  final String fromId;
  final String toId;
  final double amount;
  const Transfer(this.fromId, this.toId, this.amount);
}

/// Sum of all diffs. Non-zero means payments don't match shares (missing
/// payment, unshared item, bad uneven amounts) and transfers would be wrong.
double balanceGap(List<MemberBalance> balances) => balances.fold(0.0, (s, b) => s + b.diff);

bool isBalanced(List<MemberBalance> balances) => balanceGap(balances).abs() < 0.5;

/// Greedy settlement: biggest debtor pays biggest creditor until all are
/// even. At most n-1 transfers.
// ponytail: greedy, not the provably minimal transfer count (NP-hard in
// general); fine for a friend group.
List<Transfer> settleUp(List<MemberBalance> balances) {
  if (!isBalanced(balances)) return const [];
  final debtors = <String, double>{};
  final creditors = <String, double>{};
  for (final b in balances) {
    if (b.diff <= -0.5) debtors[b.memberId] = -b.diff;
    if (b.diff >= 0.5) creditors[b.memberId] = b.diff;
  }
  final transfers = <Transfer>[];
  while (debtors.isNotEmpty && creditors.isNotEmpty) {
    final d = debtors.entries.reduce((a, b) => b.value > a.value ? b : a);
    final c = creditors.entries.reduce((a, b) => b.value > a.value ? b : a);
    final amount = d.value < c.value ? d.value : c.value;
    transfers.add(Transfer(d.key, c.key, amount));
    d.value - amount < 0.5 ? debtors.remove(d.key) : debtors[d.key] = d.value - amount;
    c.value - amount < 0.5 ? creditors.remove(c.key) : creditors[c.key] = c.value - amount;
  }
  return transfers;
}
