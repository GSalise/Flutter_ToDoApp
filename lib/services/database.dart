import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/notes.dart';

class Database {

  static late final Isar db;

  static Future<void> setup() async {
    final appDir = await getApplicationDocumentsDirectory();
    db = await Isar.open(
      [NotesSchema],
      directory: appDir.path,
    );
  }
}
