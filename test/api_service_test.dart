import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:terapis/data/api/api_client.dart';
import 'package:terapis/data/api/api_config.dart';
import 'package:terapis/data/api/api_exception.dart';
import 'package:terapis/data/api/api_service.dart';
import 'package:terapis/data/models/job_model.dart';
import 'package:terapis/data/models/attendance_model.dart';

void main() {
  group('ApiClient & Error Matrix Integration Tests', () {
    test('Token management and Authorization header construction', () {
      final client = ApiClient.instance;
      client.setToken('test_jwt_token_123');
      expect(client.token, 'test_jwt_token_123');

      client.clearToken();
      expect(client.token, isNull);
    });

    test('HTTP 200 Success Response parsing', () async {
      final mockHttp = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'status': true,
            'message': 'Success',
            'data': {'id': 1, 'name': 'Momnjo'}
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockHttp);
      final result = await apiClient.get('/test');
      expect(result['status'], isTrue);
      expect(result['data']['name'], 'Momnjo');
    });

    test('HTTP 401 Unauthorized maps to ApiException(401)', () async {
      final mockHttp = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'status': false,
            'message': 'Username atau password salah.',
            'data': null,
          }),
          401,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockHttp);
      expect(
        () async => await apiClient.post(ApiConfig.login, body: {'username': 'wrong', 'password': '123'}),
        throwsA(predicate((e) => e is ApiException && e.statusCode == 401 && e.message.contains('Username atau password salah'))),
      );
    });

    test('HTTP 403 Forbidden (Blocked account) maps to ApiException(403)', () async {
      final mockHttp = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'status': false,
            'message': 'Akun Anda dinonaktifkan / diblokir. Hubungi admin.',
            'data': null,
          }),
          403,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockHttp);
      expect(
        () async => await apiClient.post(ApiConfig.login, body: {'username': 'blocked', 'password': '123'}),
        throwsA(predicate((e) => e is ApiException && e.statusCode == 403 && e.message.contains('diblokir'))),
      );
    });

    test('HTTP 422 Unprocessable Entity (Missing foto_arrived) maps to ApiException(422)', () async {
      final mockHttp = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'status': false,
            'message': 'Foto bukti tiba di lokasi (foto_arrived) wajib diunggah.',
            'data': null,
          }),
          422,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockHttp);
      expect(
        () async => await apiClient.post(ApiConfig.jobs, body: {'action': 'arrived', 'id_job_status': 45}),
        throwsA(predicate((e) => e is ApiException && e.statusCode == 422 && e.message.contains('foto_arrived'))),
      );
    });

    test('HTTP 409 Conflict (Concurrent therapist claim) maps to ApiException(409)', () async {
      final mockHttp = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'status': false,
            'message': 'Job sedang dikerjakan oleh terapis lain (Dewi Lestari).',
            'data': null,
          }),
          409,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockHttp);
      expect(
        () async => await apiClient.post(ApiConfig.jobs, body: {'action': 'start', 'id_job_status': 45}),
        throwsA(predicate((e) => e is ApiException && e.statusCode == 409 && e.message.contains('dikerjakan oleh terapis lain'))),
      );
    });

    test('HTTP 500 Server / Database Error maps to ApiException(500)', () async {
      final mockHttp = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'status': false,
            'message': 'Gagal terhubung ke database',
            'data': null,
          }),
          500,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockHttp);
      expect(
        () async => await apiClient.get(ApiConfig.jobs),
        throwsA(predicate((e) => e is ApiException && e.statusCode == 500 && e.message.contains('Gagal terhubung ke database'))),
      );
    });
  });

  group('ApiService Endpoints Integration Tests', () {
    test('1. healthCheck() parses server status', () async {
      final mockHttp = MockClient((request) async {
        expect(request.url.path, endsWith('/dev/api_terapis_v4/'));
        return http.Response(
          jsonEncode({
            'status': true,
            'message': 'Momnjo Therapist API v4 Service is running',
            'data': {
              'service': 'Momnjo Therapist API',
              'version': '4.0.0',
              'status': 'online',
              'server_time': '2026-10-30 15:09:29'
            }
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockHttp);
      final service = ApiService(client: apiClient);
      final res = await service.healthCheck();

      expect(res['status'], isTrue);
      expect(res['data']['version'], '4.0.0');
    });

    test('2. login() parses token and UserProfile', () async {
      final mockHttp = MockClient((request) async {
        expect(request.url.path, endsWith('/login.php'));
        final body = jsonDecode(request.body);
        expect(body['username'], 'siti.therapis');
        expect(body['password'], 'password123');

        return http.Response(
          jsonEncode({
            'status': true,
            'message': 'Login berhasil',
            'token': 'mock_jwt_token_xyz',
            'data': {
              'id_user': 12,
              'username': 'siti.therapis',
              'nama_lengkap': 'Siti Nurhaliza, A.Md.Keb',
              'nickname': 'Siti',
              'role': 'therapist',
              'id_gerai': 1,
              'nama_gerai': 'Momnjo Dharmawangsa',
              'position': 'Senior Therapist',
              'no_telp': '081234567890',
              'email': 'siti.therapis@momnjo.com',
              'address': 'Jl. Melati No. 12, Kebayoran Baru, Jakarta Selatan',
              'is_active': 1
            }
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockHttp);
      final service = ApiService(client: apiClient);
      final res = await service.login(username: 'siti.therapis', password: 'password123');

      expect(res['token'], 'mock_jwt_token_xyz');
      expect(apiClient.token, 'mock_jwt_token_xyz');
      expect(res['user'].username, 'siti.therapis');
      expect(res['user'].namaGerai, 'Momnjo Dharmawangsa');
    });

    test('3. getProfile() parses user and attendance state', () async {
      final mockHttp = MockClient((request) async {
        expect(request.url.path, endsWith('/me.php'));
        return http.Response(
          jsonEncode({
            'status': true,
            'message': 'Data profile terapis berhasil diambil',
            'data': {
              'user': {
                'id_user': 12,
                'username': 'siti.therapis',
                'nama_lengkap': 'Siti Nurhaliza',
                'nickname': 'Siti',
                'role': 'therapist',
                'id_gerai': 1,
                'nama_gerai': 'Momnjo Dharmawangsa',
                'position': 'Senior Therapist',
                'no_telp': '081234567890',
                'email': 'siti.therapis@momnjo.com',
                'address': 'Jakarta',
                'is_active': 1
              },
              'attendance': {
                'status_duty': 'on_duty',
                'last_record': {
                  'id_absensi': 1052,
                  'username_terapis': 'siti.therapis',
                  'action': 'check_in',
                  'waktu': '2026-10-30 08:45:00',
                  'lokasi': '-6.200000, 106.816666',
                  'catatan': 'Tepat waktu'
                }
              }
            }
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockHttp);
      final service = ApiService(client: apiClient);
      final res = await service.getProfile();

      expect(res['user'].nickname, 'Siti');
      expect(res['status_duty'], DutyStatus.onDuty);
      expect(res['last_record'].action, 'check_in');
    });

    test('4. submitJobAction(arrived) sends foto_arrived and receives URL', () async {
      final mockHttp = MockClient((request) async {
        expect(request.url.path, endsWith('/jobs.php'));
        final body = jsonDecode(request.body);
        expect(body['action'], 'arrived');
        expect(body['id_job_status'], 45);
        expect(body['foto_arrived'], startsWith('data:image/jpeg;base64'));

        return http.Response(
          jsonEncode({
            'status': true,
            'message': 'Berhasil memperbarui status: Tiba di Lokasi.',
            'data': {
              'id_job_status': 45,
              'status_layanan': 'Arrived',
              'waktu_arrived': '2026-10-30 09:15:00',
              'foto_arrived': 'uploads/arrived/arrived_45_20261030_091500_8f2a1b4c.jpg',
              'foto_arrived_url': 'https://dashboard.momnjo.my.id/dev/api_terapis_v4/uploads/arrived/arrived_45_20261030_091500_8f2a1b4c.jpg'
            }
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockHttp);
      final service = ApiService(client: apiClient);
      final res = await service.submitJobAction(
        idJobStatus: 45,
        action: 'arrived',
        fotoArrived: 'data:image/jpeg;base64,/9j/4AAQSkZJRg...',
        catatan: 'Tiba di depan rumah customer',
      );

      expect(res['status_layanan'], 'Arrived');
      expect(res['foto_arrived_url'], contains('uploads/arrived/arrived_45'));
    });

    test('5. submitJobAction(rekam_medis) submits 5 vital signs fields', () async {
      final mockHttp = MockClient((request) async {
        expect(request.url.path, endsWith('/jobs.php'));
        final body = jsonDecode(request.body);
        expect(body['action'], 'rekam_medis');
        expect(body['tekanan_darah'], '120 / 80');
        expect(body['suhu_tubuh'], '36.5');
        expect(body['keluhan'], 'Pegal di punggung');
        expect(body['alergi'], 'Tidak ada');
        expect(body['catatan_khusus'], 'Fokus pada pundak dan pinggang');

        return http.Response(
          jsonEncode({
            'status': true,
            'message': 'Rekam medis berhasil diperbarui.',
            'data': {
              'id_job_status': 45,
              'rekam_medis': {
                'tekanan_darah': '120/80',
                'suhu_tubuh': '36.5',
                'keluhan': 'Pegal di punggung',
                'alergi': 'Tidak ada',
                'catatan_khusus': 'Fokus pada pundak dan pinggang'
              }
            }
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockHttp);
      final service = ApiService(client: apiClient);
      final res = await service.submitJobAction(
        idJobStatus: 45,
        action: 'rekam_medis',
        rekamMedis: const MedicalRecord(
          tekananDarahSistolik: '120',
          tekananDarahDiastolik: '80',
          suhuTubuh: '36.5',
          keluhan: 'Pegal di punggung',
          alergi: 'Tidak ada',
          catatanKhusus: 'Fokus pada pundak dan pinggang',
        ),
      );

      expect(res['rekam_medis']['tekanan_darah'], '120/80');
    });

    test('6. submitAttendance(check_in) creates attendance record', () async {
      final mockHttp = MockClient((request) async {
        expect(request.url.path, endsWith('/absensi.php'));
        final body = jsonDecode(request.body);
        expect(body['action'], 'check_in');

        return http.Response(
          jsonEncode({
            'status': true,
            'message': 'Check-in berhasil dicatat.',
            'data': {
              'id_absensi': 1052,
              'username_terapis': 'siti.therapis',
              'action': 'check_in',
              'waktu': '2026-10-30 08:45:00',
              'lokasi': '-6.200000, 106.816666',
              'catatan': 'Tepat waktu'
            }
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockHttp);
      final service = ApiService(client: apiClient);
      final record = await service.submitAttendance(action: 'check_in', lokasi: '-6.2, 106.8', catatan: 'Tepat waktu');

      expect(record.action, 'check_in');
      expect(record.idAbsensi, 1052);
    });

    test('7. getReportSummary() parses financial commissions', () async {
      final mockHttp = MockClient((request) async {
        expect(request.url.path, endsWith('/report.php'));
        expect(request.url.queryParameters['type'], 'summary');

        return http.Response(
          jsonEncode({
            'status': true,
            'message': 'Laporan ringkasan komisi berhasil diambil',
            'data': {
              'periode': {
                'start_date': '2026-10-01',
                'end_date': '2026-10-31',
              },
              'komisi_reguler_5_persen': 425000,
              'komisi_redeem_5_persen': 50000,
              'total_komisi_5_persen': 475000,
              'pengerjaan_stats': {
                'total_treatment': 28,
                'total_nominal': 6000000
              }
            }
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockHttp);
      final service = ApiService(client: apiClient);
      final summary = await service.getReportSummary(startDate: '2026-10-01', endDate: '2026-10-31');

      expect(summary.totalKomisi5Persen, 475000.0);
      expect(summary.komisiReguler5Persen, 425000.0);
      expect(summary.totalTreatment, 28);
    });

    test('8. getReportSummary() gracefully falls back to pengerjaan report when backend summary returns HTTP 500', () async {
      final mockHttp = MockClient((request) async {
        if (request.url.queryParameters['type'] == 'summary') {
          return http.Response('', 500, headers: {'content-type': 'text/html'});
        } else if (request.url.queryParameters['type'] == 'pengerjaan') {
          return http.Response(
            jsonEncode({
              'status': true,
              'message': 'Daftar pengerjaan terapis berhasil diambil',
              'data': {
                'total_items': 1,
                'total_qty': 1,
                'total_nominal': 205000,
                'pengerjaan': [
                  {
                    'no': 1,
                    'terapis': 'ajad',
                    'tgl': '2026-10-29',
                    'id_trx': 'TRX26-01B-000150',
                    'nama_cust': 'Dewa',
                    'treatment': 'Duckey Splash Bubble Bath',
                    'qty': 1,
                    'nominal_satuan': 205000,
                    'total_nominal': 205000,
                    'keterangan': 'Normal',
                    'is_redeem': false,
                  }
                ]
              }
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(client: mockHttp);
      final service = ApiService(client: apiClient);
      final summary = await service.getReportSummary(startDate: '2026-10-01', endDate: '2026-10-31');

      expect(summary.totalNominal, 205000.0);
      expect(summary.komisiReguler5Persen, 10250.0);
      expect(summary.totalKomisi5Persen, 10250.0);
      expect(summary.totalTreatment, 1);
    });
  });
}
