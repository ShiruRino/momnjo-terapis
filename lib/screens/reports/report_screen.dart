import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../state/app_state.dart';
import '../../widgets/app_header.dart';
import '../../widgets/feedback_banner.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/skeleton_view.dart';
import 'modals/filter_period_sheet.dart';
import 'pengerjaan_list_screen.dart';
import 'komisi_override_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _isLoadingSkeleton = false;
  bool _isEmptyState = false;
  String? _bannerMessage;
  FeedbackBannerType _bannerType = FeedbackBannerType.danger;

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

  void _openFilterSheet() {
    final state = AppState.instance;
    FilterPeriodSheet.show(
      context,
      initialStart: state.reportStartDate,
      initialEnd: state.reportEndDate,
      initialGerai: state.selectedGeraiFilter,
      onApply: (start, end, gerai) {
        state.setReportFilters(startDate: start, endDate: end, gerai: gerai);
      },
      onReset: () {
        state.resetReportFilters();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final summary = state.reportSummary;

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppHeader(
        title: 'Laporan Saya',
        subtitle: 'Ringkasan hasil pekerjaan dan komisi',
        showBack: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.brand100,
              child: const Icon(Icons.person, color: AppColors.brand500, size: 20),
            ),
          ),
        ],
      ),
      body: _isLoadingSkeleton
          ? const SingleChildScrollView(child: ReportSkeletonView())
          : _isEmptyState
              ? EmptyStateView(
                  title: 'Belum Ada Data',
                  description: 'Tidak ada laporan untuk periode yang dipilih.',
                  buttonText: 'Ubah Periode',
                  onButtonPressed: _openFilterSheet,
                  icon: Icons.receipt_long_outlined,
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Filter Bar
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: InkWell(
                              onTap: _openFilterSheet,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.surfaceBorder),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.inkMuted),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        '1 - 31 Oktober 2026',
                                        style: AppTypography.captionBold.copyWith(color: AppColors.inkStrong),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.inkMuted),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: InkWell(
                              onTap: _openFilterSheet,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.surfaceBorder),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.storefront_outlined, size: 14, color: AppColors.inkMuted),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        state.selectedGeraiFilter ?? 'Semua Gerai',
                                        style: AppTypography.captionBold.copyWith(color: AppColors.inkStrong),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.inkMuted),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Optional Alert banner
                      if (_bannerMessage != null) ...[
                        FeedbackBanner(
                          message: _bannerMessage!,
                          type: _bannerType,
                          onDismiss: () => setState(() => _bannerMessage = null),
                        ),
                      ],

                      // Card: Total Komisi 5% (Brand Gradient)
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: AppColors.brandCardGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x338B2349),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'Total Komisi 5%',
                                  style: AppTypography.supportMedium.copyWith(color: Colors.white70),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.info_outline, color: Colors.white60, size: 14),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              Formatters.formatRupiah(summary.totalKomisi5Persen),
                              style: AppTypography.currencyDisplay.copyWith(
                                color: Colors.white,
                                fontSize: 32,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Komisi Reguler',
                                          style: AppTypography.caption.copyWith(color: Colors.white70),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          Formatters.formatRupiah(summary.komisiReguler5Persen),
                                          style: AppTypography.supportBold.copyWith(
                                            color: Colors.white,
                                            fontFeatures: [const FontFeature.tabularFigures()],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(width: 1, height: 28, color: Colors.white24),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Komisi Redeem',
                                          style: AppTypography.caption.copyWith(color: Colors.white70),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          Formatters.formatRupiah(summary.komisiRedeem5Persen),
                                          style: AppTypography.supportBold.copyWith(
                                            color: Colors.white,
                                            fontFeatures: [const FontFeature.tabularFigures()],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Card: Ringkasan Pengerjaan
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
                                MaterialPageRoute(builder: (_) => const PengerjaanListScreen()),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.bar_chart_outlined, color: AppColors.brand500, size: 20),
                                          const SizedBox(width: 8),
                                          Text('Ringkasan Pengerjaan', style: AppTypography.h2.copyWith(fontSize: 15)),
                                        ],
                                      ),
                                      const Icon(Icons.chevron_right, color: AppColors.inkLight),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Total Treatment', style: AppTypography.caption),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${summary.totalTreatment}',
                                              style: AppTypography.h2.copyWith(
                                                fontWeight: FontWeight.w700,
                                                fontFeatures: [const FontFeature.tabularFigures()],
                                              ),
                                            ),
                                            Text('Pengerjaan', style: AppTypography.caption.copyWith(color: AppColors.inkLight, fontSize: 11)),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Total Nominal', style: AppTypography.caption),
                                            const SizedBox(height: 4),
                                            Text(
                                              Formatters.formatRupiah(summary.totalNominal),
                                              style: AppTypography.h2.copyWith(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                fontFeatures: [const FontFeature.tabularFigures()],
                                              ),
                                            ),
                                            Text('Dari seluruh pekerjaan', style: AppTypography.caption.copyWith(color: AppColors.inkLight, fontSize: 11)),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Total Item', style: AppTypography.caption),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${summary.totalItem}',
                                              style: AppTypography.h2.copyWith(
                                                fontWeight: FontWeight.w700,
                                                fontFeatures: [const FontFeature.tabularFigures()],
                                              ),
                                            ),
                                            Text('Treatment', style: AppTypography.caption.copyWith(color: AppColors.inkLight, fontSize: 11)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Card: Ringkasan Omzet
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
                                const Icon(Icons.receipt_outlined, color: AppColors.brand500, size: 20),
                                const SizedBox(width: 8),
                                Text('Ringkasan Omzet', style: AppTypography.h2.copyWith(fontSize: 15)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _row('Treatment sebelum diskon', Formatters.formatRupiah(summary.treatmentSebelumDiskon)),
                            _row('Treatment setelah diskon', Formatters.formatRupiah(summary.treatmentSetelahDiskon)),
                            _row('Paket sebelum diskon', Formatters.formatRupiah(summary.paketSebelumDiskon)),
                            _row('Paket setelah diskon', Formatters.formatRupiah(summary.paketSetelahDiskon)),
                            _row('Pendapatan redeem', Formatters.formatRupiah(summary.pendapatanRedeem)),
                            const Divider(height: 16),
                            _row('Total omzet sebelum diskon', Formatters.formatRupiah(summary.totalSebelumDiskon), isBold: true),
                            _row('Total omzet setelah diskon', Formatters.formatRupiah(summary.totalSetelahDiskon), isBold: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Card: Komisi Override
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
                                MaterialPageRoute(builder: (_) => const KomisiOverrideScreen()),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.people_outline, color: AppColors.brand500, size: 20),
                                          const SizedBox(width: 8),
                                          Text('Komisi Override', style: AppTypography.h2.copyWith(fontSize: 15)),
                                        ],
                                      ),
                                      Text(
                                        'Lihat Rincian >',
                                        style: AppTypography.captionBold.copyWith(color: AppColors.brand500),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: const BoxDecoration(
                                                color: AppColors.feedbackSuccessBg,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.arrow_downward, size: 16, color: AppColors.feedbackSuccess),
                                            ),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('Override Masuk', style: AppTypography.caption),
                                                Text(
                                                  Formatters.formatRupiah(summary.totalOverrideMasuk, showSign: true),
                                                  style: AppTypography.supportBold.copyWith(
                                                    color: AppColors.feedbackSuccess,
                                                    fontFeatures: [const FontFeature.tabularFigures()],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFFDEBEC),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.arrow_upward, size: 16, color: AppColors.feedbackDanger),
                                            ),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('Override Keluar', style: AppTypography.caption),
                                                Text(
                                                  Formatters.formatRupiah(-summary.totalOverrideKeluar, showSign: true),
                                                  style: AppTypography.supportBold.copyWith(
                                                    color: AppColors.feedbackDanger,
                                                    fontFeatures: [const FontFeature.tabularFigures()],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Simulator Toggles for Testing Design References
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
                              'Simulator State Laporan (Board 04 Presentasi):',
                              style: AppTypography.captionBold.copyWith(color: AppColors.inkMuted),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                ActionChip(
                                  label: Text(_isEmptyState ? 'Data Normal' : 'Laporan Kosong', style: const TextStyle(fontSize: 11)),
                                  backgroundColor: Colors.white,
                                  onPressed: () => setState(() => _isEmptyState = !_isEmptyState),
                                ),
                                ActionChip(
                                  label: Text(_isLoadingSkeleton ? 'Stop Skeleton' : 'Loading Skeleton', style: const TextStyle(fontSize: 11)),
                                  backgroundColor: Colors.white,
                                  onPressed: () => setState(() => _isLoadingSkeleton = !_isLoadingSkeleton),
                                ),
                                ActionChip(
                                  label: const Text('Error Banner', style: TextStyle(fontSize: 11)),
                                  backgroundColor: Colors.white,
                                  onPressed: () {
                                    setState(() {
                                      _bannerMessage = 'Gagal memuat data laporan. Silakan periksa koneksi internet Anda.';
                                      _bannerType = FeedbackBannerType.danger;
                                    });
                                  },
                                ),
                                ActionChip(
                                  label: const Text('Warning Banner', style: TextStyle(fontSize: 11)),
                                  backgroundColor: Colors.white,
                                  onPressed: () {
                                    setState(() {
                                      _bannerMessage = 'Tidak ada data untuk periode ini. Coba ubah rentang tanggal atau gerai.';
                                      _bannerType = FeedbackBannerType.warning;
                                    });
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
    );
  }

  Widget _row(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.inkMuted)),
          Text(
            value,
            style: isBold
                ? AppTypography.supportBold.copyWith(
                    color: AppColors.inkStrong,
                    fontSize: 13,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  )
                : AppTypography.supportMedium.copyWith(
                    fontSize: 12,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
          ),
        ],
      ),
    );
  }
}
