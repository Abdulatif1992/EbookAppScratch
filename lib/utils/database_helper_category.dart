import 'package:ebook_app_scratch/models/category_from_sql.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DatabaseHelperCategory {

  static DatabaseHelperCategory? _databaseHelperCategory; //Singleton DatabaseHelper
  static Database? _database;


  String categoryTable = 'category_table';
  String colId = 'id';
  String colCategoryName = 'category_name';

  DatabaseHelperCategory._createInstance();  //Named constructor to create instance of DatabaseHelper


  factory DatabaseHelperCategory() {
    _databaseHelperCategory ??= DatabaseHelperCategory._createInstance();
    // if(_databaseHelperCategory == null) {
    //   _databaseHelperCategory = DatabaseHelperCategory._createInstance(); //This is executed only once, singleton object
    // }
    return _databaseHelperCategory!;
  } 

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    // if(_database == null){
    //   _database = await initializeDatabase();
    // }
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory(); 
    String path = directory.path + 'categories.db';

    // Open/create the database at a given path
    var booksDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return booksDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute('CREATE TABLE $categoryTable($colId INTEGER,  $colCategoryName VARCHAR(255))');
  }

  // Fetch Operation: Get All category object from database
  Future<List<Map<String, dynamic>>> getCategoryMapList() async {
    Database db = await database;
    var result = await db.rawQuery('SELECT * FROM $categoryTable ORDER BY $colId ASC');
    return result;
  }

  // Insert Operation: Insert a book object to database
  Future<int> insertCategory(CategoryFromSql categoryFromSql) async {
    Database db = await database;
    int result = await db.insert(categoryTable, categoryFromSql.toMap());
    return result;
  }


  Future<List<CategoryFromSql>> getCategoryList() async {
    var categoryMapList = await getCategoryMapList();
    int count = categoryMapList.length;

    List<CategoryFromSql> categoryList = <CategoryFromSql>[];

    // Loop to create a 'Note List' from a 'Map List'
    for(int i=0; i<count; i++){
      categoryList.add(CategoryFromSql.fromMapObject(categoryMapList[i]));
    } 
    return categoryList;

  }

  
}