import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class User {
  String address;
  String name;
  String privatekey;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['address'] = address;
    map['name'] = name;
    map['privatekey'] = privatekey;
    return map;
  }

  static User fromMap(Map<String, dynamic> map) {
    User user = new User();
    user.address = map['address'];
    user.name = map['name'];
    user.privatekey = map['privatekey'];
    return user;
  }

  static List<User> fromMapList(dynamic mapList) {
    List<User> list = new List(mapList.length);
    for (int i = 0; i < mapList.length; i++) {
      list[i] = fromMap(mapList[i]);
    }
    return list;
  }

}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;
  final String tableName = "table_user";
  final String columnAddress = "address";
  final String columnName = "name";
  final String columnPrivatekey = "privatekey";
  static Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'usersqflite.db');
    var ourDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return ourDb;
  }

  //创建数据库表
  void _onCreate(Database db, int version) async {
    await db.execute(
        "create table $tableName($columnAddress text primary key,$columnName text not null ,$columnPrivatekey text not null )");
    print("Table is created");
  }

//插入
  Future<int> saveItem(User user) async {
    var dbClient = await db;
    int res = await dbClient.insert("$tableName", user.toMap());
    print(res.toString());
    return res;
  }

  //查询
  Future<List> getTotalList() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $tableName ");
    return result.toList();
  }

  //查询总数
  Future<int> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(await dbClient.rawQuery(
        "SELECT COUNT(*) FROM $tableName"
    ));
  }

//按照id查询
  Future<User> getItem(int id) async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $tableName WHERE id = $id");
    if (result.length == 0) return null;
    return User.fromMap(result.first);
  }


  //清空数据
  Future<int> clear() async {
    var dbClient = await db;
    return await dbClient.delete(tableName);
  }


  //根据id删除
  Future<int> deleteItem(int id) async {
    var dbClient = await db;
    return await dbClient.delete(tableName,
        where: "$columnAddress = ?", whereArgs: [id]);
  }

  //修改
  Future<int> updateItem(User user) async {
    var dbClient = await db;
    return await dbClient.update("$tableName", user.toMap(),
        where: "$columnAddress = ?", whereArgs: [user.address]);
  }

  //关闭
  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }
}