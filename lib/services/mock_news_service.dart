import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/article.dart';
import 'news_service.dart';

/// Pilihan mode simulasi hasil pemanggilan data untuk keperluan belajar dan pengujian state UI.
enum MockResponseState {
  /// Mengembalikan daftar artikel dari file JSON contoh (status sukses)
  success,

  /// Memaksa terjadinya kegagalan untuk menguji tampilan pesan error & tombol coba lagi
  error,

  /// Mengembalikan daftar kosong `[]` untuk menguji tampilan saat berita tidak ditemukan
  empty,
}

/// Implementasi [NewsService] yang memuat data berita dari file lokal
/// `assets/mock/articles.json` dengan jeda waktu buatan 1-2 detik.
class MockNewsService implements NewsService {
  /// Pengaturan untuk memaksa hasil sukses, error, atau kosong.
  /// Ubah nilai default ini di kode jika ingin menguji tampilan error atau kosong di layar.
  MockResponseState simulatedState;

  /// Lama jeda buatan (default 1500 milidetik / 1,5 detik, sesuai rentang 1-2 detik di PRD)
  /// untuk mensimulasikan waktu tunggu jaringan (loading state).
  Duration simulatedDelay;

  /// Lokasi file JSON contoh di dalam folder assets
  final String assetPath;

  MockNewsService({
    this.simulatedState = MockResponseState.success,
    this.simulatedDelay = const Duration(milliseconds: 1500),
    this.assetPath = 'assets/mock/articles.json',
  });

  /// Mengambil daftar artikel dari file JSON lokal secara asinkron (`async`/`await`).
  /// Menggunakan [Future.delayed] untuk memberi jeda buatan seperti memanggil API sungguhan.
  @override
  Future<List<Article>> fetchArticles() async {
    // Menunggu selama `simulatedDelay` (1,5 detik) agar indikator loading tampil di UI
    await Future<void>.delayed(simulatedDelay);

    // 1. Jika disetel ke mode error, lempar Exception berbahasa Indonesia
    if (simulatedState == MockResponseState.error) {
      throw Exception(
        'Gagal memuat berita. Periksa koneksi internet Anda lalu coba lagi.',
      );
    }

    // 2. Jika disetel ke mode kosong, kembalikan list kosong
    if (simulatedState == MockResponseState.empty) {
      return <Article>[];
    }

    // 3. Jika disetel ke mode sukses, baca file JSON dari assets secara asinkron
    final String jsonString = await rootBundle.loadString(assetPath);

    // Mengubah teks JSON menjadi Map sesuai struktur respons NewsAPI.org
    final Map<String, dynamic> jsonMap =
        jsonDecode(jsonString) as Map<String, dynamic>;

    final List<dynamic> rawArticles =
        (jsonMap['articles'] as List<dynamic>?) ?? <dynamic>[];

    // Mem-parsing setiap item JSON menjadi objek Article memakai Article.fromJson
    return rawArticles
        .whereType<Map<String, dynamic>>()
        .map((Map<String, dynamic> item) => Article.fromJson(item))
        .toList();
  }
}

