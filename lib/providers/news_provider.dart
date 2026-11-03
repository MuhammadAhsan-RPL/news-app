import 'package:flutter/foundation.dart';
import '../models/article.dart';
import '../services/news_service.dart';

/// Empat status jaringan sesuai aturan proyek dan PRD:
/// loading (sedang memuat), success (berhasil ada data), error (gagal), empty (data kosong).
enum NewsStatus {
  loading,
  success,
  error,
  empty,
}

/// Provider untuk mengelola daftar berita dan status jaringan (loading, sukses, error, kosong).
/// Kelas ini hanya bergantung pada kelas abstrak [NewsService], bukan `MockNewsService`,
/// sehingga nanti mudah diganti dengan `ApiNewsService` tanpa mengubah UI.
class NewsProvider extends ChangeNotifier {
  final NewsService newsService;

  /// Menyimpan status jaringan saat ini
  NewsStatus _status = NewsStatus.loading;

  /// Menyimpan daftar artikel yang berhasil dimuat
  List<Article> _articles = <Article>[];

  /// Menyimpan pesan error berbahasa Indonesia jika pemanggilan data gagal
  String _errorMessage = '';

  NewsProvider({required this.newsService});

  /// Getter agar UI bisa membaca status jaringan saat ini
  NewsStatus get status => _status;

  /// Getter agar UI bisa membaca daftar artikel
  List<Article> get articles => _articles;

  /// Getter agar UI bisa membaca pesan error
  String get errorMessage => _errorMessage;

  /// Mengambil daftar berita dari [NewsService] secara asinkron menggunakan `async`/`await`.
  /// Setiap perubahan status memanggil `notifyListeners()` agar UI otomatis diperbarui.
  Future<void> loadArticles() async {
    // 1. Set status menjadi loading sebelum proses pengambilan data dimulai
    _status = NewsStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      // 2. Menunggu hasil pemanggilan Future dari NewsService dengan kata kunci `await`
      final List<Article> result = await newsService.fetchArticles();

      if (result.isEmpty) {
        // 3a. Jika hasil berupa list kosong, ubah status menjadi `empty`
        _articles = <Article>[];
        _status = NewsStatus.empty;
      } else {
        // 3b. Jika ada data, simpan daftar artikel dan ubah status menjadi `success`
        _articles = result;
        _status = NewsStatus.success;
      }
    } catch (e) {
      // 4. Jika terjadi error/exception, tangkap dan ubah status menjadi `error`
      _articles = <Article>[];
      _status = NewsStatus.error;
      _errorMessage =
          'Gagal memuat berita. Periksa koneksi internet Anda lalu coba lagi.';
    }

    // Memberi tahu seluruh widget pendengar (Consumer/watch) bahwa state sudah berubah
    notifyListeners();
  }
}
