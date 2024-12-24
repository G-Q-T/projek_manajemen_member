import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'anggota.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('anggota.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const anggotaTable = '''
    CREATE TABLE anggota (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nama TEXT NOT NULL,
      no_telepon TEXT NOT NULL,
      waktu_bergabung TEXT NOT NULL
    )''';
    await db.execute(anggotaTable);
  }

  Future<int> insertAnggota(Anggota anggota) async {
    final db = await instance.database;
    return await db.insert('anggota', anggota.toMap());
  }

  Future<List<Anggota>> getAllAnggota() async {
    final db = await instance.database;
    final result = await db.query('anggota');
    return result.map((json) => Anggota.fromMap(json)).toList();
  }

  Future<int> updateAnggota(Anggota anggota) async {
    final db = await instance.database;
    return await db.update(
      'anggota',
      anggota.toMap(),
      where: 'id = ?',
      whereArgs: [anggota.id],
    );
  }

  Future<int> deleteAnggota(int id) async {
    final db = await instance.database;
    return await db.delete(
      'anggota',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
