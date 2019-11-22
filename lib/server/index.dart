import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//数据库对象
final String tablePrivate = 'tablePrivate';
final String columnId = 'id';
final String columnName = 'name';
final String columnAddr = 'Address';
final String columnPrivate = "private";

class Private {
  int id;
  String name;
  String private;
  String Address;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnId: id,
      columnName: name,
      columnAddr: Address,
      columnPrivate: private
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  Private(int id, String name, String private, String Address) {
    this.id = id;
    this.name = name;
    this.private = private;
    this.Address = Address;
  }

  Private.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
    private = map[columnPrivate];
    Address = map[columnAddr];
  }
}

class PrivateSqlite {
  Database db;

// 获取本地SQLite数据库
  openSqlite() async {
    //获取数据库文件路径
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, "demo.db");

//根据数据库文件路径和数据库版本号创建数据库表
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
CREATE TABLE $tablePrivate (
$columnId INTEGER PRIMARY KEY,
$columnName TEXT,
$columnAddr TEXT,
$columnPrivate TEXT)
''');
    });
    print("数据库文件$db");
  }

// 插入一条数据
Future<Private> insert(Private private) async {
  private.id = await db.insert(tablePrivate, private.toMap());
  return private;
}

//  // 根据ID查找私钥信息
//   Future<Private> getPrivate(int id) async {
//     List<Map> maps = await db.query(tablePrivate,
//         columns: [
//           columnId,
//           columnName,
//           columnAddr,
//           columnPrivate
//         ],
//         where: '$columnId = ?',
//         whereArgs: [id]);
//     if (maps.length > 0) {
//       return Private.fromMap(maps.first);
//     }
//     return null;
//   }

 // 根据地址查找私钥信息
  Future<Private> getPrivate(String address) async {
    List<Map> maps = await db.query(tablePrivate,
        columns: [
          columnId,
          columnName,
          columnAddr,
          columnPrivate
        ],
        where: '$columnAddr = ?',
        whereArgs: [address]);
    if (maps.length > 0) {
      return Private.fromMap(maps.first);
    }
    return null;
  }

  // 根据ID删除私钥信息
  Future<int> delete(int id) async {
    return await db.delete(tablePrivate, where: '$columnId = ?', whereArgs: [id]);
  }

  // 更新私钥信息
  Future<int> update(Private private) async {
    return await db.update(tablePrivate, private.toMap(),
        where: '$columnId = ?', whereArgs: [private.id]);
  }

  // 查找所有私钥信息
  Future<List<Private>> queryAll() async {
    List<Map> maps = await db.query(tablePrivate, columns: [
      columnId,
          columnName,
          columnAddr,
          columnPrivate
    ]);

    if (maps == null || maps.length == 0) {
      return null;
    }

    List<Private> privates = [];
    for (int i = 0; i < maps.length; i++) {
      privates.add(Private.fromMap(maps[i]));
    }
    return privates;
  }

  // 记得及时关闭数据库，防止内存泄漏
  close() async {
    await db.close();
  }
}



