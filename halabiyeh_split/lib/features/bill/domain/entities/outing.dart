import 'member.dart';
import 'outing_item.dart';

class Outing {
  final String id;
  final String title;
  final DateTime createdAt;
  final List<Member> members;
  final List<OutingItem> items;
  final double servicePercent;
  final double tip;
  final Map<String, double> payments; // memberId -> amount paid
  final String? receiptPath;

  const Outing({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.members,
    required this.items,
    this.servicePercent = 0,
    this.tip = 0,
    this.payments = const {},
    this.receiptPath,
  });

  double get subtotal => items.fold(0.0, (sum, i) => sum + i.price);
  double get total => subtotal * (1 + servicePercent / 100) + tip;
  double get totalPaid => payments.values.fold(0.0, (sum, v) => sum + v);

  Outing copyWith({
    String? title,
    List<Member>? members,
    List<OutingItem>? items,
    double? servicePercent,
    double? tip,
    Map<String, double>? payments,
    String? receiptPath,
    bool clearReceipt = false,
  }) => Outing(
    id: id,
    title: title ?? this.title,
    createdAt: createdAt,
    members: members ?? this.members,
    items: items ?? this.items,
    servicePercent: servicePercent ?? this.servicePercent,
    tip: tip ?? this.tip,
    payments: payments ?? this.payments,
    receiptPath: clearReceipt ? null : receiptPath ?? this.receiptPath,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'members': members.map((m) => m.toJson()).toList(),
    'items': items.map((i) => i.toJson()).toList(),
    'servicePercent': servicePercent,
    'tip': tip,
    'payments': payments,
    'receiptPath': receiptPath,
  };

  factory Outing.fromJson(Map<String, dynamic> json) => _dropLegacyMe(
    Outing(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      members: (json['members'] as List).map((m) => Member.fromJson(m as Map<String, dynamic>)).toList(),
      items: (json['items'] as List).map((i) => OutingItem.fromJson(i as Map<String, dynamic>)).toList(),
      servicePercent: (json['servicePercent'] as num).toDouble(),
      tip: (json['tip'] as num).toDouble(),
      payments: (json['payments'] as Map).map((k, v) => MapEntry(k as String, (v as num).toDouble())),
      receiptPath: json['receiptPath'] as String?,
    ),
  );
}

/// Old builds added an "AJ (you)" member to every outing. The app has no
/// "me", only names: drop it when unused, else rename it to plain "AJ" so
/// the saved numbers stay the same.
Outing _dropLegacyMe(Outing o) {
  final me = o.members.where((m) => m.name == 'AJ (you)').firstOrNull;
  if (me == null) return o;
  final used = (o.payments[me.id] ?? 0) != 0 || o.items.any((i) => i.sharedByMemberIds.contains(me.id));
  if (used) {
    return o.copyWith(members: [for (final m in o.members) m.id == me.id ? m.copyWith(name: 'AJ') : m]);
  }
  return o.copyWith(
    members: o.members.where((m) => m.id != me.id).toList(),
    payments: Map.of(o.payments)..remove(me.id),
  );
}
