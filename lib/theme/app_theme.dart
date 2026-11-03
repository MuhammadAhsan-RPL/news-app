import 'package:flutter/material.dart';

/// Kelas pusat untuk mengatur seluruh warna, tipografi, jarak (kelipatan 8),
/// dan gaya tampilan aplikasi agar konsisten, profesional, berkelas, dan estetik.
class AppTheme {
  // Konstruktor privat agar kelas ini tidak bisa diinstansiasi secara langsung
  AppTheme._();

  // ===========================================================================
  // PALET WARNA PROFESIONAL & BERKELAS (Material 3: 1 Warna Utama + Warna Netral)
  // ===========================================================================

  /// Warna utama (Executive Navy / Biru Profesional) yang berkelas, modern, dan tepercaya
  static const Color primaryColor = Color(0xFF1E3A8A);

  /// Warna utama versi lembut untuk latar belakang chip/badge terpilih
  static const Color primaryContainerColor = Color(0xFFDBEAFE);

  /// Warna teks di atas primaryContainer
  static const Color onPrimaryContainerColor = Color(0xFF1E3A8A);

  /// Warna aksen elegan (Royal Blue) untuk penanda khusus seperti ikon bookmark aktif
  static const Color accentColor = Color(0xFF2563EB);

  /// Warna netral untuk latar belakang utama (Cool Alabaster / Abu-abu Putih Bersih)
  static const Color backgroundColor = Color(0xFFF8FAFC);

  /// Warna netral untuk permukaan kartu dan komponen (Pure Crisp White)
  static const Color surfaceColor = Color(0xFFFFFFFF);

  /// Warna netral untuk permukaan sekunder (placeholder gambar, area input)
  static const Color surfaceVariantColor = Color(0xFFF1F5F9);

  /// Warna teks utama (Deep Slate, sangat tajam dan profesional untuk membaca berita)
  static const Color textPrimaryColor = Color(0xFF0F172A);

  /// Warna teks sekunder untuk metadata, nama sumber, waktu, dan teks pendukung
  static const Color textSecondaryColor = Color(0xFF64748B);

  /// Warna garis pembatas atau border halus (Cool Gray Border)
  static const Color borderColor = Color(0xFFE2E8F0);

  /// Warna status error (Crimson Red Profesional)
  static const Color errorColor = Color(0xFFDC2626);

  /// Warna latar belakang kotak pesan error
  static const Color errorContainerColor = Color(0xFFFEE2E2);

  // ===========================================================================
  // JARAK & UKURAN (Kelipatan 8 sesuai panduan PRD)
  // ===========================================================================

  static const double spacing8 = 8.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;

  /// Radius sudut membulat (kelipatan 8) untuk kartu, gambar, dan tombol
  static const double radius8 = 8.0;
  static const double radius16 = 16.0;
  static const double radius24 = 24.0;

  /// Ukuran komponen tetap (kelipatan 8)
  static const double cardImageHeight = 184.0; // 8 * 23
  static const double detailImageHeight = 256.0; // 8 * 32
  static const double iconSizeSmall = 16.0; // 8 * 2
  static const double iconSizeMedium = 24.0; // 8 * 3
  static const double iconSizeLarge = 48.0; // 8 * 6

  // ===========================================================================
  // DUA TINGKAT TIPOGRAFI (Judul dan Isi sesuai panduan PRD)
  // ===========================================================================

  /// Tingkat 1: Tipografi Judul (tegas, modern, dan berkelas)
  static const TextStyle titleLargeStyle = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w800,
    color: textPrimaryColor,
    height: 1.25,
    letterSpacing: -0.4,
  );

  static const TextStyle titleMediumStyle = TextStyle(
    fontSize: 17.0,
    fontWeight: FontWeight.w700,
    color: textPrimaryColor,
    height: 1.35,
    letterSpacing: -0.25,
  );

  /// Tingkat 2: Tipografi Isi (proporsional dan nyaman dibaca)
  static const TextStyle bodyLargeStyle = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w400,
    color: textPrimaryColor,
    height: 1.6,
    letterSpacing: 0.1,
  );

  static const TextStyle bodyMediumStyle = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    color: textSecondaryColor,
    height: 1.45,
  );

  static const TextStyle bodyBoldStyle = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w600,
    color: primaryColor,
    height: 1.4,
  );

  // ===========================================================================
  // KONFIGURASI THEMEDATA MATERIAL 3
  // ===========================================================================

  static ThemeData get lightTheme {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: surfaceColor,
      primaryContainer: primaryContainerColor,
      onPrimaryContainer: onPrimaryContainerColor,
      secondary: accentColor,
      onSecondary: surfaceColor,
      surface: surfaceColor,
      onSurface: textPrimaryColor,
      surfaceContainerHighest: surfaceVariantColor,
      onSurfaceVariant: textSecondaryColor,
      outline: borderColor,
      error: errorColor,
      onError: surfaceColor,
      errorContainer: errorContainerColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      dividerColor: borderColor,

      // Konfigurasi dua tingkat tipografi pada TextTheme
      textTheme: const TextTheme(
        headlineMedium: titleLargeStyle,
        titleLarge: titleLargeStyle,
        titleMedium: titleMediumStyle,
        bodyLarge: bodyLargeStyle,
        bodyMedium: bodyMediumStyle,
        labelLarge: bodyBoldStyle,
      ),

      // Gaya AppBar bersih, tegas, dan modern
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimaryColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: titleLargeStyle,
        iconTheme: IconThemeData(
          color: textPrimaryColor,
          size: iconSizeMedium,
        ),
        shape: Border(
          bottom: BorderSide(color: borderColor, width: 1.0),
        ),
      ),

      // Gaya Kartu Artikel (ArticleCard) yang estetik dan rapi
      cardTheme: CardThemeData(
        color: surfaceColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius16),
          side: const BorderSide(color: borderColor, width: 1.0),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Gaya Chip Kategori yang clean dan profesional
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        selectedColor: primaryColor,
        disabledColor: surfaceVariantColor,
        labelStyle: bodyMediumStyle.copyWith(color: textPrimaryColor),
        secondaryLabelStyle: bodyBoldStyle.copyWith(color: surfaceColor),
        padding: const EdgeInsets.symmetric(
          horizontal: spacing16,
          vertical: spacing8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius24),
          side: const BorderSide(color: borderColor, width: 1.0),
        ),
        showCheckmark: false,
      ),

      // Gaya Kolom Pencarian (InputDecoration)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        hintStyle: bodyMediumStyle,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing16,
          vertical: spacing16,
        ),
        prefixIconColor: textSecondaryColor,
        suffixIconColor: textSecondaryColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius16),
          borderSide: const BorderSide(color: borderColor, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius16),
          borderSide: const BorderSide(color: borderColor, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius16),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
      ),

      // Gaya Tombol Utama (mis. Coba Lagi & Baca Selengkapnya)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: surfaceColor,
          textStyle: bodyBoldStyle.copyWith(color: surfaceColor),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing24,
            vertical: spacing16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius16),
          ),
          elevation: 0,
        ),
      ),

      // Gaya NavigationBar untuk Beranda & Favorit
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,
        indicatorColor: primaryContainerColor,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return bodyBoldStyle;
          }
          return bodyMediumStyle;
        }),
      ),

      // Gaya Indikator Loading
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        circularTrackColor: primaryContainerColor,
      ),

      // Gaya SnackBar untuk umpan balik pengguna
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimaryColor,
        contentTextStyle: bodyMediumStyle.copyWith(color: surfaceColor),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius8),
        ),
      ),
    );
  }
}
