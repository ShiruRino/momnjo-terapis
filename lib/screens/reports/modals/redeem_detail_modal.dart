import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/report_model.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/status_chip.dart';

class RedeemDetailModal extends StatelessWidget {
  final PengerjaanItem item;

  const RedeemDetailModal({super.key, required this.item});

  static void show(BuildContext context, PengerjaanItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => RedeemDetailModal(item: item),
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
                  const Text('Detail Pengerjaan', style: AppTypography.h2),
                  const SizedBox(height: 2),
                  Text('Transaksi ${item.noTransaksi}', style: AppTypography.caption),
                ],
              ),
              StatusChip.treatmentType(type: item.kategoriTipe),
            ],
          ),
          const SizedBox(height: 16),

          // Customer summary
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

          // Informasi Treatment
          Text('Informasi Treatment', style: AppTypography.captionBold.copyWith(color: AppColors.inkMuted)),
          const SizedBox(height: 8),
          _row('Nama Treatment', item.productName),
          _row('Jumlah', '${item.jumlah}'),
          _row('Nominal per item', Formatters.formatRupiah(item.nominalPerItem)),
          _row('Total Nominal', Formatters.formatRupiah(item.totalNominal), isBold: true),
          const SizedBox(height: 12),
          const Divider(),

          // Informasi Transaksi
          Text('Informasi Transaksi', style: AppTypography.captionBold.copyWith(color: AppColors.inkMuted)),
          const SizedBox(height: 8),
          _row('No. Transaksi', item.noTransaksi),
          _row('Tanggal Transaksi', Formatters.formatDateTime(item.tanggal)),
          _row('Kategori', item.kategoriTipe),
          const SizedBox(height: 12),

          // Informasi Paket if Redeem
          if (item.isRedeem && ((item.namaPaket != null && item.namaPaket!.isNotEmpty) || (item.dijualOleh != null && item.dijualOleh!.isNotEmpty))) ...[
            const Divider(),
            Text('Informasi Paket', style: AppTypography.captionBold.copyWith(color: AppColors.inkMuted)),
            const SizedBox(height: 8),
            if (item.namaPaket != null && item.namaPaket!.isNotEmpty)
              _row('Nama Paket', item.namaPaket!),
            if (item.idPaket != null && item.idPaket!.isNotEmpty)
              _row('ID Paket', item.idPaket!),
            if (item.dijualOleh != null && item.dijualOleh!.isNotEmpty)
              _row('Dijual oleh', item.dijualOleh!),
            const SizedBox(height: 12),
          ],

          const SizedBox(height: 16),
          AppButton(
            text: 'Tutup',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false}) {
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
                    color: AppColors.brand500,
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

