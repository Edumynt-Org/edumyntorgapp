import 'package:flutter/material.dart';
import '../../../../core/network/catalog_models.dart';
import '../../../../core/theme/app_colors.dart';

class BookVerticalTile extends StatelessWidget {
  final BookModel book;
  final VoidCallback? onTap;

  const BookVerticalTile({super.key, required this.book, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 120, // fixed height for the tile
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            Container(
              width: 80,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                image: book.coverUrl != null && book.coverUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(book.coverUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (book.coverUrl == null || book.coverUrl!.isEmpty)
                  ? Center(
                      child: Icon(
                        Icons.book_rounded,
                        color: mutedColor,
                        size: 30,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // For now author is empty string in BookModel, so we skip or mock
                  Text(
                    'Various Authors', // Mocked as per user's current schema limit on list fetching
                    style: TextStyle(
                      fontSize: 13,
                      color: mutedColor,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  if (book.description != null && book.description!.isNotEmpty)
                    Expanded(
                      child: Text(
                        book.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: mutedColor,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 4),
                  // Rating mock
                  Row(
                    children: List.generate(5, (index) {
                      if (index < 4) {
                        return const Icon(
                          Icons.star_rounded,
                          color: AppColors.accentDark,
                          size: 16,
                        );
                      } else if (index == 4) {
                        return const Icon(
                          Icons.star_half_rounded,
                          color: AppColors.accentDark,
                          size: 16,
                        );
                      } else {
                        return const Icon(
                          Icons.star_border_rounded,
                          color: AppColors.accentDark,
                          size: 16,
                        );
                      }
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
