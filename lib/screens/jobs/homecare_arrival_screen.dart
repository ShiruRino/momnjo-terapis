import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../state/app_state.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/feedback_banner.dart';

class HomecareArrivalScreen extends StatefulWidget {
  final int jobId;

  const HomecareArrivalScreen({super.key, required this.jobId});

  @override
  State<HomecareArrivalScreen> createState() => _HomecareArrivalScreenState();
}

class _HomecareArrivalScreenState extends State<HomecareArrivalScreen> {
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  void _handleConfirmArrival() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));
    AppState.instance.markArrived(widget.jobId, notes: _notesController.text.trim());
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil memperbarui status: Tiba di Lokasi.'),
          backgroundColor: AppColors.feedbackSuccess,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = AppState.instance.getJobById(widget.jobId);
    if (job == null) {
      return Scaffold(
        appBar: const AppHeader(title: 'Tiba di Lokasi'),
        body: const Center(child: Text('Job tidak ditemukan')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: const AppHeader(
        title: 'Tiba di Lokasi',
        subtitle: 'Konfirmasi kedatangan Anda',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Brief Card
            Container(
              padding: const EdgeInsets.all(14),
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
                    child: const Icon(Icons.home_outlined, color: AppColors.brand500, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatusChip.category(job.kategoriLayanan),
                        const SizedBox(height: 4),
                        Text(job.item.productName, style: AppTypography.supportBold),
                        const SizedBox(height: 2),
                        Text(job.idTransaksi, style: AppTypography.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Alamat Customer Card
            Container(
              padding: const EdgeInsets.all(14),
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
                          const Icon(Icons.location_on_outlined, color: AppColors.brand500, size: 18),
                          const SizedBox(width: 6),
                          Text('Alamat Customer', style: AppTypography.supportBold.copyWith(fontSize: 14)),
                        ],
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.brand500,
                          side: const BorderSide(color: AppColors.brand500),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Membuka Google Maps...')),
                          );
                        },
                        icon: const Icon(Icons.map_outlined, size: 14),
                        label: const Text('Buka Map', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job.customer.alamatDomisili,
                    style: AppTypography.support.copyWith(fontSize: 13),
                  ),
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
            const SizedBox(height: 14),

            // Callout: Foto Tidak Wajib (API v4)
            const FeedbackBanner(
              message: 'Foto tidak wajib. Anda dapat menambahkan catatan jika diperlukan.',
              type: FeedbackBannerType.warning,
            ),
            const SizedBox(height: 8),

            // Catatan Field
            AppTextField(
              label: 'Catatan (Opsional)',
              hintText: 'Tambahkan catatan jika diperlukan...',
              controller: _notesController,
              maxLines: 3,
              maxLength: 200,
            ),
            const SizedBox(height: 28),

            // Primary CTA
            AppButton(
              text: 'Konfirmasi Tiba di Lokasi',
              isLoading: _isLoading,
              onPressed: _handleConfirmArrival,
            ),
          ],
        ),
      ),
    );
  }
}
