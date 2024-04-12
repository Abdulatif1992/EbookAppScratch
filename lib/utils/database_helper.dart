import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:ebook_app_scratch/models/book_from_sql.dart';
import 'package:path/path.dart' as p;

class DatabaseHelper {

  static DatabaseHelper? _databaseHelper; //Singleton DatabaseHelper
  static Database? _database;

  String bookTable = 'book_table';
  String colId = 'id';
  String colBookId = 'book_id';
  String colBookName = 'book_name';
  String colBookTitle = 'book_title';
  String colBookType = 'book_type';
  String colCategoryId = 'category_id';
  String colStatus = 'status';
  String colBase64 = 'base64';
  String colUpdate = 'upd';
  String colDtime = 'dtime';


  DatabaseHelper._createInstance(); //Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    _databaseHelper ??= DatabaseHelper._createInstance(); //This is executed only once, singleton object
    // if(_databaseHelper == null) {
    //   _databaseHelper = DatabaseHelper._createInstance(); //This is executed only once, singleton object
    // }
    return _databaseHelper!;
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
    //Directory directory = await getApplicationDocumentsDirectory(); 
    //String path = directory.path + 'books.db';

    var databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, 'books.db');

    // Open/create the database at a given path
    var booksDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return booksDatabase;

  }

  void _createDb(Database db, int newVersion) async {
    await db.execute('CREATE TABLE $bookTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colBookId INTEGER, $colBookName VARCHAR(255), $colBookTitle TEXT, $colBookType VARCHAR(10), $colCategoryId INTEGER, $colStatus INTEGER, $colBase64, $colUpdate INTEGER, $colDtime INTEGER )');
  }

  // Fetch Operation: Get All book object from database
  Future<List<Map<String, dynamic>>> getBookMapList() async {
    Database db = await database;
    var result = await db.rawQuery('SELECT * FROM $bookTable ORDER BY $colId ASC');
    return result;
  }

  // Fetch Operation: Get only downloaded book objects from database
  Future<List<Map<String, dynamic>>> getSpecialBookMapList() async {
    Database db = await database;
    var result = await db.rawQuery('SELECT * FROM $bookTable WHERE $colUpdate = 1 ORDER BY $colDtime DESC');
    return result;
  }

  Future<List<Map<String, dynamic>>> getCategoriedBookMapList(int categoryId) async {
    Database db = await database;
    var result = await db.rawQuery('SELECT * FROM $bookTable WHERE $colCategoryId = $categoryId ORDER BY $colDtime DESC');
    return result;
  }

  // Insert Operation: Insert a book object to database
  Future<int> insertBook(BookFromSql bookFromSql) async {
    Database db = await database;
    int result = await db.insert(bookTable, bookFromSql.toMap());
    return result;
  }

  // Update Peration: Update a Book object from database
  Future<int> updateBook(BookFromSql bookFromSql) async {
    Database db = await database;
    var result = await db.update(bookTable, bookFromSql.toMap(), where: '$colBookId = ?', whereArgs: [bookFromSql.bookid]);
    return result;
  }

  // Update only upd cloumn
  Future<int> updateBookUpd(int bookId) async {
    Database db = await database;
    var result = await db.rawUpdate('''
      UPDATE $bookTable 
      SET $colUpdate = ? 
      WHERE $colBookId = ?
      ''', 
      [1, bookId]);
    return result;
  }

  // Update only Dtime cloumn
  Future<int> updateBookDtime(int bookId, int now) async {
    Database db = await database;
    var result = await db.rawUpdate('''
      UPDATE $bookTable 
      SET $colDtime = ? 
      WHERE $colBookId = ?
      ''', 
      [now, bookId]);
    return result;
  }

  // Delete Operation: a Note object from database
  Future<int> deleteBook(int bookId) async {
    var db = await database;
    int result = await db.rawDelete('DELETE FROM $bookTable WHERE $colBookId = $bookId');
    return result;
  }

  // Get number of Book objects in database
  Future<int> getCount() async {
    Database db = await database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT(*) FROM $bookTable');
    int? result = Sqflite.firstIntValue(x);
    return result!;
  }

  // Get the 'Map List' [List<Map>] and convert it to 'Book list' [List<Book>]
  Future<List<BookFromSql>> getBookList() async {
    var bookMapList = await getBookMapList();
    int count = bookMapList.length;

    List<BookFromSql> bookList = <BookFromSql>[];

    // Loop to create a 'Note List' from a 'Map List'
    for(int i=0; i<count; i++){
      bookList.add(BookFromSql.fromMapObject(bookMapList[i]));
    } 
    return bookList;

  }

  // Get the 'Map List' [List<Map>] and convert it to 'Book list' [List<Book>]
  Future<List<BookFromSql>> getBookListDowloaded() async {
    var bookMapList = await getSpecialBookMapList();
    int count = bookMapList.length;

    List<BookFromSql> bookList = <BookFromSql>[];

    // Loop to create a 'Note List' from a 'Map List'
    for(int i=0; i<count; i++){
      bookList.add(BookFromSql.fromMapObject(bookMapList[i]));
    } 
    return bookList;

  }

  Future<List<BookFromSql>> getBookListCategoried(int categoryId) async {
    var bookMapList = await getCategoriedBookMapList(categoryId);
    int count = bookMapList.length;

    List<BookFromSql> bookList = <BookFromSql>[];

    // Loop to create a 'Note List' from a 'Map List'
    for(int i=0; i<count; i++){
      bookList.add(BookFromSql.fromMapObject(bookMapList[i]));
    } 
    return bookList;

  }
}