/// Rounds each share to the nearest [step] (0 = off). Rounding drift goes
/// to the member with the largest share so the shares still sum to [total]
/// (default: the unrounded sum).
Map<String, double> roundShares(Map<String, double> shares, int step, {double? total}) {
  if (step <= 0 || shares.isEmpty) return shares;
  final target = total ?? shares.values.fold<double>(0.0, (a, b) => a + b);
  final rounded = shares.map((k, v) => MapEntry(k, (v / step).round() * step.toDouble()));
  final drift = target - rounded.values.fold<double>(0.0, (a, b) => a + b);
  final largest = shares.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  rounded[largest] = rounded[largest]! + drift;
  return rounded;
}
