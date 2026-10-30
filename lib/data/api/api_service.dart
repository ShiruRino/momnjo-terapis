import '../models/user_model.dart';
import '../models/attendance_model.dart';
import '../models/job_model.dart';
import '../models/report_model.dart';
import '../models/gerai_model.dart';
import 'api_client.dart';
import 'api_config.dart';
import 'api_exception.dart';

class ApiService {
  final ApiClient _client;
  ApiClient get client => _client;

  ApiService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  // 1. Health Check
  Future<Map<String, dynamic>> healthCheck() async {
    return await _client.get(ApiConfig.healthCheck);
  }

  // 2. Login
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await _client.post(
      ApiConfig.login,
      body: {
        'username': username,
        'password': password,
      },
    );

    final token = response['token']?.toString();
    if (token != null) {
      _client.setToken(token);
    }

    final data = response['data'] as Map<String, dynamic>;
    final user = UserProfile.fromJson(data);

    return {
      'user': user,
      'token': token,
      'message': response['message'],
    };
  }

  // 3. Profile / Me
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _client.get(ApiConfig.profile);
    final data = response['data'] as Map<String, dynamic>;

    final userJson = data['user'] as Map<String, dynamic>;
    final user = UserProfile.fromJson(userJson);

    DutyStatus statusDuty = DutyStatus.offDuty;
    AttendanceRecord? lastRecord;

    if (data['attendance'] is Map<String, dynamic>) {
      final attJson = data['attendance'] as Map<String, dynamic>;
      final dutyStr = attJson['status_duty']?.toString().toLowerCase();
      statusDuty = dutyStr == 'on_duty' ? DutyStatus.onDuty : DutyStatus.offDuty;

      if (attJson['last_record'] is Map<String, dynamic>) {
        lastRecord = AttendanceRecord.fromJson(attJson['last_record'] as Map<String, dynamic>);
      }
    }

    return {
      'user': user,
      'status_duty': statusDuty,
      'last_record': lastRecord,
    };
  }

  // 4. Update Profile
  Future<UserProfile> updateProfile({
    String? namaLengkap,
    String? nickname,
    String? email,
    String? noTelp,
    String? address,
    String? passwordLama,
    String? passwordBaru,
  }) async {
    final body = <String, dynamic>{};
    if (namaLengkap != null) body['nama_lengkap'] = namaLengkap;
    if (nickname != null) body['nickname'] = nickname;
    if (email != null) body['email'] = email;
    if (noTelp != null) body['no_telp'] = noTelp;
    if (address != null) body['address'] = address;
    if (passwordLama != null) body['password_lama'] = passwordLama;
    if (passwordBaru != null) body['password_baru'] = passwordBaru;

    final response = await _client.post(ApiConfig.updateProfile, body: body);
    final data = response['data'] as Map<String, dynamic>;
    return UserProfile.fromJson(data);
  }

  // 5. Gerai & Kontak
  Future<List<GeraiContact>> getGeraiList() async {
    final response = await _client.get(ApiConfig.gerai, queryParameters: {'list': '1'});
    final data = response['data'] as Map<String, dynamic>;
    final list = data['gerai'] as List<dynamic>? ?? [];
    return list.map((g) => GeraiContact.fromJson(g as Map<String, dynamic>)).toList();
  }

  Future<GeraiContact> getSingleGerai({int? idGerai}) async {
    final query = idGerai != null ? {'id_gerai': idGerai.toString()} : null;
    final response = await _client.get(ApiConfig.gerai, queryParameters: query);
    final data = response['data'] as Map<String, dynamic>;
    return GeraiContact.fromJson(data);
  }

  // 6. Absensi Status & History
  Future<Map<String, dynamic>> getAttendanceStatus() async {
    final response = await _client.get(ApiConfig.absensi);
    final data = response['data'] as Map<String, dynamic>;
    final dutyStr = data['status_duty']?.toString().toLowerCase();
    final statusDuty = dutyStr == 'on_duty' ? DutyStatus.onDuty : DutyStatus.offDuty;

    AttendanceRecord? lastRecord;
    if (data['last_record'] is Map<String, dynamic>) {
      lastRecord = AttendanceRecord.fromJson(data['last_record'] as Map<String, dynamic>);
    }

    return {
      'status_duty': statusDuty,
      'last_record': lastRecord,
      'today_summary': data['today_summary'],
    };
  }

  Future<List<AttendanceRecord>> getAttendanceHistory({String? bulan, int limit = 30}) async {
    final query = {
      'type': 'history',
      'bulan': ?bulan,
      'limit': limit.toString(),
    };
    final response = await _client.get(ApiConfig.absensi, queryParameters: query);
    final data = response['data'] as Map<String, dynamic>;
    final historyList = data['history'] as List<dynamic>? ?? [];
    return historyList.map((h) => AttendanceRecord.fromJson(h as Map<String, dynamic>)).toList();
  }

  // 7. Submit Absensi (Check In / Check Out)
  Future<AttendanceRecord> submitAttendance({
    required String action, // 'check_in' or 'check_out'
    String? lokasi,
    String? catatan,
  }) async {
    final body = {
      'action': action,
      'lokasi': ?lokasi,
      'catatan': ?catatan,
    };
    final response = await _client.post(ApiConfig.absensi, body: body);
    final data = response['data'] as Map<String, dynamic>;
    return AttendanceRecord.fromJson(data);
  }

  // 8. Jobs List & Detail
  Future<List<JobModel>> getJobs({
    String? status, // 'active', 'all', 'Menunggu', 'Arrived', 'Proses', 'Selesai'
    String? kategori, // 'onsite', 'homecare'
    String? tgl, // 'YYYY-MM-DD'
  }) async {
    final query = <String, dynamic>{
      'status': ?status,
      'kategori': ?kategori,
      'tgl': ?tgl,
    };
    final response = await _client.get(ApiConfig.jobs, queryParameters: query);
    final data = response['data'] as Map<String, dynamic>;
    final jobsList = data['jobs'] as List<dynamic>? ?? [];
    return jobsList.map((j) => JobModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<JobModel> getJobDetail(int idJobStatus) async {
    final response = await _client.get(ApiConfig.jobs, queryParameters: {'id': idJobStatus.toString()});
    final data = response['data'] as Map<String, dynamic>;
    return JobModel.fromJson(data);
  }

  // 9. Job Lifecycle Actions
  Future<Map<String, dynamic>> submitJobAction({
    required int idJobStatus,
    required String action, // 'arrived', 'rekam_medis', 'start', 'pause', 'resume', 'complete'
    String? fotoArrived,
    String? catatan,
    MedicalRecord? rekamMedis,
    bool force = false,
  }) async {
    final body = <String, dynamic>{
      'id_job_status': idJobStatus,
      'action': action,
      'catatan': ?catatan,
      if (force) 'force': true,
    };

    if (action == 'arrived' && fotoArrived != null) {
      body['foto_arrived'] = fotoArrived;
    }

    if (action == 'rekam_medis' && rekamMedis != null) {
      body['tekanan_darah'] = rekamMedis.tekananDarahDisplay;
      body['suhu_tubuh'] = rekamMedis.suhuTubuh;
      body['keluhan'] = rekamMedis.keluhan;
      body['alergi'] = rekamMedis.alergi;
      body['catatan_khusus'] = rekamMedis.catatanKhusus;
    }

    final response = await _client.post(ApiConfig.jobs, body: body);
    return response['data'] as Map<String, dynamic>;
  }

  // 10. Reports
  Future<ReportSummary> getReportSummary({
    String? startDate,
    String? endDate,
    String? kodeGerai,
  }) async {
    final query = <String, dynamic>{
      'type': 'summary',
      if (startDate != null && startDate.isNotEmpty) 'start_date': startDate,
      if (endDate != null && endDate.isNotEmpty) 'end_date': endDate,
      if (kodeGerai != null && kodeGerai.isNotEmpty && kodeGerai != 'Semua Gerai') 'kode_gerai': kodeGerai,
    };
    try {
      final response = await _client.get(ApiConfig.report, queryParameters: query);
      final data = response['data'];
      if (data == null || data is! Map<String, dynamic>) {
        return ReportSummary.empty();
      }
      return ReportSummary.fromJson(data);
    } on ApiException catch (e) {
      if (e.statusCode == 500) {
        // Fallback: If backend summary calculation encounters a server error (HTTP 500),
        // gracefully synthesize summary from pengerjaan endpoint which is online and operational.
        try {
          final pengerjaan = await getPengerjaanReport(
            startDate: startDate,
            endDate: endDate,
            kodeGerai: kodeGerai,
          );

          double regulerTotal = 0.0;
          double redeemTotal = 0.0;
          double nominalTotal = 0.0;
          int qtyTotal = 0;

          for (final item in pengerjaan) {
            nominalTotal += item.totalNominal;
            qtyTotal += item.jumlah;
            if (item.isRedeem) {
              redeemTotal += item.totalNominal * 0.05;
            } else {
              regulerTotal += item.totalNominal * 0.05;
            }
          }

          DateTime start = DateTime.now();
          DateTime end = DateTime.now();
          if (startDate != null) try { start = DateTime.parse(startDate); } catch (_) {}
          if (endDate != null) try { end = DateTime.parse(endDate); } catch (_) {}

          return ReportSummary(
            startPeriode: start,
            endPeriode: end,
            kodeGerai: kodeGerai,
            komisiReguler5Persen: regulerTotal,
            komisiRedeem5Persen: redeemTotal,
            totalKomisi5Persen: regulerTotal + redeemTotal,
            treatmentSebelumDiskon: nominalTotal,
            treatmentSetelahDiskon: nominalTotal,
            totalSebelumDiskon: nominalTotal,
            totalSetelahDiskon: nominalTotal,
            totalTreatment: qtyTotal,
            totalNominal: nominalTotal,
            totalItem: pengerjaan.length,
          );
        } catch (_) {}
      }
      rethrow;
    }
  }

  Future<List<PengerjaanItem>> getPengerjaanReport({
    String? startDate,
    String? endDate,
    String? kodeGerai,
  }) async {
    final query = <String, dynamic>{
      'type': 'pengerjaan',
      if (startDate != null && startDate.isNotEmpty) 'start_date': startDate,
      if (endDate != null && endDate.isNotEmpty) 'end_date': endDate,
      if (kodeGerai != null && kodeGerai.isNotEmpty && kodeGerai != 'Semua Gerai') 'kode_gerai': kodeGerai,
    };
    final response = await _client.get(ApiConfig.report, queryParameters: query);
    final data = response['data'];
    if (data == null) return [];
    List<dynamic> items = [];
    if (data is Map<String, dynamic>) {
      items = data['pengerjaan'] as List<dynamic>? ?? [];
    } else if (data is List) {
      items = data;
    }
    return items.map((i) => PengerjaanItem.fromJson(i as Map<String, dynamic>)).toList();
  }

  Future<List<OverrideItem>> getOverrideReport({
    String? startDate,
    String? endDate,
    String? kodeGerai,
  }) async {
    final query = <String, dynamic>{
      'type': 'override',
      if (startDate != null && startDate.isNotEmpty) 'start_date': startDate,
      if (endDate != null && endDate.isNotEmpty) 'end_date': endDate,
      if (kodeGerai != null && kodeGerai.isNotEmpty && kodeGerai != 'Semua Gerai') 'kode_gerai': kodeGerai,
    };
    final response = await _client.get(ApiConfig.report, queryParameters: query);
    final data = response['data'];
    if (data == null) return [];
    List<dynamic> items = [];
    if (data is Map<String, dynamic>) {
      items = data['override'] as List<dynamic>? ?? [];
    } else if (data is List) {
      items = data;
    }
    return items.map((i) => OverrideItem.fromJson(i as Map<String, dynamic>)).toList();
  }
}
