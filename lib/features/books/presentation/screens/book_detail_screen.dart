import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/catalog_repository.dart';
import '../../../../core/network/catalog_models.dart';
import '../../../../core/theme/app_colors.dart';

class BookDetailScreen extends StatefulWidget {
  final String slug;

  const BookDetailScreen({super.key, required this.slug});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  BookDetailBundle? _bundle;
  TabController? _tabController;

  String? _selectedTextEditionId;
  String? _selectedAudioEditionId;
  String _detailsViewId = 'book';

  List<String> _tabs = [];

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final repo = Provider.of<CatalogRepository>(context, listen: false);
    final bundle = await repo.getBookDetails(widget.slug);
    
    if (mounted && bundle != null) {
      _tabs = [];
      if (bundle.textEditions.isNotEmpty) _tabs.add('Read');
      if (bundle.audioEditions.isNotEmpty) _tabs.add('Listen');
      _tabs.add('Details');
      _tabs.add('Reviews');

      _tabController = TabController(length: _tabs.length, vsync: this);
      
      setState(() {
        _bundle = bundle;
        if (bundle.textEditions.isNotEmpty) {
          _selectedTextEditionId = bundle.textEditions.first.slug;
        }
        if (bundle.audioEditions.isNotEmpty) {
          _selectedAudioEditionId = bundle.audioEditions.first.slug;
        }
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _showDescriptionModal(BuildContext context, bool isDark) {
    if (_bundle == null) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('About this book', style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _bundle!.book.title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black),
                ),
                if (_bundle!.authors.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'by ${_bundle!.authors.join(', ')}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  _bundle!.book.description ?? '',
                  style: TextStyle(fontSize: 16, height: 1.6, color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87),
                ),
              ],
            ),
          ),
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_bundle == null) {
      return Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: Center(
          child: Text('Book not found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // Floating Action Buttons (AppBar)
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black, size: 20),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Text('🔖', style: TextStyle(fontSize: 16)),
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Text('⋯', style: TextStyle(fontSize: 16)),
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              
              // Side-by-side Hero Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cover
                      Container(
                        width: 120,
                        height: 180,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: _bundle!.book.coverUrl != null && _bundle!.book.coverUrl!.isNotEmpty
                              ? Image.network(_bundle!.book.coverUrl!, fit: BoxFit.cover)
                              : Center(child: Text(_bundle!.book.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _bundle!.book.title,
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, height: 1.1, color: isDark ? Colors.white : Colors.black),
                            ),
                            if (_bundle!.authors.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'by ${_bundle!.authors.join(', ')}',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                              ),
                            ],
                            const SizedBox(height: 12),
                            // Badges
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                if (_bundle!.textEditions.isNotEmpty)
                                  _buildBadge('📖 ${_bundle!.textEditions.length} Edition${_bundle!.textEditions.length > 1 ? 's' : ''}', isDark),
                                if (_bundle!.audioEditions.isNotEmpty)
                                  _buildBadge('🎧 ${_bundle!.audioEditions.length} Audio', isDark),
                              ],
                            ),
                            if (_bundle!.book.description != null && _bundle!.book.description!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                _bundle!.book.description!,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 14, height: 1.4, color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black87),
                              ),
                              GestureDetector(
                                onTap: () => _showDescriptionModal(context, isDark),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text('Read more', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Sticky Tabs
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    isScrollable: false,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    tabs: _tabs.map((t) {
                      String icon = '';
                      if (t == 'Read') icon = '📖 ';
                      if (t == 'Listen') icon = '🎧 ';
                      return Tab(text: '$icon$t');
                    }).toList(),
                  ),
                  isDark,
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: _tabs.map((tab) {
              if (tab == 'Read') return _buildReadTab(isDark);
              if (tab == 'Listen') return _buildListenTab(isDark);
              if (tab == 'Details') return _buildDetailsTab(isDark);
              return _buildReviewsTab(isDark);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
    );
  }

  Widget _buildEditionSwitcher(List<EditionModel> editions, String selectedId, Function(String) onSelect, bool isDark) {
    if (editions.length <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: editions.map((ed) {
          final isSelected = ed.id == selectedId;
          return GestureDetector(
            onTap: () => onSelect(ed.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : (isDark ? AppColors.surfaceDark : AppColors.backgroundLight),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.5) : (isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
              ),
              child: Text(
                ed.title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primary : (isDark ? Colors.white : Colors.black),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReadTab(bool isDark) {
    final structures = _bundle!.textEditionStructures[_selectedTextEditionId] ?? [];
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildEditionSwitcher(
                _bundle!.textEditions,
                _selectedTextEditionId!,
                (slug) => setState(() => _selectedTextEditionId = slug),
                isDark,
              ),
              TocAccordionWidget(items: structures, isDark: isDark),
            ],
          ),
        ),
        _buildStickyCTA('Start Reading', AppColors.primary, isDark, _selectedTextEditionId),
      ],
    );
  }

  Widget _buildListenTab(bool isDark) {
    final structures = _bundle!.audioEditionStructures[_selectedAudioEditionId] ?? [];
    final narrator = _bundle!.audioNarrators[_selectedAudioEditionId];
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildEditionSwitcher(
                _bundle!.audioEditions,
                _selectedAudioEditionId!,
                (slug) => setState(() => _selectedAudioEditionId = slug),
                isDark,
              ),
              if (narrator != null) ...[
                Text('🎙️ Narrated by $narrator', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
                const SizedBox(height: 16),
              ],
              TocAccordionWidget(items: structures, isDark: isDark),
            ],
          ),
        ),
        _buildStickyCTA('Start Listening', AppColors.secondary, isDark, _selectedAudioEditionId),
      ],
    );
  }

  Widget _buildDetailsTab(bool isDark) {
    final allEditions = [
      ..._bundle!.textEditions.map((e) => {'id': e.id, 'title': e.title, 'type': 'text'}),
      ..._bundle!.audioEditions.map((e) => {'id': e.id, 'title': e.title, 'type': 'audio'}),
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildDetailSwitcherTab('book', '📚 Book Details', isDark),
            ...allEditions.map((e) => _buildDetailSwitcherTab(e['id'] as String, '${e['type'] == 'audio' ? '🎧' : '📖'} ${e['title']}', isDark)),
          ],
        ),
        const SizedBox(height: 24),
        if (_detailsViewId == 'book') ...[
          _buildDetailRow('First Published', _bundle!.book.firstPublishedYear?.toString(), isDark),
          _buildDetailRow('Original Language', _bundle!.book.originalLanguage, isDark),
          if (_bundle!.genres.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Genres', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _bundle!.genres.map((g) => _buildBadge(g, isDark)).toList(),
            )
          ]
        ] else ...(() {
          final edText = _bundle!.textEditions.where((e) => e.id == _detailsViewId).toList();
          final edAudio = _bundle!.audioEditions.where((e) => e.id == _detailsViewId).toList();
          if (edText.isNotEmpty) {
            final e = edText.first;
            return [
              _buildDetailRow('Title', e.title, isDark),
              _buildDetailRow('Format', 'Ebook', isDark),
              _buildDetailRow('Source', e.sourceName, isDark),
              _buildDetailRow('Rights', e.rightsStatus?.replaceAll('_', ' '), isDark),
            ];
          } else if (edAudio.isNotEmpty) {
            final e = edAudio.first;
            return [
              _buildDetailRow('Title', e.title, isDark),
              _buildDetailRow('Format', 'Audiobook', isDark),
              _buildDetailRow('Source', e.sourceName, isDark),
              _buildDetailRow('Rights', e.rightsStatus?.replaceAll('_', ' '), isDark),
            ];
          }
          return <Widget>[];
        }()),
      ],
    );
  }

  Widget _buildDetailSwitcherTab(String id, String label, bool isDark) {
    final isSelected = _detailsViewId == id;
    return GestureDetector(
      onTap: () => setState(() => _detailsViewId = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : (isDark ? AppColors.surfaceDark : AppColors.backgroundLight),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.5) : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.primary : (isDark ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value, bool isDark) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
        ],
      ),
    );
  }

  Widget _buildReviewsTab(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('Reviews Coming Soon', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 8),
          Text('We\'re building something special.', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
        ],
      ),
    );
  }

  Widget _buildStickyCTA(String text, Color color, bool isDark, String? editionId) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            if (editionId != null) {
              final toc = _bundle!.textEditionStructures[editionId] ?? _bundle!.audioEditionStructures[editionId];
              String firstChapter = 'c1';
              if (toc != null && toc.isNotEmpty) {
                final firstItem = toc.first;
                if (firstItem.type == 'chapter') {
                  firstChapter = firstItem.id;
                } else if (firstItem.chapters != null && firstItem.chapters!.isNotEmpty) {
                  firstChapter = firstItem.chapters!.first.id;
                }
              }
              context.push('/book/${widget.slug}/$editionId/$firstChapter');
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class TocAccordionWidget extends StatefulWidget {
  final List<TocItemModel> items;
  final bool isDark;

  const TocAccordionWidget({super.key, required this.items, required this.isDark});

  @override
  State<TocAccordionWidget> createState() => _TocAccordionWidgetState();
}

class _TocAccordionWidgetState extends State<TocAccordionWidget> {
  late Set<String> _openParts;

  @override
  void initState() {
    super.initState();
    _openParts = widget.items.where((i) => i.type == 'part').map((i) => i.id).toSet();
  }

  @override
  void didUpdateWidget(covariant TocAccordionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _openParts = widget.items.where((i) => i.type == 'part').map((i) => i.id).toSet();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              const Text('📄', style: TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text('Content coming soon.', style: TextStyle(fontWeight: FontWeight.bold, color: widget.isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: List.generate(widget.items.length, (index) {
        final item = widget.items[index];
        final isNextToRead = index == 0;

        if (item.type == 'chapter') {
          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: isNextToRead ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isNextToRead ? Border.all(color: AppColors.primary.withValues(alpha: 0.2)) : null,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              dense: true,
              leading: SizedBox(
                width: 24,
                child: Text('${index + 1}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: isNextToRead ? AppColors.primary : (widget.isDark ? AppColors.textMutedDark : AppColors.textMutedLight))),
              ),
              title: Text(item.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: widget.isDark ? Colors.white : Colors.black)),
              trailing: isNextToRead
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
                      child: const Text('NEXT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white)),
                    )
                  : null,
            ),
          );
        }

        // Part
        final isOpen = _openParts.contains(item.id);
        return Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  if (isOpen) {
                    _openParts.remove(item.id);
                  } else {
                    _openParts.add(item.id);
                  }
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text('${index + 1}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: widget.isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
                    ),
                    const SizedBox(width: 4),
                    Text(isOpen ? '▾' : '▸', style: TextStyle(fontWeight: FontWeight.bold, color: widget.isDark ? AppColors.textMutedDark : AppColors.textMutedLight, fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item.title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: widget.isDark ? Colors.white : Colors.black)),
                    ),
                    Text('${item.chapters?.length ?? 0} chapters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: widget.isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
                  ],
                ),
              ),
            ),
            if (isOpen && item.chapters != null)
              Padding(
                padding: const EdgeInsets.only(left: 40, bottom: 8),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(left: BorderSide(color: widget.isDark ? AppColors.borderDark : AppColors.borderLight, width: 2)),
                  ),
                  child: Column(
                    children: List.generate(item.chapters!.length, (chIdx) {
                      final ch = item.chapters![chIdx];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        dense: true,
                        leading: SizedBox(
                          width: 20,
                          child: Text('${chIdx + 1}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: widget.isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
                        ),
                        title: Text(ch.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: widget.isDark ? Colors.white : Colors.black)),
                      );
                    }),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final bool _isDark;

  _SliverAppBarDelegate(this._tabBar, this._isDark);

  @override
  double get minExtent => _tabBar.preferredSize.height + 1.0;
  @override
  double get maxExtent => _tabBar.preferredSize.height + 1.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: _isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      child: Column(
        children: [
          _tabBar,
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
