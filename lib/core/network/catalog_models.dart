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

/// A download link attached to an edition (epub, pdf, mobi, etc.)
class DownloadLinkModel {
  final String type;
  final String url;

  DownloadLinkModel({required this.type, required this.url});

  factory DownloadLinkModel.fromJson(Map<String, dynamic> json) {
    return DownloadLinkModel(
      type: json['type'] ?? 'other',
      url: json['url'] ?? '',
    );
  }

  String get label {
    switch (type) {
      case 'epub': return 'EPUB';
      case 'pdf': return 'PDF';
      case 'mobi': return 'MOBI';
      default: return 'Download';
    }
  }
}

class EditionModel {
  final String id;
  final String slug;
  final String title;
  final String? sourceName;
  final String? rightsStatus;
  final List<DownloadLinkModel> downloadLinks;

  EditionModel({
    required this.id,
    required this.slug,
    required this.title,
    this.sourceName,
    this.rightsStatus,
    this.downloadLinks = const [],
  });

  factory EditionModel.fromJson(Map<String, dynamic> json) {
    List<DownloadLinkModel> links = [];
    if (json['download_links'] != null && json['download_links'] is List) {
      links = (json['download_links'] as List)
          .where((l) => l is Map<String, dynamic>)
          .map((l) => DownloadLinkModel.fromJson(l))
          .toList();
    }

    return EditionModel(
      id: json['id'],
      slug: json['slug'] ?? json['id'],
      title: json['title'],
      sourceName: json['source_name'],
      rightsStatus: json['rights_status'],
      downloadLinks: links,
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

/// Lightweight author info for display + navigation
class AuthorInfo {
  final String id;
  final String name;
  final String slug;

  AuthorInfo({required this.id, required this.name, required this.slug});
}

/// Full person detail for the person screen
class PersonModel {
  final String id;
  final String name;
  final String slug;
  final String? bio;
  final String? photoUrl;
  final int? birthYear;
  final int? deathYear;
  final String? websiteUrl;
  final String? wikipediaUrl;
  final List<String> alternateNames;

  PersonModel({
    required this.id,
    required this.name,
    required this.slug,
    this.bio,
    this.photoUrl,
    this.birthYear,
    this.deathYear,
    this.websiteUrl,
    this.wikipediaUrl,
    this.alternateNames = const [],
  });

  factory PersonModel.fromJson(Map<String, dynamic> json) {
    // Extract bio text from Lexical JSON
    String? bioText;
    if (json['bio'] != null && json['bio'] is Map) {
      final root = json['bio']['root'];
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
        bioText = paragraphs.join('\n\n');
      }
    }

    // Photo URL
    String? photoUrl;
    if (json['photo'] != null && json['photo'] is Map) {
      photoUrl = json['photo']['url'];
    }

    // Alternate names
    List<String> altNames = [];
    if (json['alternate_names'] != null && json['alternate_names'] is List) {
      altNames = (json['alternate_names'] as List)
          .where((a) => a is Map && a['name'] != null)
          .map<String>((a) => a['name'] as String)
          .toList();
    }

    return PersonModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      bio: bioText,
      photoUrl: photoUrl,
      birthYear: json['birth_year'],
      deathYear: json['death_year'],
      websiteUrl: json['website_url'],
      wikipediaUrl: json['wikipedia_url'],
      alternateNames: altNames,
    );
  }

  /// Formatted lifespan string, e.g. "1828 – 1910"
  String? get lifespan {
    if (birthYear == null && deathYear == null) return null;
    final birth = birthYear?.toString() ?? '?';
    final death = deathYear?.toString() ?? 'present';
    return '$birth – $death';
  }
}

class BookDetailBundle {
  final BookModel book;
  final List<AuthorInfo> authorDetails;
  final List<String> genres;
  final List<EditionModel> editions;
  final Map<String, List<TocItemModel>> editionStructures;

  BookDetailBundle({
    required this.book,
    this.authorDetails = const [],
    this.genres = const [],
    this.editions = const [],
    this.editionStructures = const {},
  });

  /// Convenience: list of author display names
  List<String> get authors => authorDetails.map((a) => a.name).toList();
}
