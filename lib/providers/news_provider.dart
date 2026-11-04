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

/// Provider untuk mengelola daftar berita, status jaringan (loading, sukses, error, kosong),
/// serta penyaringan berdasarkan kata kunci pencarian dan kategori.
/// Kelas ini hanya bergantung pada kelas abstrak [NewsService], bukan `MockNewsService`,
/// sehingga nanti mudah diganti dengan `ApiNewsService` tanpa mengubah UI.
class NewsProvider extends ChangeNotifier {
  final NewsService newsService;

  /// Daftar kategori berita yang tersedia di Beranda
  static const List<String> categories = <String>[
    'Semua',
    'Teknologi',
    'Bisnis',
    'Olahraga',
    'Sains',
    'Kesehatan',
  ];

  /// Menyimpan status jaringan saat ini
  NewsStatus _status = NewsStatus.loading;

  /// Menyimpan seluruh daftar artikel asli yang dimuat dari NewsService
  List<Article> _allArticles = <Article>[];

  /// Menyimpan pesan error berbahasa Indonesia jika pemanggilan data gagal
  String _errorMessage = '';

  /// Menyimpan kata kunci pencarian saat ini
  String _searchQuery = '';

  /// Menyimpan kategori yang sedang dipilih (default: 'Semua')
  String _selectedCategory = 'Semua';

  NewsProvider({required this.newsService});

  /// Getter agar UI bisa membaca status jaringan saat ini
  NewsStatus get status => _status;

  /// Getter agar UI bisa membaca pesan error
  String get errorMessage => _errorMessage;

  /// Getter untuk membaca kata kunci pencarian aktif
  String get searchQuery => _searchQuery;

  /// Getter untuk membaca kategori yang sedang dipilih
  String get selectedCategory => _selectedCategory;

  /// Getter yang mengembalikan daftar artikel yang sudah disaring berdasarkan
  /// kategori dan kata kunci pencarian.
  List<Article> get articles {
    return _allArticles.where((Article article) {
      // 1. Saring berdasarkan kategori (jika bukan 'Semua')
      final bool matchesCategory = _selectedCategory == 'Semua' ||
          (article.category?.toLowerCase() == _selectedCategory.toLowerCase());

      if (!matchesCategory) return false;

      // 2. Saring berdasarkan kata kunci pencarian (jika tidak kosong)
      final String query = _searchQuery.trim().toLowerCase();
      if (query.isEmpty) return true;

      final bool matchesTitle = article.title.toLowerCase().contains(query);
      final bool matchesDescription =
          (article.description ?? '').toLowerCase().contains(query);
      final bool matchesSource =
          (article.sourceName ?? '').toLowerCase().contains(query);

      return matchesTitle || matchesDescription || matchesSource;
    }).toList();
  }

  /// Mengubah kata kunci pencarian dan memperbarui status tampilan (`success` atau `empty`)
  /// lewat `notifyListeners()` agar UI otomatis menyesuaikan hasil saringan.
  void setSearchQuery(String query) {
    _searchQuery = query;
    _updateFilteredStatus();
    notifyListeners();
  }

  /// Mengubah kategori yang dipilih dan memperbarui status tampilan (`success` atau `empty`)
  /// lewat `notifyListeners()` agar UI otomatis menyesuaikan hasil saringan.
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    _updateFilteredStatus();
    notifyListeners();
  }

  /// Mereset pencarian dan kategori kembali ke kondisi awal ('Semua').
  void resetFilters() {
    _searchQuery = '';
    _selectedCategory = 'Semua';
    _updateFilteredStatus();
    notifyListeners();
  }

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
      _allArticles = result;

      // 3. Menentukan apakah hasil akhir (setelah disaring) berstatus `empty` atau `success`
      _updateFilteredStatus();
    } catch (e) {
      // 4. Jika terjadi error/exception, tangkap dan ubah status menjadi `error`
      _allArticles = <Article>[];
      _status = NewsStatus.error;
      _errorMessage =
          'Gagal memuat berita. Periksa koneksi internet Anda lalu coba lagi.';
    }

    // Memberi tahu seluruh widget pendengar (Consumer/watch) bahwa state sudah berubah
    notifyListeners();
  }

  /// Fungsi internal untuk mengatur status menjadi `empty` jika hasil saringan kosong
  /// atau `success` jika terdapat minimal satu artikel.
  void _updateFilteredStatus() {
    if (_status == NewsStatus.error) return;
    if (articles.isEmpty) {
      _status = NewsStatus.empty;
    } else {
      _status = NewsStatus.success;
    }
  }
}
