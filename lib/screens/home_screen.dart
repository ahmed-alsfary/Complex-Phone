import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../core/l10n.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/resident_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/ads_carousel.dart';
import '../widgets/brand_logo.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';
import 'family_screen.dart';
import 'notifications_screen.dart';
import 'services_bills_screen.dart';
import 'vehicles_screen.dart';
import 'visitors_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final resident = context.watch<ResidentProvider>();
    final settings = context.watch<SettingsProvider>();
    final s = settings.s;
    final profile = resident.profile;
    final overdue = resident.installments.where((i) => i.status == 4).length;
    final unpaid = resident.installments.where((i) => i.status == 1 || i.status == 3).length;
    final paid = resident.installments.where((i) => i.status == 2).length;
    final name = profile?.displayName.isNotEmpty == true
        ? profile!.displayName
        : (auth.user?.displayName ?? '');

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
                    auth.user?.complexName ?? s.appTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  Text(
                    s.residentServices,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.muted,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              actions: [
                PopupMenuButton<AppLang>(
                  tooltip: s.language,
                  icon: const Icon(Icons.translate_rounded),
                  onSelected: settings.setLang,
                  itemBuilder: (_) => AppLang.values
                      .map(
                        (l) => PopupMenuItem(
                          value: l,
                          child: Text(
                            l.label,
                            style: TextStyle(
                              fontWeight: settings.lang == l ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                IconButton(
                  tooltip: settings.isDark ? s.lightMode : s.darkMode,
                  onPressed: settings.toggleTheme,
                  icon: Icon(settings.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                ),
                IconButton(
                  tooltip: s.notifications,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                    );
                  },
                  icon: const Icon(Icons.notifications_none_rounded),
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
                    const SizedBox(height: 14),
                    AdsCarousel(complexId: auth.user?.complexId ?? AppConfig.complexId),
                    const SizedBox(height: 14),
                    _QuickLink(
                      icon: Icons.bolt_rounded,
                      title: s.servicesBills,
                      subtitle: s.servicesBillsHint,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ServicesBillsScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _QuickLink(
                      icon: Icons.qr_code_2_rounded,
                      title: s.visitorPass,
                      subtitle: s.visitorPassHint,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const VisitorsScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _QuickLink(
                      icon: Icons.directions_car_rounded,
                      title: s.vehicles,
                      subtitle: s.addVehicle,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const VehiclesScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _QuickLink(
                      icon: Icons.groups_rounded,
                      title: s.family,
                      subtitle: s.updateInfo,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const FamilyScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    SectionHeader(title: s.overview),
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
                  const BrandLogo(
                    size: 52,
                    padding: 6,
                    borderRadius: 16,
                    backgroundColor: Color(0x33FFFFFF),
                  ),
                  const SizedBox(width: 12),
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

class _QuickLink extends StatelessWidget {
  const _QuickLink({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardTheme.color ?? Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.brandMid.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppTheme.brandMid),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left_rounded, color: AppTheme.muted),
            ],
          ),
        ),
      ),
    );
  }
}
