import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../providers/news_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/article_card.dart';
import '../widgets/state_views.dart';

/// Layar Beranda yang menampilkan daftar berita dari [NewsProvider].
/// Mendukung keempat status jaringan: loading, sukses, error (dengan tombol coba lagi),
/// dan kosong, serta fitur tarik ke bawah (pull-to-refresh) untuk memuat ulang.
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
          // Tombol muat ulang cepat di AppBar
          IconButton(
            onPressed: () => context.read<NewsProvider>().loadArticles(),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Muat Ulang Berita',
          ),
          const SizedBox(width: AppTheme.spacing8),
        ],
      ),
      // Menggunakan Consumer<NewsProvider> untuk mendengarkan perubahan status jaringan
      // dan membangun ulang tampilan sesuai status: loading, error, empty, atau success.
      body: Consumer<NewsProvider>(
        builder: (
          BuildContext context,
          NewsProvider newsProvider,
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
                message: 'Saat ini belum ada artikel berita yang dapat ditampilkan.',
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
                    return ArticleCard(
                      article: article,
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

