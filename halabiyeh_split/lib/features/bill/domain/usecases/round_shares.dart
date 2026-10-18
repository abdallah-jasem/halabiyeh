/// Rounds shares to multiples of [step] (0 = off) and keeps their sum equal
/// to [total] (default: the unrounded sum).
///
/// Largest remainder: floor every share to a step, then give the remaining
/// whole steps to the shares that lost the most. The part of the total that
/// is not a whole step goes to the largest share. If rounding would make
/// someone who ate something pay nothing (the step is too big for this
/// bill), the shares are left exact.
Map<String, double> roundShares(Map<String, double> shares, int step, {double? total}) {
  if (step <= 0 || shares.isEmpty) return shares;
  final target = total ?? shares.values.fold<double>(0, (a, b) => a + b);
  final rounded = shares.map((k, v) => MapEntry(k, (v / step).floorToDouble() * step));
  double sum() => rounded.values.fold<double>(0, (a, b) => a + b);

  final spare = (target / step).floor() - (sum() / step).round();
  final byRemainder = shares.keys.toList()
    ..sort((a, b) => (shares[b]! - rounded[b]!).compareTo(shares[a]! - rounded[a]!));
  for (final k in byRemainder.take(spare.clamp(0, shares.length))) {
    rounded[k] = rounded[k]! + step;
  }

  if (shares.entries.any((e) => e.value > 0 && rounded[e.key] == 0)) return shares;

  final largest = shares.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  rounded[largest] = rounded[largest]! + target - sum();
  return rounded;
}
