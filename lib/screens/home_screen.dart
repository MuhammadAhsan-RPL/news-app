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

/// Layar Beranda yang menampilkan daftar berita dari [NewsProvider] dan menyediakan
/// akses ke halaman Favorit ([BookmarkScreen]) serta tombol bookmark pada setiap kartu.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      // Menggunakan Consumer2 untuk mendengarkan perubahan status jaringan (NewsProvider)
      // sekaligus status bookmark (BookmarkProvider) agar ikon bookmark selalu sinkron.
      body: Consumer2<NewsProvider, BookmarkProvider>(
        builder: (
          BuildContext context,
          NewsProvider newsProvider,
          BookmarkProvider bookmarkProvider,
          Widget? child,
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
              return EmptyStateView(
                title: 'Belum Ada Berita',
                message:
                    'Saat ini belum ada artikel berita yang dapat ditampilkan.',
                onAction: () => newsProvider.loadArticles(),
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
                        tooltip: isSaved
                            ? 'Hapus dari Favorit'
                            : 'Simpan ke Favorit',
                      ),
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }
}
