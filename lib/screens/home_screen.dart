import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/resident_provider.dart';
import '../utils/labels.dart';
import '../widgets/empty_state.dart';
import '../widgets/info_row.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/status_chip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _refresh() {
    final auth = context.read<AuthProvider>();
    return context.read<ResidentProvider>().loadHome(auth);
  }

  Color _installmentColor(int? status) {
    switch (status) {
      case 2:
        return AppTheme.success;
      case 4:
        return AppTheme.danger;
      case 3:
        return AppTheme.info;
      default:
        return AppTheme.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final resident = context.watch<ResidentProvider>();
    final profile = resident.profile;
    final overdue = resident.installments.where((i) => i.status == 4).length;
    final unpaid = resident.installments.where((i) => i.status == 1 || i.status == 3).length;
    final paid = resident.installments.where((i) => i.status == 2).length;
    final name = profile?.primaryResidentName ?? auth.user?.displayName ?? '';

    return Scaffold(
      body: RefreshIndicator(
        color: AppTheme.brandMid,
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              title: Column(
                children: [
                  Text(
                    auth.user?.complexName ?? AppConfig.appTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  Text(
                    'خدمات الساكن',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.muted,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'تحديث',
                  onPressed: resident.loading ? null : _refresh,
                  icon: resident.loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            if (resident.loading && profile == null)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (resident.error != null && profile == null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  message: resident.error!,
                  icon: Icons.error_outline_rounded,
                  actionLabel: 'إعادة المحاولة',
                  onAction: _refresh,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _WelcomeCard(
                      name: name,
                      unitNumber: profile?.unitNumber ?? auth.user?.unitNumber,
                      building: profile?.buildingName,
                      complexName: auth.user?.complexName ?? AppConfig.complexNameAr,
                      phone: profile?.phone ?? auth.user?.phone,
                    ),
                    if (resident.error != null) ...[
                      const SizedBox(height: 12),
                      _ErrorBanner(message: resident.error!),
                    ],
                    const SizedBox(height: 18),
                    const SectionHeader(title: 'نظرة سريعة'),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.28,
                      children: [
                        StatCard(
                          label: 'العقود',
                          value: '${resident.contracts.length}',
                          icon: Icons.description_outlined,
                        ),
                        StatCard(
                          label: 'أقساط مدفوعة',
                          value: '$paid',
                          icon: Icons.check_circle_outline_rounded,
                          color: AppTheme.success,
                        ),
                        StatCard(
                          label: 'غير مدفوعة',
                          value: '$unpaid',
                          icon: Icons.schedule_rounded,
                          color: AppTheme.warning,
                        ),
                        StatCard(
                          label: 'متأخرة',
                          value: '$overdue',
                          icon: Icons.warning_amber_rounded,
                          color: AppTheme.danger,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const SectionHeader(title: 'بيانات الوحدة'),
                    InfoCard(
                      children: [
                        InfoRow(
                          label: 'الوحدة',
                          value: profile?.unitNumber ?? '—',
                          icon: Icons.door_front_door_outlined,
                        ),
                        InfoRow(
                          label: 'المبنى',
                          value: profile?.buildingName ?? '—',
                          icon: Icons.apartment_outlined,
                        ),
                        InfoRow(
                          label: 'نوع الإشغال',
                          value: occupancyTypeLabel(profile?.occupancyType),
                          icon: Icons.badge_outlined,
                        ),
                        InfoRow(
                          label: 'الحالة',
                          value: residentStatusLabel(profile?.status),
                          icon: Icons.verified_outlined,
                        ),
                        InfoRow(
                          label: 'تاريخ الدخول',
                          value: formatDate(profile?.moveInDate),
                          icon: Icons.calendar_today_outlined,
                        ),
                        if (resident.unit != null) ...[
                          InfoRow(
                            label: 'المساحة',
                            value: '${resident.unit!.area} م²',
                            icon: Icons.square_foot_outlined,
                          ),
                          InfoRow(
                            label: 'الغرف',
                            value: '${resident.unit!.bedrooms}',
                            icon: Icons.bed_outlined,
                          ),
                          InfoRow(
                            label: 'الحمامات',
                            value: '${resident.unit!.bathrooms}',
                            icon: Icons.bathtub_outlined,
                            showDivider: false,
                          ),
                        ] else
                          const InfoRow(
                            label: 'تفاصيل إضافية',
                            value: '—',
                            showDivider: false,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const SectionHeader(title: 'أقرب الأقساط'),
                    if (resident.installments.isEmpty)
                      const Card(
                        child: EmptyState(message: 'لا توجد أقساط مرتبطة بحسابك'),
                      )
                    else
                      ...resident.installments.take(5).map((item) {
                        final color = _installmentColor(item.status);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(Icons.payments_outlined, color: color, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name?.isNotEmpty == true
                                              ? item.name!
                                              : formatMoney(item.amount),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'الاستحقاق: ${formatDate(item.dueDate)}',
                                          style: const TextStyle(
                                            color: AppTheme.muted,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          formatMoney(item.amount),
                                          style: TextStyle(
                                            color: color,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  StatusChip(
                                    label: installmentStatusLabel(item.status),
                                    color: color,
                                    compact: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({
    required this.name,
    required this.complexName,
    this.unitNumber,
    this.building,
    this.phone,
  });

  final String name;
  final String complexName;
  final String? unitNumber;
  final String? building;
  final String? phone;

  @override
  Widget build(BuildContext context) {
    final meta = [
      if ((unitNumber ?? '').isNotEmpty) 'وحدة $unitNumber',
      if ((building ?? '').isNotEmpty) building!,
      if ((phone ?? '').isNotEmpty) phone!,
    ].join(' · ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppTheme.brand, AppTheme.brandMid, AppTheme.brandLight],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.brandMid.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -10,
            top: -18,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name.isEmpty ? 'مرحباً بك' : 'مرحباً، $name',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'ساكن',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                complexName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
              ),
              if (meta.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  meta,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.danger.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppTheme.danger, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppTheme.danger,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
