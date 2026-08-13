import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/catalog_repository.dart';
import '../../../../core/network/catalog_models.dart';
import '../../../../core/theme/app_colors.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  
  bool _isLoading = true;
  List<BookModel> _books = [];

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _search(query);
    });
  }

  Future<void> _search(String query) async {
    setState(() => _isLoading = true);
    
    final repo = Provider.of<CatalogRepository>(context, listen: false);
    final results = await repo.searchBooks(query);
    
    if (mounted) {
      setState(() {
        _books = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _buildSearchBar(isDark),
          _buildFilterChips(isDark),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _books.isEmpty
                    ? _buildEmptyState(isDark)
                    : _buildGrid(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 2),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: 'Search for books, authors...',
            hintStyle: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight, fontWeight: FontWeight.bold),
            prefixIcon: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('🔍', style: TextStyle(fontSize: 20)),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          _buildChip('All Books', true, isDark),
          const SizedBox(width: 8),
          _buildChip('Audiobooks 🎧', false, isDark),
          const SizedBox(width: 8),
          _buildChip('Ebooks 📖', false, isDark),
          const SizedBox(width: 8),
          _buildChip('Fantasy', false, isDark),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : (isDark ? AppColors.surfaceDark : AppColors.backgroundLight),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.5) : (isDark ? AppColors.borderDark : AppColors.borderLight), 
          width: 2
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.primary : (isDark ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🤷‍♂️', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('No books found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 8),
          Text('Try searching for something else.', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
        ],
      ),
    );
  }

  Widget _buildGrid(bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.55,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
      ),
      itemCount: _books.length,
      itemBuilder: (context, index) {
        final book = _books[index];
        return _buildBookCard(book, isDark);
      },
    );
  }

  Widget _buildBookCard(BookModel book, bool isDark) {
    return GestureDetector(
      onTap: () => context.push('/book/${book.slug}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 2),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: book.coverUrl != null && book.coverUrl!.isNotEmpty
                      ? Image.network(
                          book.coverUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(book.title),
                        )
                      : _buildPlaceholder(book.title),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 2),
                        ),
                        child: const Text('🎧', style: TextStyle(fontSize: 10)),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 2),
                        ),
                        child: const Text('📖', style: TextStyle(fontSize: 10)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          book.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
            height: 1.2,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildPlaceholder(String title) {
    return Container(
      color: Colors.grey.withValues(alpha: 0.2),
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
