import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Widget untuk menampilkan indikator saat data berita sedang dimuat (state loading).
class LoadingStateView extends StatelessWidget {
  final String message;

  const LoadingStateView({
    super.key,
    this.message = 'Sedang memuat berita terbaru...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              message,
              style: AppTheme.bodyLargeStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget untuk menampilkan pesan saat pemanggilan data gagal beserta tombol "Coba Lagi" (state error).
class ErrorStateView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorStateView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              decoration: BoxDecoration(
                color: AppTheme.errorContainerColor,
                borderRadius: BorderRadius.circular(AppTheme.radius24),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: AppTheme.iconSizeLarge,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),
            const Text(
              'Terjadi Kendala',
              style: AppTheme.titleMediumStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              message,
              style: AppTheme.bodyMediumStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget untuk menampilkan pesan saat daftar berita atau hasil pencarian kosong (state kosong).
class EmptyStateView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onAction;
  final String actionLabel;
  final IconData icon;

  const EmptyStateView({
    super.key,
    this.title = 'Belum Ada Berita',
    this.message = 'Saat ini belum ada artikel berita yang dapat ditampilkan.',
    this.onAction,
    this.actionLabel = 'Muat Ulang',
    this.icon = Icons.article_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariantColor,
                borderRadius: BorderRadius.circular(AppTheme.radius24),
              ),
              child: Icon(
                icon,
                size: AppTheme.iconSizeLarge,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              title,
              style: AppTheme.titleMediumStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              message,
              style: AppTheme.bodyMediumStyle,
              textAlign: TextAlign.center,
            ),
            if (onAction != null) ...[
              const SizedBox(height: AppTheme.spacing24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

