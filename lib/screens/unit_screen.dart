import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/resident_provider.dart';
import '../utils/labels.dart';
import '../widgets/empty_state.dart';
import '../widgets/info_row.dart';
import '../widgets/section_header.dart';

class UnitScreen extends StatelessWidget {
  const UnitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final resident = context.watch<ResidentProvider>();
    final profile = resident.profile;
    final unit = resident.unit;

    return Scaffold(
      appBar: AppBar(title: const Text('وحدتي')),
      body: RefreshIndicator(
        color: AppTheme.brandMid,
        onRefresh: () => context.read<ResidentProvider>().loadUnit(context.read<AuthProvider>()),
        child: resident.loading && profile == null
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 140),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : profile == null
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      EmptyState(message: resident.error ?? 'لا توجد بيانات وحدة'),
                    ],
                  )
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: const LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [AppTheme.brand, AppTheme.brandLight],
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.home_work_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'وحدة ${profile.unitNumber ?? '—'}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    profile.buildingName ?? '—',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.85),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      residentStatusLabel(profile.status),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const SectionHeader(title: 'معلومات السكن'),
                      InfoCard(
                        children: [
                          InfoRow(
                            label: 'المبنى',
                            value: profile.buildingName ?? '—',
                            icon: Icons.apartment_outlined,
                          ),
                          InfoRow(
                            label: 'نوع الإشغال',
                            value: occupancyTypeLabel(profile.occupancyType),
                            icon: Icons.badge_outlined,
                          ),
                          InfoRow(
                            label: 'حالة السكن',
                            value: residentStatusLabel(profile.status),
                            icon: Icons.verified_outlined,
                          ),
                          InfoRow(
                            label: 'تاريخ الدخول',
                            value: formatDate(profile.moveInDate),
                            icon: Icons.calendar_today_outlined,
                          ),
                          InfoRow(
                            label: 'تاريخ الإشغال',
                            value: formatDate(profile.occupancyDate),
                            icon: Icons.event_available_outlined,
                          ),
                          InfoRow(
                            label: 'عدد الساكنين',
                            value: '${profile.totalOccupants}',
                            icon: Icons.groups_outlined,
                          ),
                          InfoRow(
                            label: 'تسليم المفاتيح',
                            value: profile.hasHandover ? 'تم' : 'لا',
                            icon: Icons.vpn_key_outlined,
                            showDivider: false,
                          ),
                        ],
                      ),
                      if (unit != null) ...[
                        const SizedBox(height: 8),
                        const SectionHeader(title: 'مواصفات الوحدة'),
                        InfoCard(
                          children: [
                            InfoRow(
                              label: 'النوع',
                              value: unitTypeLabel(unit.unitType),
                              icon: Icons.category_outlined,
                            ),
                            InfoRow(
                              label: 'المساحة',
                              value: '${unit.area} م²',
                              icon: Icons.square_foot_outlined,
                            ),
                            InfoRow(
                              label: 'الطابق',
                              value: '${unit.floorLevel}',
                              icon: Icons.layers_outlined,
                            ),
                            InfoRow(
                              label: 'غرف النوم',
                              value: '${unit.bedrooms}',
                              icon: Icons.bed_outlined,
                            ),
                            InfoRow(
                              label: 'الحمامات',
                              value: '${unit.bathrooms}',
                              icon: Icons.bathtub_outlined,
                            ),
                            InfoRow(
                              label: 'حالة الوحدة',
                              value: unitStatusLabel(unit.status),
                              icon: Icons.info_outline_rounded,
                              showDivider: false,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
      ),
    );
  }
}
