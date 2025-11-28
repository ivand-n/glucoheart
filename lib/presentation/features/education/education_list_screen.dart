import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:glucoheart_flutter/presentation/features/education/article_detail_screen.dart';
import 'package:glucoheart_flutter/presentation/providers/article_provider.dart';
import 'package:glucoheart_flutter/utils/logger.dart';
import '../../../config/themes/app_theme.dart';
import '../../../utils/url_utils.dart';

/// ===== Education List Screen =====
class EducationListScreen extends ConsumerStatefulWidget {
  const EducationListScreen({super.key});

  @override
  ConsumerState<EducationListScreen> createState() => EducationListScreenState();
}

class EducationListScreenState extends ConsumerState<EducationListScreen> {
  final _scrollController = ScrollController();
  final _searchC = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(articlesListProvider.notifier).refresh());

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 300) {
        ref.read(articlesListProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchC.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Method publik untuk fokus search bar dari luar
  void focusSearchBar() {
    if (mounted) {
      _searchFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(articlesListProvider);
    final catsAsync = ref.watch(articleCategoriesProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Edukasi',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
        ),
      ),
      body: Column(
        children: [
          // Sticky Search and Category Section
          Container(
            color: Colors.grey.shade50,
            child: Column(
              children: [
                // Search Bar - Sticky
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: _SearchBar(
                    controller: _searchC,
                    focusNode: _searchFocusNode,
                    onChanged: (v) {
                      ref.read(articlesListProvider.notifier).setSearch(v);
                    },
                    onSubmitted: (_) =>
                        ref.read(articlesListProvider.notifier).refresh(),
                  ),
                ),

                // Category Section - Sticky
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: catsAsync.when(
                    data: (cats) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kategori',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _ChipFilter(
                                label: 'Semua',
                                selected: state.selectedCategories.isEmpty,
                                onTap: () {
                                  final notifier = ref.read(articlesListProvider.notifier);
                                  for (final c in state.selectedCategories.toList()) {
                                    notifier.toggleCategory(c);
                                  }
                                  notifier.refresh();
                                },
                              ),
                              const SizedBox(width: 8),
                              ...cats.map((c) {
                                final sel = state.selectedCategories.contains(c.slug);
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _ChipFilter(
                                    label: c.name,
                                    selected: sel,
                                    onTap: () {
                                      ref.read(articlesListProvider.notifier).toggleCategory(c.slug);
                                      ref.read(articlesListProvider.notifier).refresh();
                                    },
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                    loading: () => const SizedBox(
                        height: 60, child: Center(child: CircularProgressIndicator())),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),

                // Subtle separator
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Content Area
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(articlesListProvider.notifier).refresh(),
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                children: [
                  // Articles section with header
                  if (!state.isLoading || state.items.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Artikel Terbaru',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (state.items.isNotEmpty)
                              Text(
                                '${state.items.length} artikel',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                  // Grid of cards
                  const _ArticlesGrid(),

                  if (state.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===== Enhanced Search Bar =====
class _SearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          hintText: 'Cari artikel kesehatan...',
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.grey.shade500,
            size: 22,
          ),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: Colors.grey.shade500,
              size: 20,
            ),
            onPressed: () {
              widget.controller.clear();
              widget.onChanged('');
              widget.onSubmitted('');
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

/// ===== Enhanced Filter Chip =====
class _ChipFilter extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChipFilter({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: selected
            ? AppColors.primaryColor
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selected
                ? AppColors.primaryColor
                : Colors.grey.shade300,
            width: 1,
          ),
        ),
        elevation: selected ? 2 : 0,
        shadowColor: AppColors.primaryColor.withOpacity(0.3),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ===== Enhanced Articles Grid =====
class _ArticlesGrid extends ConsumerWidget {
  const _ArticlesGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(articlesListProvider);
    final items = state.items;

    if (!state.isLoading && items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada artikel ditemukan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coba ubah kata kunci pencarian atau filter kategori',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, c) {
        final isWide = c.maxWidth >= 720;
        final cross = isWide ? 2 : 1;
        final gap = 16.0;

        if (cross == 1) {
          // Single column layout for mobile
          return Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final article = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: index < items.length - 1 ? gap : 0),
                child: _ArticleCard(article: article),
              )
                  .animate(delay: Duration(milliseconds: index * 100))
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
            }).toList(),
          );
        } else {
          // Grid layout for wider screens
          final itemW = (c.maxWidth - gap) / cross;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final article = entry.value;
              return SizedBox(
                width: itemW,
                child: _ArticleCard(article: article),
              )
                  .animate(delay: Duration(milliseconds: index * 100))
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
            }).toList(),
          );
        }
      },
    );
  }
}

/// ===== Enhanced Article Card =====
class _ArticleCard extends ConsumerStatefulWidget {
  final dynamic article;
  const _ArticleCard({required this.article});

  @override
  ConsumerState<_ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends ConsumerState<_ArticleCard> {
  static final Map<String, String> _coverCache = {};
  String? _coverUrl;
  bool _fetching = false;

  @override
  void initState() {
    super.initState();
    _resolveCover();
  }

  Future<void> _resolveCover() async {
    final slug = (widget.article.slug ?? '').toString();
    if (slug.isEmpty) return;

    final fromList = UrlUtils.full(widget.article.coverImageUrl);
    if (fromList.isNotEmpty) {
      setState(() => _coverUrl = fromList);
      _coverCache[slug] = fromList;
      return;
    }

    final cached = _coverCache[slug];
    if (cached != null && cached.isNotEmpty) {
      setState(() => _coverUrl = cached);
      return;
    }

    if (_fetching) return;
    _fetching = true;
    try {
      final detail = await ref.read(articlesRepoProvider).getBySlug(slug);
      String resolved = '';
      if ((detail.coverImageUrl ?? '').toString().isNotEmpty) {
        resolved = UrlUtils.full(detail.coverImageUrl);
      } else if ((detail.images ?? []).isNotEmpty) {
        final cov = detail.images!.firstWhere(
              (e) => (e.isCover == true),
          orElse: () => detail.images!.first,
        );
        resolved = UrlUtils.full(cov.url?.toString());
      }
      if (mounted && resolved.isNotEmpty) {
        setState(() => _coverUrl = resolved);
        _coverCache[slug] = resolved;
      }
    } catch (e) {
      Logger.w('Article cover hydrate failed for $slug: $e', tag: 'ArticleCard');
    } finally {
      _fetching = false;
    }
  }

  String _timeLabel() {
    final dt = (widget.article.publishedAt is DateTime)
        ? widget.article.publishedAt as DateTime
        : DateTime.tryParse(widget.article.publishedAt?.toString() ?? '') ??
        DateTime.now();
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari yang lalu';
    return '${(diff.inDays / 7).floor()} minggu yang lalu';
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> cats = (widget.article.categories ?? const []);
    final title = (widget.article.title ?? '').toString();
    final summary = (widget.article.summary ?? '').toString();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ArticleDetailScreen(slug: widget.article.slug),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Cover Image
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _coverUrl != null && _coverUrl!.isNotEmpty
                      ? Image.network(
                    _coverUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallbackImage(),
                  )
                      : _fallbackImage(),
                  // Gradient overlay for better text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Enhanced Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Multiple categories with enhanced styling
                  if (cats.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: cats.take(3).map((cat) {
                          final categoryName = ((cat is Map)
                              ? cat['name']
                              : cat.name).toString();
                          return _CategoryChip(label: categoryName);
                        }).toList(),
                      ),
                    ),

                  // Enhanced Title
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  // Enhanced Summary
                  if (summary.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      summary,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Enhanced Time and Read More
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 16,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _timeLabel(),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Baca selengkapnya',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor.withOpacity(0.1),
            AppColors.primaryLight.withOpacity(0.2),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.article_outlined,
          color: AppColors.primaryColor.withOpacity(0.6),
          size: 48,
        ),
      ),
    );
  }
}

/// Enhanced Category Chip
class _CategoryChip extends StatelessWidget {
  final String label;
  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.primaryColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}