import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/providers.dart';
import '../../../../core/network/catalog_models.dart';
import '../../../../core/widgets/skeleton_shimmer.dart';

class PersonDetailScreen extends ConsumerStatefulWidget {
  final String slug;
  
  const PersonDetailScreen({
    super.key,
    required this.slug,
  });

  @override
  ConsumerState<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends ConsumerState<PersonDetailScreen> {
  bool _isLoading = true;
  PersonModel? _person;
  List<BookModel> _books = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final repo = ref.read(catalogRepositoryProvider);
      final person = await repo.getPersonDetails(widget.slug);
      
      if (person != null) {
        final books = await repo.getBooksByPerson(person.id);
        if (mounted) {
          setState(() {
            _person = person;
            _books = books;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Person not found';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load details';
          _isLoading = false;
        });
      }
    }
  }

  String _formatUrl(String url) {
    if (url.startsWith('http')) return url;
    // Assuming backend is at localhost:3000 as per docs
    const baseUrl = 'http://10.0.2.2:3000'; 
    return '$baseUrl$url';
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _isLoading 
          ? _buildLoadingState() 
          : _error != null 
              ? _buildErrorState(context)
              : _buildContent(context),
    );
  }

  Widget _buildLoadingState() {
    return const ShimmerWrap(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: SkeletonBox(width: 120, height: 24),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  SkeletonBox(width: 120, height: 120, borderRadius: 60),
                  SizedBox(height: AppSpacing.md),
                  SkeletonBox(width: 200, height: 32),
                  SizedBox(height: AppSpacing.sm),
                  SkeletonBox(width: 100, height: 16),
                  SizedBox(height: AppSpacing.lg),
                  SkeletonBox(width: double.infinity, height: 100),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(
          _error ?? 'Error',
          style: TextStyle(color: isDark ? AppColors.error : AppColors.error),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final person = _person!;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final mutedTextColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildPhoto(person, surfaceColor, mutedTextColor),
                const SizedBox(height: AppSpacing.md),
                Text(
                  person.name,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (person.lifespan != null && person.lifespan!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    person.lifespan!,
                    style: textTheme.bodyLarge?.copyWith(
                      color: mutedTextColor,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                if (person.bio != null && person.bio!.isNotEmpty) ...[
                  Text(
                    person.bio!,
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
                if (_books.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Books by ${person.name}',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildBooksList(surfaceColor),
                  const SizedBox(height: AppSpacing.xl),
                ],
                if (person.websiteUrl != null || person.wikipediaUrl != null) ...[
                  const Divider(),
                  const SizedBox(height: AppSpacing.md),
                  _buildLinks(person),
                  const SizedBox(height: AppSpacing.xxxl),
                ]
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoto(PersonModel person, Color surfaceColor, Color mutedColor) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: surfaceColor,
        image: person.photoUrl != null
            ? DecorationImage(
                image: NetworkImage(_formatUrl(person.photoUrl!)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: person.photoUrl == null
          ? Icon(Icons.person, size: AppSizes.iconXl, color: mutedColor)
          : null,
    );
  }

  Widget _buildBooksList(Color surfaceColor) {
    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _books.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final book = _books[index];
          return GestureDetector(
            onTap: () => context.push('/book/${book.slug}'),
            child: Hero(
              tag: 'book-cover-${book.slug}',
              child: Container(
                width: 140,
                height: 210,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: surfaceColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  image: book.coverUrl != null
                      ? DecorationImage(
                          image: NetworkImage(_formatUrl(book.coverUrl!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: book.coverUrl == null
                    ? const Center(child: Icon(Icons.book, size: AppSizes.iconLg))
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLinks(PersonModel person) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (person.wikipediaUrl != null)
          TextButton.icon(
            onPressed: () => _launchUrl(person.wikipediaUrl!),
            icon: const Icon(Icons.public),
            label: const Text('Wikipedia'),
          ),
        if (person.websiteUrl != null)
          TextButton.icon(
            onPressed: () => _launchUrl(person.websiteUrl!),
            icon: const Icon(Icons.link),
            label: const Text('Website'),
          ),
      ],
    );
  }
}
