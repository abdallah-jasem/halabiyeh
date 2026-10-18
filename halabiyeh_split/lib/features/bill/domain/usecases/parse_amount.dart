/// Parses "150 + 60" style input. Empty = 0, any bad part = null.
double? parseAmountSum(String input) {
  if (input.trim().isEmpty) return 0;
  var sum = 0.0;
  for (final part in input.split('+')) {
    final v = double.tryParse(part.trim());
    if (v == null) return null;
    sum += v;
  }
  return sum;
}
