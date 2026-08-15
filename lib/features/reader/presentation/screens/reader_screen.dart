import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../core/network/catalog_models.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  final String slug;
  final String editionId;
  final String chapterId;

  const ReaderScreen({
    super.key,
    required this.slug,
    required this.editionId,
    required this.chapterId,
  });

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  bool _isLoading = true;
  bool _showUI = true;
  double _fontSize = 18.0;
  String _fontFamily = 'PlusJakartaSans'; // default

  Map<String, dynamic>? _chapterContent;
  List<TocItemModel> _toc = [];

  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchData();
  }

  Future<void> _fetchData() async {
    final repo = ref.read(catalogRepositoryProvider);
    final bundle = await repo.getBookDetails(widget.slug);
    final content = await repo.getChapterContent(widget.chapterId);

    if (mounted) {
      setState(() {
        if (bundle != null) {
          _toc =
              bundle.textEditionStructures[widget.editionId] ??
              bundle.audioEditionStructures[widget.editionId] ??
              [];
        }
        _chapterContent = content;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_showUI) setState(() => _showUI = false);
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_showUI) setState(() => _showUI = true);
    }
  }

  void _showSettingsModal(bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Consumer(
              builder: (context, modalRef, child) {
                final themeProviderNotifier = modalRef.watch(themeProvider);
                final theme = Theme.of(context);
                final colorScheme = theme.colorScheme;
                final onSurface = colorScheme.onSurface;
                final onSurfaceMuted = onSurface.withValues(alpha: 0.54);
                final borderColor =
                    theme.dividerTheme.color ?? colorScheme.outline;

                return Container(
                  height: MediaQuery.of(context).size.height, // Full screen
                  padding: const EdgeInsets.only(
                    top: 48,
                  ), // Space for status bar
                  color: theme.scaffoldBackgroundColor,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Display Settings',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: onSurface,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: onSurface),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Font Size
                              Text(
                                'FONT SIZE',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: onSurfaceMuted,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(
                                          () => _fontSize = (_fontSize - 2)
                                              .clamp(12.0, 32.0),
                                        );
                                        setModalState(() {});
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorScheme.surface,
                                        foregroundColor: onSurface,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                      ),
                                      child: const Text(
                                        'A-',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    '${_fontSize.toInt()}px',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(
                                          () => _fontSize = (_fontSize + 2)
                                              .clamp(12.0, 32.0),
                                        );
                                        setModalState(() {});
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorScheme.surface,
                                        foregroundColor: onSurface,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                      ),
                                      child: const Text(
                                        'A+',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),

                              // Font Family
                              Text(
                                'FONT STYLE',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: onSurfaceMuted,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setState(
                                          () => _fontFamily = 'PlusJakartaSans',
                                        );
                                        setModalState(() {});
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color:
                                              _fontFamily == 'PlusJakartaSans'
                                              ? colorScheme.primary
                                              : borderColor,
                                        ),
                                        backgroundColor:
                                            _fontFamily == 'PlusJakartaSans'
                                            ? colorScheme.primary.withValues(
                                                alpha: 0.1,
                                              )
                                            : Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                      ),
                                      child: Text(
                                        'Sans Serif',
                                        style: TextStyle(
                                          fontFamily: 'PlusJakartaSans',
                                          color: onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setState(() => _fontFamily = 'Georgia');
                                        setModalState(() {});
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: _fontFamily == 'Georgia'
                                              ? colorScheme.primary
                                              : borderColor,
                                        ),
                                        backgroundColor:
                                            _fontFamily == 'Georgia'
                                            ? colorScheme.primary.withValues(
                                                alpha: 0.1,
                                              )
                                            : Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                      ),
                                      child: Text(
                                        'Serif',
                                        style: TextStyle(
                                          fontFamily: 'Georgia',
                                          color: onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),

                              // Theme Toggle
                              Text(
                                'THEME',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: onSurfaceMuted,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        if (themeProviderNotifier.isDarkMode) {
                                          modalRef
                                              .read(themeProvider)
                                              .toggleTheme();
                                        }
                                        setModalState(() {});
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color:
                                              !themeProviderNotifier.isDarkMode
                                              ? colorScheme.primary
                                              : borderColor,
                                        ),
                                        backgroundColor:
                                            !themeProviderNotifier.isDarkMode
                                            ? colorScheme.primary.withValues(
                                                alpha: 0.1,
                                              )
                                            : Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                      ),
                                      child: Text(
                                        'Light',
                                        style: TextStyle(color: onSurface),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        if (!themeProviderNotifier.isDarkMode) {
                                          modalRef
                                              .read(themeProvider)
                                              .toggleTheme();
                                        }
                                        setModalState(() {});
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color:
                                              themeProviderNotifier.isDarkMode
                                              ? colorScheme.primary
                                              : borderColor,
                                        ),
                                        backgroundColor:
                                            themeProviderNotifier.isDarkMode
                                            ? colorScheme.primary.withValues(
                                                alpha: 0.1,
                                              )
                                            : Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                      ),
                                      child: Text(
                                        'Dark',
                                        style: TextStyle(color: onSurface),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 48),

                              // Live Preview at bottom
                              Text(
                                'PREVIEW',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: onSurfaceMuted,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  border: Border.all(color: borderColor),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'The quick brown fox jumps over the lazy dog. A journey of a thousand miles begins with a single step.',
                                  style: TextStyle(
                                    fontFamily: _fontFamily,
                                    fontSize: _fontSize,
                                    height: 1.8,
                                    color: onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 48),

                              // Reset to Default
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _fontSize = 18.0;
                                      _fontFamily = 'PlusJakartaSans';
                                    });
                                    setModalState(() {});
                                  },
                                  child: Text(
                                    'Reset to Default',
                                    style: TextStyle(
                                      color: onSurfaceMuted,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 48),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _handleHorizontalSwipe(DragEndDetails details) {
    if (details.primaryVelocity == null || _toc.isEmpty) return;

    // Flatten TOC to get purely chapters
    List<TocItemModel> flatToc = [];
    for (var item in _toc) {
      if (item.type == 'chapter') flatToc.add(item);
      if (item.chapters != null) flatToc.addAll(item.chapters!);
    }

    int currentIndex = flatToc.indexWhere(
      (c) => c.id == widget.chapterId || c.title == _chapterContent?['title'],
    );

    // Swipe Left (Next Chapter)
    if (details.primaryVelocity! < -300) {
      if (currentIndex >= 0 && currentIndex < flatToc.length - 1) {
        context.pushReplacement(
          '/book/${widget.slug}/${widget.editionId}/${flatToc[currentIndex + 1].id}',
        ); // using id as slug for now or assuming id matches slug
      }
    }
    // Swipe Right (Previous Chapter)
    else if (details.primaryVelocity! > 300) {
      if (currentIndex > 0) {
        context.pushReplacement(
          '/book/${widget.slug}/${widget.editionId}/${flatToc[currentIndex - 1].id}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProviderNotifier = ref.watch(themeProvider);
    final isDark = themeProviderNotifier.isDarkMode;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Flatten TOC
    List<TocItemModel> flatToc = [];
    for (var item in _toc) {
      if (item.type == 'chapter') flatToc.add(item);
      if (item.chapters != null) flatToc.addAll(item.chapters!);
    }

    // Fallback if chapter not found in toc
    int currentIndex = flatToc.indexWhere(
      (c) => c.id == widget.chapterId || c.title == _chapterContent?['title'],
    );

    final hasPrev = currentIndex > 0;
    final hasNext = currentIndex >= 0 && currentIndex < flatToc.length - 1;

    String content = _chapterContent?['content'] ?? 'No content available.';
    String title = _chapterContent?['title'] ?? 'Chapter';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      endDrawer: _buildTocDrawer(isDark, currentIndex, flatToc),
      body: GestureDetector(
        onTap: () => setState(() => _showUI = !_showUI),
        onHorizontalDragEnd: _handleHorizontalSwipe,
        child: Stack(
          children: [
            // Content
            SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.only(
                top: 100,
                bottom: 100,
                left: 24,
                right: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: _fontSize * 1.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    content,
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: _fontSize,
                      height: 1.8,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.9)
                          : Colors.black.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Bottom Nav Buttons
                  Row(
                    children: [
                      if (hasPrev)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              context.pushReplacement(
                                '/book/${widget.slug}/${widget.editionId}/${flatToc[currentIndex - 1].id}',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? AppColors.surfaceDark
                                  : Colors.grey.shade200,
                              foregroundColor: isDark
                                  ? Colors.white
                                  : Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                            child: const Text('← Previous'),
                          ),
                        )
                      else
                        const Spacer(),

                      const SizedBox(width: 16),

                      if (hasNext)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              context.pushReplacement(
                                '/book/${widget.slug}/${widget.editionId}/${flatToc[currentIndex + 1].id}',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                            child: const Text('Next →'),
                          ),
                        )
                      else
                        const Spacer(),
                    ],
                  ),
                ],
              ),
            ),

            // Header Overlay
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: _showUI ? 0 : -100,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  height: 60,
                  color: isDark
                      ? AppColors.backgroundDark
                      : AppColors.backgroundLight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        onPressed: () {
                          context.go('/book/${widget.slug}');
                        },
                      ),
                      Expanded(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Text(
                          'Aa',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        onPressed: () => _showSettingsModal(isDark),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.menu,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        onPressed: () {
                          _scaffoldKey.currentState?.openEndDrawer();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTocDrawer(
    bool isDark,
    int currentIndex,
    List<TocItemModel> flatToc,
  ) {
    return Drawer(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Table of Contents',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: flatToc.length,
                itemBuilder: (context, index) {
                  final item = flatToc[index];
                  final isCurrent = index == currentIndex;
                  return ListTile(
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isCurrent
                            ? Theme.of(context).colorScheme.primary
                            : (isDark ? Colors.white : Colors.black),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      if (!isCurrent) {
                        context.pushReplacement(
                          '/book/${widget.slug}/${widget.editionId}/${item.id}',
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
