import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/resident_provider.dart';
import '../utils/labels.dart';
import '../widgets/empty_state.dart';
import '../widgets/info_row.dart';
import '../widgets/section_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final resident = context.watch<ResidentProvider>();
    final profile = resident.profile;
    final user = auth.user;
    final displayName = profile?.primaryResidentName ?? user?.displayName ?? '—';

    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
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
                              gradient: const LinearGradient(
                                colors: [AppTheme.brand, AppTheme.brandLight],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                _initials(displayName),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                            ),
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
                    const SizedBox(height: 18),
                    const SectionHeader(title: 'بيانات التواصل'),
                    InfoCard(
                      children: [
                        InfoRow(
                          label: 'الهاتف',
                          value: profile.phone ?? user?.phone ?? '—',
                          icon: Icons.phone_outlined,
                        ),
                        InfoRow(
                          label: 'البريد',
                          value: profile.email ?? user?.email ?? '—',
                          icon: Icons.mail_outline_rounded,
                        ),
                        InfoRow(
                          label: 'الهوية',
                          value: profile.nationalId ?? '—',
                          icon: Icons.badge_outlined,
                        ),
                        InfoRow(
                          label: 'الطوارئ',
                          value: profile.emergencyContactName ?? '—',
                          icon: Icons.contact_emergency_outlined,
                        ),
                        InfoRow(
                          label: 'هاتف الطوارئ',
                          value: profile.emergencyPhone ?? '—',
                          icon: Icons.phone_in_talk_outlined,
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
                      foregroundColor: AppTheme.danger,
                      side: BorderSide(color: AppTheme.danger.withValues(alpha: 0.35)),
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'س';
    String firstChar(String s) => s.isEmpty ? '' : String.fromCharCodes(s.runes.take(1));
    if (parts.length == 1) return firstChar(parts.first);
    return '${firstChar(parts.first)}${firstChar(parts.last)}';
  }
}
