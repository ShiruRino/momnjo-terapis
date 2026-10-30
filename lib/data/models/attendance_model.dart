enum DutyStatus {
  onDuty,
  offDuty,
}

class AttendanceRecord {
  final int idAbsensi;
  final String usernameTerapis;
  final String action; // 'check_in' or 'check_out'
  final DateTime waktu;
  final String lokasi;
  final String? catatan;
  final bool isAutoCheckout;

  const AttendanceRecord({
    required this.idAbsensi,
    required this.usernameTerapis,
    required this.action,
    required this.waktu,
    required this.lokasi,
    this.catatan,
    this.isAutoCheckout = false,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    DateTime parsedWaktu;
    try {
      parsedWaktu = DateTime.parse(json['waktu']?.toString() ?? DateTime.now().toIso8601String());
    } catch (_) {
      parsedWaktu = DateTime.now();
    }

    final catatanStr = json['catatan']?.toString();
    final isAuto = catatanStr != null && catatanStr.contains('Human Error');

    return AttendanceRecord(
      idAbsensi: json['id_absensi'] is int
          ? json['id_absensi']
          : int.tryParse(json['id_absensi']?.toString() ?? '0') ?? 0,
      usernameTerapis: json['username_terapis']?.toString() ?? '',
      action: json['action']?.toString() ?? 'check_in',
      waktu: parsedWaktu,
      lokasi: json['lokasi']?.toString() ?? '',
      catatan: catatanStr,
      isAutoCheckout: isAuto,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_absensi': idAbsensi,
      'username_terapis': usernameTerapis,
      'action': action,
      'waktu': waktu.toIso8601String(),
      'lokasi': lokasi,
      'catatan': catatan,
    };
  }

  bool get isCheckIn => action == 'check_in';
}

class AttendanceSummary {
  final DutyStatus statusDuty;
  final DateTime? todayCheckIn;
  final DateTime? todayCheckOut;
  final int activeJobsCount;
  final int completedJobsCount;

  const AttendanceSummary({
    required this.statusDuty,
    this.todayCheckIn,
    this.todayCheckOut,
    this.activeJobsCount = 0,
    this.completedJobsCount = 0,
  });

  AttendanceSummary copyWith({
    DutyStatus? statusDuty,
    DateTime? todayCheckIn,
    DateTime? todayCheckOut,
    int? activeJobsCount,
    int? completedJobsCount,
  }) {
    return AttendanceSummary(
      statusDuty: statusDuty ?? this.statusDuty,
      todayCheckIn: todayCheckIn ?? this.todayCheckIn,
      todayCheckOut: todayCheckOut ?? this.todayCheckOut,
      activeJobsCount: activeJobsCount ?? this.activeJobsCount,
      completedJobsCount: completedJobsCount ?? this.completedJobsCount,
    );
  }
}

