class EpubBook {
  final String? bookId;
  final String? href;
  final int? created;
  final String? clf;

  EpubBook({this.bookId="", this.href="", this.created=0, this.clf=""});  

  EpubBook.fromJson(Map<String, dynamic> json)
    : bookId = json['bookId'],
      href = json['href'],
      created = json['created'],
      clf = json['clf'];

  Map<String, dynamic> toJson() => {
    'bookId': bookId,
    'href': href,
    'created': created,
    'clf': clf,
  };
}

class PdfBook {
  final String? bookId;
  final String? bookUrl;
  final int? page;

  PdfBook({this.bookId="", this.bookUrl="", this.page=0});  

  PdfBook.fromJson(Map<String, dynamic> json)
    : bookId = json['bookId'],
      bookUrl = json['bookUrl'],
      page = json['page'];

  Map<String, dynamic> toJson() => {
    'bookId': bookId,
    'bookUrl': bookUrl,
    'page': page,
  };
}

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


