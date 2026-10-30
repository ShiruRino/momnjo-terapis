import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/api/api_exception.dart';
import '../../state/app_state.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/status_chip.dart';

class HomecareArrivalScreen extends StatefulWidget {
  final int jobId;

  const HomecareArrivalScreen({super.key, required this.jobId});

  @override
  State<HomecareArrivalScreen> createState() => _HomecareArrivalScreenState();
}

class _HomecareArrivalScreenState extends State<HomecareArrivalScreen> {
  final TextEditingController _notesController = TextEditingController();
  String? _fotoArrived;
  Uint8List? _imageBytes;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fotoArrived = null;
  }

  Future<void> _pickOrTakePhoto() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Ambil Bukti Kedatangan', style: AppTypography.h2),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.brand100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: AppColors.brand500),
                  ),
                  title: const Text('Buka Kamera Terapis', style: AppTypography.supportBold),
                  subtitle: const Text('Ambil foto langsung depan pintu/rumah pelanggan', style: AppTypography.caption),
                  onTap: () {
                    Navigator.pop(ctx);
                    _captureImage(ImageSource.camera);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0F2F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library_outlined, color: AppColors.inkStrong),
                  ),
                  title: const Text('Pilih dari Galeri', style: AppTypography.supportBold),
                  subtitle: const Text('Gunakan foto dari penyimpanan perangkat', style: AppTypography.caption),
                  onTap: () {
                    Navigator.pop(ctx);
                    _captureImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _captureImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 80,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final base64Str = base64Encode(bytes);
        setState(() {
          _imageBytes = bytes;
          _fotoArrived = 'data:image/jpeg;base64,$base64Str';
          _errorMessage = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto bukti kedatangan berhasil diambil.'),
              backgroundColor: AppColors.feedbackSuccess,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal mengakses kamera: $e';
      });
    }
  }

  void _handleConfirmArrival() async {
    setState(() {
      _errorMessage = null;
    });

    // Validasi HTTP 422 sesuai update API v4: foto_arrived WAJIB diunggah!
    if (_fotoArrived == null || _fotoArrived!.isEmpty) {
      setState(() {
        _errorMessage = 'Foto bukti tiba di lokasi (foto_arrived) wajib diunggah.';
      });
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AppState.instance.markArrived(
        widget.jobId,
        fotoArrived: _fotoArrived,
        notes: _notesController.text.trim(),
      );
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil memperbarui status: Tiba di Lokasi.'),
            backgroundColor: AppColors.feedbackSuccess,
          ),
        );
        Navigator.pop(context);
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = AppState.instance.getJobById(widget.jobId);
    if (job == null) {
      return Scaffold(
        appBar: const AppHeader(title: 'Tiba di Lokasi'),
        body: const Center(child: Text('Job tidak ditemukan')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: const AppHeader(
        title: 'Tiba di Lokasi',
        subtitle: 'Ambil foto sebagai bukti kedatangan di lokasi',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Brief Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.brand100,
                    child: const Icon(Icons.home_outlined, color: AppColors.brand500, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatusChip.category(job.kategoriLayanan),
                        const SizedBox(height: 4),
                        Text(job.item.productName, style: AppTypography.supportBold),
                        const SizedBox(height: 2),
                        Text(job.idTransaksi, style: AppTypography.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Alamat Customer Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: AppColors.brand500, size: 18),
                          const SizedBox(width: 6),
                          Text('Alamat Customer', style: AppTypography.supportBold.copyWith(fontSize: 14)),
                        ],
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.brand500,
                          side: const BorderSide(color: AppColors.brand500),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Membuka Google Maps...')),
                          );
                        },
                        icon: const Icon(Icons.map_outlined, size: 14),
                        label: const Text('Buka Map', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job.customer.alamatDomisili,
                    style: AppTypography.support.copyWith(fontSize: 13),
                  ),
                  if (job.customer.catatanAlamat != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Catatan: ${job.customer.catatanAlamat}',
                      style: AppTypography.caption.copyWith(color: AppColors.inkMuted),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Foto Bukti Kedatangan (Wajib diunggah per update API v4)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _errorMessage != null ? AppColors.feedbackDanger : AppColors.surfaceBorder,
                  width: _errorMessage != null ? 1.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.camera_alt_outlined, size: 18, color: AppColors.brand500),
                          const SizedBox(width: 8),
                          Text(
                            'Foto Bukti Kedatangan',
                            style: AppTypography.supportBold.copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _fotoArrived != null
                              ? AppColors.feedbackSuccessBg
                              : const Color(0xFFFDEBEC),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _fotoArrived != null ? 'Terlampir' : 'Wajib (Required)',
                          style: AppTypography.captionBold.copyWith(
                            color: _fotoArrived != null
                                ? AppColors.feedbackSuccess
                                : AppColors.feedbackDanger,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_fotoArrived != null) ...[
                    // Preview Photo
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.feedbackSuccess, width: 1.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (_imageBytes != null)
                              Image.memory(
                                _imageBytes!,
                                fit: BoxFit.cover,
                              )
                            else
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE8F6F0),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check, color: AppColors.feedbackSuccess, size: 28),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text('Foto Lokasi Kedatangan Siap Diunggah', style: AppTypography.supportBold),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Foto siap dikirim sebagai bukti',
                                    style: AppTypography.caption.copyWith(color: AppColors.inkMuted, fontSize: 11),
                                  ),
                                ],
                              ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.feedbackSuccess,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle, size: 14, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text('Foto Terlampir', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                                  foregroundColor: AppColors.inkStrong,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: _pickOrTakePhoto,
                                icon: const Icon(Icons.flip_camera_ios_outlined, size: 14),
                                label: const Text('Ambil Ulang', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Photo not taken yet placeholder
                    InkWell(
                      onTap: _pickOrTakePhoto,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 110,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.brand100, width: 1.5),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: AppColors.brand100,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add_a_photo_outlined, color: AppColors.brand500, size: 20),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ambil Foto atau Pilih dari Galeri',
                              style: AppTypography.supportBold.copyWith(color: AppColors.brand500, fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Wajib sebagai bukti tiba di lokasi pelanggan',
                              style: AppTypography.caption.copyWith(color: AppColors.inkMuted, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.error_outline, size: 14, color: AppColors.feedbackDanger),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTypography.caption.copyWith(color: AppColors.feedbackDanger),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Catatan Field
            AppTextField(
              label: 'Catatan (Opsional)',
              hintText: 'Tambahkan catatan jika diperlukan...',
              controller: _notesController,
              maxLines: 3,
              maxLength: 200,
            ),
            const SizedBox(height: 24),

            // Primary CTA
            AppButton(
              text: 'Kirim Bukti Kedatangan',
              isLoading: _isLoading,
              onPressed: _handleConfirmArrival,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
