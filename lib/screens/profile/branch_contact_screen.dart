import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/gerai_model.dart';
import '../../state/app_state.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_button.dart';
import '../../widgets/feedback_banner.dart';
import '../../widgets/custom_bottom_sheets.dart';
import '../../widgets/skeleton_view.dart';

class BranchContactScreen extends StatefulWidget {
  const BranchContactScreen({super.key});

  @override
  State<BranchContactScreen> createState() => _BranchContactScreenState();
}

class _BranchContactScreenState extends State<BranchContactScreen> {
  @override
  void initState() {
    super.initState();
    AppState.instance.addListener(_onStateChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AppState.instance.isLoggedIn) {
        AppState.instance.fetchGeraiList();
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

  void _openWhatsApp(String branchName, {String? phone, String? waLink}) {
    if ((phone == null || phone.isEmpty) && (waLink == null || waLink.isEmpty)) {
      CustomBottomSheets.showBranchUnavailableSheet(
        context,
        branchName: branchName,
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Membuka WhatsApp Admin $branchName (${phone ?? waLink})...'),
        backgroundColor: AppColors.feedbackSuccess,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    // Determine therapist's primary branch
    GeraiContact? primaryBranch = state.primaryGerai;
    if (primaryBranch == null && state.geraiList.isNotEmpty) {
      try {
        primaryBranch = state.geraiList.firstWhere(
          (g) =>
              g.idGerai == state.user.idGerai ||
              (state.user.kodeGerai.isNotEmpty && g.kodeGerai == state.user.kodeGerai) ||
              (state.user.namaGerai.isNotEmpty &&
                  (g.namaGerai.toLowerCase().contains(state.user.namaGerai.toLowerCase()) ||
                      state.user.namaGerai.toLowerCase().contains(g.namaGerai.toLowerCase()))),
        );
      } catch (_) {
        primaryBranch = state.geraiList.first;
      }
    }

    final otherBranches = primaryBranch != null
        ? state.geraiList.where((g) => g.idGerai != primaryBranch!.idGerai).toList()
        : state.geraiList;

    final displayName = primaryBranch?.namaGerai ??
        (state.user.namaGerai.isNotEmpty ? state.user.namaGerai : 'Mom N Jo Darmawangsa');
    final displayKota = (primaryBranch?.kota.isNotEmpty ?? false)
        ? primaryBranch!.kota
        : 'Jakarta Selatan';

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: const AppHeader(
        title: 'Kontak Gerai',
        subtitle: 'Hubungi admin gerai untuk bantuan',
      ),
      body: state.isLoadingGerai
          ? const SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: ListTileSkeletonView(itemCount: 4),
            )
          : RefreshIndicator(
              color: AppColors.brand500,
              onRefresh: () => state.fetchGeraiList(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                      displayName,
                      style: AppTypography.h2.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayKota,
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
                            onPressed: () => _openWhatsApp(
                              displayName,
                              phone: primaryBranch != null
                                  ? (primaryBranch.waNumber.isNotEmpty ? primaryBranch.waNumber : primaryBranch.kontakWa)
                                  : null,
                              waLink: primaryBranch?.waLink,
                            ),
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
                    if (otherBranches.isNotEmpty) ...[
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
                              onTap: () => _openWhatsApp(
                                branch.namaGerai,
                                phone: branch.waNumber.isNotEmpty ? branch.waNumber : branch.kontakWa,
                              ),
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
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}

