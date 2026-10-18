import '../entities/outing.dart';
import '../entities/outing_item.dart';
import 'round_shares.dart';

class MemberBalance {
  final String memberId;
  final double share; // what they owe in total
  final double paid;
  double get diff => paid - share; // + gets back, - owes

  const MemberBalance({required this.memberId, required this.share, required this.paid});
}

/// Per-item share: fixed members get their fixed amount, the remaining
/// price splits equally among the rest of the sharers.
Map<String, double> itemShares(OutingItem item) {
  final shares = <String, double>{};
  if (item.sharedByMemberIds.isEmpty) return shares;

  if (item.splitMode == SplitMode.equal) {
    final each = item.price / item.sharedByMemberIds.length;
    for (final id in item.sharedByMemberIds) {
      shares[id] = each;
    }
    return shares;
  }

  final fixedTotal = _fixedTotal(item);
  final flexibleIds = item.sharedByMemberIds.where((id) => !item.fixedShares.containsKey(id)).toList();
  final remaining = item.price - fixedTotal;
  final eachFlexible = flexibleIds.isEmpty ? 0.0 : remaining / flexibleIds.length;

  for (final id in item.sharedByMemberIds) {
    shares[id] = item.fixedShares[id] ?? eachFlexible;
  }
  return shares;
}

double _fixedTotal(OutingItem item) =>
    item.sharedByMemberIds.where(item.fixedShares.containsKey).fold(0.0, (sum, id) => sum + item.fixedShares[id]!);

/// For an uneven item whose typed amounts can't add up to its price
/// (over the price, or everyone fixed and short), returns the typed total.
/// Null when the item is fine.
double? unevenMismatch(OutingItem item) {
  if (item.splitMode != SplitMode.uneven) return null;
  final fixedTotal = _fixedTotal(item);
  final allFixed = item.sharedByMemberIds.every(item.fixedShares.containsKey);
  final off = allFixed ? (fixedTotal - item.price).abs() >= 0.5 : fixedTotal - item.price >= 0.5;
  return off ? fixedTotal : null;
}

/// Key for the service + tip line in [shareBreakdown].
const serviceTipKey = '';

/// Where each member's share comes from: item name -> amount, plus
/// service/tip (proportional to item share) under [serviceTipKey].
Map<String, Map<String, double>> shareBreakdown(Outing outing) {
  final out = {for (final m in outing.members) m.id: <String, double>{}};
  for (final item in outing.items) {
    for (final e in itemShares(item).entries) {
      final lines = out[e.key];
      if (lines != null) lines[item.name] = (lines[item.name] ?? 0) + e.value;
    }
  }
  final subtotal = outing.subtotal;
  final serviceAndTip = subtotal * (outing.servicePercent / 100) + outing.tip;
  if (subtotal > 0 && serviceAndTip != 0) {
    for (final lines in out.values) {
      final own = lines.values.fold(0.0, (a, b) => a + b);
      if (own != 0) lines[serviceTipKey] = serviceAndTip * own / subtotal;
    }
  }
  return out;
}

/// Full balance sheet: each member's total share (items + proportional
/// service/tip) vs what they paid. [roundStep] > 0 rounds shares (see
/// [roundShares]).
List<MemberBalance> calculateBalances(Outing outing, {int roundStep = 0}) {
  final totalShare = shareBreakdown(outing).map((id, lines) => MapEntry(id, lines.values.fold(0.0, (a, b) => a + b)));
  final shares = roundShares(totalShare, roundStep);
  return outing.members
      .map((m) => MemberBalance(memberId: m.id, share: shares[m.id] ?? 0, paid: outing.payments[m.id] ?? 0))
      .toList();
}
