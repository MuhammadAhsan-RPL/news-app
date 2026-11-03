import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../providers/bookmark_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/article_card.dart';

/// Layar Detail untuk menampilkan isi lengkap dari satu [Article].
/// Menampilkan gambar, sumber, tanggal terbit, judul, penulis, deskripsi,
/// isi berita, tombol bookmark di AppBar, dan tombol "Baca selengkapnya".
class DetailScreen extends StatelessWidget {
  final Article article;

  const DetailScreen({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    // Menangani nilai kosong (null) pada setiap field artikel dengan teks cadangan berbahasa Indonesia
    final String sourceText = article.sourceName ?? 'Sumber Tidak Diketahui';
    final String authorText = article.author ?? 'Redaksi';
    final String dateText = ArticleCard.formatPublishedDate(article.publishedAt);
    final String descriptionText =
        article.description ?? 'Deskripsi singkat tidak tersedia untuk artikel ini.';
    final String contentText =
        article.content ??
        'Isi lengkap berita tidak disertakan pada ringkasan ini. Silakan tekan tombol Baca selengkapnya di bawah untuk membuka artikel asli.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Berita'),
        actions: [
          // Menggunakan Consumer<BookmarkProvider> agar tombol bookmark di AppBar
          // selalu sinkron dengan Beranda dan halaman Favorit.
          Consumer<BookmarkProvider>(
            builder: (
              BuildContext context,
              BookmarkProvider bookmarkProvider,
              Widget? child,
            ) {
              final bool isSaved = bookmarkProvider.isBookmarked(article);
              return IconButton(
                onPressed: () {
                  bookmarkProvider.toggleBookmark(article);
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          isSaved
                              ? 'Dihapus dari daftar favorit.'
                              : 'Disimpan ke daftar favorit.',
                        ),
                      ),
                    );
                },
                icon: Icon(
                  isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: isSaved
                      ? AppTheme.accentColor
                      : AppTheme.textPrimaryColor,
                ),
                tooltip: isSaved ? 'Hapus dari Favorit' : 'Simpan ke Favorit',
              );
            },
          ),
          const SizedBox(width: AppTheme.spacing8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar utama artikel dengan placeholder jika kosong atau gagal dimuat
            _DetailHeaderImage(imageUrl: article.urlToImage),

            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baris badge sumber dan kategori (jika ada)
                  Wrap(
                    spacing: AppTheme.spacing8,
                    runSpacing: AppTheme.spacing8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
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
                        ),
                      ),
                      if (article.category != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing8,
                            vertical: AppTheme.spacing8 / 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceVariantColor,
                            borderRadius: BorderRadius.circular(AppTheme.radius8),
                          ),
                          child: Text(
                            article.category!,
                            style: AppTheme.bodyMediumStyle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing16),

                  // Judul artikel (Tingkat 1: Tipografi Judul)
                  Text(
                    article.title,
                    style: AppTheme.titleLargeStyle,
                  ),
                  const SizedBox(height: AppTheme.spacing16),

                  // Informasi penulis dan tanggal terbit dalam kartu ringkas
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(AppTheme.radius16),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline_rounded,
                              size: AppTheme.iconSizeSmall,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: AppTheme.spacing8),
                            Expanded(
                              child: Text(
                                'Penulis: $authorText',
                                style: AppTheme.bodyBoldStyle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: AppTheme.iconSizeSmall,
                              color: AppTheme.textSecondaryColor,
                            ),
                            const SizedBox(width: AppTheme.spacing8),
                            Expanded(
                              child: Text(
                                'Diterbitkan: $dateText',
                                style: AppTheme.bodyMediumStyle,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing24),

                  // Deskripsi artikel (Tingkat 2: Tipografi Isi)
                  const Text(
                    'Ringkasan',
                    style: AppTheme.titleMediumStyle,
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  Text(
                    descriptionText,
                    style: AppTheme.bodyLargeStyle,
                  ),
                  const SizedBox(height: AppTheme.spacing24),

                  // Isi berita lengkap (Tingkat 2: Tipografi Isi)
                  const Text(
                    'Isi Berita',
                    style: AppTheme.titleMediumStyle,
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  Text(
                    contentText,
                    style: AppTheme.bodyLargeStyle,
                  ),
                  const SizedBox(height: AppTheme.spacing32),

                  // Tombol "Baca selengkapnya" sesuai PRD (aksi membuka tautan dipasang pada tahap integrasi)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        final String urlInfo = article.url != null
                            ? 'Tautan artikel (${article.url}) akan dibuka pada tahap integrasi API.'
                            : 'Tautan sumber tidak tersedia untuk artikel ini.';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(urlInfo),
                          ),
                        );
                      },
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('Baca selengkapnya'),
                    ),
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

/// Widget internal untuk menampilkan gambar header di layar Detail beserta placeholder
/// saat `imageUrl` kosong (null) atau gagal dimuat.
class _DetailHeaderImage extends StatelessWidget {
  final String? imageUrl;

  const _DetailHeaderImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    return SizedBox(
      height: AppTheme.detailImageHeight,
      width: double.infinity,
      child: Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (
          BuildContext context,
          Widget child,
          ImageChunkEvent? loadingProgress,
        ) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder(isLoading: true);
        },
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
      height: AppTheme.detailImageHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceVariantColor,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor),
        ),
      ),
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
