class BookFromSql{
  int? _bookId;
  String? _bookName;
  String? _bookTitle;
  String? _bookType;
  int? _categoryId;
  int? _status;
  String? _base64;
  int? _upd;
  int? _dtime;

  BookFromSql(this._bookId, this._bookName, this._bookTitle, this._bookType, this._categoryId, this._status, this._base64, this._upd, this._dtime);

  int get bookid => _bookId!;
  String get bookname => _bookName!;
  String get booktitle => _bookTitle!;
  String get booktype => _bookType!;
  int get categoryid =>_categoryId!;
  int get status =>_status!;
  String get base64 => _base64!;  
  int get upd => _upd!;  
  int get dtime => _dtime!;  

  // Convert a BookFromSql object into a Map object
  // becouse SqlLite database works with Map object

  // Map<String, dynamic> toMap(){
  //   var map = Map<String, dynamic>();
  //   map['book_id'] = _bookId;
  //   map['book_name'] = _bookName;
  //   map['book_title'] = _bookTitle;
  //   map['book_type'] = _bookType;
  //   map['category_id'] = _categoryId;
  //   map['status'] = _status;
  //   map['base64'] = _base64;
  //   map['upd'] = _upd;
  //   map['dtime'] = _dtime;

  //   return map;
  // }

  Map<String, dynamic> toMap() {
  return {
    'book_id': _bookId,
    'book_name': _bookName,
    'book_title': _bookTitle,
    'book_type': _bookType,
    'category_id': _categoryId,
    'status': _status,
    'base64': _base64,
    'upd': _upd,
    'dtime': _dtime,
  };
}

  //Extract a BookFromSql object from a Map object
  BookFromSql.fromMapObject(Map<String, dynamic> map){
    _bookId = map['book_id'];
    _bookName = map['book_name'];
    _bookTitle = map['book_title'];
    _bookType = map['book_type'];
    _categoryId = map['category_id'];
    _status = map['status'];
    _base64 = map['base64'];
    _upd = map['upd'];
    _dtime = map['dtime'];
  }

}