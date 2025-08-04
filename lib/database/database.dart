import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/AppInfo.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("apps.db");
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE apps (
        appName TEXT PRIMARY KEY,
        phone TEXT,
        address TEXT,
        url TEXT
      )
    ''');
  }

  Future<void> insertApp(AppInfo app) async {
    final db = await instance.database;
    await db.insert('apps', app.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<AppInfo>> getAllApps() async {
    final db = await instance.database;
    final result = await db.query('apps');
    return result.map((map) => AppInfo.fromMap(map)).toList();
  }

  Future<void> deleteApp(String appName) async {
    final db = await instance.database;
    await db.delete('apps', where: 'appName = ?', whereArgs: [appName]);
  }

  Future<void> updateApp(AppInfo app) async {
    final db = await instance.database;
    await db.update('apps', app.toMap(), where: 'appName = ?', whereArgs: [app.appName]);
  }
}
