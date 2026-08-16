import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers.dart';
import '../../../../core/network/catalog_models.dart';
import '../../../../core/theme/app_colors.dart';

class BookDetailScreen extends ConsumerStatefulWidget {
  final String slug;

  const BookDetailScreen({super.key, required this.slug});

  @override
  ConsumerState<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends ConsumerState<BookDetailScreen> {
  bool _isLoading = true;
  BookDetailBundle? _bundle;
  String? _selectedEditionId;
  bool _descriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final repo = ref.read(catalogRepositoryProvider);
    final bundle = await repo.getBookDetails(widget.slug);

    if (mounted && bundle != null) {
      setState(() {
        _bundle = bundle;
        if (bundle.editions.isNotEmpty) {
          _selectedEditionId = bundle.editions.first.slug;
        }
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _currentEditionHasAudio() {
    if (_bundle == null || _selectedEditionId == null) return false;
    final toc = _bundle!.editionStructures[_selectedEditionId] ?? <TocItemModel>[];
    
    // Check if any chapter has audio
    for (var item in toc) {
      if (item.type == 'chapter' && item.hasAudio) return true;
      if (item.type == 'part' && item.chapters != null) {
        for (var ch in item.chapters!) {
          if (ch.hasAudio) return true;
        }
      }
    }
    return false;
  }

  void _showEditionSelector() {
    if (_bundle == null || _bundle!.editions.length <= 1) return;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Edition',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.textDark : AppColors.textLight,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ..._bundle!.editions.map((edition) {
                  final isSelected = edition.slug == _selectedEditionId;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedEditionId = edition.slug;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) 
                          : Colors.transparent,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              edition.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                                color: isSelected 
                                    ? Theme.of(context).colorScheme.primary 
                                    : (isDark ? AppColors.textDark : AppColors.textLight),
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDownloadsModal() {
    // Placeholder for download functionality
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Downloads',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.textDark : AppColors.textLight,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Icon(Icons.download_for_offline, size: 64, color: AppColors.textMutedLight),
                const SizedBox(height: 16),
                const Text('Download options will appear here.', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  String _toRoman(int num) {
    final values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
    final numerals = ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"];
    String result = "";
    for (int i = 0; i < values.length; i++) {
      while (num >= values[i]) {
        num -= values[i];
        result += numerals[i];
      }
    }
    return result.isEmpty ? "0" : result;
  }

  List<Widget> _buildTocList(List<TocItemModel> toc, bool isDark) {
    List<Widget> widgets = [];
    int standaloneChapterCount = 1;
    int partCount = 1;

    for (int i = 0; i < toc.length; i++) {
      final item = toc[i];
      
      if (item.type == 'part') {
        final title = 'Part $partCount: ${item.title}';
        partCount++;
        widgets.add(_buildPartHeader(title, isDark));
        
        if (item.chapters != null) {
          int partChapterCount = 1;
          for (int j = 0; j < item.chapters!.length; j++) {
            final ch = item.chapters![j];
            final isRealChapter = ch.chapterType == null || ch.chapterType == 'chapter';
            
            String prefix = '';
            if (isRealChapter) {
              prefix = '${_toRoman(partChapterCount)}. ';
              partChapterCount++;
            }
            
            widgets.add(_buildChapterRow(
              ch, 
              isDark, 
              displayTitle: '$prefix${ch.title}', 
              isLast: j == item.chapters!.length - 1 && i == toc.length - 1,
              isIndented: true,
            ));
          }
        }
      } else {
        final isRealChapter = item.chapterType == null || item.chapterType == 'chapter';
        String prefix = '';
        if (isRealChapter) {
          prefix = '$standaloneChapterCount. ';
          standaloneChapterCount++;
        }
        
        widgets.add(_buildChapterRow(
          item, 
          isDark, 
          displayTitle: '$prefix${item.title}',
          isLast: i == toc.length - 1,
          isIndented: false,
        ));
      }
    }
    
    return widgets;
  }

  Widget _buildPartHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: isDark ? AppColors.textDark : AppColors.textLight,
        ),
      ),
    );
  }

  Widget _buildChapterRow(TocItemModel chapter, bool isDark, {required String displayTitle, bool isFirst = false, bool isLast = false, bool isIndented = false}) {
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    
    Widget content = Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              displayTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
          ),
          if (chapter.hasAudio)
            Container(
              margin: const EdgeInsets.only(left: 12),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.headphones, 
                size: 16, 
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
    );

    if (isIndented) {
      content = Padding(
        padding: const EdgeInsets.only(left: 16.0), // Indent for chapters inside parts
        child: content,
      );
    }

    return InkWell(
      onTap: () {
        context.push('/book/${widget.slug}/$_selectedEditionId/${chapter.id}');
      },
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: const BackButton()),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_bundle == null) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: const BackButton()),
        body: Center(
          child: Text('Book not found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        ),
      );
    }

    final book = _bundle!.book;
    final hasAudio = _currentEditionHasAudio();
    final List<TocItemModel> toc = _selectedEditionId != null ? (_bundle!.editionStructures[_selectedEditionId] ?? <TocItemModel>[]) : <TocItemModel>[];

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // 1. Transparent App Bar
              SliverAppBar(
                pinned: true,
                backgroundColor: bgColor,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: textColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.share_outlined, color: textColor),
                    onPressed: () {},
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
                      icon: Icon(Icons.file_download_outlined, color: textColor),
                      onPressed: _showDownloadsModal,
                    ),
                  ),
                ],
              ),
              
              // 2. Hero Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    children: [
                      // Cover
                      Container(
                        width: 160,
                        height: 240,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: book.coverUrl != null && book.coverUrl!.isNotEmpty
                              ? Image.network(book.coverUrl!, fit: BoxFit.cover)
                              : Container(
                                  color: isDark ? AppColors.surfaceDark : Colors.white,
                                  alignment: Alignment.center,
                                  child: Text(book.title, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Metadata
                      Text(
                        book.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_bundle!.authors.isNotEmpty)
                        Text(
                          _bundle!.authors.join(', '),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (book.firstPublishedYear != null) ...[
                            Text(
                              book.firstPublishedYear.toString(),
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                            ),
                            const SizedBox(width: 12),
                            Text('•', style: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
                            const SizedBox(width: 12),
                          ],
                          if (book.originalLanguage != null)
                            Text(
                              book.originalLanguage!,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Description
                      if (book.description != null && book.description!.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _descriptionExpanded = !_descriptionExpanded;
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AnimatedCrossFade(
                                duration: const Duration(milliseconds: 300),
                                crossFadeState: _descriptionExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                firstChild: ShaderMask(
                                  shaderCallback: (rect) {
                                    return LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.black, Colors.transparent],
                                      stops: const [0.5, 1.0],
                                    ).createShader(rect);
                                  },
                                  blendMode: BlendMode.dstIn,
                                  child: Text(
                                    book.description!,
                                    maxLines: 3,
                                    style: TextStyle(
                                      fontSize: 15,
                                      height: 1.5,
                                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                    ),
                                  ),
                                ),
                                secondChild: Text(
                                  book.description!,
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 1.5,
                                    color: isDark ? AppColors.textDark : AppColors.textLight,
                                  ),
                                ),
                              ),
                              if (!_descriptionExpanded)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Read more',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // 3. Edition Selector
              if (_bundle!.editions.length > 1)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: InkWell(
                      onTap: _showEditionSelector,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.library_books_outlined, size: 20, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Edition: ${_bundle!.editions.firstWhere((e) => e.slug == _selectedEditionId).title}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_drop_down, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // 4. Content (Chapters List)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 120), // Padding bottom for FAB
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    _buildTocList(toc, isDark),
                  ),
                ),
              ),
            ],
          ),

          // 5. Floating Action Buttons
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _startReading(toc);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 8,
                      shadowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book, size: 20),
                        SizedBox(width: 10),
                        Text('Read', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ),
                if (hasAudio) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                         _startReading(toc); // Audio logic to be handled in player
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentLight, // Gold for audio
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 8,
                        shadowColor: AppColors.accentLight.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.headphones, size: 20),
                          SizedBox(width: 10),
                          Text('Listen', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startReading(List<TocItemModel> toc) {
    if (_selectedEditionId == null || toc.isEmpty) return;
    
    String firstChapter = 'c1';
    final firstItem = toc.first;
    if (firstItem.type == 'chapter') {
      firstChapter = firstItem.id;
    } else if (firstItem.chapters != null && firstItem.chapters!.isNotEmpty) {
      firstChapter = firstItem.chapters!.first.id;
    }
    
    context.push('/book/${widget.slug}/$_selectedEditionId/$firstChapter');
  }
}
