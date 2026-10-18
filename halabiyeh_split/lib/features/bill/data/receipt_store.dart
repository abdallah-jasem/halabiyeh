import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Copies a picked photo into the app documents dir so it survives if the
/// source (camera cache, gallery) is deleted. Returns the copied path.
Future<String> storeReceipt(String sourcePath) async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory('${docs.path}/receipts')..createSync(recursive: true);
  final ext = sourcePath.contains('.') ? sourcePath.split('.').last : 'jpg';
  final dest = '${dir.path}/${const Uuid().v4()}.$ext';
  await File(sourcePath).copy(dest);
  return dest;
}
