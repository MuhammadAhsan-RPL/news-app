import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../providers/bookmark_provider.dart';
import '../providers/news_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/article_card.dart';
import '../widgets/state_views.dart';
import 'bookmark_screen.dart';
import 'detail_screen.dart';

/// Layar Beranda yang menampilkan kolom pencarian, chip kategori, daftar berita
/// dari [NewsProvider], serta akses ke halaman Favorit ([BookmarkScreen]).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Memanggil loadArticles() lewat Provider setelah frame pertama selesai dibangun
    // agar proses pengambilan berita otomatis berjalan saat layar Beranda dibuka.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NewsProvider>().loadArticles();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kabar Hari Ini'),
        actions: [
          // Tombol menuju halaman Favorit (BookmarkScreen)
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const BookmarkScreen(),
                ),
              );
            },
            icon: const Icon(Icons.bookmarks_outlined),
            tooltip: 'Berita Favorit',
          ),
          // Tombol muat ulang cepat di AppBar
          IconButton(
            onPressed: () => context.read<NewsProvider>().loadArticles(),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Muat Ulang Berita',
          ),
          const SizedBox(width: AppTheme.spacing8),
        ],
      ),
      // Menggunakan Consumer2 untuk mendengarkan perubahan status jaringan & filter (NewsProvider)
      // sekaligus status bookmark (BookmarkProvider) agar tampilan selalu sinkron.
      body: Consumer2<NewsProvider, BookmarkProvider>(
        builder: (
          BuildContext context,
          NewsProvider newsProvider,
          BookmarkProvider bookmarkProvider,
          Widget? child,
        ) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bagian atas: Kolom pencarian dan deretan chip kategori
              _SearchAndCategorySection(
                searchController: _searchController,
                selectedCategory: newsProvider.selectedCategory,
                searchQuery: newsProvider.searchQuery,
                onSearchChanged: (String value) {
                  newsProvider.setSearchQuery(value);
                },
                onClearSearch: () {
                  _searchController.clear();
                  newsProvider.setSearchQuery('');
                },
                onCategorySelected: (String category) {
                  newsProvider.setSelectedCategory(category);
                },
              ),

              // Bagian bawah: Konten daftar berita sesuai 4 status jaringan
              Expanded(
                child: _buildBodyByStatus(
                  context,
                  newsProvider,
                  bookmarkProvider,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBodyByStatus(
    BuildContext context,
    NewsProvider newsProvider,
    BookmarkProvider bookmarkProvider,
  ) {
    switch (newsProvider.status) {
      case NewsStatus.loading:
        return const LoadingStateView();

      case NewsStatus.error:
        return ErrorStateView(
          message: newsProvider.errorMessage,
          onRetry: () => newsProvider.loadArticles(),
        );

      case NewsStatus.empty:
        final bool hasActiveFilter =
            newsProvider.searchQuery.trim().isNotEmpty ||
            newsProvider.selectedCategory != 'Semua';

        return EmptyStateView(
          icon: hasActiveFilter
              ? Icons.search_off_rounded
              : Icons.article_outlined,
          title: hasActiveFilter
              ? 'Berita Tidak Ditemukan'
              : 'Belum Ada Berita',
          message: hasActiveFilter
              ? 'Tidak ada artikel yang cocok dengan pencarian atau kategori yang dipilih.'
              : 'Saat ini belum ada artikel berita yang dapat ditampilkan.',
          actionLabel: hasActiveFilter ? 'Reset Filter' : 'Muat Ulang',
          onAction: () {
            if (hasActiveFilter) {
              _searchController.clear();
              newsProvider.resetFilters();
            } else {
              newsProvider.loadArticles();
            }
          },
        );

      case NewsStatus.success:
        // RefreshIndicator memungkinkan pengguna menarik daftar ke bawah
        // untuk memuat ulang berita secara asinkron (mengembalikan Future<void>).
        return RefreshIndicator(
          color: AppTheme.primaryColor,
          backgroundColor: AppTheme.surfaceColor,
          onRefresh: () => newsProvider.loadArticles(),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppTheme.spacing16),
            itemCount: newsProvider.articles.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: AppTheme.spacing16),
            itemBuilder: (BuildContext context, int index) {
              final Article article = newsProvider.articles[index];
              final bool isSaved = bookmarkProvider.isBookmarked(article);

              return ArticleCard(
                article: article,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => DetailScreen(article: article),
                    ),
                  );
                },
                trailingAction: IconButton(
                  onPressed: () {
                    bookmarkProvider.toggleBookmark(article);
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            isSaved
                                ? 'Dihapus dari daftar favorit.'
                                : 'Disimpan ke daftar favorit.',
                          ),
                        ),
                      );
                  },
                  icon: Icon(
                    isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: isSaved
                        ? AppTheme.accentColor
                        : AppTheme.textSecondaryColor,
                  ),
                  tooltip:
                      isSaved ? 'Hapus dari Favorit' : 'Simpan ke Favorit',
                ),
              );
            },
          ),
        );
    }
  }
}

/// Widget internal untuk menampilkan kolom pencarian dan daftar chip kategori
/// dengan gaya profesional sesuai [AppTheme].
class _SearchAndCategorySection extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedCategory;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onCategorySelected;

  const _SearchAndCategorySection({
    required this.searchController,
    required this.selectedCategory,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing16,
        AppTheme.spacing16,
        AppTheme.spacing16,
        AppTheme.spacing16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kolom pencarian berita
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            textInputAction: TextInputAction.search,
            style: AppTheme.bodyLargeStyle,
            decoration: InputDecoration(
              hintText: 'Cari judul, topik, atau sumber berita...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: onClearSearch,
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Hapus Pencarian',
                    )
                  : null,
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),

          // Deretan chip kategori yang bisa digeser ke samping (horizontal scroll)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: NewsProvider.categories.map((String category) {
                final bool isSelected = category == selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: AppTheme.spacing8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) => onCategorySelected(category),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
