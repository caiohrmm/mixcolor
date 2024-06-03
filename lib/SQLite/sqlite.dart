import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mixcolor/JsonModels/car_model.dart';
import 'package:mixcolor/JsonModels/color.dart';
import 'package:mixcolor/JsonModels/users.dart';

class DatabaseHelper {
  final databaseName = "mixcolor.db";
  String carTable =
      "CREATE TABLE cars (carId INTEGER PRIMARY KEY AUTOINCREMENT, brand TEXT NOT NULL, model TEXT NOT NULL, year INTEGER NOT NULL)";

  String colorTable =
      "CREATE TABLE colors (colorId INTEGER PRIMARY KEY AUTOINCREMENT, colorName TEXT NOT NULL, inkCode TEXT NOT NULL)";

  String carColorTable =
      "CREATE TABLE car_colors (id INTEGER PRIMARY KEY AUTOINCREMENT, carId INTEGER, colorId INTEGER, FOREIGN KEY (carId) REFERENCES cars (carId), FOREIGN KEY (colorId) REFERENCES colors (colorId))";

  //Now we must create our user table into our sqlite db

  String users =
      "create table users (usrId INTEGER PRIMARY KEY AUTOINCREMENT, usrName TEXT UNIQUE, usrPassword TEXT)";

  //We are done in this section

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(carTable);
      await db.execute(colorTable);
      await db.execute(carColorTable);
      await db.execute(users);
    });
  }

  Future<bool> login(Users user) async {
    final Database db = await initDB();

    // I forgot the password to check
    var result = await db.rawQuery(
        "select * from users where usrName = '${user.usrName}' AND usrPassword = '${user.usrPassword}'");
    if (result.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  //Sign up
  Future<int> signup(Users user) async {
    final Database db = await initDB();

    return db.insert('users', user.toMap());
  }

  // CRUD Methods for Car

  Future<int> addCar(Car car) async {
    final Database db = await initDB();
    return db.insert('cars', car.toMap());
  }

  Future<List<Car>> getCars() async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db.query('cars');
    return result.map((e) => Car.fromMap(e)).toList();
  }

  Future<int> updateCar(Car car) async {
    final Database db = await initDB();
    return db.update('cars', car.toMap(),
        where: 'carId = ?', whereArgs: [car.carId]);
  }

  Future<int> deleteCar(int id) async {
    final Database db = await initDB();
    return db.delete('cars', where: 'carId = ?', whereArgs: [id]);
  }

  // CRUD Methods for Color

  Future<int> addColor(ColorModel color) async {
    final Database db = await initDB();
    return db.insert('colors', color.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<int?> getColorIdByName(String colorName) async {
    final Database db = await initDB();
    List<Map<String, dynamic>> result = await db.query('colors',
        where: 'colorName = ?', whereArgs: [colorName], limit: 1);
    if (result.isNotEmpty) {
      return result.first['colorId'];
    } else {
      return null;
    }
  }

  Future<bool> _updateColor(Map<String, dynamic> color) async {
    final Database database = await openDatabase('mixcolor.db');
    try {
      await database.update(
        'colors',
        color,
        where: 'colorId = ?',
        whereArgs: [color['colorId']],
      );
      return true;
    } catch (e) {
      print('Erro ao atualizar a cor: $e');
      return false;
    }
  }

  Future<bool> _deleteColorById(int colorId) async {
    final Database database = await openDatabase('mixcolor.db');
    try {
      await database.delete(
        'colors',
        where: 'colorId = ?',
        whereArgs: [colorId],
      );
      return true;
    } catch (e) {
      print('Erro ao excluir a cor: $e');
      return false;
    }
  }

  // CRUD Methods for Car_Color

  Future<int> addCarColorAssociation(int carId, int colorId) async {
    final Database db = await initDB();
    return db.insert('car_colors', {'carId': carId, 'colorId': colorId},
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<int> addCarColor(int carId, int colorId) async {
    final Database database = await openDatabase('mixcolor.db');
    try {
      int id = await database.insert(
        'car_colors',
        {'carId': carId, 'colorId': colorId},
      );
      return id;
    } catch (e) {
      print('Erro ao adicionar a associação carro-cor: $e');
      return -1;
    }
  }

  Future<void> deleteCarsByModelAndYear(String model, int year) async {
    final Database database = await openDatabase('mixcolor.db');
    try {
      await database.delete(
        'cars',
        where: 'model = ? AND year = ?',
        whereArgs: [model, year],
      );
      print('Carros $model - $year excluídos com sucesso');
    } catch (e) {
      print('Erro ao excluir carros: $e');
      rethrow; // Rethrow para informar o erro ao chamador, se necessário
    }
  }

  Future<List<ColorModel>> getCarColors(int carId) async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db.rawQuery('''
      SELECT colors.colorId, colors.colorName, colors.colorCode FROM car_colors
      INNER JOIN colors ON car_colors.colorId = colors.colorId
      WHERE car_colors.carId = ?
    ''', [carId]);
    return result.map((e) => ColorModel.fromMap(e)).toList();
  }

  //CRUD Methods
}
