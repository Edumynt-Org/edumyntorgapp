import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/catalog_models.dart';
import '../../../../core/theme/app_colors.dart';
import 'book_cover_card.dart';

class BookListHorizontalSection extends StatelessWidget {
  final BookListModel bookList;

  const BookListHorizontalSection({super.key, required this.bookList});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                bookList.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${bookList.totalBooks}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: mutedColor,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  context.push('/book-list/${bookList.id}');
                },
                child: Text(
                  'All',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Horizontal Scroll
        SizedBox(
          height: 270,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: bookList.books.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final book = bookList.books[index];
              return BookCoverCard(
                book: book,
                onTap: () {
                  context.push('/book/${book.slug}');
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
