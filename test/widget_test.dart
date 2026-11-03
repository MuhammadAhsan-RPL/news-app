import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/main.dart';
import 'package:news_app/theme/app_theme.dart';

void main() {
  testWidgets('Aplikasi memuat tema AppTheme dengan benar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NewsApp());

    // Memastikan judul halaman pratinjau tampil berbahasa Indonesia
    expect(find.text('Kabar Hari Ini'), findsOneWidget);
    expect(find.text('Tema Siap Dites'), findsOneWidget);
    expect(AppTheme.lightTheme.useMaterial3, isTrue);
  });
}
