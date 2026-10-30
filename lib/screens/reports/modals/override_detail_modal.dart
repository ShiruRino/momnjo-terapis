import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/report_model.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/status_chip.dart';

class OverrideDetailModal extends StatelessWidget {
  final OverrideItem item;

  const OverrideDetailModal({super.key, required this.item});

  static void show(BuildContext context, OverrideItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => OverrideDetailModal(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Detail Komisi Override', style: AppTypography.h2),
                  const SizedBox(height: 2),
                  Text('Transaksi ${item.noTransaksi}', style: AppTypography.caption),
                ],
              ),
              StatusChip.override(isMasuk: item.isMasuk),
            ],
          ),
          const SizedBox(height: 16),

          // Customer
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.brand100,
                child: const Icon(Icons.person, color: AppColors.brand500),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.customerName, style: AppTypography.supportBold),
                  Text(item.customerPhone, style: AppTypography.caption),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),

          // Informasi Transaksi
          Text('Informasi Transaksi', style: AppTypography.captionBold.copyWith(color: AppColors.inkMuted)),
          const SizedBox(height: 8),
          _row('Tanggal Transaksi', Formatters.formatDateTime(item.tanggal)),
          _row('No. Transaksi', item.noTransaksi),
          const SizedBox(height: 12),
          const Divider(),

          // Informasi Treatment
          Text('Informasi Treatment', style: AppTypography.captionBold.copyWith(color: AppColors.inkMuted)),
          const SizedBox(height: 8),
          _row('Nama Treatment', item.productName),
          _row('Nama Paket', item.namaPaket),
          _row('ID Paket', item.idPaket),
          const SizedBox(height: 12),
          const Divider(),

          // Informasi Terapis
          Text('Informasi Terapis', style: AppTypography.captionBold.copyWith(color: AppColors.inkMuted)),
          const SizedBox(height: 8),
          _row('Dijual oleh (Terapis Paket)', item.dijualOleh),
          _row('Dikerjakan oleh', item.dikerjakanOleh),
          const SizedBox(height: 12),
          const Divider(),

          // Perhitungan Override
          Text('Perhitungan Override', style: AppTypography.captionBold.copyWith(color: AppColors.inkMuted)),
          const SizedBox(height: 8),
          _row('Dasar Komisi', Formatters.formatRupiah(item.dasarKomisi)),
          _row('Rate Komisi', '${item.rateKomisi.toInt()}%'),
          _row(
            'Komisi Override',
            Formatters.formatRupiah(item.komisiOverride, showSign: true),
            isBold: true,
            customColor: item.isMasuk ? AppColors.feedbackSuccess : AppColors.feedbackDanger,
          ),
          const SizedBox(height: 20),

          AppButton(
            text: 'Tutup',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false, Color? customColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.support.copyWith(fontSize: 13)),
          Text(
            value,
            style: isBold
                ? AppTypography.supportBold.copyWith(
                    color: customColor ?? AppColors.brand500,
                    fontSize: 14,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  )
                : AppTypography.supportMedium.copyWith(
                    fontSize: 13,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
          ),
        ],
      ),
    );
  }
}

