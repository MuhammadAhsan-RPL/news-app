import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/main.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/theme/app_theme.dart';

void main() {
  testWidgets('Aplikasi memuat tema AppTheme dengan benar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NewsApp());

    // Memastikan judul halaman pratinjau tampil berbahasa Indonesia
    expect(find.text('Kabar Hari Ini'), findsOneWidget);
    expect(find.text('Tema Siap Dites'), findsOneWidget);
    expect(AppTheme.lightTheme.useMaterial3, isTrue);
  });

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
}
