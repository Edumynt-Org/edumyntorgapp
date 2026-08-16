class BookModel {
  final String id;
  final String title;
  final String slug;
  final String? coverUrl;

  final String? description;
  final int? firstPublishedYear;
  final String? originalLanguage;

  BookModel({
    required this.id,
    required this.title,
    required this.slug,
    this.coverUrl,
    this.description,
    this.firstPublishedYear,
    this.originalLanguage,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    String? cUrl;
    if (json['cover'] != null && json['cover'] is Map) {
      final coverData = json['cover'];
      if (coverData['sizes'] != null &&
          coverData['sizes']['cover_medium'] != null &&
          coverData['sizes']['cover_medium']['url'] != null) {
        cUrl = coverData['sizes']['cover_medium']['url'];
      } else {
        cUrl = coverData['url'];
      }
    }

    String? descText;
    if (json['description'] != null && json['description'] is Map) {
      final root = json['description']['root'];
      if (root != null && root['children'] != null) {
        List<String> paragraphs = [];
        for (var node in root['children']) {
          if (node['children'] != null) {
            String paragraph = '';
            for (var child in node['children']) {
              if (child['text'] != null) {
                paragraph += child['text'];
              }
            }
            if (paragraph.isNotEmpty) paragraphs.add(paragraph);
          }
        }
        descText = paragraphs.join('\n\n');
      }
    }

    return BookModel(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      coverUrl: cUrl,
      description: descText,
      firstPublishedYear: json['first_published_year'],
      originalLanguage: json['original_language'] is Map
          ? json['original_language']['name']
          : null,
    );
  }
}

class BookListModel {
  final String id;
  final String title;
  final String? description;
  final List<BookModel> books;
  final int totalBooks;

  BookListModel({
    required this.id,
    required this.title,
    this.description,
    this.books = const [],
    this.totalBooks = 0,
  });

  factory BookListModel.fromJson(
    Map<String, dynamic> json,
    List<BookModel> books,
    int totalBooks,
  ) {
    return BookListModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      books: books,
      totalBooks: totalBooks,
    );
  }
}

class EditionModel {
  final String id;
  final String slug;
  final String title;
  final String? sourceName;
  final String? rightsStatus;

  EditionModel({
    required this.id,
    required this.slug,
    required this.title,
    this.sourceName,
    this.rightsStatus,
  });

  factory EditionModel.fromJson(Map<String, dynamic> json) {
    return EditionModel(
      id: json['id'],
      slug: json['slug'] ?? json['id'], // fallback
      title: json['title'],
      sourceName: json['source_name'],
      rightsStatus: json['rights_status'],
    );
  }
}

class TocItemModel {
  final String id;
  final String title;
  final String type; // 'part' or 'chapter'
  final String? chapterType;
  final int sortOrder;
  final List<TocItemModel>? chapters; // Only if type == 'part'
  final bool hasAudio;

  TocItemModel({
    required this.id,
    required this.title,
    required this.type,
    this.chapterType,
    required this.sortOrder,
    this.chapters,
    this.hasAudio = false,
  });
}

class BookDetailBundle {
  final BookModel book;
  final List<String> authors;
  final List<String> genres;
  final List<EditionModel> editions;
  final Map<String, List<TocItemModel>> editionStructures;

  BookDetailBundle({
    required this.book,
    this.authors = const [],
    this.genres = const [],
    this.editions = const [],
    this.editionStructures = const {},
  });
}
