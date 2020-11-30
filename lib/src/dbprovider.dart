import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();
  static Database _database;

  Future<Database> get database async {
    // If database exists, return database
    if (_database != null) return _database;

    // If database don't exists, create one
    _database = await initDB();

    return _database;
  }

  // Create the database and the empresas table
  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'consultaflutter.db');

    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute('CREATE TABLE empresas('
          'id INTEGER PRIMARY KEY,'
          'razao TEXT,'
          'cnpj TEXT'
          ')');
    });
  }

  newEmpresa(razao, cnpj) async {
    final db = await database;

    var res = await db.rawInsert("INSERT Into empresas (razao, cnpj)"
        " VALUES ('${razao}','${cnpj}')");
    //print(res);
    return res;
  }

  getLastEmpresa() async {
    final db = await database;
    final res =
        await db.rawQuery("SELECT * FROM empresas order by id desc limit 1");
    //print(res);
    return res.isNotEmpty ? res : null;
  }
}
