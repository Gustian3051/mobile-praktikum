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
      version: 2, // Ganti versi agar terjadi migrasi
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE images (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            imagePath TEXT NOT NULL,
            location TEXT NOT NULL,
            accelerometerX REAL,
            accelerometerY REAL,
            accelerometerZ REAL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            ALTER TABLE images ADD COLUMN accelerometerX REAL;
          ''');
          await db.execute('''
            ALTER TABLE images ADD COLUMN accelerometerY REAL;
          ''');
          await db.execute('''
            ALTER TABLE images ADD COLUMN accelerometerZ REAL;
          ''');
        }
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
