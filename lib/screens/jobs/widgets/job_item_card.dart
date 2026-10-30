import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/job_model.dart';
import '../../../widgets/status_chip.dart';

class JobItemCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback onTap;

  const JobItemCard({
    super.key,
    required this.job,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final customerName = job.customer.fullname.isNotEmpty
        ? job.customer.fullname
        : (job.isOnsite ? 'Pelanggan Onsite' : 'Pelanggan Homecare');
    final scheduleTime = job.waktuJadwal != null
        ? '${job.waktuJadwal!.hour.toString().padLeft(2, '0')}.${job.waktuJadwal!.minute.toString().padLeft(2, '0')} WIB'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.brand100,
                  child: const Icon(Icons.person, color: AppColors.brand500, size: 24),
                ),
                const SizedBox(width: 12),
                // Main Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              customerName,
                              style: AppTypography.supportBold.copyWith(fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          StatusChip.fromJobStatus(job.statusLayanan),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              job.item.productName.isNotEmpty ? job.item.productName : '-',
                              style: AppTypography.caption.copyWith(color: AppColors.inkMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (scheduleTime.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              scheduleTime,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.inkMuted,
                                fontFeatures: [const FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            job.isHomecare ? Icons.home_outlined : Icons.storefront_outlined,
                            size: 14,
                            color: AppColors.inkLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            job.isHomecare ? 'Homecare' : 'Onsite',
                            style: AppTypography.caption.copyWith(color: AppColors.inkMuted),
                          ),
                          if (job.durasiStandar > 0) ...[
                            const SizedBox(width: 10),
                            const Icon(Icons.access_time, size: 13, color: AppColors.inkLight),
                            const SizedBox(width: 4),
                            Text(
                              '${job.durasiStandar} menit',
                              style: AppTypography.caption.copyWith(color: AppColors.inkMuted),
                            ),
                          ],
                          if (job.isOnsite && job.customer.ruangan != null && job.customer.ruangan!.isNotEmpty) ...[
                            const SizedBox(width: 10),
                            const Icon(Icons.meeting_room_outlined, size: 13, color: AppColors.inkLight),
                            const SizedBox(width: 4),
                            Text(
                              job.customer.ruangan!,
                              style: AppTypography.caption.copyWith(color: AppColors.inkMuted),
                            ),
                          ],
                          const Spacer(),
                          Text(
                            job.idTransaksi,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.inkLight,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, color: AppColors.inkLight, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

