import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/bookmark_provider.dart';
import 'providers/news_provider.dart';
import 'screens/home_screen.dart';
import 'services/mock_news_service.dart';
import 'services/news_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const NewsApp());
}

/// Widget akar aplikasi News App yang memasang [NewsProvider] dan [BookmarkProvider]
/// menggunakan [MultiProvider], serta menampilkan layar Beranda ([HomeScreen]).
class NewsApp extends StatelessWidget {
  /// Parameter opsional [newsService] agar saat pengujian atau tahap integrasi API
  /// sumber data dapat disuntikkan melalui tipe abstrak [NewsService].
  final NewsService? newsService;

  const NewsApp({
    super.key,
    this.newsService,
  });

  @override
  Widget build(BuildContext context) {
    // Mendaftarkan NewsProvider dan BookmarkProvider di tingkat atas aplikasi
    // menggunakan MultiProvider sehingga Beranda, Detail, dan Favorit dapat mengaksesnya.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NewsProvider>(
          create: (_) => NewsProvider(
            newsService: newsService ?? MockNewsService(),
          ),
        ),
        ChangeNotifierProvider<BookmarkProvider>(
          create: (_) => BookmarkProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Portal Berita',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
