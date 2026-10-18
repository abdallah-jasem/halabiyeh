import 'dart:convert';

import 'package:hive_ce/hive_ce.dart';

import '../../../core/hive_setup.dart';
import '../domain/group_repository.dart';

class HiveGroupRepository implements GroupRepository {
  Box<String> get _box => Hive.box<String>(groupsBox);

  @override
  List<String> load() {
    final raw = _box.get('usual');
    return raw == null ? [] : List<String>.from(jsonDecode(raw) as List);
  }

  @override
  Future<void> save(List<String> names) => _box.put('usual', jsonEncode(names));
}
