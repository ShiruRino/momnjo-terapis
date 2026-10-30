import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/attendance_model.dart';
import '../../state/app_state.dart';
import '../../widgets/app_header.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/feedback_banner.dart';
import '../../widgets/skeleton_view.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  static const _indonesianDays = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  static const _indonesianMonths = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  void initState() {
    super.initState();
    AppState.instance.addListener(_onStateChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AppState.instance.isLoggedIn) {
        AppState.instance.fetchAttendanceHistory();
      }
    });
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  String _formatDayName(DateTime dt) {
    final now = DateTime.now();
    final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final dayName = _indonesianDays[dt.weekday - 1];
    return isToday ? '$dayName (Hari Ini)' : dayName;
  }

  String _formatDayHeader(DateTime dt) {
    return '${dt.day} ${_indonesianMonths[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final records = state.attendanceRecords;

    final sortedRecords = List<AttendanceRecord>.from(records)
      ..sort((a, b) => b.waktu.compareTo(a.waktu));

    final Map<String, List<AttendanceRecord>> grouped = {};
    for (final rec in sortedRecords) {
      final key = '${rec.waktu.year}-${rec.waktu.month.toString().padLeft(2, '0')}-${rec.waktu.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(rec);
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: const AppHeader(
        title: 'Riwayat Absensi',
        subtitle: 'Catatan kehadiran dan aktivitas kerja',
      ),
      body: state.isLoadingHistory
          ? const SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: ListTileSkeletonView(itemCount: 5),
            )
          : records.isEmpty
              ? EmptyStateView(
                  title: 'Belum Ada Riwayat',
                  description: 'Tidak ada catatan absensi pada periode ini.',
                  buttonText: 'Segarkan',
                  onButtonPressed: () => state.fetchAttendanceHistory(),
                  icon: Icons.calendar_today_outlined,
                )
              : RefreshIndicator(
                  color: AppColors.brand500,
                  onRefresh: () => state.fetchAttendanceHistory(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Month Selector Bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.chevron_left, color: AppColors.inkMuted),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.brand500),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_indonesianMonths[DateTime.now().month - 1]} ${DateTime.now().year}',
                                    style: AppTypography.supportBold.copyWith(fontSize: 14),
                                  ),
                                ],
                              ),
                              const Icon(Icons.chevron_right, color: AppColors.inkMuted),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Dynamic grouped records
                        ...grouped.entries.map((entry) {
                          final firstRec = entry.value.first;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDayHeader(
                                _formatDayHeader(firstRec.waktu),
                                _formatDayName(firstRec.waktu),
                              ),
                              ...entry.value.map((r) => _buildTimelineCard(
                                    isCheckIn: r.action == 'check_in',
                                    isAuto: r.isAutoCheckout,
                                    time: '${r.waktu.hour.toString().padLeft(2, '0')}.${r.waktu.minute.toString().padLeft(2, '0')} WIB',
                                    branch: state.user.namaGerai.isNotEmpty
                                        ? state.user.namaGerai
                                        : 'Momnjo',
                                    autoNote: r.isAutoCheckout
                                        ? (r.catatan ?? 'Lupa Offduty (Human Error)\nSistem secara otomatis mengakhiri status kerja Anda.')
                                        : null,
                                  )),
                              const SizedBox(height: 14),
                            ],
                          );
                        }),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildDayHeader(String date, String day) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFDEFF4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date, style: AppTypography.captionBold.copyWith(color: AppColors.brand700)),
          Text(day, style: AppTypography.caption.copyWith(color: AppColors.brand500)),
        ],
      ),
    );
  }

  Widget _buildTimelineCard({
    required bool isCheckIn,
    bool isAuto = false,
    required String time,
    required String branch,
    String? autoNote,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCheckIn
                      ? AppColors.feedbackSuccessBg
                      : (isAuto ? const Color(0xFFFFEEDD) : const Color(0xFFFDEBEC)),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCheckIn ? Icons.login : Icons.logout,
                  size: 16,
                  color: isCheckIn
                      ? AppColors.feedbackSuccess
                      : (isAuto ? const Color(0xFFC25D00) : AppColors.feedbackDanger),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isCheckIn ? 'Check In' : 'Check Out',
                          style: AppTypography.supportBold,
                        ),
                        Text(
                          time,
                          style: AppTypography.supportBold.copyWith(
                            fontFeatures: [const FontFeature.tabularFigures()],
                          ),
                        ),
                        StatusChip.attendanceAction(isCheckIn: isCheckIn, isAuto: isAuto),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: AppColors.inkMuted),
                        const SizedBox(width: 4),
                        Text(branch, style: AppTypography.caption),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (autoNote != null) ...[
            const SizedBox(height: 10),
            FeedbackBanner(
              message: autoNote,
              type: FeedbackBannerType.warning,
              margin: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }
}
