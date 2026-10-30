import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/job_model.dart';
import '../../data/api/api_exception.dart';
import '../../state/app_state.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_button.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/feedback_banner.dart';
import '../../widgets/treatment_timer_widget.dart';
import '../../widgets/custom_bottom_sheets.dart';
import '../../widgets/custom_dialogs.dart';
import '../../widgets/skeleton_view.dart';
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

  void _handleStart() async {
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

    try {
      await state.startTreatment(widget.jobId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Treatment dimulai. Timer aktif.'),
            backgroundColor: AppColors.feedbackSuccess,
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _bannerMessage = e.message;
          _bannerType = FeedbackBannerType.danger;
        });
      }
    }
  }

  void _handlePause() async {
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

    try {
      await state.pauseTreatment(widget.jobId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Timer berhasil di-pause.'),
            backgroundColor: AppColors.feedbackWarning,
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _bannerMessage = e.message;
          _bannerType = FeedbackBannerType.danger;
        });
      }
    }
  }

  void _handleResume() async {
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

    try {
      await state.resumeTreatment(widget.jobId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Timer berhasil di-resume.'),
            backgroundColor: AppColors.feedbackSuccess,
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _bannerMessage = e.message;
          _bannerType = FeedbackBannerType.danger;
        });
      }
    }
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
      customerName: job.customer.fullname.isNotEmpty ? job.customer.fullname : (job.isOnsite ? 'Pelanggan Onsite' : 'Pelanggan Homecare'),
      treatmentName: job.item.productName.isNotEmpty ? job.item.productName : '-',
      isOnsite: job.isOnsite,
      totalDurationSeconds: job.timer.elapsedSeconds,
      durasiMenit: job.durasiStandar > 0 ? job.durasiStandar : null,
      onConfirm: () async {
        try {
          await state.completeTreatment(widget.jobId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Treatment berhasil diselesaikan.'),
                backgroundColor: AppColors.feedbackSuccess,
              ),
            );
          }
        } on ApiException catch (e) {
          if (mounted) {
            setState(() {
              _bannerMessage = e.message;
              _bannerType = FeedbackBannerType.danger;
            });
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = AppState.instance.getJobById(widget.jobId);
    if (job == null) {
      return const Scaffold(
        backgroundColor: AppColors.surfaceCanvas,
        appBar: AppHeader(title: 'Detail Pekerjaan'),
        body: SafeArea(
          child: SingleChildScrollView(
            child: JobDetailSkeletonView(),
          ),
        ),
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
              FeedbackBanner(
                title: 'Treatment sudah selesai.',
                message: job.waktuSelesai != null
                    ? 'Pekerjaan ini telah diselesaikan pada ${Formatters.formatDate(job.waktuSelesai!)}, ${job.waktuSelesai!.hour.toString().padLeft(2, '0')}.${job.waktuSelesai!.minute.toString().padLeft(2, '0')} WIB.'
                    : 'Pekerjaan ini telah diselesaikan.',
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
                  pausedSince: job.pausedAt != null
                      ? 'Dijeda sejak ${job.pausedAt!.hour.toString().padLeft(2, '0')}.${job.pausedAt!.minute.toString().padLeft(2, '0')} WIB'
                      : null,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 18, color: AppColors.brand500),
                          const SizedBox(width: 8),
                          Text('Informasi Pelanggan', style: AppTypography.supportBold.copyWith(fontSize: 14)),
                        ],
                      ),
                      if (job.isOnsite && job.customer.ruangan != null && job.customer.ruangan!.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.brand100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            job.customer.ruangan!,
                            style: AppTypography.captionBold.copyWith(
                              color: AppColors.brand500,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.customer.fullname.isNotEmpty
                                  ? job.customer.fullname
                                  : (job.isOnsite ? 'Pelanggan Onsite' : 'Pelanggan Homecare'),
                              style: AppTypography.supportBold,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              job.customer.phone.isNotEmpty
                                  ? job.customer.phone
                                  : (job.isOnsite
                                      ? (job.customer.ruangan != null && job.customer.ruangan!.isNotEmpty
                                          ? 'Ruangan: ${job.customer.ruangan}'
                                          : 'Layanan Onsite Gerai')
                                      : '-'),
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                      ),
                      if (job.customer.phone.isNotEmpty) ...[
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
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Card: Lokasi / Alamat (Hanya untuk Homecare, Onsite tidak memerlukan widget ini)
            if (job.isHomecare) ...[
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
                            const Icon(
                              Icons.home_outlined,
                              size: 18,
                              color: AppColors.brand500,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Alamat Homecare',
                              style: AppTypography.supportBold.copyWith(fontSize: 14),
                            ),
                          ],
                        ),
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
                    ),
                    const SizedBox(height: 8),
                    Text(
                      job.customer.alamatDomisili.isNotEmpty ? job.customer.alamatDomisili : '-',
                      style: AppTypography.support.copyWith(fontSize: 13),
                    ),
                    if (job.customer.catatanAlamat != null && job.customer.catatanAlamat!.isNotEmpty) ...[
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
            ],

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
                  _buildDetailRow('Nama Treatment', job.item.productName.isNotEmpty ? job.item.productName : '-', isLong: true),
                  const SizedBox(height: 10),
                  _buildDetailRow('Durasi Standar', job.durasiStandar > 0 ? '${job.durasiStandar} menit' : '-'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Kategori', job.isHomecare ? 'Homecare' : 'Onsite'),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Jadwal',
                    job.waktuJadwal != null
                        ? '${Formatters.formatDate(job.waktuJadwal!)}, ${job.waktuJadwal!.hour.toString().padLeft(2, '0')}.${job.waktuJadwal!.minute.toString().padLeft(2, '0')} WIB'
                        : '-',
                  ),
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
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLong = false}) {
    if (isLong) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.inkMuted)),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.supportBold.copyWith(fontSize: 14, color: AppColors.inkStrong),
          ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption.copyWith(color: AppColors.inkMuted)),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTypography.supportMedium.copyWith(fontSize: 13),
          ),
        ),
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

