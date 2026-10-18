class Member {
  final String id;
  final String name;
  final int colorValue;

  const Member({required this.id, required this.name, required this.colorValue});

  Member copyWith({String? name, int? colorValue}) =>
      Member(id: id, name: name ?? this.name, colorValue: colorValue ?? this.colorValue);

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'colorValue': colorValue};

  factory Member.fromJson(Map<String, dynamic> json) =>
      Member(id: json['id'] as String, name: json['name'] as String, colorValue: json['colorValue'] as int);
}
