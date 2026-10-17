import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pemob_kilas/screens/home/data/report_repository.dart';
import 'package:pemob_kilas/widgets/home/upvote_button.dart';

void main() {
  group('Refactoring Verification - ReportRepository (Single Source of Truth)', () {
    test('Mengupdate status laporan di repository langsung memicu listener secara real-time', () {
      final repo = ReportRepository.instance;
      expect(repo.length, greaterThan(0));

      final firstReport = repo[0];
      final initialCount = firstReport.upvoteCount;
      final initialVoteState = firstReport.isUpvoted;

      bool listenerCalled = false;
      void listener() {
        listenerCalled = true;
      }

      repo.addListener(listener);

      // Mutasi data (misal upvote dari Detail Screen atau Search Screen)
      final updatedReport = firstReport.copyWith(
        isUpvoted: !initialVoteState,
        upvoteCount: initialCount + (!initialVoteState ? 1 : -1),
      );

      repo.updateById(firstReport.id, updatedReport);

      // Verifikasi: listener screen otomatis terpicu tanpa perlu passing data manual
      expect(listenerCalled, isTrue, reason: 'Listener wajib terpicu secara instan');
      expect(repo[0].upvoteCount, equals(updatedReport.upvoteCount));
      expect(repo[0].isUpvoted, equals(updatedReport.isUpvoted));

      // Kembalikan ke state semula
      repo.updateById(firstReport.id, firstReport);
      repo.removeListener(listener);
    });
  });

  group('Refactoring Verification - UpvoteButton (Enkapsulasi & Anti-Spam Validation)', () {
    testWidgets('Tapping UpvoteButton memperbarui UI dan memblokir klik spam bertubi-tubi', (tester) async {
      int changeCount = 0;
      bool cooldownTriggered = false;
      bool currentIsUpvoted = false;
      int currentVoteCount = 10;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: UpvoteButton(
                initialCount: currentVoteCount,
                initialIsUpvoted: currentIsUpvoted,
                cooldownDuration: const Duration(seconds: 2),
                onChanged: (isUpvoted, count) {
                  changeCount++;
                  currentIsUpvoted = isUpvoted;
                  currentVoteCount = count;
                },
                onCooldownTriggered: () {
                  cooldownTriggered = true;
                },
              ),
            ),
          ),
        ),
      );

      // Verifikasi angka awal
      expect(find.text('10'), findsOneWidget);

      // Tap pertama: Sukses
      await tester.tap(find.byType(UpvoteButton));
      await tester.pump();

      expect(changeCount, equals(1));
      expect(currentIsUpvoted, isTrue);
      expect(currentVoteCount, equals(11));
      expect(find.text('11'), findsOneWidget);

      // Tap kedua segera setelahnya (< 2 detik cooldown): Harus diblokir!
      await tester.tap(find.byType(UpvoteButton));
      await tester.pump();

      expect(changeCount, equals(1), reason: 'Klik spam wajib diblokir oleh anti-spam validator');
      expect(cooldownTriggered, isTrue, reason: 'Callback cooldown wajib terpicu untuk feedback user');
      expect(currentVoteCount, equals(11), reason: 'Angka tidak boleh bertambah saat cooldown');

      // Setelah 2.1 detik waktu nyata berlalu, tap ketiga harus diterima kembali
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 2100));
      });
      await tester.pump();
      await tester.tap(find.byType(UpvoteButton));
      await tester.pump();

      expect(changeCount, equals(2));
      expect(currentIsUpvoted, isFalse);
      expect(currentVoteCount, equals(10));
      expect(find.text('10'), findsOneWidget);
    });
  });
}
