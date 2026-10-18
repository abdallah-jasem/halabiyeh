import 'dart:convert';
import 'dart:io';

import 'package:hive_ce/hive_ce.dart';

import '../../../core/hive_setup.dart';
import '../../bill/domain/entities/outing.dart';
import '../domain/outing_repository.dart';

// ponytail: outing stored as one JSON blob per key instead of normalized
// members/items — single-group app, no cross-outing queries needed.
class HiveOutingRepository implements OutingRepository {
  Box<String> get _box => Hive.box<String>(outingsBox);

  @override
  Future<List<Outing>> getHistory() async {
    final all = _box.values.map((v) => Outing.fromJson(jsonDecode(v) as Map<String, dynamic>)).toList();
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all;
  }

  @override
  Future<void> save(Outing outing) => _box.put(outing.id, jsonEncode(outing.toJson()));

  @override
  Future<void> delete(String id) async {
    final raw = _box.get(id);
    if (raw != null) {
      final path = Outing.fromJson(jsonDecode(raw) as Map<String, dynamic>).receiptPath;
      if (path != null) {
        final file = File(path);
        if (file.existsSync()) file.deleteSync();
      }
    }
    await _box.delete(id);
  }
}
