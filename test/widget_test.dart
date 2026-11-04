import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/main.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/providers/bookmark_provider.dart';
import 'package:news_app/providers/news_provider.dart';
import 'package:news_app/screens/bookmark_screen.dart';
import 'package:news_app/screens/detail_screen.dart';
import 'package:news_app/services/mock_news_service.dart';
import 'package:news_app/services/news_service.dart';
import 'package:news_app/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Aplikasi memuat Beranda dan menampilkan daftar berita lewat NewsProvider (Langkah 4)',
    (WidgetTester tester) async {
      // Menyuntikkan MockNewsService tanpa jeda untuk pengujian widget di lingkungan test
      final NewsService mockService = MockNewsService(
        simulatedState: MockResponseState.success,
        simulatedDelay: Duration.zero,
      );

      await tester.pumpWidget(NewsApp(newsService: mockService));

      // Memastikan judul AppBar tampil berbahasa Indonesia dan indikator loading muncul dulu
      expect(find.text('Kabar Hari Ini'), findsOneWidget);
      expect(find.text('Sedang memuat berita terbaru...'), findsOneWidget);
      expect(AppTheme.lightTheme.useMaterial3, isTrue);

      // Menjalankan proses async pembacaan file assets di luar fake async
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();

      expect(find.text('Kompas Tekno'), findsOneWidget);
      expect(
        find.text(
          'Inovasi Kecerdasan Buatan Lokal Dorong Efisiensi Industri Kreatif di Indonesia',
        ),
        findsOneWidget,
      );
    },
  );

  group('Pengujian Model Article dan Article.fromJson (Langkah 2)', () {
    test(
      'Berhasil mem-parsing seluruh artikel dari file assets/mock/articles.json berformat NewsAPI.org',
      () async {
        // Membaca file JSON contoh secara asinkron menggunakan async/await
        final File jsonFile = File('assets/mock/articles.json');
        final String jsonString = await jsonFile.readAsString();

        // Mengubah teks JSON menjadi Map seperti respons dari NewsAPI.org
        final Map<String, dynamic> responseMap =
            jsonDecode(jsonString) as Map<String, dynamic>;

        expect(responseMap['status'], equals('ok'));
        expect(responseMap['articles'], isA<List<dynamic>>());

        final List<dynamic> rawArticles =
            responseMap['articles'] as List<dynamic>;

        // Mem-parsing setiap objek JSON menjadi model Article menggunakan Article.fromJson
        final List<Article> articles = rawArticles
            .map(
              (dynamic item) => Article.fromJson(item as Map<String, dynamic>),
            )
            .toList();

        expect(articles.length, equals(8));

        // Memeriksa artikel pertama yang memiliki semua field lengkap
        final Article first = articles.first;
        expect(first.sourceName, equals('Kompas Tekno'));
        expect(first.author, equals('Rizky Pratama'));
        expect(
          first.title,
          equals(
            'Inovasi Kecerdasan Buatan Lokal Dorong Efisiensi Industri Kreatif di Indonesia',
          ),
        );
        expect(first.urlToImage, isNotNull);
        expect(first.publishedAt, isNotNull);
        expect(first.category, equals('Teknologi'));

        // Memeriksa artikel ke-4 yang memiliki author, description, dan urlToImage bernilai null
        final Article fourth = articles[3];
        expect(fourth.sourceName, equals('Sains Populer'));
        expect(fourth.author, isNull);
        expect(fourth.description, isNull);
        expect(fourth.urlToImage, isNull);

        // Memeriksa artikel ke-8 yang memiliki source.name null, author string kosong, dan publishedAt null
        final Article last = articles.last;
        expect(last.sourceName, isNull);
        expect(last.author, isNull);
        expect(last.urlToImage, isNull);
        expect(last.publishedAt, isNull);
      },
    );

    test(
      'Article.fromJson menangani field kosong atau null tanpa menyebabkan error',
      () {
        final Map<String, dynamic> emptyJson = <String, dynamic>{
          'source': null,
          'author': '   ',
          'title': null,
          'description': '',
          'url': null,
          'urlToImage': '   ',
          'publishedAt': 'tanggal-tidak-valid',
          'content': null,
        };

        final Article article = Article.fromJson(emptyJson);

        expect(article.title, equals('Judul berita tidak tersedia'));
        expect(article.sourceName, isNull);
        expect(article.author, isNull);
        expect(article.description, isNull);
        expect(article.url, isNull);
        expect(article.urlToImage, isNull);
        expect(article.publishedAt, isNull);
        expect(article.content, isNull);
      },
    );
  });

  group('Pengujian NewsService dan MockNewsService (Langkah 3)', () {
    test(
      'MockNewsService mengembalikan daftar artikel saat simulatedState = success',
      () async {
        // Menggunakan tipe abstrak NewsService sesuai arsitektur PRD
        final NewsService service = MockNewsService(
          simulatedState: MockResponseState.success,
          simulatedDelay: Duration.zero,
        );

        final List<Article> articles = await service.fetchArticles();

        expect(articles, isNotEmpty);
        expect(articles.length, equals(8));
        expect(articles.first.sourceName, equals('Kompas Tekno'));
      },
    );

    test(
      'MockNewsService mengembalikan daftar kosong saat simulatedState = empty',
      () async {
        final NewsService service = MockNewsService(
          simulatedState: MockResponseState.empty,
          simulatedDelay: Duration.zero,
        );

        final List<Article> articles = await service.fetchArticles();

        expect(articles, isEmpty);
      },
    );

    test(
      'MockNewsService melempar Exception saat simulatedState = error',
      () async {
        final NewsService service = MockNewsService(
          simulatedState: MockResponseState.error,
          simulatedDelay: Duration.zero,
        );

        expect(
          () async => await service.fetchArticles(),
          throwsA(isA<Exception>()),
        );
      },
    );
  });

  group('Pengujian NewsProvider dengan 4 Status Jaringan (Langkah 4)', () {
    test('Status berubah dari loading ke success saat berita berhasil dimuat', () async {
      final NewsProvider provider = NewsProvider(
        newsService: MockNewsService(
          simulatedState: MockResponseState.success,
          simulatedDelay: Duration.zero,
        ),
      );

      expect(provider.status, equals(NewsStatus.loading));
      await provider.loadArticles();
      expect(provider.status, equals(NewsStatus.success));
      expect(provider.articles.length, equals(8));
    });

    test('Status berubah menjadi empty saat hasil daftar berita kosong', () async {
      final NewsProvider provider = NewsProvider(
        newsService: MockNewsService(
          simulatedState: MockResponseState.empty,
          simulatedDelay: Duration.zero,
        ),
      );

      await provider.loadArticles();
      expect(provider.status, equals(NewsStatus.empty));
      expect(provider.articles, isEmpty);
    });

    test('Status berubah menjadi error saat pemanggilan gagal', () async {
      final NewsProvider provider = NewsProvider(
        newsService: MockNewsService(
          simulatedState: MockResponseState.error,
          simulatedDelay: Duration.zero,
        ),
      );

      await provider.loadArticles();
      expect(provider.status, equals(NewsStatus.error));
      expect(provider.errorMessage, isNotEmpty);
    });
  });

  group('Pengujian Layar Detail (Langkah 5)', () {
    testWidgets(
      'DetailScreen menampilkan informasi artikel lengkap dan menangani field null dengan rapi',
      (WidgetTester tester) async {
        const Article sampleArticle = Article(
          title: 'Judul Artikel Uji Coba Detail',
          sourceName: null,
          author: null,
          description: null,
          content: null,
          urlToImage: null,
          publishedAt: null,
        );

        await tester.pumpWidget(
          ChangeNotifierProvider<BookmarkProvider>(
            create: (_) => BookmarkProvider(),
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const DetailScreen(article: sampleArticle),
            ),
          ),
        );

        expect(find.text('Detail Berita'), findsOneWidget);
        expect(find.text('Judul Artikel Uji Coba Detail'), findsOneWidget);
        expect(find.text('Sumber Tidak Diketahui'), findsOneWidget);
        expect(find.text('Penulis: Redaksi'), findsOneWidget);
        expect(find.text('Baca selengkapnya'), findsOneWidget);
      },
    );
  });

  group('Pengujian BookmarkProvider dan Layar Favorit (Langkah 6)', () {
    test('BookmarkProvider dapat menambah dan menghapus artikel favorit di memori', () {
      final BookmarkProvider bookmarkProvider = BookmarkProvider();
      const Article sampleArticle = Article(
        title: 'Artikel Uji Bookmark',
        url: 'https://contoh.id/artikel-uji',
      );

      expect(bookmarkProvider.isBookmarked(sampleArticle), isFalse);
      expect(bookmarkProvider.bookmarks, isEmpty);

      // Menambahkan ke favorit
      bookmarkProvider.toggleBookmark(sampleArticle);
      expect(bookmarkProvider.isBookmarked(sampleArticle), isTrue);
      expect(bookmarkProvider.bookmarks.length, equals(1));

      // Menghapus dari favorit
      bookmarkProvider.toggleBookmark(sampleArticle);
      expect(bookmarkProvider.isBookmarked(sampleArticle), isFalse);
      expect(bookmarkProvider.bookmarks, isEmpty);
    });

    testWidgets('BookmarkScreen menampilkan pesan kosong saat belum ada favorit', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<BookmarkProvider>(
          create: (_) => BookmarkProvider(),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const BookmarkScreen(),
          ),
        ),
      );

      expect(find.text('Berita Favorit'), findsOneWidget);
      expect(find.text('Belum Ada Berita Favorit'), findsOneWidget);
    });
  });

  group(
    'Pengujian Pencarian, Kategori, dan Ketiga State Tampilan (Langkah 7)',
    () {
      test(
        'Pencarian dan filter kategori menyaring daftar artikel serta mengubah state menjadi empty bila tidak ada yang cocok',
        () async {
          final NewsProvider provider = NewsProvider(
            newsService: MockNewsService(
              simulatedState: MockResponseState.success,
              simulatedDelay: Duration.zero,
            ),
          );

          await provider.loadArticles();
          expect(provider.status, equals(NewsStatus.success));
          expect(provider.articles.length, equals(8));

          // Filter kategori Teknologi (ada 2 artikel di mock JSON)
          provider.setSelectedCategory('Teknologi');
          expect(provider.status, equals(NewsStatus.success));
          expect(provider.articles.length, equals(2));

          // Pencarian kata kunci "Flutter" di dalam kategori Teknologi
          provider.setSearchQuery('Flutter');
          expect(provider.status, equals(NewsStatus.success));
          expect(provider.articles.length, equals(1));
          expect(
            provider.articles.first.title,
            contains('Belajar Flutter'),
          );

          // Pencarian kata kunci yang tidak ada -> status berubah menjadi empty
          provider.setSearchQuery('KataKunciYangTidakAdaSamaSekali123');
          expect(provider.status, equals(NewsStatus.empty));
          expect(provider.articles, isEmpty);

          // Reset filter mengembalikan semua artikel dan status menjadi success
          provider.resetFilters();
          expect(provider.status, equals(NewsStatus.success));
          expect(provider.articles.length, equals(8));
        },
      );

      testWidgets(
        'Uji UI State Error: Menampilkan pesan kendala dan tombol Coba Lagi',
        (WidgetTester tester) async {
          final NewsService errorService = MockNewsService(
            simulatedState: MockResponseState.error,
            simulatedDelay: Duration.zero,
          );

          await tester.pumpWidget(NewsApp(newsService: errorService));
          await tester.pumpAndSettle();

          expect(find.text('Terjadi Kendala'), findsOneWidget);
          expect(find.text('Coba Lagi'), findsOneWidget);
        },
      );

      testWidgets(
        'Uji UI State Kosong: Menampilkan pesan Belum Ada Berita saat data kosong',
        (WidgetTester tester) async {
          final NewsService emptyService = MockNewsService(
            simulatedState: MockResponseState.empty,
            simulatedDelay: Duration.zero,
          );

          await tester.pumpWidget(NewsApp(newsService: emptyService));
          await tester.pumpAndSettle();

          expect(find.text('Belum Ada Berita'), findsOneWidget);
          expect(find.text('Muat Ulang'), findsOneWidget);
        },
      );
    },
  );
}
