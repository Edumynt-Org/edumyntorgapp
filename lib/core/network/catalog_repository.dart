import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'catalog_models.dart';

class CatalogRepository {
  String get _baseUrl => ApiConfig.baseUrl;

  // ── In-memory caches ──────────────────────────────────────────────
  final Map<String, BookDetailBundle> _bookCache = {};
  final Map<String, PersonModel> _personCache = {};
  List<BookListModel>? _homepageCache;
  final Map<String, List<BookModel>> _searchCache = {};

  String _formatCoverUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return '$_baseUrl$url';
  }

  BookModel _formatBook(BookModel book) {
    return BookModel(
      id: book.id,
      title: book.title,
      slug: book.slug,
      coverUrl: _formatCoverUrl(book.coverUrl),
      description: book.description,
      firstPublishedYear: book.firstPublishedYear,
      originalLanguage: book.originalLanguage,
    );
  }

  List<BookModel> _parseBooksFromItems(List items) {
    List<BookModel> books = [];
    for (var item in items) {
      if (item['book'] != null && item['book'] is Map) {
        books.add(_formatBook(BookModel.fromJson(item['book'])));
      }
    }
    return books;
  }

  // ── Homepage Lists ────────────────────────────────────────────────

  Future<List<BookListModel>> getHomepageLists({bool forceRefresh = false}) async {
    if (!forceRefresh && _homepageCache != null) return _homepageCache!;

    try {
      final response = await http.get(Uri.parse(
        '$_baseUrl/api/list-type-book-lists?where[list_type.slug][equals]=homepage&sort=sort_order&depth=1',
      ));
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      final junctions = data['docs'] as List;
      final lists = junctions
          .map((j) => j['book_list'])
          .where((l) => l != null && l is Map && l['status'] == 'published')
          .toList();

      // Fetch all list items in parallel
      final itemFutures = lists.map((listData) {
        final listId = listData['id'];
        return http.get(Uri.parse(
          '$_baseUrl/api/book-list-items?where[book_list][equals]=$listId&sort=sort_order&depth=2&limit=10',
        ));
      }).toList();

      final itemResponses = await Future.wait(itemFutures);

      List<BookListModel> result = [];
      for (int i = 0; i < lists.length; i++) {
        List<BookModel> books = [];
        int totalBooks = 0;
        if (itemResponses[i].statusCode == 200) {
          final itemsData = jsonDecode(itemResponses[i].body);
          totalBooks = itemsData['totalDocs'] ?? 0;
          books = _parseBooksFromItems(itemsData['docs'] as List);
        }
        result.add(BookListModel.fromJson(lists[i], books, totalBooks));
      }

      _homepageCache = result;
      return result;
    } catch (e) {
      debugPrint('Error fetching homepage lists: $e');
      return [];
    }
  }

  // ── Book List By ID ───────────────────────────────────────────────

  Future<BookListModel?> getBookListById(String id) async {
    try {
      // Fetch list meta and items in parallel
      final results = await Future.wait([
        http.get(Uri.parse('$_baseUrl/api/book-lists/$id')),
        http.get(Uri.parse(
          '$_baseUrl/api/book-list-items?where[book_list][equals]=$id&sort=sort_order&depth=2&limit=100',
        )),
      ]);

      if (results[0].statusCode != 200) return null;
      final listData = jsonDecode(results[0].body);

      List<BookModel> books = [];
      int totalBooks = 0;
      if (results[1].statusCode == 200) {
        final itemsData = jsonDecode(results[1].body);
        totalBooks = itemsData['totalDocs'] ?? 0;
        books = _parseBooksFromItems(itemsData['docs'] as List);
      }

      return BookListModel.fromJson(listData, books, totalBooks);
    } catch (e) {
      debugPrint('Error fetching book list: $e');
      return null;
    }
  }

  // ── Search ────────────────────────────────────────────────────────

  Future<List<BookModel>> searchBooks(String query) async {
    if (_searchCache.containsKey(query)) return _searchCache[query]!;

    try {
      String url = '$_baseUrl/api/books?where[status][equals]=published&depth=1&limit=50';
      if (query.isNotEmpty) url += '&where[title][like]=$query';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final docs = data['docs'] as List;
        final results = docs.map((json) => _formatBook(BookModel.fromJson(json))).toList();
        _searchCache[query] = results;
        return results;
      }
      return [];
    } catch (e) {
      debugPrint('Error searching books: $e');
      return [];
    }
  }

  // ── Book Details (with parallel fetching + caching) ───────────────

  Future<BookDetailBundle?> getBookDetails(String slug, {bool forceRefresh = false}) async {
    if (!forceRefresh && _bookCache.containsKey(slug)) return _bookCache[slug]!;

    try {
      // 1. Fetch book first (we need its ID for everything else)
      final bookResponse = await http.get(Uri.parse(
        '$_baseUrl/api/books?where[slug][equals]=$slug&where[status][equals]=published&depth=1&limit=1',
      ));
      if (bookResponse.statusCode != 200) return null;
      final bookData = jsonDecode(bookResponse.body);
      if ((bookData['docs'] as List).isEmpty) return null;

      final bookJson = bookData['docs'][0];
      final formattedBook = _formatBook(BookModel.fromJson(bookJson));

      // 2. Fetch authors, genres, editions, and audio chapter map IN PARALLEL
      final parallel = await Future.wait([
        http.get(Uri.parse('$_baseUrl/api/book-contributors?where[book][equals]=${formattedBook.id}&sort=sort_order&depth=1')),
        http.get(Uri.parse('$_baseUrl/api/book-genres?where[book][equals]=${formattedBook.id}&depth=1')),
        http.get(Uri.parse('$_baseUrl/api/editions?where[book][equals]=${formattedBook.id}&where[status][equals]=published&sort=sort_order&depth=1')),
        http.get(Uri.parse('$_baseUrl/api/audio-chapters?depth=0&limit=1000')),
      ]);

      // Parse authors with full detail (id, name, slug) for navigation
      List<AuthorInfo> authorDetails = [];
      if (parallel[0].statusCode == 200) {
        final docs = jsonDecode(parallel[0].body)['docs'] as List;
        for (var c in docs) {
          if ((c['role'] == 'author' || c['role'] == 'co_author') && c['person'] is Map) {
            authorDetails.add(AuthorInfo(
              id: c['person']['id'],
              name: c['person']['name'],
              slug: c['person']['slug'] ?? c['person']['id'],
            ));
          }
        }
      }

      // Parse genres
      List<String> genres = [];
      if (parallel[1].statusCode == 200) {
        final docs = jsonDecode(parallel[1].body)['docs'] as List;
        for (var c in docs) {
          if (c['genre'] is Map) genres.add(c['genre']['name']);
        }
      }

      // Parse editions (download_links included at depth=1)
      List<EditionModel> editions = [];
      if (parallel[2].statusCode == 200) {
        final docs = jsonDecode(parallel[2].body)['docs'] as List;
        editions = docs.map((json) => EditionModel.fromJson(json)).toList();
      }

      // Build audio chapter lookup
      Map<String, bool> chapterAudioMap = {};
      if (parallel[3].statusCode == 200) {
        final docs = jsonDecode(parallel[3].body)['docs'] as List;
        for (var doc in docs) {
          if (doc['chapter'] != null) {
            String chapterId = doc['chapter'] is Map ? doc['chapter']['id'] : doc['chapter'].toString();
            chapterAudioMap[chapterId] = true;
          }
        }
      }

      // 3. Build ALL edition structures IN PARALLEL
      Map<String, List<TocItemModel>> editionStructures = {};
      if (editions.isNotEmpty) {
        // Fetch chapters + parts for all editions at once
        final structureFutures = <Future<List<http.Response>>>[];
        for (var ed in editions) {
          structureFutures.add(Future.wait([
            http.get(Uri.parse('$_baseUrl/api/edition-chapters?where[edition][equals]=${ed.id}&sort=sort_order&depth=1')),
            http.get(Uri.parse('$_baseUrl/api/edition-parts?where[edition][equals]=${ed.id}&sort=sort_order&depth=1')),
          ]));
        }
        final structureResults = await Future.wait(structureFutures);

        for (int i = 0; i < editions.length; i++) {
          final ed = editions[i];
          final chResp = structureResults[i][0];
          final pResp = structureResults[i][1];
          List<TocItemModel> allItems = [];

          // Chapters
          if (chResp.statusCode == 200) {
            final docs = jsonDecode(chResp.body)['docs'] as List;
            for (var ec in docs) {
              if (ec['chapter'] is Map) {
                final cId = ec['chapter']['id'];
                allItems.add(TocItemModel(
                  id: ec['chapter']['slug'] ?? cId,
                  title: ec['chapter']['title'],
                  type: 'chapter',
                  chapterType: ec['chapter']['chapter_type'],
                  sortOrder: ec['sort_order'] ?? 0,
                  hasAudio: chapterAudioMap[cId] ?? false,
                ));
              }
            }
          }

          // Parts — fetch part-chapters in parallel
          if (pResp.statusCode == 200) {
            final docs = jsonDecode(pResp.body)['docs'] as List;
            final partFutures = <Future<http.Response>>[];
            final partMeta = <Map<String, dynamic>>[];
            for (var ep in docs) {
              if (ep['part'] is Map) {
                partMeta.add(ep);
                partFutures.add(http.get(Uri.parse(
                  '$_baseUrl/api/part-chapters?where[part][equals]=${ep['part']['id']}&sort=sort_order&depth=1',
                )));
              }
            }
            final partResults = await Future.wait(partFutures);
            for (int j = 0; j < partMeta.length; j++) {
              final ep = partMeta[j];
              List<TocItemModel> partChapters = [];
              if (partResults[j].statusCode == 200) {
                final pcDocs = jsonDecode(partResults[j].body)['docs'] as List;
                for (var pc in pcDocs) {
                  if (pc['chapter'] is Map) {
                    final cId = pc['chapter']['id'];
                    partChapters.add(TocItemModel(
                      id: pc['chapter']['slug'] ?? cId,
                      title: pc['chapter']['title'],
                      type: 'chapter',
                      chapterType: pc['chapter']['chapter_type'],
                      sortOrder: pc['sort_order'] ?? 0,
                      hasAudio: chapterAudioMap[cId] ?? false,
                    ));
                  }
                }
              }
              allItems.add(TocItemModel(
                id: ep['part']['id'],
                title: ep['part']['title'],
                type: 'part',
                sortOrder: ep['sort_order'] ?? 0,
                chapters: partChapters,
              ));
            }
          }

          allItems.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          editionStructures[ed.slug] = allItems;
        }
      }

      final bundle = BookDetailBundle(
        book: formattedBook,
        authorDetails: authorDetails,
        genres: genres,
        editions: editions,
        editionStructures: editionStructures,
      );

      _bookCache[slug] = bundle;
      return bundle;
    } catch (e) {
      debugPrint('Error fetching book details: $e');
      return null;
    }
  }

  // ── Chapter Content ───────────────────────────────────────────────

  Future<Map<String, dynamic>?> getChapterContent(String chapterSlug) async {
    try {
      final response = await http.get(Uri.parse(
        '$_baseUrl/api/chapters?where[slug][equals]=$chapterSlug&depth=0&limit=1',
      ));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final docs = data['docs'] as List;
      if (docs.isEmpty) return null;

      final chapter = docs[0];

      // Fetch audio URL in parallel with nothing else, but keep it simple
      String? audioUrl;
      try {
        final audioResp = await http.get(Uri.parse(
          '$_baseUrl/api/audio-chapters?where[chapter][equals]=${chapter['id']}&depth=1',
        ));
        if (audioResp.statusCode == 200) {
          final audioDocs = jsonDecode(audioResp.body)['docs'] as List;
          if (audioDocs.isNotEmpty) {
            final ac = audioDocs[0];
            if (ac['audio_file'] is Map && ac['audio_file']['url'] != null) {
              audioUrl = ac['audio_file']['url'];
            }
          }
        }
      } catch (_) {}

      return {
        'id': chapter['id'],
        'title': chapter['title'],
        'slug': chapter['slug'],
        'content': chapter['content'],
        'chapterType': chapter['chapter_type'],
        'audioUrl': audioUrl,
      };
    } catch (e) {
      debugPrint('Error fetching chapter content: $e');
      return null;
    }
  }

  // ── Person Details ────────────────────────────────────────────────

  Future<PersonModel?> getPersonDetails(String slug) async {
    if (_personCache.containsKey(slug)) return _personCache[slug]!;

    try {
      final response = await http.get(Uri.parse(
        '$_baseUrl/api/people?where[slug][equals]=$slug&depth=1&limit=1',
      ));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final docs = data['docs'] as List;
      if (docs.isEmpty) return null;

      final person = PersonModel.fromJson(docs[0]);
      // Format photo URL
      final formattedPerson = PersonModel(
        id: person.id,
        name: person.name,
        slug: person.slug,
        bio: person.bio,
        photoUrl: _formatCoverUrl(person.photoUrl),
        birthYear: person.birthYear,
        deathYear: person.deathYear,
        websiteUrl: person.websiteUrl,
        wikipediaUrl: person.wikipediaUrl,
        alternateNames: person.alternateNames,
      );

      _personCache[slug] = formattedPerson;
      return formattedPerson;
    } catch (e) {
      debugPrint('Error fetching person details: $e');
      return null;
    }
  }

  /// Books by a person (author/contributor)
  Future<List<BookModel>> getBooksByPerson(String personId) async {
    try {
      final response = await http.get(Uri.parse(
        '$_baseUrl/api/book-contributors?where[person][equals]=$personId&depth=2&limit=50',
      ));
      if (response.statusCode != 200) return [];

      final docs = jsonDecode(response.body)['docs'] as List;
      List<BookModel> books = [];
      for (var c in docs) {
        if (c['book'] is Map) {
          books.add(_formatBook(BookModel.fromJson(c['book'])));
        }
      }
      return books;
    } catch (e) {
      debugPrint('Error fetching books by person: $e');
      return [];
    }
  }

  /// Clear all caches (useful on pull-to-refresh)
  void clearCache() {
    _bookCache.clear();
    _personCache.clear();
    _homepageCache = null;
    _searchCache.clear();
  }
}
