import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gezdirelim/core/app_colors.dart';
import 'package:gezdirelim/features/profile/presentation/profile_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  late TextEditingController _cityController;
  late TextEditingController _districtController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    _nameController = TextEditingController(text: profile.name);
    _emailController = TextEditingController(text: profile.email);
    _bioController = TextEditingController(text: profile.bio);
    _cityController = TextEditingController(text: profile.city);
    _districtController = TextEditingController(text: profile.district);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : () => _saveProfile(notifier),
            child: Text(
              'Kaydet',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _isSaving ? AppColors.textMuted : null,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profil fotoğrafı
            _buildPhotoSection(profile, notifier),
            const SizedBox(height: 40),

            // Form alanları
            _buildInputSection(
              'Ad Soyad',
              _nameController,
              LucideIcons.user,
              hintText: 'Adınız Soyadınız',
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
            ),
            const SizedBox(height: 20),
            _buildInputSection(
              'E-posta',
              _emailController,
              LucideIcons.mail,
              hintText: 'ornek@email.com',
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
            ),
            const SizedBox(height: 20),
            _buildInputSection(
              'Hakkında',
              _bioController,
              LucideIcons.alignLeft,
              maxLines: 3,
              hintText: 'Yolunu belirle, hikayeni anlat...',
            ),
            const SizedBox(height: 20),
            _buildInputSection(
              'Şehir',
              _cityController,
              LucideIcons.mapPin,
              hintText: 'İstanbul',
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.addressCity],
            ),
            const SizedBox(height: 20),
            _buildInputSection(
              'İlçe',
              _districtController,
              LucideIcons.mapPin,
              hintText: 'Kadıköy',
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 40),

            // Kaydet butonu
            ElevatedButton(
              onPressed: _isSaving ? null : () => _saveProfile(notifier),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isSaving ? AppColors.textMuted : AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Değişiklikleri Kaydet',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection(ProfileState profile, ProfileNotifier notifier) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 52,
              backgroundColor: AppColors.surfaceLight,
              backgroundImage: profile.photoPath.isNotEmpty
                  ? FileImage(File(profile.photoPath))
                  : const AssetImage('assets/images/min.png') as ImageProvider,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _pickImage(notifier),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: AppColors.background, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(LucideIcons.camera,
                    color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
    String? hintText,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<String>? autofillHints,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          autofillHints: autofillHints,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: maxLines == 1
                ? Icon(icon, color: AppColors.textMuted, size: 20)
                : null,
            hintText: hintText,
            hintStyle:
                const TextStyle(color: AppColors.textMuted, fontSize: 14),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(ProfileNotifier notifier) async {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
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
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.camera,
                      color: AppColors.primary),
                ),
                title: const Text('Kamera'),
                subtitle: const Text('Fotoğraf çek',
                    style: TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(context);
                  try {
                    final picked = await picker.pickImage(
                        source: ImageSource.camera, imageQuality: 80);
                    if (picked != null) {
                      await notifier.updatePhoto(picked.path);
                    }
                  } catch (e) {
                    messenger.showSnackBar(
                      const SnackBar(
                          content: Text('Fotoğraf çekilemedi')),
                    );
                  }
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.image,
                      color: AppColors.secondary),
                ),
                title: const Text('Galeri'),
                subtitle: const Text('Galeriden seç',
                    style: TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(context);
                  try {
                    final picked = await picker.pickImage(
                        source: ImageSource.gallery, imageQuality: 80);
                    if (picked != null) {
                      await notifier.updatePhoto(picked.path);
                    }
                  } catch (e) {
                    messenger.showSnackBar(
                      const SnackBar(
                          content: Text('Fotoğraf seçilemedi')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  // CRASH FIX: async + try-catch + mounted + _isSaving
  // ─────────────────────────────────────────────────
  Future<void> _saveProfile(ProfileNotifier notifier) async {
    // Double-click prevention
    if (_isSaving) return;

    // Validation
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(LucideIcons.alertCircle, color: AppColors.error, size: 18),
              SizedBox(width: 10),
              Text('Ad Soyad boş bırakılamaz'),
            ],
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await notifier.updateProfile(
        name: name,
        email: _emailController.text.trim(),
        bio: _bioController.text.trim(),
        city: _cityController.text.trim(),
        district: _districtController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(LucideIcons.check, color: AppColors.success, size: 18),
              SizedBox(width: 10),
              Text('Profil başarıyla güncellendi'),
            ],
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(LucideIcons.alertCircle, color: AppColors.error, size: 18),
              SizedBox(width: 10),
              Expanded(child: Text('Bir hata oluştu, lütfen tekrar deneyin')),
            ],
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
