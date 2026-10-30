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

