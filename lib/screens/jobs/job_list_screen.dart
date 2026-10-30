import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/job_model.dart';
import '../../state/app_state.dart';
import '../../widgets/app_header.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/skeleton_view.dart';
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
  DateTime? _selectedDate = DateTime.now(); // Default hari ini!

  @override
  void initState() {
    super.initState();
    _selectedTab = AppState.instance.jobFilterTab;
    AppState.instance.addListener(_onStateChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppState.instance.fetchJobs();
    });
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) {
      if (_selectedTab != AppState.instance.jobFilterTab) {
        _selectedTab = AppState.instance.jobFilterTab;
      }
      setState(() {});
    }
  }

  String _formatDateFilter(DateTime? date) {
    if (date == null) return 'Semua Tanggal';
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final formatted = Formatters.formatDate(date);
    return isToday ? 'Hari Ini ($formatted)' : formatted;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Pilih Tanggal Pekerjaan',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.brand500,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.inkStrong,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
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

      // Filter tanggal jika dipilih
      if (_selectedDate != null && job.waktuJadwal != null) {
        final jobDate = job.waktuJadwal!;
        if (jobDate.year != _selectedDate!.year ||
            jobDate.month != _selectedDate!.month ||
            jobDate.day != _selectedDate!.day) {
          return false;
        }
      }

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
                      onTap: () {
                        setState(() => _selectedTab = tab);
                        state.setJobFilterTab(tab);
                        state.fetchJobs();
                      },
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
                // Date filter button (Interactive with DatePicker)
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedDate != null ? AppColors.brand500 : AppColors.surfaceBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: _selectedDate != null ? AppColors.brand500 : AppColors.inkMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatDateFilter(_selectedDate),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _selectedDate != null ? AppColors.brand500 : AppColors.inkStrong,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.inkMuted),
                      ],
                    ),
                  ),
                ),
                if (_selectedDate != null) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16, color: AppColors.inkMuted),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Tampilkan Semua Tanggal',
                    onPressed: () => setState(() => _selectedDate = null),
                  ),
                ],
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
                    final cat = val ? 'onsite' : null;
                    setState(() => _selectedCategory = cat);
                    state.setCategoryFilter(cat);
                    state.fetchJobs();
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
                    final cat = val ? 'homecare' : null;
                    setState(() => _selectedCategory = cat);
                    state.setCategoryFilter(cat);
                    state.fetchJobs();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Job list or Skeleton or Empty state with Pull-to-Refresh
          Expanded(
            child: RefreshIndicator(
              color: AppColors.brand500,
              onRefresh: () => state.fetchJobs(),
              child: state.isLoadingJobs && allJobs.isEmpty
                  ? const SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: JobListSkeletonView(),
                    )
                  : filteredJobs.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 60),
                            EmptyStateView(
                              title: 'Belum Ada Pekerjaan',
                              description: 'Tidak ada pekerjaan yang cocok dengan filter yang dipilih.',
                              icon: Icons.work_off_outlined,
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
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
          ),
        ],
      ),
    );
  }
}
