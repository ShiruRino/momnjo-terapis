import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../state/app_state.dart';
import '../../widgets/app_header.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/feedback_banner.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/skeleton_view.dart';
import 'modals/redeem_detail_modal.dart';

class PengerjaanListScreen extends StatefulWidget {
  const PengerjaanListScreen({super.key});

  @override
  State<PengerjaanListScreen> createState() => _PengerjaanListScreenState();
}

class _PengerjaanListScreenState extends State<PengerjaanListScreen> {
  bool _isLoading = false;
  String _selectedCategory = 'Semua'; // 'Semua', 'Reguler', 'Redeem'

  @override
  void initState() {
    super.initState();
    AppState.instance.addListener(_onStateChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
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

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await AppState.instance.fetchPengerjaan();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final items = state.pengerjaanList;
    final totalNominal = items.fold<double>(0.0, (sum, i) => sum + i.totalNominal);
    final totalQty = items.fold<int>(0, (sum, i) => sum + i.jumlah);
    final filteredItems = items.where((item) {
      if (_selectedCategory == 'Reguler') {
        return !item.isRedeem;
      } else if (_selectedCategory == 'Redeem') {
        return item.isRedeem;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: const AppHeader(
        title: 'Rincian Pengerjaan',
        subtitle: 'Daftar treatment & layanan',
      ),
      body: _isLoading || state.isLoadingReport
          ? const SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: ListTileSkeletonView(itemCount: 4),
            )
          : items.isEmpty
              ? EmptyStateView(
                  title: 'Belum Ada Data',
                  description: 'Tidak ada rincian pengerjaan untuk periode ini.',
                  buttonText: 'Segarkan',
                  onButtonPressed: _loadData,
                  icon: Icons.receipt_long_outlined,
                )
              : RefreshIndicator(
                  color: AppColors.brand500,
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                        const SizedBox(height: 14),

                        // Interactive Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilterChip(
                                label: Text('Semua (${items.length})', style: const TextStyle(fontSize: 12)),
                                selected: _selectedCategory == 'Semua',
                                selectedColor: AppColors.brand100,
                                checkmarkColor: AppColors.brand500,
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: AppColors.surfaceBorder),
                                onSelected: (_) => setState(() => _selectedCategory = 'Semua'),
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: Text(
                                  'Reguler (${items.where((i) => !i.isRedeem).length})',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                selected: _selectedCategory == 'Reguler',
                                selectedColor: const Color(0xFFFDEFF4),
                                checkmarkColor: AppColors.brand500,
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: AppColors.surfaceBorder),
                                onSelected: (_) => setState(() => _selectedCategory = 'Reguler'),
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: Text(
                                  'Redeem (${items.where((i) => i.isRedeem).length})',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                selected: _selectedCategory == 'Redeem',
                                selectedColor: const Color(0xFFFFF3E6),
                                checkmarkColor: const Color(0xFFC9600E),
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: AppColors.surfaceBorder),
                                onSelected: (_) => setState(() => _selectedCategory = 'Redeem'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Items List
                        if (filteredItems.isEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.surfaceBorder),
                            ),
                            child: Center(
                              child: Text(
                                'Tidak ada treatment kategori $_selectedCategory pada periode ini.',
                                style: AppTypography.caption.copyWith(color: AppColors.inkMuted),
                              ),
                            ),
                          ),
                        ] else ...[
                          ...filteredItems.map((item) {
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
                                      if (item.isRedeem && ((item.namaPaket != null && item.namaPaket!.isNotEmpty) || (item.dijualOleh != null && item.dijualOleh!.isNotEmpty))) ...[
                                        const SizedBox(height: 8),
                                        if (item.namaPaket != null && item.namaPaket!.isNotEmpty)
                                          _row('Nama Paket', item.namaPaket!),
                                        if (item.dijualOleh != null && item.dijualOleh!.isNotEmpty)
                                          _row('Dijual oleh', item.dijualOleh!),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                        ],
                        const SizedBox(height: 8),

                        // Callout info
                        if (items.any((i) => i.isRedeem)) ...[
                          const FeedbackBanner(
                            message: 'Nominal redeem mengikuti perhitungan paket.',
                            type: FeedbackBannerType.info,
                          ),
                          const SizedBox(height: 24),
                        ] else ...[
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
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

