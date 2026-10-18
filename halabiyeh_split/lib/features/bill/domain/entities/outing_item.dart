enum SplitMode { equal, uneven }

/// One billed item (e.g. "Food"), shared by a subset of members.
/// In [SplitMode.uneven], a member may have a fixed amount in [fixedShares];
/// the remaining price (after fixed shares) splits equally among the rest.
class OutingItem {
  final String id;
  final String name;
  final double price;
  final List<String> sharedByMemberIds;
  final SplitMode splitMode;
  final Map<String, double> fixedShares; // memberId -> fixed amount

  const OutingItem({
    required this.id,
    required this.name,
    required this.price,
    required this.sharedByMemberIds,
    this.splitMode = SplitMode.equal,
    this.fixedShares = const {},
  });

  OutingItem copyWith({
    String? name,
    double? price,
    List<String>? sharedByMemberIds,
    SplitMode? splitMode,
    Map<String, double>? fixedShares,
  }) => OutingItem(
    id: id,
    name: name ?? this.name,
    price: price ?? this.price,
    sharedByMemberIds: sharedByMemberIds ?? this.sharedByMemberIds,
    splitMode: splitMode ?? this.splitMode,
    fixedShares: fixedShares ?? this.fixedShares,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'sharedByMemberIds': sharedByMemberIds,
    'splitMode': splitMode.name,
    'fixedShares': fixedShares,
  };

  factory OutingItem.fromJson(Map<String, dynamic> json) => OutingItem(
    id: json['id'] as String,
    name: json['name'] as String,
    price: (json['price'] as num).toDouble(),
    sharedByMemberIds: List<String>.from(json['sharedByMemberIds'] as List),
    splitMode: SplitMode.values.byName(json['splitMode'] as String),
    fixedShares: (json['fixedShares'] as Map).map((k, v) => MapEntry(k as String, (v as num).toDouble())),
  );
}
