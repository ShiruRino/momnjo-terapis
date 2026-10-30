import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/job_model.dart';
import '../../state/app_state.dart';
import '../../widgets/app_header.dart';
import '../../widgets/empty_state_view.dart';
import 'widgets/job_item_card.dart';
import 'job_detail_screen.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  String _selectedTab = 'Aktif'; // 'Aktif', 'Selesai', 'Semua'
  String? _selectedCategory; // null, 'onsite', 'homecare'

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

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final allJobs = state.jobs;

    final filteredJobs = allJobs.where((job) {
      if (_selectedTab == 'Aktif') {
        if (job.statusLayanan == StatusLayanan.selesai) return false;
      } else if (_selectedTab == 'Selesai') {
        if (job.statusLayanan != StatusLayanan.selesai) return false;
      }

      if (_selectedCategory == 'onsite' && !job.isOnsite) return false;
      if (_selectedCategory == 'homecare' && !job.isHomecare) return false;

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppHeader(
        title: 'Daftar Pekerjaan',
        showBack: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.inkStrong),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pencarian pekerjaan aktif')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Segmented Tab Filter (Aktif, Selesai, Semua)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 42,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: ['Aktif', 'Selesai', 'Semua'].map((tab) {
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
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Secondary Filters (Date & Layanan Dropdowns)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                // Date filter button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.inkMuted),
                      SizedBox(width: 6),
                      Text('Rabu, 24 Apr 2024', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.inkMuted),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Category chips
                FilterChip(
                  label: const Text('Onsite', style: TextStyle(fontSize: 12)),
                  selected: _selectedCategory == 'onsite',
                  selectedColor: AppColors.brand100,
                  checkmarkColor: AppColors.brand500,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.surfaceBorder),
                  onSelected: (val) {
                    setState(() {
                      _selectedCategory = val ? 'onsite' : null;
                    });
                  },
                ),
                const SizedBox(width: 8),

                FilterChip(
                  label: const Text('Homecare', style: TextStyle(fontSize: 12)),
                  selected: _selectedCategory == 'homecare',
                  selectedColor: AppColors.brand100,
                  checkmarkColor: AppColors.brand500,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.surfaceBorder),
                  onSelected: (val) {
                    setState(() {
                      _selectedCategory = val ? 'homecare' : null;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Job list or Empty state
          Expanded(
            child: filteredJobs.isEmpty
                ? const EmptyStateView(
                    title: 'Belum Ada Pekerjaan',
                    description: 'Tidak ada pekerjaan yang cocok dengan filter yang dipilih.',
                    icon: Icons.work_off_outlined,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredJobs.length,
                    itemBuilder: (context, index) {
                      final job = filteredJobs[index];
                      return JobItemCard(
                        job: job,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => JobDetailScreen(jobId: job.idJobStatus),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
