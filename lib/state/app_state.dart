import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/models/attendance_model.dart';
import '../data/models/job_model.dart';
import '../data/models/report_model.dart';
import '../data/models/gerai_model.dart';
import '../data/api/api_service.dart';
import '../data/api/api_exception.dart';
import '../data/local/session_manager.dart';

class AppState extends ChangeNotifier {
  static final AppState instance = AppState._internal();
  factory AppState() => instance;

  AppState._internal() {
    _initData();
  }

  final ApiService _apiService = ApiService();
  ApiService get apiService => _apiService;

  bool _useLiveApi = true;
  bool get useLiveApi => _useLiveApi;

  void setUseLiveApi(bool val) {
    _useLiveApi = val;
    notifyListeners();
  }

  String? _lastApiError;
  String? get lastApiError => _lastApiError;

  void clearApiError() {
    _lastApiError = null;
    notifyListeners();
  }

  // Loading States for Skeletons
  bool _isLoadingBeranda = false;
  bool get isLoadingBeranda => _isLoadingBeranda;

  bool _isLoadingJobs = false;
  bool get isLoadingJobs => _isLoadingJobs;

  bool _isLoadingReport = false;
  bool get isLoadingReport => _isLoadingReport;
  String? _reportError;
  String? get reportError => _reportError;

  bool _isLoadingProfile = false;
  bool get isLoadingProfile => _isLoadingProfile;

  bool _isLoadingHistory = false;
  bool get isLoadingHistory => _isLoadingHistory;

  bool _isLoadingGerai = false;
  bool get isLoadingGerai => _isLoadingGerai;

  // Navigation State
  int _selectedNavIndex = 0;
  int get selectedNavIndex => _selectedNavIndex;

  void switchNavigation(int index) {
    if (_selectedNavIndex != index) {
      _selectedNavIndex = index;
      notifyListeners();
    }
  }

  // Auth State
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  UserProfile? _user;
  UserProfile get user => _user ?? UserProfile.empty();

  // Attendance State
  DutyStatus _dutyStatus = DutyStatus.offDuty;
  DutyStatus get dutyStatus => _dutyStatus;
  bool get isOnDuty => _dutyStatus == DutyStatus.onDuty;

  DateTime? _todayCheckInTime;
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
  ReportSummary? _reportSummary;
  ReportSummary get reportSummary => _reportSummary ?? ReportSummary.empty();

  DateTime _reportStartDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime get reportStartDate => _reportStartDate;

  DateTime _reportEndDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
  DateTime get reportEndDate => _reportEndDate;

  String? _selectedGeraiFilter = 'Semua Gerai';
  String? get selectedGeraiFilter => _selectedGeraiFilter;

  List<PengerjaanItem> _pengerjaanList = [];
  List<PengerjaanItem> get pengerjaanList => _pengerjaanList;

  List<OverrideItem> _overrideList = [];
  List<OverrideItem> get overrideList => _overrideList;

  List<GeraiContact> _geraiList = [];
  List<GeraiContact> get geraiList => _geraiList;

  GeraiContact? _primaryGerai;
  GeraiContact? get primaryGerai => _primaryGerai;

  // Timer ticker
  Timer? _ticker;

  void _initData() {
    _attendanceRecords = [];
    _jobs = [];
    _pengerjaanList = [];
    _overrideList = [];
    _geraiList = [];

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

  // Session Restoration
  Future<void> restoreSession() async {
    await SessionManager.init();
    final token = await SessionManager.getToken();
    final savedUser = await SessionManager.getUser();
    final savedDuty = await SessionManager.getDutyStatus();

    if (token != null && token.isNotEmpty && savedUser != null) {
      _apiService.client.setToken(token);
      _user = savedUser;
      if (savedDuty != null) _dutyStatus = savedDuty;
      _isLoggedIn = true;
      notifyListeners();

      // Refresh in background
      try {
        await Future.wait([
          fetchProfileAndAttendance(),
          fetchJobs(),
          fetchGeraiList(),
          setReportFilters(startDate: _reportStartDate, endDate: _reportEndDate),
        ]);
      } catch (e) {
        if (e is ApiException && e.statusCode == 401) {
          await logout();
        }
      }
    }
  }

  // Auth Actions
  Future<void> login({required String username, required String password}) async {
    if (_useLiveApi) {
      try {
        final result = await _apiService.login(username: username, password: password);
        _user = result['user'] as UserProfile;
        _isLoggedIn = true;
        _lastApiError = null;

        // Persist session to local storage
        final token = result['token']?.toString() ?? _apiService.client.token;
        if (token != null && token.isNotEmpty) {
          await SessionManager.saveSession(
            token: token,
            user: _user!,
            dutyStatus: _dutyStatus,
          );
        }

        // Fetch live server data
        try {
          await Future.wait([
            fetchProfileAndAttendance(),
            fetchJobs(),
            fetchGeraiList(),
            setReportFilters(startDate: _reportStartDate, endDate: _reportEndDate),
          ]);
        } catch (_) {}

        notifyListeners();
        return;
      } on ApiException catch (e) {
        _lastApiError = e.message;
        rethrow;
      } catch (e) {
        _lastApiError = e.toString();
        rethrow;
      }
    } else {
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _apiService.client.clearToken();
    _user = null;
    _jobs = [];
    _attendanceRecords = [];
    _pengerjaanList = [];
    _overrideList = [];
    _dutyStatus = DutyStatus.offDuty;
    _todayCheckInTime = null;
    _todayCheckOutTime = null;
    _selectedNavIndex = 0;
    await SessionManager.clearSession();
    notifyListeners();
  }

  // Attendance Actions
  Future<void> checkIn({String? location, String? catatan}) async {
    _dutyStatus = DutyStatus.onDuty;
    _todayCheckInTime = DateTime.now();
    _todayCheckOutTime = null;
    unawaited(SessionManager.saveDutyStatus(_dutyStatus));

    final newRecord = AttendanceRecord(
      idAbsensi: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      usernameTerapis: user.username,
      action: 'check_in',
      waktu: DateTime.now(),
      lokasi: location ?? '-6.200000, 106.816666',
      catatan: catatan,
    );
    _attendanceRecords.insert(0, newRecord);
    notifyListeners();

    if (_useLiveApi) {
      try {
        await _apiService.submitAttendance(
          action: 'check_in',
          lokasi: location ?? '-6.200000, 106.816666',
          catatan: catatan,
        );
      } catch (e) {
        // Handled gracefully in UI via exception or banner
      }
    }
  }

  Future<void> checkOut({String? location, String? catatan}) async {
    _dutyStatus = DutyStatus.offDuty;
    _todayCheckOutTime = DateTime.now();
    unawaited(SessionManager.saveDutyStatus(_dutyStatus));

    final newRecord = AttendanceRecord(
      idAbsensi: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      usernameTerapis: user.username,
      action: 'check_out',
      waktu: DateTime.now(),
      lokasi: location ?? '-6.200000, 106.816666',
      catatan: catatan,
    );
    _attendanceRecords.insert(0, newRecord);
    notifyListeners();

    if (_useLiveApi) {
      try {
        await _apiService.submitAttendance(
          action: 'check_out',
          lokasi: location ?? '-6.200000, 106.816666',
          catatan: catatan,
        );
      } catch (e) {
        // Handled gracefully
      }
    }
  }

  // Refresh Attendance & Profile from API
  Future<void> fetchProfileAndAttendance() async {
    _isLoadingBeranda = true;
    _isLoadingProfile = true;
    notifyListeners();
    try {
      final res = await _apiService.getProfile();
      _user = res['user'] as UserProfile;
      _dutyStatus = res['status_duty'] as DutyStatus;
      if (res['last_record'] != null) {
        final lastRec = res['last_record'] as AttendanceRecord;
        if (lastRec.action == 'check_in') {
          _todayCheckInTime = lastRec.waktu;
        } else if (lastRec.action == 'check_out') {
          _todayCheckOutTime = lastRec.waktu;
        }
      }
    } catch (_) {
    } finally {
      _isLoadingBeranda = false;
      _isLoadingProfile = false;
      notifyListeners();
    }
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

  void setJobs(List<JobModel> jobs) {
    _jobs = List.from(jobs);
    notifyListeners();
  }

  // Fetch Jobs from Live API
  Future<void> fetchJobs() async {
    _isLoadingJobs = true;
    notifyListeners();
    try {
      final statusQuery = _jobFilterTab == 'Semua' ? 'all' : (_jobFilterTab == 'Selesai' ? 'Selesai' : 'active');
      final fetched = await _apiService.getJobs(
        status: statusQuery,
        kategori: _selectedCategoryFilter,
      );
      _jobs = fetched;
    } catch (_) {
    } finally {
      _isLoadingJobs = false;
      notifyListeners();
    }
  }

  // Job Workflow Actions
  Future<void> markArrived(int jobId, {String? fotoArrived, String? notes}) async {
    final index = _jobs.indexWhere((j) => j.idJobStatus == jobId);
    if (index != -1) {
      final job = _jobs[index];
      final timestamp = DateTime.now();
      _jobs[index] = job.copyWith(
        statusLayanan: StatusLayanan.arrived,
        waktuArrived: timestamp,
        catatanKedatangan: notes,
        fotoArrived: fotoArrived,
        fotoArrivedUrl: fotoArrived != null
            ? 'https://dashboard.momnjo.my.id/dev/api_terapis_v4/uploads/arrived/arrived_${jobId}_${timestamp.millisecondsSinceEpoch}.jpg'
            : null,
      );
      notifyListeners();
    }

    if (_useLiveApi) {
      try {
        await _apiService.submitJobAction(
          idJobStatus: jobId,
          action: 'arrived',
          fotoArrived: fotoArrived,
          catatan: notes,
        );
      } catch (e) {
        if (e is ApiException) rethrow;
      }
    }
  }

  Future<void> saveMedicalAssessment(int jobId, MedicalRecord record) async {
    final index = _jobs.indexWhere((j) => j.idJobStatus == jobId);
    if (index != -1) {
      _jobs[index] = _jobs[index].copyWith(
        medicalRecord: record,
      );
      notifyListeners();
    }

    if (_useLiveApi) {
      try {
        await _apiService.submitJobAction(
          idJobStatus: jobId,
          action: 'rekam_medis',
          rekamMedis: record,
        );
      } catch (e) {
        if (e is ApiException) rethrow;
      }
    }
  }

  Future<void> startTreatment(int jobId) async {
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

    if (_useLiveApi) {
      try {
        await _apiService.submitJobAction(
          idJobStatus: jobId,
          action: 'start',
        );
      } catch (e) {
        if (e is ApiException) rethrow;
      }
    }
  }

  Future<void> pauseTreatment(int jobId) async {
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

    if (_useLiveApi) {
      try {
        await _apiService.submitJobAction(
          idJobStatus: jobId,
          action: 'pause',
        );
      } catch (e) {
        if (e is ApiException) rethrow;
      }
    }
  }

  Future<void> resumeTreatment(int jobId) async {
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

    if (_useLiveApi) {
      try {
        await _apiService.submitJobAction(
          idJobStatus: jobId,
          action: 'resume',
        );
      } catch (e) {
        if (e is ApiException) rethrow;
      }
    }
  }

  Future<void> completeTreatment(int jobId, {String? notes}) async {
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

    if (_useLiveApi) {
      try {
        await _apiService.submitJobAction(
          idJobStatus: jobId,
          action: 'complete',
          catatan: notes,
        );
      } catch (e) {
        if (e is ApiException) rethrow;
      }
    }
  }

  // Profile Update
  Future<void> updateProfile({
    String? namaLengkap,
    String? nickname,
    String? email,
    String? noTelp,
    String? address,
    String? passwordLama,
    String? passwordBaru,
  }) async {
    _user = user.copyWith(
      namaLengkap: namaLengkap ?? user.namaLengkap,
      nickname: nickname ?? user.nickname,
      email: email ?? user.email,
      noTelp: noTelp ?? user.noTelp,
      address: address ?? user.address,
    );
    notifyListeners();

    if (_useLiveApi) {
      try {
        final updated = await _apiService.updateProfile(
          namaLengkap: namaLengkap,
          nickname: nickname,
          email: email,
          noTelp: noTelp,
          address: address,
          passwordLama: passwordLama,
          passwordBaru: passwordBaru,
        );
        _user = updated;
        notifyListeners();
      } catch (e) {
        if (e is ApiException) rethrow;
      }
    }
  }

  // Report Filter Actions
  Future<void> setReportFilters({
    required DateTime startDate,
    required DateTime endDate,
    String? gerai,
  }) async {
    _reportStartDate = startDate;
    _reportEndDate = endDate;
    _selectedGeraiFilter = gerai ?? 'Semua Gerai';
    _isLoadingReport = true;
    notifyListeners();

    String? kode;
    if (gerai != null && gerai != 'Semua Gerai') {
      try {
        final match = _geraiList.firstWhere(
          (g) => g.namaGerai.toLowerCase() == gerai.toLowerCase() || g.kodeGerai == gerai,
        );
        kode = match.kodeGerai;
      } catch (_) {
        kode = gerai;
      }
    }

    try {
      final summary = await _apiService.getReportSummary(
        startDate: '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
        endDate: '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}',
        kodeGerai: kode,
      );
      _reportSummary = summary;
      _reportError = null;

      try {
        final pengerjaan = await _apiService.getPengerjaanReport(
          startDate: '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
          endDate: '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}',
          kodeGerai: kode,
        );
        _pengerjaanList = pengerjaan;
      } catch (_) {}
    } catch (e) {
      _reportError = e is ApiException ? e.message : 'Gagal memuat ringkasan laporan';
    } finally {
      _isLoadingReport = false;
      notifyListeners();
    }
  }

  Future<void> fetchPengerjaan() async {
    try {
      String? kode;
      if (_selectedGeraiFilter != null && _selectedGeraiFilter != 'Semua Gerai') {
        try {
          final match = _geraiList.firstWhere(
            (g) => g.namaGerai.toLowerCase() == _selectedGeraiFilter!.toLowerCase() || g.kodeGerai == _selectedGeraiFilter,
          );
          kode = match.kodeGerai;
        } catch (_) {
          kode = _selectedGeraiFilter;
        }
      }

      final list = await _apiService.getPengerjaanReport(
        startDate: '${_reportStartDate.year}-${_reportStartDate.month.toString().padLeft(2, '0')}-${_reportStartDate.day.toString().padLeft(2, '0')}',
        endDate: '${_reportEndDate.year}-${_reportEndDate.month.toString().padLeft(2, '0')}-${_reportEndDate.day.toString().padLeft(2, '0')}',
        kodeGerai: kode,
      );
      _pengerjaanList = list;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchOverride() async {
    try {
      String? kode;
      if (_selectedGeraiFilter != null && _selectedGeraiFilter != 'Semua Gerai') {
        try {
          final match = _geraiList.firstWhere(
            (g) => g.namaGerai.toLowerCase() == _selectedGeraiFilter!.toLowerCase() || g.kodeGerai == _selectedGeraiFilter,
          );
          kode = match.kodeGerai;
        } catch (_) {
          kode = _selectedGeraiFilter;
        }
      }

      final list = await _apiService.getOverrideReport(
        startDate: '${_reportStartDate.year}-${_reportStartDate.month.toString().padLeft(2, '0')}-${_reportStartDate.day.toString().padLeft(2, '0')}',
        endDate: '${_reportEndDate.year}-${_reportEndDate.month.toString().padLeft(2, '0')}-${_reportEndDate.day.toString().padLeft(2, '0')}',
        kodeGerai: kode,
      );
      _overrideList = list;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchAttendanceHistory({String? bulan}) async {
    _isLoadingHistory = true;
    notifyListeners();
    try {
      final list = await _apiService.getAttendanceHistory(bulan: bulan);
      _attendanceRecords = list;
    } catch (_) {
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  Future<void> fetchGeraiList() async {
    _isLoadingGerai = true;
    notifyListeners();
    try {
      final list = await _apiService.getGeraiList();
      _geraiList = list;

      if (_isLoggedIn) {
        try {
          final single = await _apiService.getSingleGerai();
          _primaryGerai = single;
        } catch (_) {
          if (list.isNotEmpty && _user != null) {
            try {
              _primaryGerai = list.firstWhere(
                (g) => g.idGerai == _user!.idGerai ||
                    g.namaGerai.toLowerCase().contains(_user!.namaGerai.toLowerCase()) ||
                    _user!.namaGerai.toLowerCase().contains(g.namaGerai.toLowerCase()),
              );
            } catch (_) {
              _primaryGerai = list.first;
            }
          }
        }
      }
    } catch (_) {
    } finally {
      _isLoadingGerai = false;
      notifyListeners();
    }
  }

  Future<void> resetReportFilters() async {
    final now = DateTime.now();
    await setReportFilters(
      startDate: DateTime(now.year, now.month, 1),
      endDate: DateTime(now.year, now.month + 1, 0),
      gerai: 'Semua Gerai',
    );
  }
}
