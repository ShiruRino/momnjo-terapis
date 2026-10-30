import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/job_model.dart';
import '../../state/app_state.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_button.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/feedback_banner.dart';
import '../../widgets/treatment_timer_widget.dart';
import '../../widgets/custom_bottom_sheets.dart';
import '../../widgets/custom_dialogs.dart';
import 'widgets/treatment_stepper.dart';
import 'homecare_arrival_screen.dart';
import 'medical_assessment_screen.dart';

class JobDetailScreen extends StatefulWidget {
  final int jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  String? _bannerMessage;
  FeedbackBannerType _bannerType = FeedbackBannerType.info;

  // Error simulation states
  bool _isNetworkError = false;
  bool _isServerError = false;

  @override
  void initState() {
    super.initState();
    AppState.instance.addListener(_onStateChange);
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  void _handleStart() {
    final state = AppState.instance;
    final job = state.getJobById(widget.jobId);
    if (job == null) return;

    if (job.statusLayanan == StatusLayanan.proses) {
      setState(() {
        _bannerMessage = 'Treatment sudah dalam proses berjalan. Timer telah disesuaikan dengan data terbaru.';
        _bannerType = FeedbackBannerType.danger;
      });
      return;
    }
    state.startTreatment(widget.jobId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Treatment dimulai. Timer aktif.'),
        backgroundColor: AppColors.feedbackSuccess,
      ),
    );
  }

  void _handlePause() {
    final state = AppState.instance;
    final job = state.getJobById(widget.jobId);
    if (job == null) return;

    if (job.statusLayanan != StatusLayanan.proses) {
      setState(() {
        _bannerMessage = 'Hanya treatment yang sedang berjalan (Proses) yang dapat di-pause. Saat ini pekerjaan masih dalam status Menunggu.';
        _bannerType = FeedbackBannerType.warning;
      });
      return;
    }
    state.pauseTreatment(widget.jobId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Timer berhasil di-pause.'),
        backgroundColor: AppColors.feedbackWarning,
      ),
    );
  }

  void _handleResume() {
    final state = AppState.instance;
    final job = state.getJobById(widget.jobId);
    if (job == null) return;

    if (!job.isPaused) {
      setState(() {
        _bannerMessage = 'Timer tidak sedang di-pause. Treatment saat ini masih berjalan.';
        _bannerType = FeedbackBannerType.info;
      });
      return;
    }
    state.resumeTreatment(widget.jobId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Timer berhasil di-resume.'),
        backgroundColor: AppColors.feedbackSuccess,
      ),
    );
  }

  void _handleComplete() {
    final state = AppState.instance;
    final job = state.getJobById(widget.jobId);
    if (job == null) return;

    if (job.statusLayanan == StatusLayanan.selesai) {
      CustomDialogs.showTreatmentAlreadyCompletedDialog(
        context,
        onBack: () => Navigator.pop(context),
      );
      return;
    }

    CustomBottomSheets.showFinishTreatmentSheet(
      context,
      customerName: job.customer.fullname,
      treatmentName: job.item.productName,
      isOnsite: job.isOnsite,
      totalDurationSeconds: job.timer.elapsedSeconds,
      onConfirm: () {
        state.completeTreatment(widget.jobId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Treatment berhasil diselesaikan.'),
            backgroundColor: AppColors.feedbackSuccess,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isNetworkError) {
      return Scaffold(
        appBar: const AppHeader(title: 'Detail Pekerjaan'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 64, color: AppColors.brand500),
                const SizedBox(height: 16),
                const Text('Koneksi Internet Bermasalah', style: AppTypography.h2),
                const SizedBox(height: 8),
                const Text(
                  'Silakan periksa jaringan Anda.\nPastikan perangkat Anda terhubung ke internet dan coba lagi.',
                  textAlign: TextAlign.center,
                  style: AppTypography.support,
                ),
                const SizedBox(height: 24),
                AppButton(
                  text: 'Coba Lagi',
                  icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
                  onPressed: () => setState(() => _isNetworkError = false),
                ),
                const SizedBox(height: 16),
                const FeedbackBanner(
                  message: 'Data yang ditampilkan mungkin tidak terbaru.',
                  type: FeedbackBannerType.info,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_isServerError) {
      return Scaffold(
        appBar: const AppHeader(title: 'Detail Pekerjaan'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.dns_outlined, size: 64, color: AppColors.feedbackDanger),
                const SizedBox(height: 16),
                const Text('Server Sedang Mengalami Gangguan', style: AppTypography.h2),
                const SizedBox(height: 8),
                const Text(
                  'Terjadi kendala pada server.\nSilakan coba lagi beberapa saat atau hubungi admin.',
                  textAlign: TextAlign.center,
                  style: AppTypography.support,
                ),
                const SizedBox(height: 24),
                AppButton(
                  text: 'Coba Lagi',
                  icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
                  onPressed: () => setState(() => _isServerError = false),
                ),
                const SizedBox(height: 10),
                AppButton(
                  text: 'Kembali',
                  variant: AppButtonVariant.secondary,
                  onPressed: () => setState(() => _isServerError = false),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final job = AppState.instance.getJobById(widget.jobId);
    if (job == null) {
      return Scaffold(
        appBar: const AppHeader(title: 'Detail Pekerjaan'),
        body: const Center(child: Text('Pekerjaan tidak ditemukan')),
      );
    }

    final bool isTimerActive = job.statusLayanan == StatusLayanan.proses || job.statusLayanan == StatusLayanan.dijeda;

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppHeader(
        title: 'Detail Pekerjaan',
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: AppColors.inkStrong),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top badges & Job Title Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusChip.category(job.kategoriLayanan),
                      const SizedBox(width: 8),
                      StatusChip.fromJobStatus(job.statusLayanan),
                      if (job.isClosed) ...[
                        const SizedBox(width: 8),
                        StatusChip.closed(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.brand100,
                        child: Icon(
                          job.isHomecare ? Icons.home_outlined : Icons.spa_outlined,
                          color: AppColors.brand500,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(job.item.productName, style: AppTypography.h2.copyWith(fontSize: 16)),
                            const SizedBox(height: 2),
                            Text(job.idTransaksi, style: AppTypography.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Closed transaction notice if applicable
            if (job.isClosed) ...[
              const FeedbackBanner(
                title: 'Status transaksi: Closed',
                message: 'Tidak mempengaruhi operasional treatment. Anda tetap dapat memulai treatment sesuai status job.',
                type: FeedbackBannerType.warning,
              ),
            ],

            // Active Banner message if set
            if (_bannerMessage != null) ...[
              FeedbackBanner(
                message: _bannerMessage!,
                type: _bannerType,
                onDismiss: () => setState(() => _bannerMessage = null),
              ),
            ],

            // Completed notice if Selesai
            if (job.statusLayanan == StatusLayanan.selesai) ...[
              const FeedbackBanner(
                title: 'Treatment sudah selesai.',
                message: 'Pekerjaan ini telah diselesaikan pada 28 Okt 2026, 15.30 WIB.',
                type: FeedbackBannerType.success,
              ),
            ],

            // Stepper indicator (Menunggu -> Tiba di Lokasi -> Proses -> Selesai)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: TreatmentStepper(
                isHomecare: job.isHomecare,
                currentStatus: job.statusLayanan,
              ),
            ),
            const SizedBox(height: 12),

            // Timer Widget if in Proses or Dijeda
            if (isTimerActive) ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: TreatmentTimerWidget(
                  durasiStandarDetik: job.timer.durasiStandarDetik,
                  elapsedSeconds: job.timer.elapsedSeconds,
                  remainingSeconds: job.timer.remainingSeconds,
                  isPaused: job.isPaused,
                  pausedSince: 'Dijeda sejak 11.20 WIB',
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Card: Informasi Pelanggan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 18, color: AppColors.brand500),
                      const SizedBox(width: 8),
                      Text('Informasi Pelanggan', style: AppTypography.supportBold.copyWith(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(job.customer.fullname, style: AppTypography.supportBold),
                          const SizedBox(height: 2),
                          Text(job.customer.phone, style: AppTypography.caption),
                        ],
                      ),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.brand100,
                            child: const Icon(Icons.phone_outlined, size: 16, color: AppColors.brand500),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFFE8F6F0),
                            child: const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.feedbackSuccess),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Card: Lokasi / Alamat
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            job.isHomecare ? Icons.home_outlined : Icons.storefront_outlined,
                            size: 18,
                            color: AppColors.brand500,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            job.isHomecare ? 'Alamat Homecare' : 'Lokasi Onsite',
                            style: AppTypography.supportBold.copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                      if (job.isHomecare) ...[
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.brand500,
                            side: const BorderSide(color: AppColors.brand500),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.map_outlined, size: 12),
                          label: const Text('Buka Map', style: TextStyle(fontSize: 11)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(job.customer.alamatDomisili, style: AppTypography.support.copyWith(fontSize: 13)),
                  if (job.customer.catatanAlamat != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Catatan: ${job.customer.catatanAlamat}',
                      style: AppTypography.caption.copyWith(color: AppColors.inkMuted),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Card: Informasi Treatment
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.spa_outlined, size: 18, color: AppColors.brand500),
                      const SizedBox(width: 8),
                      Text('Informasi Treatment', style: AppTypography.supportBold.copyWith(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Nama Treatment', job.item.productName),
                  const SizedBox(height: 8),
                  _buildDetailRow('Durasi Standar', '${job.durasiStandar} menit'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Kategori', job.isHomecare ? 'Homecare' : 'Onsite'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Jadwal', '30 Okt 2026, 10.00 WIB'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Status', job.statusLayanan.name.toUpperCase()),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Card: Rekam Medis (Opsional)
            Container(
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
                        builder: (_) => MedicalAssessmentScreen(jobId: widget.jobId),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.assignment_outlined, size: 20, color: AppColors.brand500),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rekam Medis (Opsional)',
                                style: AppTypography.supportBold.copyWith(fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                job.medicalRecord != null
                                    ? 'Tekanan Darah: ${job.medicalRecord!.tekananDarahDisplay} mmHg'
                                    : 'Catat kondisi pelanggan sebelum/saat treatment',
                                style: AppTypography.caption.copyWith(color: AppColors.inkMuted),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.inkLight),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons Section
            _buildActionButtons(job),
            const SizedBox(height: 24),

            // Error & Transition Testing Simulator Box
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
                    'Simulator Edge Cases & Error API (Mockup 01-11):',
                    style: AppTypography.captionBold.copyWith(color: AppColors.inkMuted),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      ActionChip(
                        label: const Text('Already Running (400)', style: TextStyle(fontSize: 11)),
                        backgroundColor: Colors.white,
                        onPressed: () {
                          setState(() {
                            _bannerMessage = 'Treatment sudah dalam proses berjalan. Timer telah disesuaikan dengan data terbaru.';
                            _bannerType = FeedbackBannerType.danger;
                          });
                        },
                      ),
                      ActionChip(
                        label: const Text('Pause Not Allowed (400)', style: TextStyle(fontSize: 11)),
                        backgroundColor: Colors.white,
                        onPressed: () {
                          setState(() {
                            _bannerMessage = 'Hanya treatment yang sedang berjalan (Proses) yang dapat di-pause. Saat ini pekerjaan masih dalam status Menunggu.';
                            _bannerType = FeedbackBannerType.warning;
                          });
                        },
                      ),
                      ActionChip(
                        label: const Text('Job Not Found / Reassigned (404)', style: TextStyle(fontSize: 11)),
                        backgroundColor: Colors.white,
                        onPressed: () {
                          CustomDialogs.showJobNotFoundDialog(
                            context,
                            onBackToJobs: () => Navigator.pop(context),
                          );
                        },
                      ),
                      ActionChip(
                        label: const Text('Reassign Conflict (409)', style: TextStyle(fontSize: 11)),
                        backgroundColor: Colors.white,
                        onPressed: () {
                          CustomDialogs.showReassignConflictDialog(
                            context,
                            currentTerapis: 'dewi.sartika',
                            newTerapis: 'siti.nurhaliza',
                          );
                        },
                      ),
                      ActionChip(
                        label: const Text('Simulate Network Error', style: TextStyle(fontSize: 11)),
                        backgroundColor: Colors.white,
                        onPressed: () => setState(() => _isNetworkError = true),
                      ),
                      ActionChip(
                        label: const Text('Simulate 500 Server Error', style: TextStyle(fontSize: 11)),
                        backgroundColor: Colors.white,
                        onPressed: () => setState(() => _isServerError = true),
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
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.caption.copyWith(color: AppColors.inkMuted)),
        Text(value, style: AppTypography.supportMedium.copyWith(fontSize: 13)),
      ],
    );
  }

  Widget _buildActionButtons(JobModel job) {
    switch (job.statusLayanan) {
      case StatusLayanan.menunggu:
        if (job.isHomecare) {
          return AppButton(
            text: 'Konfirmasi Tiba di Lokasi',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HomecareArrivalScreen(jobId: widget.jobId),
                ),
              );
            },
          );
        } else {
          return AppButton(
            text: 'Mulai Treatment',
            onPressed: _handleStart,
          );
        }

      case StatusLayanan.arrived:
        return AppButton(
          text: 'Mulai Treatment',
          onPressed: _handleStart,
        );

      case StatusLayanan.proses:
        return Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'Jeda',
                variant: AppButtonVariant.secondary,
                icon: const Icon(Icons.pause, size: 18, color: AppColors.brand500),
                onPressed: _handlePause,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                text: 'Selesaikan Treatment',
                icon: const Icon(Icons.check, size: 18, color: Colors.white),
                onPressed: _handleComplete,
              ),
            ),
          ],
        );

      case StatusLayanan.dijeda:
        return Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'Lanjutkan',
                icon: const Icon(Icons.play_arrow, size: 18, color: Colors.white),
                onPressed: _handleResume,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                text: 'Selesaikan Treatment',
                variant: AppButtonVariant.secondary,
                onPressed: _handleComplete,
              ),
            ),
          ],
        );

      case StatusLayanan.selesai:
        return AppButton(
          text: 'Kembali ke Daftar Job',
          onPressed: () => Navigator.pop(context),
        );
    }
  }
}

