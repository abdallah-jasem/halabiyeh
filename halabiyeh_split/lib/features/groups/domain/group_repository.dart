abstract class GroupRepository {
  List<String> load();
  Future<void> save(List<String> names);
}
