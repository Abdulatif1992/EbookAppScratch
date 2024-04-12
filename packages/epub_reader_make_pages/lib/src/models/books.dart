
class HtmlBook {
  final String? bookId;
  final int? page;
  final double location;

  HtmlBook({this.bookId="", this.page=0, this.location=0}); 

  HtmlBook.fromJson(Map<String, dynamic> json)
    : bookId    = json['bookId'],
      page      = json['page'],
      location  = json['location'];

  Map<String, dynamic> toJson() => {
    'bookId':   bookId,
    'page':     page,
    'location': location,
  };   
}

