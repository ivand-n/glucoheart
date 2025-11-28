class ArticleCategory {
  final int id;
  final String name;
  final String slug;

  ArticleCategory({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory ArticleCategory.fromJson(Map<String, dynamic> json) => ArticleCategory(
    id: (json['id'] as num).toInt(),
    name: json['name'] ?? '',
    slug: json['slug'] ?? '',
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'slug': slug};
}

class ArticleImage {
  final int id;
  final String url;
  final String? alt;
  final bool isCover;
  final int position;

  ArticleImage({
    required this.id,
    required this.url,
    this.alt,
    required this.isCover,
    required this.position,
  });

  factory ArticleImage.fromJson(Map<String, dynamic> json) => ArticleImage(
    id: (json['id'] as num).toInt(),
    url: json['url'] ?? '',
    alt: json['alt'],
    isCover: (json['isCover'] ?? false) == true,
    position: (json['position'] ?? 0) is num
        ? (json['position'] as num).toInt()
        : 0,
  );
}

class Article {
  final int id;
  final String title;
  final String slug;
  final String? summary;
  final String status; // 'draft' | 'published'
  final DateTime? publishedAt;
  final String? coverImageUrl; // nullable
  final List<ArticleCategory> categories;

  // detail
  final String? content; // HTML string (bisa null di list)
  final List<ArticleImage>? images; // hanya di detail

  Article({
    required this.id,
    required this.title,
    required this.slug,
    required this.status,
    this.summary,
    this.publishedAt,
    this.coverImageUrl,
    this.categories = const [],
    this.content,
    this.images,
  });

  factory Article.fromListJson(Map<String, dynamic> json) {
    // FIXED: Handle both search results and public list formats
    final cover = json['coverImage']; // from public list
    final coverImageUrl = json['coverImageUrl']; // from search results
    final cats = (json['categories'] ?? []) as List? ?? [];

    return Article(
      id: (json['id'] as num).toInt(),
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      status: json['status'] ?? 'draft',
      summary: json['summary'],
      publishedAt: _parseDateTime(json['publishedAt'] ?? json['published_at']),
      // FIXED: Handle both cover formats
      coverImageUrl: coverImageUrl ?? (cover != null ? (cover['url'] as String?) : null),
      categories: cats
          .map((e) => ArticleCategory.fromJson(Map<String, dynamic>.from(e)))
          .toList()
          .cast<ArticleCategory>(),
    );
  }

  factory Article.fromDetailJson(Map<String, dynamic> json) {
    final imgs = (json['images'] ?? []) as List? ?? [];
    final cats = (json['categories'] ?? []) as List? ?? []; // FIXED: Handle categories in detail

    return Article(
      id: (json['id'] as num).toInt(),
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      status: json['status'] ?? 'draft',
      summary: json['summary'],
      publishedAt: _parseDateTime(json['publishedAt'] ?? json['published_at']),
      // FIXED: Use coverImageUrl directly from backend response
      coverImageUrl: json['coverImageUrl'],
      // FIXED: Parse categories from detail response
      categories: cats
          .map((e) => ArticleCategory.fromJson(Map<String, dynamic>.from(e)))
          .toList()
          .cast<ArticleCategory>(),
      content: json['content'],
      images: imgs
          .map((e) => ArticleImage.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  // FIXED: Helper method to parse different datetime formats
  static DateTime? _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return null;
    if (dateTime is DateTime) return dateTime;
    return DateTime.tryParse(dateTime.toString());
  }
}