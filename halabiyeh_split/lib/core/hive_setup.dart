import 'package:hive_ce_flutter/hive_ce_flutter.dart';

const outingsBox = 'outings';
const groupsBox = 'groups';

/// Opens the on-device boxes. Both hold JSON strings.
Future<void> initHive() async {
  await Hive.initFlutter();
  await Hive.openBox<String>(outingsBox);
  await Hive.openBox<String>(groupsBox);
}
