import 'package:flutter_test/flutter_test.dart';
import 'package:terapis/main.dart';
import 'package:terapis/state/app_state.dart';
import 'package:terapis/data/models/job_model.dart';

void main() {
  tearDown(() {
    AppState.instance.stopActiveTimers();
  });

  testWidgets('App mounts and displays navigation tabs and greeting', (WidgetTester tester) async {
    await tester.pumpWidget(const MomnjoTherapistApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify Bottom Navigation tabs exist
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Job'), findsOneWidget);
    expect(find.text('Laporan'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);

    // Verify Greeting exists on Beranda
    expect(find.textContaining('Selamat'), findsOneWidget);

    // Cancel periodic ticker so test clean up succeeds
    AppState.instance.stopActiveTimers();
  });

  test('AppState handles attendance and job workflows correctly', () {
    final state = AppState.instance;

    // Test Duty status
    state.checkIn();
    expect(state.isOnDuty, isTrue);

    state.checkOut();
    expect(state.isOnDuty, isFalse);

    // Test Job transitions
    final job = state.jobs.first;
    final jobId = job.idJobStatus;

    state.markArrived(jobId);
    expect(state.getJobById(jobId)?.statusLayanan, StatusLayanan.arrived);

    state.startTreatment(jobId);
    expect(state.getJobById(jobId)?.statusLayanan, StatusLayanan.proses);

    state.pauseTreatment(jobId);
    expect(state.getJobById(jobId)?.statusLayanan, StatusLayanan.dijeda);

    state.resumeTreatment(jobId);
    expect(state.getJobById(jobId)?.statusLayanan, StatusLayanan.proses);

    state.completeTreatment(jobId);
    expect(state.getJobById(jobId)?.statusLayanan, StatusLayanan.selesai);
  });
}
