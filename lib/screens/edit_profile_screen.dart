import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../providers/resident_provider.dart';
import '../services/resident_service.dart';
import '../utils/labels.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.profile});

  final ResidentProfile profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nicknameCtrl;
  late final TextEditingController _secondaryPhoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _loginCodeCtrl;
  DateTime? _birthDate;
  String? _photoUrl;
  bool _saving = false;
  bool _uploadingPhoto = false;
  bool _obscureCode = true;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nicknameCtrl = TextEditingController(text: p.nickname ?? '');
    _secondaryPhoneCtrl = TextEditingController(text: p.secondaryPhone ?? '');
    _emailCtrl = TextEditingController(text: p.email ?? '');
    _loginCodeCtrl = TextEditingController();
    _birthDate = p.birthDate;
    _photoUrl = p.profilePhotoUrl;
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _secondaryPhoneCtrl.dispose();
    _emailCtrl.dispose();
    _loginCodeCtrl.dispose();
    super.dispose();
  }

  String? _absolutePhoto(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    if (path.startsWith('http')) return path;
    return '${AppConfig.apiBaseUrl}$path';
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial = _birthDate ?? DateTime(now.year - 30);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1940),
      lastDate: now,
      locale: const Locale('ar'),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (file == null) return;

    setState(() => _uploadingPhoto = true);
    final residentService = context.read<ResidentService>();
    final residentProvider = context.read<ResidentProvider>();
    final auth = context.read<AuthProvider>();
    try {
      final url = await residentService.uploadProfilePhoto(
            residentId: widget.profile.id,
            filePath: file.path,
            fileName: file.name,
          );
      if (!mounted) return;
      setState(() => _photoUrl = url.isEmpty ? _photoUrl : url);
      await residentProvider.loadProfile(auth);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث الصورة الشخصية')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final updated = await context.read<ResidentService>().updateSelfProfile(
            residentId: widget.profile.id,
            birthDate: _birthDate,
            nickname: _nicknameCtrl.text.trim(),
            secondaryPhone: _secondaryPhoneCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            loginCode: _loginCodeCtrl.text,
          );
      if (!mounted) return;
      context.read<ResidentProvider>().applyProfile(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ التعديلات')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final photo = _absolutePhoto(_photoUrl);

    return Scaffold(
      appBar: AppBar(title: const Text('تعديل بياناتي')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppTheme.brandSoft,
                    backgroundImage: photo != null ? NetworkImage(photo) : null,
                    child: photo == null
                        ? const Icon(Icons.person_rounded, size: 42, color: AppTheme.brandMid)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Material(
                      color: AppTheme.brandMid,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _uploadingPhoto ? null : _pickPhoto,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: _uploadingPhoto
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'يمكن تعديل: الاسم المستعار، تاريخ الميلاد، الهاتف الثانوي، البريد، الصورة، ورمز الدخول.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.muted,
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nicknameCtrl,
              decoration: const InputDecoration(
                labelText: 'الاسم المستعار',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 12),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: _pickBirthDate,
                borderRadius: BorderRadius.circular(16),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'تاريخ الميلاد',
                    prefixIcon: Icon(Icons.cake_outlined),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    formatDate(_birthDate),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _secondaryPhoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'رقم هاتف ثانٍ',
                prefixIcon: Icon(Icons.phone_android_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
              validator: (v) {
                final t = (v ?? '').trim();
                if (t.isEmpty) return null;
                if (!t.contains('@')) return 'بريد غير صالح';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _loginCodeCtrl,
              obscureText: _obscureCode,
              decoration: InputDecoration(
                labelText: 'رمز الدخول (اختياري)',
                hintText: widget.profile.hasLoginCode
                    ? 'اتركه فارغاً للإبقاء على الرمز الحالي'
                    : 'عيّن رمزاً جديداً',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscureCode = !_obscureCode),
                  icon: Icon(_obscureCode ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                ),
              ),
              validator: (v) {
                final t = (v ?? '').trim();
                if (t.isEmpty) return null;
                if (t.length < 4 || t.length > 32) {
                  return 'الرمز بين 4 و 32 حرفاً';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}
