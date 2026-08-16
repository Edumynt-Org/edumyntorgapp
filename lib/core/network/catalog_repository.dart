import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'catalog_models.dart';

class CatalogRepository {
  String get _baseUrl => ApiConfig.baseUrl;

  String _formatCoverUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return '$_baseUrl$url';
  }

  Future<List<BookListModel>> getHomepageLists() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/list-type-book-lists?where[list_type.slug][equals]=homepage&sort=sort_order&depth=1'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final junctions = data['docs'] as List;
        final lists = junctions.map((j) => j['book_list']).where((l) => l != null && l is Map && l['status'] == 'published').toList();
        List<BookListModel> result = [];
        for (var listData in lists) {
          final listId = listData['id'];
          final itemsResponse = await http.get(Uri.parse('$_baseUrl/api/book-list-items?where[book_list][equals]=$listId&sort=sort_order&depth=2&limit=10'));
          List<BookModel> books = [];
          int totalBooks = 0;
          if (itemsResponse.statusCode == 200) {
            final itemsData = jsonDecode(itemsResponse.body);
            final items = itemsData['docs'] as List;
            totalBooks = itemsData['totalDocs'] ?? 0;
            for (var item in items) {
              if (item['book'] != null && item['book'] is Map) {
                final bookModel = BookModel.fromJson(item['book']);
                final formattedBook = BookModel(
                  id: bookModel.id, title: bookModel.title, slug: bookModel.slug, coverUrl: _formatCoverUrl(bookModel.coverUrl), description: bookModel.description,
                );
                books.add(formattedBook);
              }
            }
          }
          result.add(BookListModel.fromJson(listData, books, totalBooks));
        }
        return result;
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching homepage lists: $e');
      return [];
    }
  }

  Future<BookListModel?> getBookListById(String id) async {
    try {
      final listResponse = await http.get(Uri.parse('$_baseUrl/api/book-lists/$id'));
      if (listResponse.statusCode != 200) return null;
      final listData = jsonDecode(listResponse.body);
      final itemsResponse = await http.get(Uri.parse('$_baseUrl/api/book-list-items?where[book_list][equals]=$id&sort=sort_order&depth=2&limit=100'));
      List<BookModel> books = [];
      int totalBooks = 0;
      if (itemsResponse.statusCode == 200) {
        final itemsData = jsonDecode(itemsResponse.body);
        final items = itemsData['docs'] as List;
        totalBooks = itemsData['totalDocs'] ?? 0;
        for (var item in items) {
          if (item['book'] != null && item['book'] is Map) {
            final bookModel = BookModel.fromJson(item['book']);
            final formattedBook = BookModel(
              id: bookModel.id, title: bookModel.title, slug: bookModel.slug, coverUrl: _formatCoverUrl(bookModel.coverUrl), description: bookModel.description,
            );
            books.add(formattedBook);
          }
        }
      }
      return BookListModel.fromJson(listData, books, totalBooks);
    } catch (e) {
      return null;
    }
  }

  Future<List<BookModel>> searchBooks(String query) async {
    try {
      String url = '$_baseUrl/api/books?where[status][equals]=published&depth=1&limit=50';
      if (query.isNotEmpty) url += '&where[title][like]=$query';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final docs = data['docs'] as List;
        return docs.map((json) {
          final bookModel = BookModel.fromJson(json);
          return BookModel(
            id: bookModel.id, title: bookModel.title, slug: bookModel.slug, coverUrl: _formatCoverUrl(bookModel.coverUrl), description: bookModel.description,
          );
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<BookDetailBundle?> getBookDetails(String slug) async {
    try {
      // 1. Fetch book
      final bookResponse = await http.get(Uri.parse('$_baseUrl/api/books?where[slug][equals]=$slug&where[status][equals]=published&depth=1&limit=1'));
      if (bookResponse.statusCode != 200) return null;
      final bookData = jsonDecode(bookResponse.body);
      if ((bookData['docs'] as List).isEmpty) return null;

      final bookJson = bookData['docs'][0];
      final book = BookModel.fromJson(bookJson);
      final formattedBook = BookModel(
        id: book.id, title: book.title, slug: book.slug, coverUrl: _formatCoverUrl(book.coverUrl), description: book.description,
        firstPublishedYear: book.firstPublishedYear, originalLanguage: book.originalLanguage,
      );

      // 2. Fetch Authors
      List<String> authors = [];
      final authorsResponse = await http.get(Uri.parse('$_baseUrl/api/book-contributors?where[book][equals]=${book.id}&sort=sort_order&depth=1'));
      if (authorsResponse.statusCode == 200) {
        final docs = jsonDecode(authorsResponse.body)['docs'] as List;
        for (var c in docs) {
          if ((c['role'] == 'author' || c['role'] == 'co_author') && c['person'] is Map) authors.add(c['person']['name']);
        }
      }

      // 3. Fetch Genres
      List<String> genres = [];
      final genresResponse = await http.get(Uri.parse('$_baseUrl/api/book-genres?where[book][equals]=${book.id}&depth=1'));
      if (genresResponse.statusCode == 200) {
        final docs = jsonDecode(genresResponse.body)['docs'] as List;
        for (var c in docs) {
          if (c['genre'] is Map) genres.add(c['genre']['name']);
        }
      }

      // 4. Fetch Editions
      List<EditionModel> editions = [];
      final textEdResponse = await http.get(Uri.parse('$_baseUrl/api/editions?where[book][equals]=${book.id}&where[status][equals]=published&sort=sort_order&depth=0'));
      if (textEdResponse.statusCode == 200) {
        final docs = jsonDecode(textEdResponse.body)['docs'] as List;
        editions = docs.map((json) => EditionModel.fromJson(json)).toList();
      }

      // 5. Fetch Audio Chapters Map for fast lookup (just to see if a chapter has audio)
      Map<String, bool> chapterAudioMap = {};
      final audioChResponse = await http.get(Uri.parse('$_baseUrl/api/audio-chapters?depth=0&limit=1000'));
      if (audioChResponse.statusCode == 200) {
        final docs = jsonDecode(audioChResponse.body)['docs'] as List;
        for (var doc in docs) {
          if (doc['chapter'] != null) {
            String chapterId = doc['chapter'] is Map ? doc['chapter']['id'] : doc['chapter'].toString();
            chapterAudioMap[chapterId] = true;
          }
        }
      }

      // 6. Build Edition Structures
      Map<String, List<TocItemModel>> editionStructures = {};
      for (var ed in editions) {
        List<TocItemModel> allItems = [];

        // Chapters
        final chResp = await http.get(Uri.parse('$_baseUrl/api/edition-chapters?where[edition][equals]=${ed.id}&sort=sort_order&depth=1'));
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

        // Parts
        final pResp = await http.get(Uri.parse('$_baseUrl/api/edition-parts?where[edition][equals]=${ed.id}&sort=sort_order&depth=1'));
        if (pResp.statusCode == 200) {
          final docs = jsonDecode(pResp.body)['docs'] as List;
          for (var ep in docs) {
            if (ep['part'] is Map) {
              final partId = ep['part']['id'];
              List<TocItemModel> partChapters = [];
              final pcResp = await http.get(Uri.parse('$_baseUrl/api/part-chapters?where[part][equals]=$partId&sort=sort_order&depth=1'));
              if (pcResp.statusCode == 200) {
                final pcDocs = jsonDecode(pcResp.body)['docs'] as List;
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
                id: partId, title: ep['part']['title'], type: 'part', sortOrder: ep['sort_order'] ?? 0, chapters: partChapters,
              ));
            }
          }
        }

        allItems.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        editionStructures[ed.slug] = allItems;
      }

      return BookDetailBundle(
        book: formattedBook,
        authors: authors,
        genres: genres,
        editions: editions,
        editionStructures: editionStructures,
      );
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getChapterContent(String chapterSlug) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/chapters?where[slug][equals]=$chapterSlug&depth=0&limit=1'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final docs = data['docs'] as List;
        if (docs.isNotEmpty) {
          final chapter = docs[0];
          
          // Fetch audio URL if exists
          String? audioUrl;
          try {
            final audioResp = await http.get(Uri.parse('$_baseUrl/api/audio-chapters?where[chapter][equals]=${chapter['id']}&depth=1'));
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
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
