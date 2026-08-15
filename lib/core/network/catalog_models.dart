class BookModel {
  final String id;
  final String title;
  final String slug;
  final String? coverUrl;

  // Extended fields for detail view
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

    // Parse lexical description
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

  BookListModel({
    required this.id,
    required this.title,
    this.description,
    this.books = const [],
  });

  factory BookListModel.fromJson(
    Map<String, dynamic> json,
    List<BookModel> books,
  ) {
    return BookListModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      books: books,
    );
  }
}

class EditionModel {
  final String id;
  final String slug;
  final String title;
  final bool isAudio;
  final String? sourceName;
  final String? rightsStatus;

  EditionModel({
    required this.id,
    required this.slug,
    required this.title,
    this.isAudio = false,
    this.sourceName,
    this.rightsStatus,
  });

  factory EditionModel.fromJson(
    Map<String, dynamic> json, {
    bool isAudio = false,
  }) {
    return EditionModel(
      id: json['id'],
      slug: json['slug'] ?? json['id'], // fallback
      title: json['title'],
      isAudio: isAudio,
      sourceName: json['source_name'],
      rightsStatus: json['rights_status'],
    );
  }
}

class TocItemModel {
  final String id;
  final String title;
  final String type; // 'part' or 'chapter'
  final int sortOrder;
  final List<TocItemModel>? chapters; // Only if type == 'part'

  TocItemModel({
    required this.id,
    required this.title,
    required this.type,
    required this.sortOrder,
    this.chapters,
  });
}

class BookDetailBundle {
  final BookModel book;
  final List<String> authors;
  final List<String> genres;
  final List<EditionModel> textEditions;
  final List<EditionModel> audioEditions;
  final Map<String, List<TocItemModel>> textEditionStructures;
  final Map<String, List<TocItemModel>> audioEditionStructures;
  final Map<String, String> audioNarrators;

  BookDetailBundle({
    required this.book,
    this.authors = const [],
    this.genres = const [],
    this.textEditions = const [],
    this.audioEditions = const [],
    this.textEditionStructures = const {},
    this.audioEditionStructures = const {},
    this.audioNarrators = const {},
  });
}
