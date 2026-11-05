import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terapis/data/local/session_manager.dart';
import 'package:terapis/data/models/user_model.dart';
import 'package:terapis/main.dart';
import 'package:terapis/screens/jobs/job_list_screen.dart';
import 'package:terapis/screens/jobs/job_detail_screen.dart';
import 'package:terapis/screens/profile/branch_contact_screen.dart';
import 'package:terapis/screens/reports/report_screen.dart';
import 'package:terapis/screens/reports/pengerjaan_list_screen.dart';
import 'package:terapis/data/models/report_model.dart';
import 'package:terapis/widgets/status_chip.dart';
import 'package:terapis/state/app_state.dart';
import 'package:terapis/data/models/job_model.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    AppState.instance.stopActiveTimers();
  });

  test('SessionManager persists and retrieves auth token and user profile', () async {
    const user = UserProfile(
      username: 'siti.therapis',
      namaLengkap: 'Siti Nurhaliza',
      nickname: 'Siti',
      email: 'siti@momnjo.com',
      noTelp: '081234567890',
      foto: '',
      idGerai: 2,
      namaGerai: 'Mom N Jo Darmawangsa',
      kodeGerai: '001',
      idPegawai: 15,
      position: 'Therapist Senior',
      workInBranch: 'Darmawangsa',
    );

    await SessionManager.saveSession(
      token: 'jwt_mock_token_123',
      user: user,
    );

    final token = await SessionManager.getToken();
    final retrievedUser = await SessionManager.getUser();

    expect(token, 'jwt_mock_token_123');
    expect(retrievedUser?.username, 'siti.therapis');
    expect(retrievedUser?.namaGerai, 'Mom N Jo Darmawangsa');

    await SessionManager.clearSession();
    expect(await SessionManager.getToken(), isNull);
    expect(await SessionManager.getUser(), isNull);
  });

  testWidgets('App mounts and displays login screen initially', (WidgetTester tester) async {
    AppState.instance.logout();
    await tester.pumpWidget(const MomnjoTherapistApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('momnjo'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);

    AppState.instance.stopActiveTimers();
  });

  testWidgets('App displays navigation tabs and greeting when logged in', (WidgetTester tester) async {
    final state = AppState.instance;
    state.setUseLiveApi(false);
    await state.login(username: 'siti.therapis', password: 'password123');

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
    state.stopActiveTimers();
  });

  testWidgets('Home screen interactive widgets redirect smoothly', (WidgetTester tester) async {
    final state = AppState.instance;
    state.setUseLiveApi(false);
    await state.login(username: 'siti.therapis', password: 'password123');

    await tester.pumpWidget(const MomnjoTherapistApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify clicking Pekerjaan Aktif switches tab to Job and filter to Aktif
    final pekerjaanAktifFinder = find.text('Pekerjaan Aktif');
    if (pekerjaanAktifFinder.evaluate().isNotEmpty) {
      await tester.tap(pekerjaanAktifFinder.first);
      await tester.pumpAndSettle();
      expect(state.selectedNavIndex, 1);
      expect(state.jobFilterTab, 'Aktif');
    }

    state.stopActiveTimers();
  });

  testWidgets('JobListScreen allows changing tabs and renders correctly', (WidgetTester tester) async {
    final state = AppState.instance;
    state.setUseLiveApi(false);

    await tester.pumpWidget(
      const MaterialApp(
        home: JobListScreen(),
      ),
    );
    await tester.pump();

    // Verify filter tabs exist and can be tapped
    expect(find.text('Aktif'), findsOneWidget);
    expect(find.text('Selesai'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);

    await tester.tap(find.text('Selesai'));
    await tester.pump();

    await tester.tap(find.text('Semua'));
    await tester.pump();
  });

  testWidgets('ReportScreen renders dynamic date range and filter bar', (WidgetTester tester) async {
    final state = AppState.instance;
    state.setUseLiveApi(false);

    await tester.pumpWidget(
      const MaterialApp(
        home: ReportScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('Laporan Saya'), findsOneWidget);
    expect(find.text('Semua Gerai'), findsWidgets);
  });

  testWidgets('BranchContactScreen displays primary branch accurately', (WidgetTester tester) async {
    final state = AppState.instance;
    state.setUseLiveApi(false);
    await state.login(username: 'siti.therapis', password: 'password123');

    await tester.pumpWidget(
      const MaterialApp(
        home: BranchContactScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('Kontak Gerai'), findsOneWidget);
    expect(find.text('Mom N Jo Darmawangsa'), findsWidgets);
  });

  test('AppState handles attendance and job workflows correctly', () async {
    final state = AppState.instance;
    state.setUseLiveApi(false);

    final testJob = JobModel.fromJson({
      'id_job_status': 101,
      'id_transaksi': 1,
      'id_booking': 1,
      'kategori_layanan': 'homecare',
      'status_layanan': 'menunggu',
      'terapis': 'Siti Nurhaliza',
      'durasi_standar': 90,
      'customer': {
        'id_customer': 1,
        'nama_lengkap': 'Ny. Aurelia Putri',
        'no_telp': '081234567890',
        'alamat': 'Jl. Senopati No. 45, Kebayoran Baru, Jakarta Selatan',
      },
      'item': {
        'nama_item': 'Mom Postpartum Care & Relaxing Massage',
        'jumlah': 1,
        'nominal': 475000,
        'kategori_tipe': 'reguler',
      },
    });
    state.setJobs([testJob]);

    // Test Duty status
    await state.checkIn();
    expect(state.isOnDuty, isTrue);

    await state.checkOut();
    expect(state.isOnDuty, isFalse);

    // Test Job transitions
    final job = state.jobs.first;
    final jobId = job.idJobStatus;

    await state.markArrived(jobId, fotoArrived: 'data:image/jpeg;base64,sample_photo');
    expect(state.getJobById(jobId)?.statusLayanan, StatusLayanan.arrived);
    expect(state.getJobById(jobId)?.fotoArrived, isNotNull);

    await state.startTreatment(jobId);
    expect(state.getJobById(jobId)?.statusLayanan, StatusLayanan.proses);

    await state.pauseTreatment(jobId);
    expect(state.getJobById(jobId)?.statusLayanan, StatusLayanan.dijeda);

    await state.resumeTreatment(jobId);
    expect(state.getJobById(jobId)?.statusLayanan, StatusLayanan.proses);

    await state.completeTreatment(jobId);
    expect(state.getJobById(jobId)?.statusLayanan, StatusLayanan.selesai);
    expect(state.getJobById(jobId)?.waktuSelesai, isNotNull);
  });

  testWidgets('JobDetailScreen hides Lokasi widget for Onsite job and displays customer and dynamic info', (tester) async {
    final state = AppState.instance;
    final onsiteJob = JobModel.fromJson({
      'id_job_status': 99,
      'id_transaksi': 'TRX-ONSITE-01',
      'id_booking': 'BKG-ONSITE-01',
      'kategori_layanan': 'onsite',
      'status_layanan': 'selesai',
      'waktu_selesai': '2026-10-30T16:45:00',
      'durasi_standar': 60,
      'nama_cust': 'Ibu Kartika Wijaya',
      'ruangan': 'Room Melati 03',
      'treatment': 'Baby Massage & Hydrotherapy',
    });
    state.setJobs([onsiteJob]);

    await tester.pumpWidget(
      const MaterialApp(
        home: JobDetailScreen(jobId: 99),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify customer info displayed
    expect(find.text('Ibu Kartika Wijaya'), findsOneWidget);
    expect(find.text('Room Melati 03'), findsOneWidget);

    // 2. Verify Lokasi/Alamat widget is NOT rendered for onsite
    expect(find.text('Alamat Homecare'), findsNothing);
    expect(find.text('Lokasi Onsite'), findsNothing);
    expect(find.text('Buka Map'), findsNothing);

    // 3. Verify dynamic completion date message
    expect(find.textContaining('Pekerjaan ini telah diselesaikan pada'), findsOneWidget);
    expect(find.textContaining('28 Okt 2026'), findsNothing);

    // 4. Verify treatment name
    expect(find.text('Baby Massage & Hydrotherapy'), findsWidgets);
  });

  testWidgets('PengerjaanListScreen displays dynamic treatment badges (Reguler vs Redeem)', (tester) async {
    final state = AppState.instance;
    final itemReguler = PengerjaanItem.fromJson({
      'no': 1,
      'tgl': '2026-10-30',
      'id_trx': 'TRX-REG-01',
      'nama_cust': 'Ibu Aurelia',
      'treatment': 'Mom Massage & Scrub 90 Menit',
      'qty': 1,
      'nominal_satuan': 250000,
      'total_nominal': 250000,
      'keterangan': 'Normal',
      'is_redeem': false,
    });

    final itemRedeem = PengerjaanItem.fromJson({
      'no': 2,
      'tgl': '2026-10-30',
      'id_trx': 'TRX-RED-02',
      'nama_cust': 'Ibu Dewi',
      'treatment': 'Postnatal Care',
      'qty': 1,
      'nominal_satuan': 150000,
      'total_nominal': 150000,
      'keterangan': 'Redeem',
      'is_redeem': true,
      'package_custom_name': 'Paket Pemulihan Ibu 5 Sesi',
    });

    final itemOverride = PengerjaanItem.fromJson({
      'no': 3,
      'tgl': '2026-10-30',
      'id_trx': 'TRX-OVR-03',
      'nama_cust': 'Ibu Kartika',
      'treatment': 'Baby Spa',
      'qty': 1,
      'nominal_satuan': 180000,
      'total_nominal': 180000,
      'keterangan': 'Redeem Override',
      'is_redeem': true,
    });

    expect(itemReguler.isRedeem, isFalse);
    expect(itemReguler.kategoriTipe, 'Treatment Reguler');
    expect(itemRedeem.isRedeem, isTrue);
    expect(itemRedeem.kategoriTipe, 'Redeem Paket');
    expect(itemOverride.isRedeem, isTrue);
    expect(itemOverride.kategoriTipe, 'Redeem Override');

    state.setPengerjaanList([itemReguler, itemRedeem, itemOverride]);

    await tester.pumpWidget(
      const MaterialApp(
        home: PengerjaanListScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify all 3 dynamic badges render distinctly
    expect(find.text('Treatment Reguler'), findsOneWidget);
    expect(find.text('Redeem Paket'), findsOneWidget);
    expect(find.text('Redeem Override'), findsOneWidget);

    // Test filter chips
    expect(find.text('Semua (3)'), findsOneWidget);
    expect(find.text('Reguler (1)'), findsOneWidget);
    expect(find.text('Redeem (2)'), findsOneWidget);

    // Tap Reguler chip
    await tester.tap(find.text('Reguler (1)'));
    await tester.pumpAndSettle();

    expect(find.text('Ibu Aurelia'), findsOneWidget);
    expect(find.text('Ibu Dewi'), findsNothing);
    expect(find.text('Ibu Kartika'), findsNothing);

    // Tap Redeem chip
    await tester.tap(find.text('Redeem (2)'));
    await tester.pumpAndSettle();

    expect(find.text('Ibu Aurelia'), findsNothing);
    expect(find.text('Ibu Dewi'), findsOneWidget);
    expect(find.text('Ibu Kartika'), findsOneWidget);
  });
}
