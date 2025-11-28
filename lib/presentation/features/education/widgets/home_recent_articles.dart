import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glucoheart_flutter/presentation/providers/article_provider.dart';
import 'package:glucoheart_flutter/utils/url_utils.dart';
import '../../../../config/themes/app_theme.dart';
import '../../education/article_detail_screen.dart';

class HomeRecentArticles extends ConsumerWidget {
  final VoidCallback onSeeAll;
  const HomeRecentArticles({super.key, required this.onSeeAll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(latestArticlesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Edukasi Terbaru',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: onSeeAll,
              child: const Text('Lihat semua'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        async.when(
          data: (items) {
            if (items.isEmpty) {
              return const Text('Belum ada artikel.');
            }
            return SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final a = items[i];
                  final img = UrlUtils.full(a.coverImageUrl);
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ArticleDetailScreen(slug: a.slug)),
                      );
                    },
                    child: Container(
                      width: 240,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppBorderRadius.large,
                        boxShadow: [AppShadows.small],
                        image: a.coverImageUrl != null && a.coverImageUrl!.isNotEmpty
                            ? DecorationImage(
                          image: NetworkImage(img),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: AppBorderRadius.large,
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(.55),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 12,
                            child: Text(
                              a.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('Gagal memuat: $e'),
        ),
      ],
    );
  }
}
