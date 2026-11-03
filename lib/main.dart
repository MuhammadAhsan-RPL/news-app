import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const NewsApp());
}

/// Widget akar aplikasi News App yang menerapkan tema dari [AppTheme].
/// Pada langkah selanjutnya, Provider dan layar utama akan dihubungkan di sini.
class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portal Berita',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const ThemePreviewScreen(),
    );
  }
}

/// Layar pratinjau sementara untuk mengecek tampilan tema profesional dan estetik
/// pada Langkah 1 sebelum layar Beranda dibuat pada langkah berikutnya.
class ThemePreviewScreen extends StatelessWidget {
  const ThemePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kabar Hari Ini'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.bookmark_border_rounded),
            tooltip: 'Favorit',
          ),
          const SizedBox(width: AppTheme.spacing8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        children: [
          // Pratinjau kolom pencarian dengan gaya tema
          const TextField(
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'Cari berita terkini...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),

          // Pratinjau chip kategori
          Wrap(
            spacing: AppTheme.spacing8,
            runSpacing: AppTheme.spacing8,
            children: const [
              ChoiceChip(
                label: Text('Semua'),
                selected: true,
              ),
              ChoiceChip(
                label: Text('Teknologi'),
                selected: false,
              ),
              ChoiceChip(
                label: Text('Bisnis'),
                selected: false,
              ),
              ChoiceChip(
                label: Text('Olahraga'),
                selected: false,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing24),

          // Pratinjau kartu berita dengan tipografi Judul dan Isi
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: AppTheme.cardImageHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariantColor,
                      borderRadius: BorderRadius.circular(AppTheme.radius8),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.newspaper_rounded,
                      size: AppTheme.iconSizeLarge,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        child: const Text(
                          'Kompas Tekno',
                          style: AppTheme.bodyBoldStyle,
                        ),
                      ),
                      const Text(
                        'Baru saja',
                        style: AppTheme.bodyMediumStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  const Text(
                    'Langkah 1 Selesai: Tema Profesional, Berkelas & Estetik Siap Digunakan',
                    style: AppTheme.titleMediumStyle,
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  const Text(
                    'Seluruh warna, ukuran teks (dua tingkat tipografi: judul dan isi), serta jarak kelipatan 8 kini diambil langsung dari AppTheme.',
                    style: AppTheme.bodyLargeStyle,
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.verified_outlined),
                      label: const Text('Tema Siap Dites'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
