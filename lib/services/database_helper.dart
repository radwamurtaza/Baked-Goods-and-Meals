import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _dbName = "bgam";
  static const _dbVersion = 1;

  late Database _db;

  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _dbName);
    _db = await openDatabase(
      path,
      version: _dbVersion,
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await this.hasInitialized().then((value) async {
      if (!value) {
        await refreshDB();
      }
    });
    prefs.setBool("dbInitialized", true);
  }

  Future<void> refreshDB() async {}

  Future<bool> hasInitialized() async {
    var tables =
        await _db.rawQuery("SELECT * FROM sqlite_master WHERE type='table';");
    return tables.length > 3;
  }
}
