import 'package:flutter/foundation.dart';
import '../models/article.dart';

/// Provider untuk menyimpan daftar artikel favorit (bookmark) di dalam memori (RAM).
/// Sesuai PRD versi 1, daftar favorit sengaja disimpan di memori lewat Provider
/// tanpa penyimpanan lokal permanen.
class BookmarkProvider extends ChangeNotifier {
  final List<Article> _bookmarks = <Article>[];

  /// Mengembalikan daftar artikel yang telah ditandai sebagai favorit
  List<Article> get bookmarks => List<Article>.unmodifiable(_bookmarks);

  /// Mengecek apakah sebuah artikel sudah ada di dalam daftar favorit.
  /// Menggunakan kombinasi `url` (jika ada) dan `title` sebagai penanda unik artikel.
  bool isBookmarked(Article article) {
    return _bookmarks.any((Article item) => _isSameArticle(item, article));
  }

  /// Menambahkan artikel ke daftar favorit jika belum ada, atau menghapusnya jika sudah ada.
  /// Memanggil `notifyListeners()` agar ikon bookmark di Beranda, Detail, dan Favorit
  /// langsung berubah secara konsisten.
  void toggleBookmark(Article article) {
    final int existingIndex = _bookmarks.indexWhere(
      (Article item) => _isSameArticle(item, article),
    );

    if (existingIndex >= 0) {
      _bookmarks.removeAt(existingIndex);
    } else {
      _bookmarks.add(article);
    }

    notifyListeners();
  }

  /// Fungsi bantu untuk membandingkan kesamaan dua objek [Article].
  bool _isSameArticle(Article a, Article b) {
    if (a.url != null && b.url != null) {
      return a.url == b.url;
    }
    return a.title == b.title;
  }
}

