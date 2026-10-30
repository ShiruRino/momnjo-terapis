import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../state/app_state.dart';
import '../../widgets/app_header.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/feedback_banner.dart';
import 'modals/redeem_detail_modal.dart';

class PengerjaanListScreen extends StatelessWidget {
  const PengerjaanListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final items = state.pengerjaanList;
    final totalNominal = items.fold<double>(0.0, (sum, i) => sum + i.totalNominal);
    final totalQty = items.fold<int>(0, (sum, i) => sum + i.jumlah);

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: const AppHeader(
        title: 'Rincian Pengerjaan',
        subtitle: 'Oktober 2026',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.receipt_long_outlined,
                    iconColor: AppColors.brand500,
                    label: 'Total Pengerjaan',
                    value: Formatters.formatRupiah(totalNominal),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.format_list_bulleted,
                    iconColor: AppColors.feedbackInfo,
                    label: 'Jumlah Treatment',
                    value: '${items.length}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.inventory_2_outlined,
                    iconColor: const Color(0xFFC9600E),
                    label: 'Total Qty',
                    value: '$totalQty',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Items List
            ...items.map((item) {
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
                    onTap: () => RedeemDetailModal.show(context, item),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.inkMuted),
                                  const SizedBox(width: 6),
                                  Text(
                                    Formatters.formatDate(item.tanggal),
                                    style: AppTypography.captionBold.copyWith(color: AppColors.inkMuted),
                                  ),
                                ],
                              ),
                              StatusChip.treatmentType(type: item.kategoriTipe),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.person_outline, size: 16, color: AppColors.brand500),
                              const SizedBox(width: 6),
                              Text(item.customerName, style: AppTypography.supportBold),
                              const Spacer(),
                              const Icon(Icons.chevron_right, size: 18, color: AppColors.inkLight),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.spa_outlined, size: 14, color: AppColors.brand500),
                              const SizedBox(width: 6),
                              Text(item.productName, style: AppTypography.caption.copyWith(color: AppColors.inkMuted)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(height: 1),
                          const SizedBox(height: 8),
                          _row('No. Transaksi', item.noTransaksi),
                          _row('Jumlah', '${item.jumlah}'),
                          _row('Nominal per item', Formatters.formatRupiah(item.nominalPerItem)),
                          _row('Total Nominal', Formatters.formatRupiah(item.totalNominal), isBold: true),
                          if (item.isRedeem) ...[
                            const SizedBox(height: 8),
                            _row('Nama Paket', item.namaPaket ?? 'Paket Sehat Cantik 4 Sesi'),
                            _row('Dijual oleh', item.dijualOleh ?? 'Dewi Sartika'),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),

            // Callout info
            const FeedbackBanner(
              message: 'Nominal redeem mengikuti perhitungan paket.',
              type: FeedbackBannerType.info,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTypography.caption.copyWith(fontSize: 10, color: AppColors.inkMuted),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.supportBold.copyWith(
              fontSize: 13,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.inkMuted)),
          Text(
            value,
            style: isBold
                ? AppTypography.supportBold.copyWith(
                    color: AppColors.brand500,
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

