import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/**
 * Table
 */

const String userInfo = "user_info";


/**
 * Colums
 */

class AppDataBase{
  static Database? _userDb;

  Future<Database?> get userDb async {
    _userDb = await initUserDB();
    return _userDb;
  }

  Future initUserDB() async {
    String path = join(await getDatabasesPath(), 'handon_user.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute("CREATE TABLE IF NOT EXISTS $userDb");
      }
    );
  }

  //Future updateUserInfo();

}