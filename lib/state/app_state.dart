import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/models/attendance_model.dart';
import '../data/models/job_model.dart';
import '../data/models/report_model.dart';
import '../data/models/gerai_model.dart';
import '../data/mock/mock_data.dart';

class AppState extends ChangeNotifier {
  // Singleton pattern for simple global access
  static final AppState instance = AppState._internal();
  factory AppState() => instance;

  AppState._internal() {
    _initData();
  }

  // Auth State
  bool _isLoggedIn = true;
  bool get isLoggedIn => _isLoggedIn;

  UserProfile _user = MockData.defaultProfile;
  UserProfile get user => _user;

  // Attendance State
  DutyStatus _dutyStatus = DutyStatus.onDuty;
  DutyStatus get dutyStatus => _dutyStatus;
  bool get isOnDuty => _dutyStatus == DutyStatus.onDuty;

  DateTime? _todayCheckInTime = DateTime(2026, 10, 30, 8, 45);
  DateTime? get todayCheckInTime => _todayCheckInTime;

  DateTime? _todayCheckOutTime;
  DateTime? get todayCheckOutTime => _todayCheckOutTime;

  List<AttendanceRecord> _attendanceRecords = [];
  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;

  // Jobs State
  List<JobModel> _jobs = [];
  List<JobModel> get jobs => _jobs;

  String _jobFilterTab = 'Aktif'; // 'Aktif', 'Selesai', 'Semua'
  String get jobFilterTab => _jobFilterTab;

  String? _selectedCategoryFilter; // null, 'onsite', 'homecare'
  String? get selectedCategoryFilter => _selectedCategoryFilter;

  // Reports State
  final ReportSummary _reportSummary = MockData.defaultReportSummary;
  ReportSummary get reportSummary => _reportSummary;

  DateTime _reportStartDate = DateTime(2026, 10, 1);
  DateTime get reportStartDate => _reportStartDate;

  DateTime _reportEndDate = DateTime(2026, 10, 31);
  DateTime get reportEndDate => _reportEndDate;

  String? _selectedGeraiFilter = 'Semua Gerai';
  String? get selectedGeraiFilter => _selectedGeraiFilter;

  List<PengerjaanItem> _pengerjaanList = [];
  List<PengerjaanItem> get pengerjaanList => _pengerjaanList;

  List<OverrideItem> _overrideList = [];
  List<OverrideItem> get overrideList => _overrideList;

  List<GeraiContact> _geraiList = [];
  List<GeraiContact> get geraiList => _geraiList;

  // Timer ticker
  Timer? _ticker;

  void _initData() {
    _attendanceRecords = List.from(MockData.attendanceHistory);
    _jobs = MockData.generateMockJobs();
    _pengerjaanList = List.from(MockData.pengerjaanList);
    _overrideList = List.from(MockData.overrideList);
    _geraiList = List.from(MockData.geraiList);

    _startActiveTimers();
  }

  void _startActiveTimers() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      bool hasChanges = false;
      for (int i = 0; i < _jobs.length; i++) {
        final job = _jobs[i];
        if (job.statusLayanan == StatusLayanan.proses && !job.isPaused) {
          final newElapsed = job.timer.elapsedSeconds + 1;
          final newRemaining = (job.timer.durasiStandarDetik - newElapsed).clamp(0, job.timer.durasiStandarDetik);

          _jobs[i] = job.copyWith(
            timer: job.timer.copyWith(
              elapsedSeconds: newElapsed,
              remainingSeconds: newRemaining,
            ),
          );
          hasChanges = true;
        }
      }
      if (hasChanges) {
        notifyListeners();
      }
    });
  }

  void stopActiveTimers() {
    _ticker?.cancel();
    _ticker = null;
  }

  void resumeActiveTimers() {
    _startActiveTimers();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  // Auth Actions
  void login({required String username, required String password}) {
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  // Attendance Actions
  void checkIn({String? location, String? catatan}) {
    _dutyStatus = DutyStatus.onDuty;
    _todayCheckInTime = DateTime.now();
    _todayCheckOutTime = null;

    _attendanceRecords.insert(
      0,
      AttendanceRecord(
        idAbsensi: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        usernameTerapis: _user.username,
        action: 'check_in',
        waktu: DateTime.now(),
        lokasi: location ?? '-6.200000, 106.816666',
        catatan: catatan,
      ),
    );
    notifyListeners();
  }

  void checkOut({String? location, String? catatan}) {
    _dutyStatus = DutyStatus.offDuty;
    _todayCheckOutTime = DateTime.now();

    _attendanceRecords.insert(
      0,
      AttendanceRecord(
        idAbsensi: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        usernameTerapis: _user.username,
        action: 'check_out',
        waktu: DateTime.now(),
        lokasi: location ?? '-6.200000, 106.816666',
        catatan: catatan,
      ),
    );
    notifyListeners();
  }

  // Job Filter Actions
  void setJobFilterTab(String tab) {
    _jobFilterTab = tab;
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    _selectedCategoryFilter = category;
    notifyListeners();
  }

  List<JobModel> get filteredJobs {
    return _jobs.where((j) {
      if (_jobFilterTab == 'Aktif') {
        if (j.statusLayanan == StatusLayanan.selesai) return false;
      } else if (_jobFilterTab == 'Selesai') {
        if (j.statusLayanan != StatusLayanan.selesai) return false;
      }
      if (_selectedCategoryFilter != null) {
        if (_selectedCategoryFilter == 'onsite' && !j.isOnsite) return false;
        if (_selectedCategoryFilter == 'homecare' && !j.isHomecare) return false;
      }
      return true;
    }).toList();
  }

  JobModel? getJobById(int id) {
    try {
      return _jobs.firstWhere((j) => j.idJobStatus == id);
    } catch (_) {
      return null;
    }
  }

  // Job Workflow Actions
  void markArrived(int jobId, {String? notes}) {
    final index = _jobs.indexWhere((j) => j.idJobStatus == jobId);
    if (index != -1) {
      final job = _jobs[index];
      _jobs[index] = job.copyWith(
        statusLayanan: StatusLayanan.arrived,
        waktuArrived: DateTime.now(),
        catatanKedatangan: notes,
      );
      notifyListeners();
    }
  }

  void saveMedicalAssessment(int jobId, MedicalRecord record) {
    final index = _jobs.indexWhere((j) => j.idJobStatus == jobId);
    if (index != -1) {
      _jobs[index] = _jobs[index].copyWith(
        medicalRecord: record,
      );
      notifyListeners();
    }
  }

  void startTreatment(int jobId) {
    final index = _jobs.indexWhere((j) => j.idJobStatus == jobId);
    if (index != -1) {
      final job = _jobs[index];
      _jobs[index] = job.copyWith(
        statusLayanan: StatusLayanan.proses,
        waktuMulai: DateTime.now(),
        isPaused: false,
        timer: job.timer.copyWith(isPaused: false),
      );
      notifyListeners();
    }
  }

  void pauseTreatment(int jobId) {
    final index = _jobs.indexWhere((j) => j.idJobStatus == jobId);
    if (index != -1) {
      final job = _jobs[index];
      _jobs[index] = job.copyWith(
        statusLayanan: StatusLayanan.dijeda,
        isPaused: true,
        pausedAt: DateTime.now(),
        timer: job.timer.copyWith(isPaused: true),
      );
      notifyListeners();
    }
  }

  void resumeTreatment(int jobId) {
    final index = _jobs.indexWhere((j) => j.idJobStatus == jobId);
    if (index != -1) {
      final job = _jobs[index];
      _jobs[index] = job.copyWith(
        statusLayanan: StatusLayanan.proses,
        isPaused: false,
        timer: job.timer.copyWith(isPaused: false),
      );
      notifyListeners();
    }
  }

  void completeTreatment(int jobId, {String? notes}) {
    final index = _jobs.indexWhere((j) => j.idJobStatus == jobId);
    if (index != -1) {
      final job = _jobs[index];
      _jobs[index] = job.copyWith(
        statusLayanan: StatusLayanan.selesai,
        waktuSelesai: DateTime.now(),
        catatanPenyelesaian: notes,
        isPaused: false,
        timer: job.timer.copyWith(
          isPaused: false,
          remainingSeconds: 0,
        ),
      );
      notifyListeners();
    }
  }

  // Profile Update
  void updateProfile({
    required String namaLengkap,
    required String nickname,
    required String email,
    required String noTelp,
    required String address,
  }) {
    _user = _user.copyWith(
      namaLengkap: namaLengkap,
      nickname: nickname,
      email: email,
      noTelp: noTelp,
      address: address,
    );
    notifyListeners();
  }

  // Report Filter Actions
  void setReportFilters({
    required DateTime startDate,
    required DateTime endDate,
    String? gerai,
  }) {
    _reportStartDate = startDate;
    _reportEndDate = endDate;
    _selectedGeraiFilter = gerai ?? 'Semua Gerai';
    notifyListeners();
  }

  void resetReportFilters() {
    _reportStartDate = DateTime(2026, 10, 1);
    _reportEndDate = DateTime(2026, 10, 31);
    _selectedGeraiFilter = 'Semua Gerai';
    notifyListeners();
  }
}
