import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/catalog_models.dart';
import '../../../../core/providers.dart';

final homepageListsProvider = FutureProvider<List<BookListModel>>((ref) async {
  final catalogRepo = ref.watch(catalogRepositoryProvider);
  return await catalogRepo.getHomepageLists();
});

final bookListDetailProvider = FutureProvider.family<BookListModel?, String>((
  ref,
  listId,
) async {
  final catalogRepo = ref.watch(catalogRepositoryProvider);
  return await catalogRepo.getBookListById(listId);
});
