import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/resident_provider.dart';
import '../services/resident_service.dart';
import '../utils/labels.dart';
import '../widgets/empty_state.dart';
import '../widgets/info_row.dart';
import '../widgets/section_header.dart';
import 'edit_profile_screen.dart';
import 'family_screen.dart';
import 'vehicles_screen.dart';
import 'visitors_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String? _photoUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    if (path.startsWith('http')) return path;
    return '${AppConfig.apiBaseUrl}$path';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final resident = context.watch<ResidentProvider>();
    final profile = resident.profile;
    final user = auth.user;
    final displayName = profile?.displayName.isNotEmpty == true
        ? profile!.displayName
        : (profile?.primaryResidentName ?? user?.displayName ?? '—');
    final photo = _photoUrl(profile?.profilePhotoUrl);

    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابي'),
        actions: [
          if (profile != null)
            TextButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(profile: profile),
                  ),
                );
              },
              child: const Text('تعديل'),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.brandMid,
        onRefresh: () => context.read<ResidentProvider>().loadProfile(auth),
        child: profile == null && resident.loading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 140),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                children: [
                  if (profile == null)
                    EmptyState(message: resident.error ?? 'تعذر تحميل الملف الشخصي')
                  else ...[
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: photo == null
                                  ? const LinearGradient(
                                      colors: [AppTheme.brand, AppTheme.brandLight],
                                    )
                                  : null,
                              image: photo != null
                                  ? DecorationImage(
                                      image: NetworkImage(photo),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: photo == null
                                ? Center(
                                    child: Text(
                                      _initials(displayName),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 20,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?.complexName ?? 'مجمع الزهراء',
                                  style: const TextStyle(
                                    color: AppTheme.muted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if ((profile.unitNumber ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.brandSoft,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      'وحدة ${profile.unitNumber}',
                                      style: const TextStyle(
                                        color: AppTheme.brandMid,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const VisitorsScreen()),
                        );
                      },
                      icon: const Icon(Icons.qr_code_2_rounded),
                      label: const Text('تصاريح الزوار'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const VehiclesScreen()),
                        );
                      },
                      icon: const Icon(Icons.directions_car_outlined),
                      label: const Text('مركباتي'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const FamilyScreen()),
                        );
                      },
                      icon: const Icon(Icons.groups_outlined),
                      label: const Text('أفراد الأسرة والتابعين'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const SectionHeader(title: 'المعلومات الشخصية'),
                    InfoCard(
                      children: [
                        InfoRow(
                          label: 'الاسم المستعار',
                          value: (profile.nickname ?? '').isEmpty ? '—' : profile.nickname!,
                          icon: Icons.badge_outlined,
                        ),
                        InfoRow(
                          label: 'تاريخ الميلاد',
                          value: formatDate(profile.birthDate),
                          icon: Icons.cake_outlined,
                        ),
                        InfoRow(
                          label: 'الهاتف',
                          value: profile.phone ?? user?.phone ?? '—',
                          icon: Icons.phone_outlined,
                        ),
                        InfoRow(
                          label: 'هاتف ثانٍ',
                          value: (profile.secondaryPhone ?? '').isEmpty
                              ? '—'
                              : profile.secondaryPhone!,
                          icon: Icons.phone_android_outlined,
                        ),
                        InfoRow(
                          label: 'البريد',
                          value: profile.email ?? user?.email ?? '—',
                          icon: Icons.mail_outline_rounded,
                        ),
                        InfoRow(
                          label: 'رمز الدخول',
                          value: profile.hasLoginCode ? 'مفعّل' : 'غير مفعّل',
                          icon: Icons.lock_outline_rounded,
                          showDivider: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SectionHeader(
                      title: 'آخر الدفعات (${resident.payments.length})',
                    ),
                    if (resident.payments.isEmpty)
                      const Card(
                        child: EmptyState(message: 'لا توجد دفعات مسجّلة'),
                      )
                    else
                      ...resident.payments.take(10).map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppTheme.success.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Icons.receipt_long_outlined,
                                      color: AppTheme.success,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          formatMoney(p.amount),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${formatDate(p.paymentDate)} · ${paymentMethodLabel(p.paymentMethod)}',
                                          style: const TextStyle(
                                            color: AppTheme.muted,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if ((p.referenceNumber ?? '').isNotEmpty)
                                    Text(
                                      p.referenceNumber!,
                                      style: const TextStyle(
                                        color: AppTheme.brandMid,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('تسجيل الخروج'),
                          content: const Text('هل تريد تسجيل الخروج من حساب الساكن؟'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('إلغاء'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('خروج'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        context.read<ResidentProvider>().clear();
                        await auth.logout();
                      }
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('تسجيل الخروج'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.brandMid,
                      side: const BorderSide(color: AppTheme.border),
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => _confirmDeleteAccount(context, auth, profile!.id),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.danger,
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: const Text('حذف الحساب'),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    AuthProvider auth,
    String residentId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد حذف الحساب'),
        content: const Text('هل أنت متأكد من حذف الحساب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف الحساب'),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await context.read<ResidentService>().selfDelete(residentId);
      if (!context.mounted) return;
      Navigator.of(context).pop(); // loading
      context.read<ResidentProvider>().clear();
      await auth.logout();
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'س';
    String firstChar(String s) => s.isEmpty ? '' : String.fromCharCodes(s.runes.take(1));
    if (parts.length == 1) return firstChar(parts.first);
    return '${firstChar(parts.first)}${firstChar(parts.last)}';
  }
}
