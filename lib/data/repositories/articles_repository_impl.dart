import '../../domain/entities/article.dart';
import '../datasources/remote/articles_api.dart';

abstract class ArticlesRepository {
  Future<List<Article>> fetchLatest({int limit = 6});
  Future<List<Article>> search({
    int page,
    int limit,
    String? search,
    List<String> categories,
  });
  Future<Article> getBySlug(String slug);
  Future<List<ArticleCategory>> listCategories({String? q});
}

class ArticlesRepositoryImpl implements ArticlesRepository {
  final ArticlesApi api;
  ArticlesRepositoryImpl(this.api);

  @override
  Future<List<Article>> fetchLatest({int limit = 6}) async {
    final raw = await api.getPublicList(limit: limit, offset: 0);
    return raw
        .cast<Map<String, dynamic>>()
        .map((e) => Article.fromListJson(e))
        .toList();
  }

  @override
  Future<List<Article>> search({
    int page = 1,
    int limit = 10,
    String? search,
    List<String> categories = const [],
  }) async {
    final res = await api.searchPaginated(
      page: page,
      limit: limit,
      search: search,
      categorySlugs: categories,
    );
    final list = (res['articles'] ?? []) as List;
    return list
        .cast<Map<String, dynamic>>()
        .map((e) => Article.fromListJson(e))
        .toList();
  }

  @override
  Future<Article> getBySlug(String slug) async {
    final json = await api.getPublicBySlug(slug);
    return Article.fromDetailJson(json);
  }

  @override
  Future<List<ArticleCategory>> listCategories({String? q}) async {
    final raw = await api.listCategories(q: q, limit: 100);
    return raw
        .cast<Map<String, dynamic>>()
        .map((e) => ArticleCategory.fromJson(e))
        .toList();
  }
}
