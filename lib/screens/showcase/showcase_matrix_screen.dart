import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../state/app_state.dart';
import '../../widgets/app_header.dart';
import '../../widgets/custom_bottom_sheets.dart';
import '../../widgets/custom_dialogs.dart';
import '../auth/login_screen.dart';
import '../jobs/job_detail_screen.dart';
import '../jobs/homecare_arrival_screen.dart';
import '../jobs/medical_assessment_screen.dart';
import '../reports/report_screen.dart';
import '../reports/pengerjaan_list_screen.dart';
import '../reports/komisi_override_screen.dart';
import '../reports/modals/filter_period_sheet.dart';
import '../reports/modals/redeem_detail_modal.dart';
import '../reports/modals/override_detail_modal.dart';
import '../profile/edit_profile_screen.dart';
import '../profile/change_password_screen.dart';
import '../profile/attendance_history_screen.dart';
import '../profile/branch_contact_screen.dart';

class ShowcaseMatrixScreen extends StatelessWidget {
  const ShowcaseMatrixScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: const AppHeader(
        title: 'Master Showcase Layar & State',
        subtitle: 'Navigasi langsung ke seluruh layar & kondisi error mockup',
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Banner intro
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppColors.brandCardGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.palette_outlined, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '100% Sesuai dengan 11 Mockup Board & Design System Momnjo API v4',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 1. Auth & Login States
          _buildCategoryHeader('01. Autentikasi & Akun (Auth & Account)'),
          _buildTile(
            context,
            title: 'Login Screen (Normal)',
            subtitle: 'Mockup 01 • Username, Password, Ilustrasi Ibu & Terapis',
            icon: Icons.login,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
          ),
          _buildTile(
            context,
            title: 'Modal Akun Tidak Aktif / Diblokir (HTTP 403)',
            subtitle: 'Mockup 03 Kesalahan • Pilih Gerai & Hubungi Admin WA',
            icon: Icons.block,
            iconColor: AppColors.feedbackWarning,
            onTap: () {
              CustomDialogs.showBlockedAccountDialog(
                context,
                branchList: const ['Momnjo Dharmawangsa', 'Momnjo Gading Serpong'],
                onContactAdmin: (_) {},
              );
            },
          ),
          _buildTile(
            context,
            title: 'Sheet Sesi Telah Berakhir (HTTP 401)',
            subtitle: 'Mockup 04 Kesalahan • Lock Icon & Masuk Kembali CTA',
            icon: Icons.lock_clock_outlined,
            iconColor: AppColors.brand500,
            onTap: () => CustomBottomSheets.showSessionExpiredSheet(context, onLoginAgain: () {}),
          ),
          _buildTile(
            context,
            title: 'Dialog Akun Dinonaktifkan (HTTP 403)',
            subtitle: 'Mockup 01 Validasi • Alert merah & Kembali ke Login',
            icon: Icons.person_off_outlined,
            iconColor: AppColors.feedbackDanger,
            onTap: () => CustomDialogs.showAccountDeactivatedDialog(context, onBackToLogin: () {}),
          ),

          // 2. Beranda & Absensi States
          _buildCategoryHeader('02. Beranda & Absensi (Home & Attendance)'),
          _buildTile(
            context,
            title: 'Sheet Konfirmasi Check In (On Duty)',
            subtitle: 'Mockup 02 Kolase (1) • Alamat GPS, Waktu, Lokasi Sesuai, Catatan',
            icon: Icons.how_to_reg_outlined,
            onTap: () {
              CustomBottomSheets.showCheckInSheet(
                context,
                branchName: 'Momnjo Dharmawangsa',
                address: 'Jl. Dharmawangsa IV No. 8, Jakarta Selatan',
                onConfirm: () {},
              );
            },
          ),
          _buildTile(
            context,
            title: 'Riwayat Absensi & Auto Check-Out Info',
            subtitle: 'Mockup 10 & Mockup 02 Revisi • Timeline & Lupa Offduty (Human Error)',
            icon: Icons.history_toggle_off,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen())),
          ),

          // 3. Job Workflow & Treatment States
          _buildCategoryHeader('03. Workflow Treatment & Timer (Job & Cycle)'),
          _buildTile(
            context,
            title: 'Detail Job - Menunggu (Homecare)',
            subtitle: 'Mockup 04 Kolase • Stepper 4 Tahap, Info Customer, Buka Map',
            icon: Icons.home_outlined,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JobDetailScreen(jobId: 45))),
          ),
          _buildTile(
            context,
            title: 'Tiba di Lokasi (Homecare Arrival Revised)',
            subtitle: 'Mockup 01 Revisi • Foto tidak wajib (API v4), Buka Map, Catatan',
            icon: Icons.pin_drop_outlined,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomecareArrivalScreen(jobId: 45))),
          ),
          _buildTile(
            context,
            title: 'Asesmen Rekam Medis (Medical Assessment Revised)',
            subtitle: 'Mockup 02 Revisi • 5 Bidang: TD (sistolik/diastolik), Suhu, Keluhan, Alergi, Catatan',
            icon: Icons.medical_services_outlined,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicalAssessmentScreen(jobId: 45))),
          ),
          _buildTile(
            context,
            title: 'Detail Job - Status Closed (Closed Transaksi Tetap Jalan)',
            subtitle: 'Mockup 07 Revisi • Banner Closed tapi Mulai Treatment tetap aktif!',
            icon: Icons.lock_open_outlined,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JobDetailScreen(jobId: 46))),
          ),
          _buildTile(
            context,
            title: 'Running Timer Treatment (Treatment Berjalan)',
            subtitle: 'Mockup 08 Revisi & 06 Kolase • Sisa Waktu 00:25:30, Arc Circular Progress',
            icon: Icons.timer_outlined,
            iconColor: AppColors.brand500,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JobDetailScreen(jobId: 47))),
          ),
          _buildTile(
            context,
            title: 'Sheet Selesaikan Treatment',
            subtitle: 'Mockup 06 Kolase (1) • Summary, Total Durasi, Catatan Internal, Konfirmasi',
            icon: Icons.task_alt,
            onTap: () {
              CustomBottomSheets.showFinishTreatmentSheet(
                context,
                customerName: 'Anisa Putri',
                treatmentName: 'Mom Massage & Scrub Spa',
                isOnsite: false,
                totalDurationSeconds: 5400,
                onConfirm: () {},
              );
            },
          ),
          _buildTile(
            context,
            title: 'Treatment Selesai (Completed Read-Only)',
            subtitle: 'Mockup 10 Revisi • Banner Hijau Selesai, Stepper Full, Kembali ke Job',
            icon: Icons.check_circle_outline,
            iconColor: AppColors.feedbackSuccess,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JobDetailScreen(jobId: 49))),
          ),
          _buildTile(
            context,
            title: 'Dialog Pekerjaan Tidak Ditemukan / Dialihkan (HTTP 404)',
            subtitle: 'Mockup 03 Merah Muda • Blocking Alert & Kembali ke Daftar Job',
            icon: Icons.folder_delete_outlined,
            iconColor: AppColors.feedbackDanger,
            onTap: () => CustomDialogs.showJobNotFoundDialog(context, onBackToJobs: () {}),
          ),
          _buildTile(
            context,
            title: 'Dialog Konflik Reassign Sedang Proses (HTTP 409)',
            subtitle: 'Dokumentasi API 409 Conflict • Terapis Sedang Memproses, Butuh Konfirmasi Force',
            icon: Icons.sync_problem,
            iconColor: AppColors.feedbackWarning,
            onTap: () => CustomDialogs.showReassignConflictDialog(context, currentTerapis: 'dewi.sartika', newTerapis: 'siti.nurhaliza'),
          ),

          // 4. Laporan & Komisi States
          _buildCategoryHeader('04. Laporan Komisi & Rincian (Reports & Commissions)'),
          _buildTile(
            context,
            title: 'Dashboard Komisi 5% (Laporan Saya)',
            subtitle: 'Mockup 06 Revisi & 07 Komisi • Total Rp475.000, Reguler, Redeem, Omzet, Override',
            icon: Icons.pie_chart_outline,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportScreen())),
          ),
          _buildTile(
            context,
            title: 'Sheet Filter Periode Laporan',
            subtitle: 'Mockup 01 Presentasi • Tanggal Mulai, Tanggal Akhir, Gerai, Terapkan & Reset',
            icon: Icons.filter_alt_outlined,
            onTap: () {
              FilterPeriodSheet.show(
                context,
                initialStart: DateTime(2026, 10, 1),
                initialEnd: DateTime(2026, 10, 31),
                onApply: (start, end, gerai) {},
                onReset: () {},
              );
            },
          ),
          _buildTile(
            context,
            title: 'Rincian Pengerjaan Treatment',
            subtitle: 'Mockup 08 Komisi • Reguler & Redeem Paket Cards, Total Qty & Nominal',
            icon: Icons.receipt_long_outlined,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PengerjaanListScreen())),
          ),
          _buildTile(
            context,
            title: 'Modal Detail Pengerjaan Redeem Paket',
            subtitle: 'Mockup 02 Presentasi • Rincian Paket Sehat Cantik 4 Sesi & Penjual Paket',
            icon: Icons.card_giftcard,
            onTap: () {
              final item = AppState.instance.pengerjaanList.firstWhere((i) => i.isRedeem);
              RedeemDetailModal.show(context, item);
            },
          ),
          _buildTile(
            context,
            title: 'Komisi Override Sharing Paket',
            subtitle: 'Mockup 09 Komisi • Override Masuk (+Rp12.500), Keluar (-Rp10.000), Total Bersih',
            icon: Icons.compare_arrows,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KomisiOverrideScreen())),
          ),
          _buildTile(
            context,
            title: 'Modal Detail Komisi Override',
            subtitle: 'Mockup 03 Presentasi • Perhitungan Dasar Komisi, Rate 5%, +Rp12.500',
            icon: Icons.calculate_outlined,
            onTap: () {
              final item = AppState.instance.overrideList.first;
              OverrideDetailModal.show(context, item);
            },
          ),

          // 5. Profil & Support States
          _buildCategoryHeader('05. Profil & Bantuan (Profile & Support)'),
          _buildTile(
            context,
            title: 'Edit Profil (Revised)',
            subtitle: 'Mockup 03 Revisi • Alamat editable, Username/Gerai protected, Validasi',
            icon: Icons.edit_note,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
          ),
          _buildTile(
            context,
            title: 'Sheet Profil Berhasil Diperbarui',
            subtitle: 'Mockup 04 Aplikasi • Sukses centang hijau & Kembali ke Profil',
            icon: Icons.check_circle_outline,
            iconColor: AppColors.feedbackSuccess,
            onTap: () => CustomBottomSheets.showEditProfileSuccessSheet(context),
          ),
          _buildTile(
            context,
            title: 'Ganti Password (Revised)',
            subtitle: 'Mockup 04 Revisi • Indikator minimal 6 karakter, Cocok password, Error 400',
            icon: Icons.password,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
          ),
          _buildTile(
            context,
            title: 'Kontak Gerai & WhatsApp API v4 (Revised)',
            subtitle: 'Mockup 05 Revisi • Tombol Hubungi Admin Gerai (WA) & Daftar Gerai Lainnya',
            icon: Icons.support_agent_outlined,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BranchContactScreen())),
          ),
          _buildTile(
            context,
            title: 'Sheet Kontak Gerai Belum Tersedia (HTTP 404)',
            subtitle: 'Mockup 04 Validasi • WhatsApp button nonaktif & Pesan Info Sistem',
            icon: Icons.store_mall_directory_outlined,
            iconColor: AppColors.feedbackDanger,
            onTap: () => CustomBottomSheets.showBranchUnavailableSheet(context, branchName: 'Momnjo Dharmawangsa'),
          ),
          _buildTile(
            context,
            title: 'Sheet Konfirmasi Keluar dari Akun (Logout)',
            subtitle: 'Mockup 06 Aplikasi • Tetap Masuk vs Ya, Keluar',
            icon: Icons.logout,
            iconColor: AppColors.feedbackDanger,
            onTap: () => CustomBottomSheets.showLogoutConfirmationSheet(context),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
      child: Text(
        title,
        style: AppTypography.supportBold.copyWith(
          color: AppColors.brand700,
          fontSize: 13,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.brand500).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor ?? AppColors.brand500, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTypography.supportBold.copyWith(fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: AppTypography.caption.copyWith(color: AppColors.inkMuted)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.inkLight),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
