import 'package:atvflutter/model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseController {
  static const String DB_NAME = 'users.db';
  static const String TABLE_NAME = 'users';
  static const String CREATE_TABLE_SCRIPT =
      "CREATE TABLE IF NOT EXISTS users(id INTEGER PRIMARY KEY, username TEXT, password TEXT)";

  Future<Database> _getDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), DB_NAME),
      onCreate: (db, version) {
        return db.execute(CREATE_TABLE_SCRIPT);
      },
      version: 1,
    );
  }

  Future<bool> registerUser(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      throw Exception('Nome de usuário e senha são obrigatórios.');
    }
    try {
      final Database db = await _getDatabase();
      await db.insert(TABLE_NAME, {'username': username, 'password': password});
      return true;
    } catch (ex) {
      print(ex);
      return false;
    }
  }

  Future<UserModel?> loginUser(String username, String password) async {
    try {
      final Database db = await _getDatabase();
      final List<Map<String, dynamic>> results = await db.query(
        TABLE_NAME,
        where: 'username = ? AND password = ?',
        whereArgs: [username, password],
      );

      if (results.isNotEmpty) {
        return UserModel.fromMap(results.first);
      }
    } catch (ex) {
      print(ex);
    }
    return null;
  }
}
