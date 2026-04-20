import 'package:flutter_demo_ui/data/todo_item.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'constants.dart';

class DatabaseHelper {
  static const _databaseName = "todo_database.db";
  static const _databaseVersion = 1;
  static const table = "todos";

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper _instance = DatabaseHelper._privateConstructor();
  static DatabaseHelper get instance => _instance;

  late Database _db;

  Future init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(''' 
    CREATE TABLE $table(
    $columnId INTEGER PRIMARY KEY,
    $columnTitle TEXT NOT NULL,
    $columnDescription TEXT,
    $columnDeadline INTEGER NOT NULL,
    $columnDone INTEGER NOT NULL
    )''');
  }

  //Hae Tiedot
  Future<List<TodoItem>> queryAllRows() async {
    final List<Map<String, dynamic>> maps = await _db.query(table);

    return List.generate(maps.length, (index) {
      return TodoItem(
        id: maps[index][columnId],
        title: maps[index][columnTitle],
        description: maps[index][columnDescription],
        deadline: DateTime.fromMillisecondsSinceEpoch(
          maps[index][columnDeadline],
        ),
        done: maps[index][columnDone] == 1,
      );
    });
  }

  //Lisää item
  Future<int> insert(TodoItem item) async {
    return await _db.insert(table, item.toFBMap());
  }

  //Poista item
  Future<int> delete(int id) async {
    return await _db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  //Päivitä item
  Future<int> update(TodoItem item) async {
    return await _db.update(
      table,
      item.toFBMap(),
      where: '$columnId = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteDatabase(String path) =>
      databaseFactory.deleteDatabase(path);
}
