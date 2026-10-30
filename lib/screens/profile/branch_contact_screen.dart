import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../state/app_state.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_button.dart';
import '../../widgets/feedback_banner.dart';
import '../../widgets/custom_bottom_sheets.dart';

class BranchContactScreen extends StatefulWidget {
  const BranchContactScreen({super.key});

  @override
  State<BranchContactScreen> createState() => _BranchContactScreenState();
}

class _BranchContactScreenState extends State<BranchContactScreen> {
  void _openWhatsApp(String branchName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Membuka WhatsApp Admin $branchName (wa.me)...'),
        backgroundColor: AppColors.feedbackSuccess,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final primaryBranch = state.geraiList.isNotEmpty ? state.geraiList.first : null;
    final otherBranches = state.geraiList.length > 1 ? state.geraiList.sublist(1) : [];

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: const AppHeader(
        title: 'Kontak Gerai',
        subtitle: 'Hubungi admin gerai untuk bantuan',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            // Storefront Banner Icon
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDEBEC),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.storefront_rounded, size: 38, color: AppColors.brand500),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              primaryBranch?.namaGerai ?? 'Momnjo Dharmawangsa',
              style: AppTypography.h2.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 2),
            Text(
              primaryBranch?.kota ?? 'Jakarta Selatan',
              style: AppTypography.caption.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(height: 20),

            // Help Card
            Container(
              padding: const EdgeInsets.all(18),
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
                      const Icon(Icons.help_outline, color: AppColors.brand500, size: 20),
                      const SizedBox(width: 8),
                      Text('Butuh Bantuan?', style: AppTypography.supportBold.copyWith(fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Silakan hubungi admin gerai melalui WhatsApp untuk bantuan operasional, akses akun, atau kendala lainnya.',
                    style: AppTypography.support.copyWith(fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 18),
                  AppButton(
                    text: 'Hubungi Admin Gerai',
                    icon: const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.white),
                    onPressed: () => _openWhatsApp(primaryBranch?.namaGerai ?? 'Momnjo Dharmawangsa'),
                  ),
                  const SizedBox(height: 14),
                  const FeedbackBanner(
                    message:
                        'Kontak ini disediakan oleh sistem. Jika tidak dapat dihubungi, silakan hubungi tim pusat.',
                    type: FeedbackBannerType.info,
                    margin: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Gerai Lainnya Section
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const Icon(Icons.storefront_outlined, size: 18, color: AppColors.brand500),
                  const SizedBox(width: 6),
                  Text(
                    'Gerai Lainnya',
                    style: AppTypography.supportBold.copyWith(fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            ...otherBranches.map((branch) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _openWhatsApp(branch.namaGerai),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppColors.brand100,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.storefront, size: 16, color: AppColors.brand500),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(branch.namaGerai, style: AppTypography.supportBold),
                                Text(branch.kota, style: AppTypography.caption),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.inkLight),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            // Simulator 404
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
                  const Text('Simulasi 404 Not Found:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ActionChip(
                    label: const Text('Kontak Belum Tersedia', style: TextStyle(fontSize: 11)),
                    backgroundColor: Colors.white,
                    onPressed: () {
                      CustomBottomSheets.showBranchUnavailableSheet(
                        context,
                        branchName: 'Momnjo Dharmawangsa',
                      );
                    },
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
}

