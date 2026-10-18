import '../../bill/domain/entities/outing.dart';
import '../../bill/domain/usecases/calculate_balances.dart';
import '../../bill/domain/usecases/settle_up.dart';

/// Translated strings for the summary and PDF. Built from AppLocalizations
/// in presentation so this layer stays pure Dart.
class ShareLabels {
  final String total, getsBack, owes, settleUp, name, share, paid, diff;
  final String Function(String from, String to, int amount) gives;
  const ShareLabels({
    required this.total,
    required this.getsBack,
    required this.owes,
    required this.settleUp,
    required this.name,
    required this.share,
    required this.paid,
    required this.diff,
    required this.gives,
  });
}

/// Unicode isolates. Without them a mixed Arabic/English line like
/// "زياد gives كيخيا 25" reorders and reads backwards, and "-35" shows as
/// "35-" in RTL text.
String isolate(String s) => '\u2068$s\u2069';
String ltr(String s) => '\u2066$s\u2069';

/// WhatsApp-ready recap: bill, per-person diff, and who pays whom.
String formatOutingSummary(Outing outing, ShareLabels l) {
  final balances = calculateBalances(outing);
  final nameFor = {for (final m in outing.members) m.id: m.name};
  final buffer = StringBuffer()
    ..writeln('*${outing.title}*')
    ..writeln('${l.total}: ${ltr('${outing.total.round()}')}')
    ..writeln();
  for (final b in balances) {
    final diff = b.diff.round();
    final line = diff >= 0 ? '${ltr('+$diff')} (${l.getsBack})' : '${ltr('$diff')} (${l.owes})';
    buffer.writeln('${isolate(nameFor[b.memberId] ?? '?')}: $line');
  }
  final transfers = settleUp(balances);
  if (transfers.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('*${l.settleUp}*');
    for (final t in transfers) {
      buffer.writeln(l.gives(isolate(nameFor[t.fromId] ?? '?'), isolate(nameFor[t.toId] ?? '?'), t.amount.round()));
    }
  }
  return buffer.toString();
}
