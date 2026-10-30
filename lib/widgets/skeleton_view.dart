import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(
              const Color(0xFFF1F3F7),
              const Color(0xFFE2E6EF),
              _controller.value,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

class ReportSkeletonView extends StatelessWidget {
  const ReportSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 120, height: 16),
                SizedBox(height: 12),
                SkeletonBox(width: 200, height: 36),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: SkeletonBox(width: double.infinity, height: 40)),
                    SizedBox(width: 12),
                    Expanded(child: SkeletonBox(width: double.infinity, height: 40)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Ringkasan Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 160, height: 20),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: SkeletonBox(width: double.infinity, height: 50)),
                    SizedBox(width: 10),
                    Expanded(child: SkeletonBox(width: double.infinity, height: 50)),
                    SizedBox(width: 10),
                    Expanded(child: SkeletonBox(width: double.infinity, height: 50)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // List Item Skeleton
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 140, height: 18),
                SizedBox(height: 12),
                SkeletonBox(width: double.infinity, height: 14),
                SizedBox(height: 8),
                SkeletonBox(width: 220, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BerandaSkeletonView extends StatelessWidget {
  const BerandaSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Notification Skeleton
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 180, height: 24),
                  SizedBox(height: 6),
                  SkeletonBox(width: 240, height: 14),
                ],
              ),
              SkeletonBox(width: 42, height: 42, borderRadius: 21),
            ],
          ),
          const SizedBox(height: 20),

          // Attendance Card Skeleton
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBox(width: 90, height: 26, borderRadius: 999),
                    SkeletonBox(width: 110, height: 18),
                  ],
                ),
                SizedBox(height: 16),
                SkeletonBox(width: double.infinity, height: 48, borderRadius: 14),
                SizedBox(height: 14),
                SkeletonBox(width: 180, height: 14),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stats Summary Row Skeleton
          const Row(
            children: [
              Expanded(
                child: SkeletonBox(width: double.infinity, height: 80, borderRadius: 16),
              ),
              SizedBox(width: 12),
              Expanded(
                child: SkeletonBox(width: double.infinity, height: 80, borderRadius: 16),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Active Job Section Header
          const SkeletonBox(width: 140, height: 18),
          const SizedBox(height: 12),

          // Job Card Skeleton
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBox(width: 70, height: 22, borderRadius: 6),
                    SkeletonBox(width: 90, height: 16),
                  ],
                ),
                SizedBox(height: 12),
                SkeletonBox(width: 200, height: 18),
                SizedBox(height: 8),
                SkeletonBox(width: double.infinity, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class JobListSkeletonView extends StatelessWidget {
  const JobListSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Filter Row Skeleton
          const Row(
            children: [
              SkeletonBox(width: 130, height: 34, borderRadius: 8),
              SizedBox(width: 8),
              SkeletonBox(width: 70, height: 34, borderRadius: 8),
              SizedBox(width: 8),
              SkeletonBox(width: 80, height: 34, borderRadius: 8),
            ],
          ),
          const SizedBox(height: 16),

          // 3x Job Card Skeleton
          for (int i = 0; i < 3; i++) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonBox(width: 80, height: 22, borderRadius: 6),
                      SkeletonBox(width: 100, height: 16),
                    ],
                  ),
                  SizedBox(height: 12),
                  SkeletonBox(width: 180, height: 18),
                  SizedBox(height: 8),
                  SkeletonBox(width: double.infinity, height: 14),
                  SizedBox(height: 8),
                  SkeletonBox(width: 140, height: 14),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class JobDetailSkeletonView extends StatelessWidget {
  const JobDetailSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBox(width: 80, height: 24, borderRadius: 6),
                    SkeletonBox(width: 90, height: 20),
                  ],
                ),
                SizedBox(height: 12),
                SkeletonBox(width: 220, height: 20),
                SizedBox(height: 8),
                SkeletonBox(width: 140, height: 14),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stepper Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SkeletonBox(width: 32, height: 32, borderRadius: 16),
                SkeletonBox(width: 40, height: 4),
                SkeletonBox(width: 32, height: 32, borderRadius: 16),
                SkeletonBox(width: 40, height: 4),
                SkeletonBox(width: 32, height: 32, borderRadius: 16),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Customer Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 120, height: 16),
                SizedBox(height: 10),
                SkeletonBox(width: 180, height: 18),
                SizedBox(height: 6),
                SkeletonBox(width: double.infinity, height: 14),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Button Skeleton
          const SkeletonBox(width: double.infinity, height: 50, borderRadius: 14),
        ],
      ),
    );
  }
}

class ListTileSkeletonView extends StatelessWidget {
  final int count;

  const ListTileSkeletonView({super.key, int? itemCount, int count = 4})
      : count = itemCount ?? count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          for (int i = 0; i < count; i++) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: const Row(
                children: [
                  SkeletonBox(width: 36, height: 36, borderRadius: 18),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 150, height: 16),
                        SizedBox(height: 6),
                        SkeletonBox(width: 200, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

