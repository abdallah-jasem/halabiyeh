import '../../bill/domain/entities/outing.dart';

abstract class OutingRepository {
  Future<List<Outing>> getHistory();
  Future<void> save(Outing outing);
  Future<void> delete(String id);
}
