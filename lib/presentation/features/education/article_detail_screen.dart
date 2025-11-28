import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:glucoheart_flutter/presentation/providers/article_provider.dart';
import '../../../config/themes/app_theme.dart';
import '../../../utils/url_utils.dart';

class ArticleDetailScreen extends ConsumerWidget {
  final String slug;
  const ArticleDetailScreen({super.key, required this.slug});

  /// Ganti semua src="/uploads/..." jadi absolute URL pakai base server
  String _fixRelativeImageUrls(String html) {
    return html.replaceAllMapped(
      RegExp(r'src="(\/[^"]+)"'),
          (m) => 'src="${UrlUtils.full(m.group(1))}"',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(articleDetailProvider(slug));

    return Scaffold(
      backgroundColor: Colors.white,
      body: state.when(
        loading: () => const _LoadingView(),
        error: (e, _) => _ErrorView(message: e.toString()),
        data: (article) {
          final coverUrl = UrlUtils.full(article.coverImageUrl);
          final categories = article.categories ?? const [];
          final publishedAt = article.publishedAt;
          final displayDate = publishedAt != null ? _formatDate(publishedAt) : null;
          final displayTimeAgo = publishedAt != null ? _formatTimeAgo(publishedAt) : null;

          // HTML content
          final htmlContentRaw = article.content?.trim();
          final htmlContent = htmlContentRaw != null && htmlContentRaw.isNotEmpty
              ? _fixRelativeImageUrls(htmlContentRaw)
              : (article.summary ?? '');

          final images = article.images ?? const [];

          return CustomScrollView(
            slivers: [
              // Professional News-style App Bar
              _NewsStyleSliverAppBar(
                title: article.title ?? 'Artikel',
                coverUrl: coverUrl,
              ),

              // Article Content - News Style
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Categories - Simple tags like news sites
                      if (categories.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: Wrap(
                            spacing: 12,
                            children: categories.map((c) {
                              final name = c.name.toString();
                              return _NewsTagChip(label: name);
                            }).toList(),
                          ),
                        ),

                      // Title - News headline style
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                        child: Text(
                          article.title ?? '',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),

                      // Meta info - News style
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  displayDate ?? '—',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (displayTimeAgo != null) ...[
                                  Text(
                                    ' • $displayTimeAgo',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Divider like news sites
                      Container(
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryColor,
                              AppColors.primaryColor.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                      // Article Content - Compact news formatting
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Html(
                          data: htmlContent,
                          style: {
                            'body': Style(
                              fontSize: FontSize(17),
                              lineHeight: LineHeight.number(1.6),
                              color: const Color(0xFF2C2C2C),
                              padding: HtmlPaddings.zero,
                              margin: Margins.zero,
                              fontFamily: 'Georgia, serif',
                            ),
                            'p': Style(
                              margin: Margins.only(bottom: 18),
                              textAlign: TextAlign.justify,
                              fontSize: FontSize(17),
                              lineHeight: LineHeight.number(1.6),
                            ),
                            'img': Style(
                              margin: Margins.symmetric(vertical: 20),
                              width: Width.auto(),
                              height: Height.auto(),
                            ),
                            'h1': Style(
                              fontSize: FontSize(26),
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                              margin: Margins.only(bottom: 16, top: 24),
                              lineHeight: LineHeight.number(1.2),
                            ),
                            'h2': Style(
                              fontSize: FontSize(22),
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              margin: Margins.only(bottom: 12, top: 20),
                              lineHeight: LineHeight.number(1.3),
                            ),
                            'h3': Style(
                              fontSize: FontSize(19),
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              margin: Margins.only(bottom: 10, top: 16),
                              lineHeight: LineHeight.number(1.3),
                            ),
                            'ul': Style(
                              margin: Margins.only(bottom: 18, left: 0),
                              padding: HtmlPaddings.only(left: 20),
                            ),
                            'ol': Style(
                              margin: Margins.only(bottom: 18, left: 0),
                              padding: HtmlPaddings.only(left: 20),
                            ),
                            'li': Style(
                              margin: Margins.only(bottom: 8),
                              fontSize: FontSize(17),
                              lineHeight: LineHeight.number(1.6),
                            ),
                            'a': Style(
                              color: AppColors.primaryColor,
                              textDecoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                            'blockquote': Style(
                              margin: Margins.symmetric(vertical: 20),
                              padding: HtmlPaddings.all(16),
                              backgroundColor: Colors.grey.shade50,
                              border: Border(
                                left: BorderSide(
                                  color: AppColors.primaryColor,
                                  width: 4,
                                ),
                              ),
                              fontStyle: FontStyle.italic,
                              fontSize: FontSize(16),
                            ),
                            'strong': Style(
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                            'b': Style(
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                            'em': Style(
                              fontStyle: FontStyle.italic,
                            ),
                            'i': Style(
                              fontStyle: FontStyle.italic,
                            ),
                          },
                          onLinkTap: (url, _, __) {
                            // TODO: pakai url_launcher kalau perlu
                          },
                        ),
                      ),

                      // Gallery - News style
                      if (images.isNotEmpty) ...[
                        Container(
                          height: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.photo_library_outlined,
                                size: 20,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'GALERI FOTO',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey.shade700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${images.length}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final w = constraints.maxWidth;
                              final col = w >= 600 ? 2 : 1;
                              final gap = 12.0;
                              final itemW = col == 1 ? w : (w - gap) / col;

                              return Wrap(
                                spacing: gap,
                                runSpacing: gap,
                                children: images.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final img = entry.value;
                                  final url = UrlUtils.full(img.url.toString());

                                  return SizedBox(
                                    width: itemW,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: Image.network(
                                          url,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            color: Colors.grey.shade200,
                                            child: Icon(
                                              Icons.image_not_supported_outlined,
                                              color: Colors.grey.shade400,
                                              size: 32,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

    return '${days[dt.weekday % 7]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${(diff.inDays / 7).floor()} minggu lalu';
  }
}

// News-style Sliver App Bar (cleaner, more professional)
class _NewsStyleSliverAppBar extends StatelessWidget {
  final String title;
  final String? coverUrl;

  const _NewsStyleSliverAppBar({
    required this.title,
    this.coverUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      foregroundColor: Colors.black87,
      pinned: true,
      stretch: true,
      expandedHeight: coverUrl?.isNotEmpty == true ? 250 : 0,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back,
            color: Colors.black87,
            size: 20,
          ),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: coverUrl?.isNotEmpty == true
          ? FlexibleSpaceBar(
        background: Image.network(
          coverUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey.shade200,
            child: Icon(
              Icons.image_not_supported_outlined,
              color: Colors.grey.shade400,
              size: 48,
            ),
          ),
        ),
      )
          : null,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.grey.shade200,
        ),
      ),
    );
  }
}

// Simple news-style tag chip
class _NewsTagChip extends StatelessWidget {
  final String label;
  const _NewsTagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// Minimalist Loading View
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }
}

// Clean Error View
class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text('Error'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                'Artikel tidak dapat dimuat',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}