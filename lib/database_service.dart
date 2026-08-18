import 'package:flutter/material.dart';
import 'dart:developer';
import 'mood-model.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer';
import 'package:sqflite/sqflite.dart';

class DatabaseService{
  static final DatabaseService _databaseService = DatabaseService._internal();
  factory DatabaseService() => _databaseService;
  DatabaseService._internal();
  static Database? _database;   //Database? = can be null

//Get an instance of database, one access one instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

//Initialize a database
  Future<Database> initDatabase() async {
    final getDirectory = await getApplicationDocumentsDirectory();
    String path = '${getDirectory.path}/moods.db';
    log(path);
    return await openDatabase(path, onCreate: _onCreate, version: 1);
  }


//Create an instance of database = create table
  void _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE Moods('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'scale INTEGER, '
            'description TEXT, '
            'createdOn DATETIME DEFAULT CURRENT_TIMESTAMP)');
    log('TABLE CREATED');
  }

  //function involve data, use future
  Future<List<MoodModel>> getMood() async {
    final db = await _databaseService.database;
    var data = await db.query('Moods');
    List<MoodModel> moods =
    List.generate(data.length, (index) => MoodModel.fromJson(data[index]));
    print(moods.length);
    return moods;
  }

  Future<void> insertMood(MoodModel mood) async {
    final db = await _databaseService.database;
    var data = await db.rawInsert(
        'INSERT INTO Moods(scale, description) VALUES(?,?)',
        [mood.scale, mood.description]);
    log('inserted $data');
  }

  Future<void> editMood(MoodModel mood) async {
    final db = await _databaseService.database;
    //mood to map = convert to json, when data is exist
    var data = await db.update('Moods', mood.toMap(), where: 'id=?', whereArgs:
    [mood.id]);
    log('updated $data');
  }

  Future<void> deleteMood(int id) async {
    final db = await _databaseService.database;
    var data = await db.delete('Moods', where: 'id = ?', whereArgs: [id]);
    log('deleted $data');
  }
}