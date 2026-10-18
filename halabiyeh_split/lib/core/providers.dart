import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/groups/data/hive_group_repository.dart';
import '../features/groups/domain/group_repository.dart';
import '../features/history/data/hive_outing_repository.dart';
import '../features/history/domain/outing_repository.dart';

/// DI wiring. Tests override these with fakes.
final outingRepositoryProvider = Provider<OutingRepository>((ref) => HiveOutingRepository());
final groupRepositoryProvider = Provider<GroupRepository>((ref) => HiveGroupRepository());
