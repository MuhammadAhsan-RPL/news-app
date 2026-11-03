import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../providers/bookmark_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/article_card.dart';
import '../widgets/state_views.dart';
import 'detail_screen.dart';

/// Layar Favorit yang menampilkan seluruh artikel yang telah disimpan pengguna
/// melalui [BookmarkProvider]. Menggunakan komponen [ArticleCard] yang sama dengan Beranda.
class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Berita Favorit'),
      ),
      // Mendengarkan perubahan daftar favorit dari BookmarkProvider menggunakan Consumer
      body: Consumer<BookmarkProvider>(
        builder: (
          BuildContext context,
          BookmarkProvider bookmarkProvider,
          Widget? child,
        ) {
          final List<Article> bookmarkedArticles = bookmarkProvider.bookmarks;

          // Jika belum ada artikel yang disimpan, tampilkan state kosong berbahasa Indonesia
          if (bookmarkedArticles.isEmpty) {
            return const EmptyStateView(
              icon: Icons.bookmark_border_rounded,
              title: 'Belum Ada Berita Favorit',
              message:
                  'Tandai artikel yang menarik di Beranda atau halaman Detail untuk membacanya kembali di sini.',
            );
          }

          // Jika ada artikel favorit, tampilkan menggunakan komponen ArticleCard yang sama
          return ListView.separated(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            itemCount: bookmarkedArticles.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: AppTheme.spacing16),
            itemBuilder: (BuildContext context, int index) {
              final Article article = bookmarkedArticles[index];
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
                        const SnackBar(
                          content: Text('Dihapus dari daftar favorit.'),
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
                  tooltip: 'Hapus dari Favorit',
                ),
              );
            },
          );
        },
      ),
    );
  }
}

