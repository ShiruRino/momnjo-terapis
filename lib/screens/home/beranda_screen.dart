import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../state/app_state.dart';
import '../../data/models/job_model.dart';
import '../../widgets/feedback_banner.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/custom_bottom_sheets.dart';
import '../../widgets/empty_state_view.dart';
import 'widgets/attendance_card.dart';
import 'widgets/job_summary_card.dart';
import '../jobs/job_detail_screen.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  String? _bannerMessage;
  FeedbackBannerType _bannerType = FeedbackBannerType.warning;

  @override
  void initState() {
    super.initState();
    AppState.instance.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  void _handleAttendanceToggle() {
    final state = AppState.instance;
    if (!state.isOnDuty) {
      // Show Check In sheet
      CustomBottomSheets.showCheckInSheet(
        context,
        branchName: state.user.namaGerai,
        address: 'Jl. Dharmawangsa IV No. 8, Jakarta Selatan',
        onConfirm: () {
          state.checkIn();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Berhasil Check-In. Selamat bekerja!'),
              backgroundColor: AppColors.feedbackSuccess,
            ),
          );
        },
      );
    } else {
      // Check Out confirmation
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Konfirmasi Check Out', style: AppTypography.h2),
          content: const Text(
            'Apakah Anda yakin ingin mengakhiri shift hari ini (Off Duty)?',
            style: AppTypography.support,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: AppColors.inkMuted)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                state.checkOut();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Berhasil Check-Out. Sampai jumpa besok!'),
                    backgroundColor: AppColors.brand500,
                  ),
                );
              },
              child: const Text('Check Out', style: TextStyle(color: AppColors.feedbackDanger, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final user = state.user;
    final isOnDuty = state.isOnDuty;

    final activeJobs = state.jobs
        .where((j) => j.statusLayanan != StatusLayanan.selesai)
        .toList();
    final completedJobsCount = state.jobs
        .where((j) => j.statusLayanan == StatusLayanan.selesai)
        .length;

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Greeting and Notification
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOnDuty ? 'Selamat Pagi, ${user.nickname}!' : 'Selamat Malam, ${user.nickname}!',
                          style: AppTypography.h1.copyWith(fontSize: 22),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isOnDuty
                              ? 'Tetap semangat merawat lebih banyak ibu hari ini ❤️'
                              : 'Semoga hari ini menyenangkan dan penuh makna. ❤️',
                          style: AppTypography.caption.copyWith(color: AppColors.inkMuted),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: const Icon(Icons.notifications_none_rounded, color: AppColors.inkStrong),
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.brand500,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Error/Info banner if simulated
              if (_bannerMessage != null) ...[
                FeedbackBanner(
                  message: _bannerMessage!,
                  type: _bannerType,
                  onDismiss: () => setState(() => _bannerMessage = null),
                ),
              ],

              // Profile Brief Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.brand100,
                      child: const Icon(Icons.person, color: AppColors.brand500, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.namaLengkap, style: AppTypography.supportBold),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(user.position, style: AppTypography.caption),
                              const SizedBox(width: 6),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: AppColors.inkLight,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  user.namaGerai,
                                  style: AppTypography.caption.copyWith(color: AppColors.brand500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.inkLight),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Attendance Card
              AttendanceCard(
                isOnDuty: isOnDuty,
                checkInTime: state.todayCheckInTime != null
                    ? '${state.todayCheckInTime!.hour.toString().padLeft(2, '0')}.${state.todayCheckInTime!.minute.toString().padLeft(2, '0')} WIB'
                    : null,
                onToggleDuty: _handleAttendanceToggle,
              ),
              const SizedBox(height: 14),

              // Stats Row
              Row(
                children: [
                  JobSummaryCard(
                    count: isOnDuty ? activeJobs.length : 0,
                    label: 'Pekerjaan Aktif',
                    subLabel: 'Hari ini',
                    icon: Icons.assignment_outlined,
                    iconColor: AppColors.brand500,
                    iconBgColor: AppColors.brand100,
                  ),
                  const SizedBox(width: 12),
                  JobSummaryCard(
                    count: isOnDuty ? completedJobsCount : 0,
                    label: 'Pekerjaan Selesai',
                    subLabel: 'Hari ini',
                    icon: Icons.check_circle_outline,
                    iconColor: AppColors.feedbackSuccess,
                    iconBgColor: AppColors.feedbackSuccessBg,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Active Jobs Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isOnDuty ? 'Pekerjaan Aktif' : 'Jadwal Selanjutnya',
                    style: AppTypography.h2.copyWith(fontSize: 16),
                  ),
                  Text(
                    'Lihat Semua >',
                    style: AppTypography.captionBold.copyWith(color: AppColors.brand500),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Jobs List or Empty State
              if (activeJobs.isEmpty) ...[
                const EmptyStateView(
                  title: 'Belum Ada Pekerjaan',
                  description: 'Tidak ada pekerjaan aktif untuk saat ini.',
                  icon: Icons.event_note_outlined,
                ),
              ] else ...[
                ...activeJobs.take(3).map((job) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => JobDetailScreen(jobId: job.idJobStatus),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: job.isHomecare ? AppColors.brand100 : const Color(0xFFE8F4EE),
                                child: Icon(
                                  job.isHomecare ? Icons.home_outlined : Icons.spa_outlined,
                                  color: job.isHomecare ? AppColors.brand500 : const Color(0xFF2C7D59),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            job.item.productName,
                                            style: AppTypography.supportBold,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        StatusChip.fromJobStatus(job.statusLayanan),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(job.customer.fullname, style: AppTypography.caption),
                                        const SizedBox(width: 8),
                                        Text('•', style: AppTypography.caption),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${job.durasiStandar} menit',
                                          style: AppTypography.caption.copyWith(color: AppColors.inkMuted),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right, color: AppColors.inkLight),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 16),

              // Simulator Bar for Testing Edge Cases
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Simulator Kondisi Error & Absensi:',
                      style: AppTypography.captionBold.copyWith(color: AppColors.inkMuted),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        ActionChip(
                          label: const Text('Already On Duty (400)', style: TextStyle(fontSize: 11)),
                          backgroundColor: Colors.white,
                          onPressed: () {
                            setState(() {
                              _bannerMessage = 'Anda sudah On Duty. Harap Check-Out terlebih dahulu.';
                              _bannerType = FeedbackBannerType.warning;
                            });
                          },
                        ),
                        ActionChip(
                          label: const Text('Already Off Duty (400)', style: TextStyle(fontSize: 11)),
                          backgroundColor: Colors.white,
                          onPressed: () {
                            setState(() {
                              _bannerMessage = 'Anda sedang Off Duty. Harap Check-In terlebih dahulu.';
                              _bannerType = FeedbackBannerType.info;
                            });
                          },
                        ),
                        ActionChip(
                          label: const Text('Session Expired (401)', style: TextStyle(fontSize: 11)),
                          backgroundColor: Colors.white,
                          onPressed: () {
                            CustomBottomSheets.showSessionExpiredSheet(
                              context,
                              onLoginAgain: () => Navigator.pop(context),
                            );
                          },
                        ),
                        ActionChip(
                          label: const Text('Clear Banner', style: TextStyle(fontSize: 11)),
                          backgroundColor: Colors.white,
                          onPressed: () {
                            setState(() => _bannerMessage = null);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

