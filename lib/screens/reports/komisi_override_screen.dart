import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../state/app_state.dart';
import '../../widgets/app_header.dart';
import '../../widgets/status_chip.dart';
import 'modals/override_detail_modal.dart';

class KomisiOverrideScreen extends StatefulWidget {
  const KomisiOverrideScreen({super.key});

  @override
  State<KomisiOverrideScreen> createState() => _KomisiOverrideScreenState();
}

class _KomisiOverrideScreenState extends State<KomisiOverrideScreen> {
  String _selectedTab = 'Semua'; // 'Semua', 'Masuk', 'Keluar'

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final allItems = state.overrideList;

    final filtered = allItems.where((i) {
      if (_selectedTab == 'Masuk') return i.isMasuk;
      if (_selectedTab == 'Keluar') return !i.isMasuk;
      return true;
    }).toList();

    double totalMasuk = 0;
    double totalKeluar = 0;
    for (var i in allItems) {
      if (i.isMasuk) {
        totalMasuk += i.komisiOverride;
      } else {
        totalKeluar += i.komisiOverride.abs();
      }
    }
    double totalBersih = totalMasuk - totalKeluar;

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: const AppHeader(
        title: 'Komisi Override',
        subtitle: 'Rincian sharing komisi paket',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.brand500),
                  SizedBox(width: 8),
                  Text('Oktober 2026', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  SizedBox(width: 6),
                  Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.inkMuted),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Top Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildSummaryBox(
                    icon: Icons.arrow_downward,
                    iconColor: AppColors.feedbackSuccess,
                    iconBg: AppColors.feedbackSuccessBg,
                    label: 'Override Masuk',
                    amount: Formatters.formatRupiah(totalMasuk, showSign: true),
                    textColor: AppColors.feedbackSuccess,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryBox(
                    icon: Icons.arrow_upward,
                    iconColor: AppColors.feedbackDanger,
                    iconBg: AppColors.feedbackDangerBg,
                    label: 'Override Keluar',
                    amount: Formatters.formatRupiah(-totalKeluar, showSign: true),
                    textColor: AppColors.feedbackDanger,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryBox(
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: const Color(0xFFAD3B64),
                    iconBg: const Color(0xFFF7DFE8),
                    label: 'Total Bersih',
                    amount: Formatters.formatRupiah(totalBersih),
                    textColor: AppColors.inkStrong,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Segmented Pills
            Container(
              height: 38,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: ['Semua', 'Masuk', 'Keluar'].map((tab) {
                  final isSelected = _selectedTab == tab;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = tab),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.brand500 : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          tab,
                          style: AppTypography.captionBold.copyWith(
                            color: isSelected ? Colors.white : AppColors.inkMuted,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Items List
            ...filtered.map((item) {
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
                    onTap: () => OverrideDetailModal.show(context, item),
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
                              StatusChip.override(isMasuk: item.isMasuk),
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
                          _row('Paket', item.namaPaket),
                          _row('No. Transaksi', item.noTransaksi),
                          _row('Dijual oleh', item.dijualOleh),
                          _row('Dikerjakan oleh', item.dikerjakanOleh),
                          _row('Dasar Komisi', Formatters.formatRupiah(item.dasarKomisi)),
                          _row('Rate Komisi', '${item.rateKomisi.toInt()}%'),
                          const SizedBox(height: 4),
                          _row(
                            'Komisi Override',
                            Formatters.formatRupiah(item.komisiOverride, showSign: true),
                            isBold: true,
                            customColor: item.isMasuk ? AppColors.feedbackSuccess : AppColors.feedbackDanger,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBox({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String amount,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTypography.caption.copyWith(fontSize: 10, color: AppColors.inkMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: AppTypography.supportBold.copyWith(
              color: textColor,
              fontSize: 12,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false, Color? customColor}) {
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
                    color: customColor ?? AppColors.brand500,
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

