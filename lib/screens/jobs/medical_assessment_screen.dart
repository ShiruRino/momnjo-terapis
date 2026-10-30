import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/job_model.dart';
import '../../data/api/api_exception.dart';
import '../../state/app_state.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/feedback_banner.dart';

class MedicalAssessmentScreen extends StatefulWidget {
  final int jobId;

  const MedicalAssessmentScreen({super.key, required this.jobId});

  @override
  State<MedicalAssessmentScreen> createState() => _MedicalAssessmentScreenState();
}

class _MedicalAssessmentScreenState extends State<MedicalAssessmentScreen> {
  final TextEditingController _sistolikController = TextEditingController();
  final TextEditingController _diastolikController = TextEditingController();
  final TextEditingController _suhuController = TextEditingController();
  final TextEditingController _keluhanController = TextEditingController();
  final TextEditingController _alergiController = TextEditingController();
  final TextEditingController _catatanKhususController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final job = AppState.instance.getJobById(widget.jobId);
    if (job?.medicalRecord != null) {
      final m = job!.medicalRecord!;
      _sistolikController.text = m.tekananDarahSistolik;
      _diastolikController.text = m.tekananDarahDiastolik;
      _suhuController.text = m.suhuTubuh;
      _keluhanController.text = m.keluhan;
      _alergiController.text = m.alergi;
      _catatanKhususController.text = m.catatanKhusus;
    }
  }

  void _handleSave() async {
    setState(() => _isLoading = true);

    final record = MedicalRecord(
      tekananDarahSistolik: _sistolikController.text.trim(),
      tekananDarahDiastolik: _diastolikController.text.trim(),
      suhuTubuh: _suhuController.text.trim(),
      keluhan: _keluhanController.text.trim(),
      alergi: _alergiController.text.trim(),
      catatanKhusus: _catatanKhususController.text.trim(),
    );

    try {
      await AppState.instance.saveMedicalAssessment(widget.jobId, record);
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rekam medis berhasil disimpan.'),
            backgroundColor: AppColors.feedbackSuccess,
          ),
        );
        Navigator.pop(context);
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.feedbackDanger,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan rekam medis: $e'),
            backgroundColor: AppColors.feedbackDanger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: const AppHeader(
        title: 'Asesmen Kesehatan',
        subtitle: 'Isi jika diperlukan (opsional)',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            const FeedbackBanner(
              message: 'Rekam medis bersifat opsional dan digunakan untuk mendukung kenyamanan & keamanan treatment.',
              type: FeedbackBannerType.info,
            ),
            const SizedBox(height: 12),

            // 1. Tekanan Darah (Sistolik / Diastolik mmHg)
            Text(
              'Tekanan Darah',
              style: AppTypography.supportMedium.copyWith(
                color: AppColors.inkStrong,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: AppTextField(
                    label: '',
                    hintText: '120',
                    controller: _sistolikController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '/',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ),
                Expanded(
                  child: AppTextField(
                    label: '',
                    hintText: '80',
                    controller: _diastolikController,
                    keyboardType: TextInputType.number,
                    suffixUnit: 'mmHg',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 2. Suhu Tubuh (°C)
            AppTextField(
              label: 'Suhu Tubuh',
              hintText: '36.5',
              controller: _suhuController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              suffixUnit: '°C',
            ),
            const SizedBox(height: 14),

            // 3. Keluhan
            AppTextField(
              label: 'Keluhan',
              hintText: 'Tuliskan keluhan yang disampaikan oleh customer...',
              controller: _keluhanController,
              maxLines: 3,
              maxLength: 200,
            ),
            const SizedBox(height: 14),

            // 4. Alergi
            AppTextField(
              label: 'Alergi',
              hintText: 'Contoh: alergi obat, alergi minyak, dll...',
              controller: _alergiController,
              maxLines: 3,
              maxLength: 200,
            ),
            const SizedBox(height: 14),

            // 5. Catatan Khusus
            AppTextField(
              label: 'Catatan Khusus',
              hintText: 'Tambahkan catatan khusus jika ada...',
              controller: _catatanKhususController,
              maxLines: 3,
              maxLength: 200,
            ),
            const SizedBox(height: 24),

            // CTAs
            AppButton(
              text: 'Simpan Asesmen',
              isLoading: _isLoading,
              onPressed: _handleSave,
            ),
            const SizedBox(height: 10),
            AppButton(
              text: 'Lewati untuk Sekarang',
              variant: AppButtonVariant.secondary,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

