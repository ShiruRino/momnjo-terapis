import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../widgets/app_button.dart';

class FilterPeriodSheet extends StatefulWidget {
  final DateTime initialStart;
  final DateTime initialEnd;
  final String? initialGerai;
  final Function(DateTime start, DateTime end, String? gerai) onApply;
  final VoidCallback onReset;

  const FilterPeriodSheet({
    super.key,
    required this.initialStart,
    required this.initialEnd,
    this.initialGerai,
    required this.onApply,
    required this.onReset,
  });

  static Future<void> show(
    BuildContext context, {
    required DateTime initialStart,
    required DateTime initialEnd,
    String? initialGerai,
    required Function(DateTime start, DateTime end, String? gerai) onApply,
    required VoidCallback onReset,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => FilterPeriodSheet(
        initialStart: initialStart,
        initialEnd: initialEnd,
        initialGerai: initialGerai,
        onApply: onApply,
        onReset: onReset,
      ),
    );
  }

  @override
  State<FilterPeriodSheet> createState() => _FilterPeriodSheetState();
}

class _FilterPeriodSheetState extends State<FilterPeriodSheet> {
  late DateTime _startDate;
  late DateTime _endDate;
  String _selectedGerai = 'Semua Gerai';

  final List<String> _geraiOptions = const [
    'Semua Gerai',
    'Momnjo Dharmawangsa',
    'Momnjo Gading Serpong',
    'Momnjo Green Lake',
    'Momnjo Kelapa Gading',
  ];

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStart;
    _endDate = widget.initialEnd;
    _selectedGerai = widget.initialGerai ?? 'Semua Gerai';
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_startDate.isAfter(_endDate)) _endDate = _startDate;
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) _startDate = _endDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
              const Text('Filter Laporan', style: AppTypography.h2),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.inkMuted),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tanggal Mulai
          Text('Tanggal Mulai', style: AppTypography.captionBold.copyWith(color: AppColors.inkMuted)),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => _selectDate(true),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.brand500),
                  const SizedBox(width: 10),
                  Expanded(child: Text(Formatters.formatDateFull(_startDate), style: AppTypography.supportMedium)),
                  const Icon(Icons.keyboard_arrow_down, color: AppColors.inkMuted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Tanggal Akhir
          Text('Tanggal Akhir', style: AppTypography.captionBold.copyWith(color: AppColors.inkMuted)),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => _selectDate(false),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.brand500),
                  const SizedBox(width: 10),
                  Expanded(child: Text(Formatters.formatDateFull(_endDate), style: AppTypography.supportMedium)),
                  const Icon(Icons.keyboard_arrow_down, color: AppColors.inkMuted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Pilih Gerai (Opsional)
          Text('Pilih Gerai (Opsional)', style: AppTypography.captionBold.copyWith(color: AppColors.inkMuted)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedGerai,
                isExpanded: true,
                items: _geraiOptions.map((g) {
                  return DropdownMenuItem<String>(
                    value: g,
                    child: Row(
                      children: [
                        const Icon(Icons.storefront_outlined, size: 18, color: AppColors.brand500),
                        const SizedBox(width: 10),
                        Text(g, style: AppTypography.supportMedium),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedGerai = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          AppButton(
            text: 'Terapkan Filter',
            onPressed: () {
              widget.onApply(_startDate, _endDate, _selectedGerai);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 10),
          AppButton(
            text: 'Reset',
            variant: AppButtonVariant.secondary,
            onPressed: () {
              widget.onReset();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

