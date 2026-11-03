import '../models/article.dart';

/// Kelas abstrak yang menjadi titik sambung antara UI/Provider dan sumber data berita.
/// UI serta Provider hanya bergantung pada kelas [NewsService] ini, sehingga pada
/// tahap integrasi API nanti, siswa cukup mengganti [MockNewsService] dengan
/// `ApiNewsService` tanpa mengubah kode tampilan sama sekali.
abstract class NewsService {
  /// Mengambil daftar artikel secara asinkron.
  /// Mengembalikan [Future] berisi `List<Article>` setelah proses pemuatan selesai.
  Future<List<Article>> fetchArticles();
}

