class CategoryFromSql{
  int? _id;
  String? _categoryName;

  CategoryFromSql(this._id, this._categoryName);

  int get id => _id!;
  String get categoryName => _categoryName!; 

  // Convert a CategoryFromSql object into a Map object
  // becouse SqlLite database works with Map object

  // Map<String, dynamic> toMap(){
  //   var map = Map<String, dynamic>();
  //   map['id'] = _id;
  //   map['category_name'] = _categoryName;
  //   return map;
  // }

  Map<String, dynamic> toMap(){
    return {
      'id': _id,
      'category_name': _categoryName,
    };
  }

  //Extract a BookFromSql object from a Map object
  CategoryFromSql.fromMapObject(Map<String, dynamic> map){
    _id = map['id'];
    _categoryName = map['category_name'];
  }

}