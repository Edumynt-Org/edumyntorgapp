import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/home_providers.dart';
import '../widgets/book_vertical_tile.dart';

class BookListScreen extends ConsumerWidget {
  final String listId;

  const BookListScreen({super.key, required this.listId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asyncList = ref.watch(bookListDetailProvider(listId));

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: asyncList.when(
          data: (list) => list == null
              ? const Text('List Not Found')
              : Text(
                  list.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
          loading: () => const Text('Loading...'),
          error: (err, stack) => const Text('Error'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            onPressed: () {
              // TODO: Sort and filter
            },
          ),
        ],
        centerTitle: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: asyncList.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (list) {
          if (list == null) {
            return const Center(child: Text('Book list could not be found.'));
          }

          if (list.books.isEmpty) {
            return const Center(child: Text('No books in this list.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.books.length,
            itemBuilder: (context, index) {
              final book = list.books[index];
              return BookVerticalTile(
                book: book,
                onTap: () {
                  // Navigate to book details
                  context.push('/book/${book.slug}');
                },
              );
            },
          );
        },
      ),
    );
  }
}
