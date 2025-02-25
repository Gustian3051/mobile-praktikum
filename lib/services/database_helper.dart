// import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:praktikum3/models/image_model.dart';
import 'package:sqflite/sqflite.dart';

class DataBaseHelper {
  static final DataBaseHelper instance = DataBaseHelper._init();
  static Database? _database;
  DataBaseHelper._init();
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('images.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE images (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          imagePath TEXT NOT NULL
        )''');
      },
    );
  }

  Future<int> insertImage(ImageModel image) async {
    final db = await database;
    return await db.insert(
      'images',
      image.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ImageModel>> getAllImages() async {
    final db = await instance.database;
    final result = await db.query('images');
    return result.map((e) => ImageModel.fromMap(e)).toList();
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
