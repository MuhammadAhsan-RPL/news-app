/// Model data untuk satu artikel berita yang sesuai dengan format respons NewsAPI.org.
/// Semua field boleh bernilai kosong (null) kecuali [title], tetapi tetap diberi
/// nilai cadangan (fallback) pada [fromJson] agar UI selalu aman dari error null.
class Article {
  final String? sourceName;
  final String? author;
  final String title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final DateTime? publishedAt;
  final String? content;

  /// Field opsional tambahan untuk membantu penyaringan kategori pada data contoh
  final String? category;

  const Article({
    this.sourceName,
    this.author,
    required this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.category,
  });

  /// Factory constructor `fromJson` berfungsi mengubah Map JSON (dari file lokal
  /// maupun respons API NewsAPI.org) menjadi objek [Article] di Dart.
  /// Setiap field dicek dan dibersihkan agar tahan terhadap nilai null atau string kosong.
  factory Article.fromJson(Map<String, dynamic> json) {
    // Mengambil objek `source` di dalam JSON karena format NewsAPI menyimpan
    // nama media di dalam `source: { "id": ..., "name": "..." }`.
    final Map<String, dynamic>? sourceMap =
        json['source'] is Map<String, dynamic>
            ? json['source'] as Map<String, dynamic>
            : null;

    // Mengambil dan membersihkan judul; jika kosong atau null, gunakan teks cadangan berbahasa Indonesia.
    final String rawTitle = (json['title'] as String?)?.trim() ?? '';
    final String safeTitle =
        rawTitle.isEmpty ? 'Judul berita tidak tersedia' : rawTitle;

    // Mengubah string waktu ISO-8601 (mis. "2026-10-13T08:30:00Z") menjadi DateTime.
    // `DateTime.tryParse` dipakai agar tidak melempar error jika format tanggal tidak valid atau null.
    final String? rawPublishedAt = json['publishedAt'] as String?;
    final DateTime? parsedDate =
        rawPublishedAt != null ? DateTime.tryParse(rawPublishedAt) : null;

    return Article(
      sourceName: _cleanNullableString(sourceMap?['name'] as String?),
      author: _cleanNullableString(json['author'] as String?),
      title: safeTitle,
      description: _cleanNullableString(json['description'] as String?),
      url: _cleanNullableString(json['url'] as String?),
      urlToImage: _cleanNullableString(json['urlToImage'] as String?),
      publishedAt: parsedDate,
      content: _cleanNullableString(json['content'] as String?),
      category: _cleanNullableString(json['category'] as String?),
    );
  }

  /// Fungsi bantu untuk mengubah string yang kosong atau hanya berisi spasi menjadi null,
  /// sehingga UI dapat menampilkan teks pengganti (fallback) dengan rapi.
  static String? _cleanNullableString(String? value) {
    if (value == null) return null;
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

