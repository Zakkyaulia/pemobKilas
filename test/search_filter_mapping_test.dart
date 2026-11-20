import 'package:flutter_test/flutter_test.dart';
import 'package:pemob_kilas/screens/search/search_filter_screen.dart';

/// Memastikan pilihan di layar Cari & Filter diterjemahkan dengan benar
/// ke parameter `GET /api/reports` (category, q, sort, from).
void main() {
  final now = DateTime(2026, 11, 20, 19, 45);

  SearchFilterResult result({
    String query = '',
    Set<ReportCategory> categories = SearchFilterResult.defaultCategories,
    SortMode sort = SortMode.terbaru,
    TimeRange range = TimeRange.semua,
  }) =>
      SearchFilterResult(
        query: query,
        categories: categories,
        sortMode: sort,
        timeRange: range,
        resultCount: 0,
      );

  test('Pilihan bawaan = tanpa filter', () {
    final f = result().toReportFilter(now: now);
    expect(f.category, isNull);
    expect(f.query, isNull);
    expect(f.from, isNull);
    expect(f.isActive, isFalse);
    expect(result().isActive, isFalse);
  });

  test('Satu kategori dikirim sebagai category', () {
    expect(result(categories: {ReportCategory.kondisiKampus}).toReportFilter(now: now).category, 'kondisi_kampus');
    expect(result(categories: {ReportCategory.informasiPenting}).toReportFilter(now: now).category, 'informasi_penting');
  });

  test('Kata kunci & urutan', () {
    final f = result(query: 'lampu', sort: SortMode.upvoteTerbanyak).toReportFilter(now: now);
    expect(f.query, 'lampu');
    expect(f.sort, 'terpopuler');
    expect(f.isActive, isTrue);
  });

  test('Rentang waktu menjadi tanggal awal', () {
    expect(result(range: TimeRange.hariIni).toReportFilter(now: now).from, DateTime(2026, 11, 20));
    expect(result(range: TimeRange.tujuhHari).toReportFilter(now: now).from, DateTime(2026, 11, 13, 19, 45));
    expect(result(range: TimeRange.bulanIni).toReportFilter(now: now).from, DateTime(2026, 11, 1));
  });

  test('Ringkasan untuk bar Filter aktif', () {
    final r = result(
      query: 'lampu',
      categories: {ReportCategory.kondisiKampus},
      range: TimeRange.tujuhHari,
      sort: SortMode.upvoteTerbanyak,
    );
    expect(r.summary, '"lampu" · Kondisi Kampus · 7 hari · Upvote terbanyak');
  });
}
