import 'package:flutter/material.dart';
import '../../../../core/network/catalog_models.dart';
import '../../../../core/theme/app_colors.dart';

class BookCoverCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback? onTap;

  const BookCoverCard({super.key, required this.book, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            Container(
              width: 120,
              height: 180,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
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
                        size: 40,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              book.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
