import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../state/app_state.dart';
import '../../widgets/app_header.dart';
import '../../widgets/custom_bottom_sheets.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'attendance_history_screen.dart';
import 'branch_contact_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  void _handleLogout() async {
    final confirmed = await CustomBottomSheets.showLogoutConfirmationSheet(context);
    if (confirmed == true && mounted) {
      AppState.instance.logout();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AppState.instance.user;

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppHeader(
        title: 'Profil Saya',
        showBack: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.support_agent_outlined, color: AppColors.inkStrong),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BranchContactScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Top Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceBorder),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.brand100,
                    child: const Icon(Icons.person, color: AppColors.brand500, size: 44),
                  ),
                  const SizedBox(height: 12),
                  Text(user.namaLengkap, style: AppTypography.h1.copyWith(fontSize: 20)),
                  const SizedBox(height: 2),
                  Text(user.nickname, style: AppTypography.caption.copyWith(color: AppColors.inkMuted)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDEFF4),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      user.position,
                      style: AppTypography.captionBold.copyWith(color: AppColors.brand700),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.storefront_outlined, size: 16, color: AppColors.brand500),
                      const SizedBox(width: 6),
                      Text(
                        user.namaGerai,
                        style: AppTypography.captionBold.copyWith(color: AppColors.brand500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card: Informasi Akun
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.badge_outlined, color: AppColors.brand500, size: 18),
                      const SizedBox(width: 8),
                      Text('Informasi Akun', style: AppTypography.supportBold.copyWith(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _row('Username', user.username),
                  _row('Nama Lengkap', user.namaLengkap),
                  _row('Email', user.email),
                  _row('Nomor Telepon', user.noTelp),
                  _row('Posisi', user.position),
                  _row('Gerai', user.namaGerai),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Menu Items
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                children: [
                  _menuItem(
                    icon: Icons.edit_outlined,
                    label: 'Edit Profil',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 52),
                  _menuItem(
                    icon: Icons.lock_outline,
                    label: 'Ganti Password',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 52),
                  _menuItem(
                    icon: Icons.calendar_today_outlined,
                    label: 'Riwayat Absensi',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 52),
                  _menuItem(
                    icon: Icons.storefront_outlined,
                    label: 'Kontak Gerai',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BranchContactScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 52),
                  _menuItem(
                    icon: Icons.logout,
                    label: 'Keluar',
                    isDanger: true,
                    onTap: _handleLogout,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.inkMuted)),
          Text(value, style: AppTypography.supportMedium.copyWith(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isDanger ? AppColors.feedbackDanger : AppColors.brand500,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.supportBold.copyWith(
                    color: isDanger ? AppColors.feedbackDanger : AppColors.inkStrong,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDanger ? AppColors.feedbackDanger : AppColors.inkLight,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

