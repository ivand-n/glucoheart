import 'package:dio/dio.dart';
import 'api_client.dart';

class ArticlesApi {
  final _client = ApiClient();

  /// Public list (published). Supports q, limit, offset
  Future<List<dynamic>> getPublicList({
    String? q,
    int limit = 12,
    int offset = 0,
  }) async {
    final res = await _client.get(
      '/articles',
      queryParameters: {
        if (q != null && q.isNotEmpty) 'q': q,
        'limit': limit,
        'offset': offset,
      },
    );

    // ApiClient.get() mengembalikan Response<dynamic>
    final data = (res is Response) ? res.data : res;

    if (data is List) return data;
    // beberapa backend mungkin balas { items: [...] }
    if (data is Map && data['items'] is List) return List.from(data['items']);
    return <dynamic>[];
  }

  /// Public detail by slug
  Future<Map<String, dynamic>> getPublicBySlug(String slug) async {
    final res = await _client.get('/articles/slug/$slug');
    final data = (res is Response) ? res.data : res;
    return Map<String, dynamic>.from(data as Map);
  }

  /// List categories (public) - FIXED: Use correct endpoint
  Future<List<dynamic>> listCategories({
    String? q,
    int limit = 100,
    int offset = 0,
  }) async {
    // FIXED: Use /articles/categories/all endpoint instead of paginated one
    final res = await _client.get(
      '/articles/categories/all',
      queryParameters: {
        if (q != null && q.isNotEmpty) 'search': q, // FIXED: backend uses 'search' not 'q'
        // Remove limit/offset since /all endpoint doesn't use pagination
      },
    );

    final data = (res is Response) ? res.data : res;

    if (data is List) return data;
    return <dynamic>[];
  }

  /// Search with categories filter via /articles/search?scope=public
  /// returns { articles: [...], total_articles, ... }
  Future<Map<String, dynamic>> searchPaginated({
    int page = 1,
    int limit = 10,
    String? search,
    List<String> categorySlugs = const [],
  }) async {
    final res = await _client.get(
      '/articles/search',
      queryParameters: {
        'page': page,
        'limit': limit,
        'scope': 'public',
        if (search != null && search.isNotEmpty) 'search': search,
        if (categorySlugs.isNotEmpty) 'categories': categorySlugs.join('.'),
      },
    );

    final data = (res is Response) ? res.data : res;
    return Map<String, dynamic>.from(data as Map);
  }
}