import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/app_header.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/feedback_banner.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  bool _isEmpty = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: const AppHeader(
        title: 'Riwayat Absensi',
        subtitle: 'Catatan kehadiran dan aktivitas kerja',
      ),
      body: _isEmpty
          ? EmptyStateView(
              title: 'Belum Ada Riwayat',
              description: 'Tidak ada catatan absensi pada periode ini.',
              buttonText: 'Tampilkan Riwayat',
              onButtonPressed: () => setState(() => _isEmpty = false),
              icon: Icons.calendar_today_outlined,
            )
          : SingleChildScrollView(
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
                            Text('Oktober 2026', style: AppTypography.supportBold.copyWith(fontSize: 14)),
                          ],
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.inkMuted),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 1. Kamis, 29 Oktober 2026
                  _buildDayHeader('29 Oktober 2026', 'Kamis'),
                  _buildTimelineCard(
                    isCheckIn: true,
                    time: '08.45 WIB',
                    branch: 'Momnjo Dharmawangsa',
                  ),
                  const SizedBox(height: 14),

                  // 2. Rabu, 28 Oktober 2026 (Includes Auto Checkout!)
                  _buildDayHeader('28 Oktober 2026', 'Rabu'),
                  _buildTimelineCard(
                    isCheckIn: true,
                    time: '08.50 WIB',
                    branch: 'Momnjo Dharmawangsa',
                  ),
                  _buildTimelineCard(
                    isCheckIn: false,
                    isAuto: true,
                    time: '23.59 WIB',
                    branch: 'Momnjo Dharmawangsa',
                    autoNote:
                        'Lupa Offduty (Human Error)\nSistem secara otomatis mengakhiri status kerja Anda pada pukul 23.59 WIB karena belum melakukan check out.',
                  ),
                  const SizedBox(height: 14),

                  // 3. Selasa, 27 Oktober 2026
                  _buildDayHeader('27 Oktober 2026', 'Selasa'),
                  _buildTimelineCard(
                    isCheckIn: true,
                    time: '09.00 WIB',
                    branch: 'Momnjo Dharmawangsa',
                  ),
                  _buildTimelineCard(
                    isCheckIn: false,
                    time: '17.30 WIB',
                    branch: 'Momnjo Dharmawangsa',
                  ),
                  const SizedBox(height: 24),

                  // Simulator
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Toggle Riwayat Kosong:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ActionChip(
                          label: Text(_isEmpty ? 'Lihat Riwayat' : 'Simulasi Kosong', style: const TextStyle(fontSize: 11)),
                          backgroundColor: Colors.white,
                          onPressed: () => setState(() => _isEmpty = !_isEmpty),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
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
