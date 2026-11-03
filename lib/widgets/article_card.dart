import 'package:flutter/material.dart';
import '../models/article.dart';
import '../theme/app_theme.dart';

/// Komponen kartu berita yang dipakai di layar Beranda dan Favorit.
/// Menampilkan gambar (dengan placeholder jika kosong/gagal), nama sumber,
/// waktu terbit, judul, dan deskripsi singkat.
class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback? onTap;
  final Widget? trailingAction;

  const ArticleCard({
    super.key,
    required this.article,
    this.onTap,
    this.trailingAction,
  });

  /// Mengubah [DateTime] menjadi format tanggal berbahasa Indonesia yang rapi.
  /// Jika `publishedAt` bernilai null, tampilkan teks cadangan.
  static String formatPublishedDate(DateTime? date) {
    if (date == null) {
      return 'Waktu tidak diketahui';
    }

    const List<String> namaBulan = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    final DateTime localDate = date.toLocal();
    final String hari = localDate.day.toString().padLeft(2, '0');
    final String bulan = namaBulan[localDate.month - 1];
    final String tahun = localDate.year.toString();
    final String jam = localDate.hour.toString().padLeft(2, '0');
    final String menit = localDate.minute.toString().padLeft(2, '0');

    return '$hari $bulan $tahun · $jam:$menit';
  }

  @override
  Widget build(BuildContext context) {
    final String sourceText = article.sourceName ?? 'Sumber Tidak Diketahui';
    final String dateText = formatPublishedDate(article.publishedAt);
    final String descriptionText =
        article.description ?? 'Deskripsi berita tidak tersedia untuk artikel ini.';

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radius16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar artikel dengan penanganan nilai null dan error pemuatan jaringan
            _ArticleImageBanner(imageUrl: article.urlToImage),

            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baris metadata: nama sumber, waktu terbit, dan tombol aksi opsional (mis. bookmark)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing8,
                            vertical: AppTheme.spacing8 / 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryContainerColor,
                            borderRadius: BorderRadius.circular(AppTheme.radius8),
                          ),
                          child: Text(
                            sourceText,
                            style: AppTheme.bodyBoldStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing8),
                      Expanded(
                        child: Text(
                          dateText,
                          style: AppTheme.bodyMediumStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ),
                      if (trailingAction != null) ...[
                        const SizedBox(width: AppTheme.spacing8),
                        trailingAction!,
                      ],
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing8),

                  // Judul artikel (Tingkat 1: Tipografi Judul)
                  Text(
                    article.title,
                    style: AppTheme.titleMediumStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spacing8),

                  // Deskripsi singkat artikel (Tingkat 2: Tipografi Isi)
                  Text(
                    descriptionText,
                    style: AppTheme.bodyMediumStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget internal untuk menampilkan gambar artikel beserta placeholder
/// jika `imageUrl` bernilai null atau gagal dimuat dari internet.
class _ArticleImageBanner extends StatelessWidget {
  final String? imageUrl;

  const _ArticleImageBanner({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    return SizedBox(
      height: AppTheme.cardImageHeight,
      width: double.infinity,
      child: Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        // Menampilkan placeholder saat gambar masih diunduh
        loadingBuilder: (
          BuildContext context,
          Widget child,
          ImageChunkEvent? loadingProgress,
        ) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder(isLoading: true);
        },
        // Menampilkan placeholder rapi saat gambar gagal dimuat (mis. sedang offline)
        errorBuilder: (
          BuildContext context,
          Object error,
          StackTrace? stackTrace,
        ) {
          return _buildPlaceholder();
        },
      ),
    );
  }

  Widget _buildPlaceholder({bool isLoading = false}) {
    return Container(
      height: AppTheme.cardImageHeight,
      width: double.infinity,
      color: AppTheme.surfaceVariantColor,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isLoading ? Icons.hourglass_top_rounded : Icons.image_outlined,
            size: AppTheme.iconSizeLarge,
            color: AppTheme.textSecondaryColor,
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            isLoading ? 'Memuat gambar...' : 'Gambar tidak tersedia',
            style: AppTheme.bodyMediumStyle,
          ),
        ],
      ),
    );
  }
}

