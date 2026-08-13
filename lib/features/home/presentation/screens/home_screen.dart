import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/catalog_repository.dart';
import '../../../../core/network/catalog_models.dart';
import '../../../../core/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  List<BookListModel> _homepageLists = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repo = Provider.of<CatalogRepository>(context, listen: false);
    final lists = await repo.getHomepageLists();
    if (mounted) {
      setState(() {
        _homepageLists = lists;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 4),
                Text('12', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black, fontSize: 16)),
                const SizedBox(width: 16),
                const Text('💎', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 4),
                const Text('450', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary, fontSize: 16)),
              ],
            ),
          )
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                children: [
                  _buildContinueReading(isDark),
                  const SizedBox(height: 32),
                  ..._homepageLists.map((list) => _buildCarousel(list, isDark)),
                ],
              ),
            ),
    );
  }

  Widget _buildContinueReading(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Continue Reading', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 2),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 90,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: Text('📖', style: TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('The Way of Kings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                      const SizedBox(height: 4),
                      Text('Part 1, Chapter 3', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
                      const SizedBox(height: 12),
                      Container(
                        height: 12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.35,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCarousel(BookListModel list, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              list.title, 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black),
            ),
          ),
          if (list.description != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                list.description!,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (list.books.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 2, style: BorderStyle.none),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text('No books in this list yet.', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
                ),
              ),
            )
          else
            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                itemCount: list.books.length,
                itemBuilder: (context, index) {
                  final book = list.books[index];
                  return _buildBookCard(book, isDark);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBookCard(BookModel book, bool isDark) {
    return GestureDetector(
      onTap: () => context.push('/book/${book.slug}'),
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 6.0),
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
          ),
          const SizedBox(height: 12),
          Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
              height: 1.2,
            ),
          ),
        ],
      ),
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
