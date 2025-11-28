import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/articles_api.dart';
import '../../data/repositories/articles_repository_impl.dart';
import '../../domain/entities/article.dart';

/// DI
final articlesApiProvider = Provider<ArticlesApi>((ref) => ArticlesApi());
final articlesRepoProvider = Provider<ArticlesRepository>((ref) {
  final api = ref.watch(articlesApiProvider);
  return ArticlesRepositoryImpl(api);
});

/// Categories
final articleCategoriesProvider =
FutureProvider.autoDispose<List<ArticleCategory>>((ref) async {
  final repo = ref.read(articlesRepoProvider);
  final data = await repo.listCategories();
  data.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return data;
});

/// List state
class ArticlesListState {
  final List<Article> items;
  final bool isLoading;
  final bool canLoadMore;
  final String search;
  final Set<String> selectedCategories; // slugs
  final int page;

  const ArticlesListState({
    this.items = const [],
    this.isLoading = false,
    this.canLoadMore = true,
    this.search = '',
    this.selectedCategories = const {},
    this.page = 1,
  });

  ArticlesListState copyWith({
    List<Article>? items,
    bool? isLoading,
    bool? canLoadMore,
    String? search,
    Set<String>? selectedCategories,
    int? page,
  }) {
    return ArticlesListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      canLoadMore: canLoadMore ?? this.canLoadMore,
      search: search ?? this.search,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      page: page ?? this.page,
    );
  }
}

class ArticlesListNotifier extends StateNotifier<ArticlesListState> {
  ArticlesListNotifier(this.ref) : super(const ArticlesListState());
  final Ref ref;

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, page: 1);
    final repo = ref.read(articlesRepoProvider);
    final items = await repo.search(
      page: 1,
      limit: 10,
      search: state.search.isEmpty ? null : state.search,
      categories: state.selectedCategories.toList(),
    );
    state = state.copyWith(
      items: items,
      isLoading: false,
      canLoadMore: items.length >= 10,
      page: 1,
    );
  }

  Future<void> loadMore() async {
    if (!state.canLoadMore || state.isLoading) return;
    state = state.copyWith(isLoading: true);
    final repo = ref.read(articlesRepoProvider);
    final next = state.page + 1;
    final items = await repo.search(
      page: next,
      limit: 10,
      search: state.search.isEmpty ? null : state.search,
      categories: state.selectedCategories.toList(),
    );
    state = state.copyWith(
      items: [...state.items, ...items],
      isLoading: false,
      canLoadMore: items.length >= 10,
      page: next,
    );
  }

  void setSearch(String value) {
    state = state.copyWith(search: value);
  }

  void toggleCategory(String slug) {
    final set = Set<String>.from(state.selectedCategories);
    if (set.contains(slug)) {
      set.remove(slug);
    } else {
      set.add(slug);
    }
    state = state.copyWith(selectedCategories: set);
  }
}

final articlesListProvider =
StateNotifierProvider<ArticlesListNotifier, ArticlesListState>(
      (ref) => ArticlesListNotifier(ref),
);

/// Detail
final articleDetailProvider =
FutureProvider.family<Article, String>((ref, slug) async {
  final repo = ref.read(articlesRepoProvider);
  return repo.getBySlug(slug);
});

/// Latest for Home
final latestArticlesProvider =
FutureProvider<List<Article>>((ref) async {
  final repo = ref.read(articlesRepoProvider);
  return repo.fetchLatest(limit: 6);
});
